import 'dart:async';
import 'package:flutter/foundation.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/rbac/rbac.dart';

/// Preloads critical Firestore data into the offline cache so the app
/// is fully functional when the network drops.
///
/// Without warming, the cache is populated lazily — only data the user
/// has actually viewed gets cached. This means a fresh login followed
/// by going offline would show empty pages.
///
/// With warming, the app proactively fetches and caches:
/// - All pharmacies owned by the user
/// - All product master records
/// - All stock balances
/// - All stock counts
/// - All low stock alerts
/// - All goods received receipts
/// - All stock movements
///
/// The warmer runs:
/// - Automatically on login (triggered from [main.dart] when the auth
///   stream fires a non-null user)
/// - Manually via a "Warm Offline Cache" button in the settings page
///
/// The warm is idempotent — running it again only refreshes the cache
/// and doesn't duplicate data.
class CacheWarmerService extends ChangeNotifier {
  CacheWarmerService._internal();
  static final CacheWarmerService _instance = CacheWarmerService._internal();
  factory CacheWarmerService() => _instance;

  bool _isWarming = false;
  double _progress = 0.0;
  String _currentStep = '';
  int _recordsCached = 0;
  String? _lastError;
  DateTime? _lastWarmedAt;

  bool get isWarming => _isWarming;
  double get progress => _progress;
  String get currentStep => _currentStep;
  int get recordsCached => _recordsCached;
  String? get lastError => _lastError;
  DateTime? get lastWarmedAt => _lastWarmedAt;

  /// Warm the cache by fetching all critical collections.
  ///
  /// Returns the total number of documents cached.
  /// Reports progress via [notifyListeners] so the UI can show a
  /// progress bar.
  ///
  /// All 16 collections are fired in parallel via `Future.wait` —
  /// previously each step awaited sequentially with a 50 ms sleep
  /// per step (≥800 ms of pure sleep + 16× Firestore RTT back-to-
  /// back). Now the warm completes in roughly one network wave.
  /// Per-future try/catch preserves the "partial warm > no warm"
  /// guarantee.
  Future<int> warmCache() async {
    if (_isWarming) return _recordsCached;

    final userDoc = currentUserDocument;
    if (userDoc == null) {
      _lastError = 'No user signed in';
      notifyListeners();
      return 0;
    }

    final isPulse = AppRole.isPulseAccountType(userDoc.accountType);

    // Resolve the owner reference (pharmacies live under the owner). Pulse
    // users intentionally use collection-group queries so their network views
    // are ready offline too.
    final ownerRef =
        AccessControl.parentRefFromDoc(userDoc, currentUserReference);
    if (!isPulse && ownerRef == null) {
      _lastError = 'Unable to identify your owner pharmacy';
      notifyListeners();
      return 0;
    }
    final workspaceParent = isPulse ? null : ownerRef;

    _isWarming = true;
    _progress = 0.0;
    _recordsCached = 0;
    _lastError = null;
    _currentStep = 'Warming 16 collections in parallel';
    notifyListeners();

    // Wrap each query with a per-future try/catch so one failure
    // doesn't break the rest. Returns a (name, docCount) tuple.
    Future<({String name, int count})> guarded(
      String name,
      Future<List<dynamic>> future,
    ) async {
      try {
        final docs = await future;
        return (name: name, count: docs.length);
      } catch (e) {
        debugPrint('[CacheWarmer] $name failed: $e');
        return (name: name, count: 0);
      }
    }

    final futures = <Future<({String name, int count})>>[
      guarded('Pharmacies', queryPharmacyRecordOnce(parent: workspaceParent)),
      guarded('Product Catalogue', queryProductMasterRecordOnce()),
      guarded('Inventory', queryStockRecordOnce(parent: workspaceParent)),
      guarded('Stock Balances', queryStockBalanceRecordOnce(parent: workspaceParent)),
      guarded('Stock Counts', queryStockCountRecordOnce(parent: workspaceParent)),
      guarded('Sales', querySalesRecordOnce(parent: workspaceParent)),
      guarded('Finance', queryFinanceRecordOnce(parent: workspaceParent)),
      guarded('Outlets', queryOutletRecordOnce(parent: workspaceParent)),
      guarded('Damaged Stock', queryDamagedStockRecordOnce(parent: workspaceParent)),
      guarded('Low Stock Alerts', queryLowStockAlertRecordOnce()),
      guarded('Goods Received', queryGoodsReceivedRecordOnce(parent: workspaceParent)),
      guarded('Stock Movements', queryStockMovementRecordOnce(parent: workspaceParent)),
      guarded('Pharmacy Staff', queryPharmacyStaffRecordOnce(parent: workspaceParent)),
      guarded('Suppliers', querySupplierRecordOnce()),
      guarded('Batches', queryBatchRecordOnce()),
      guarded('Replenishment', queryReplenishmentRecordOnce()),
    ];

    // Fire all 16 in parallel — single wave to Firestore.
    final results = await Future.wait(futures);

    int total = 0;
    for (final r in results) {
      total += r.count;
      debugPrint('[CacheWarmer] ${r.name}: ${r.count} docs cached');
    }

    _recordsCached = total;
    _progress = 1.0;
    _currentStep = 'Complete';
    _lastWarmedAt = DateTime.now();
    _isWarming = false;
    notifyListeners();

    debugPrint(
        '[CacheWarmer] Cache warm complete — $total records cached across ${results.length} collections');
    return total;
  }
}
