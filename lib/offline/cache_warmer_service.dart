import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';

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
  Future<int> warmCache() async {
    if (_isWarming) return _recordsCached;

    final userDoc = currentUserDocument;
    if (userDoc == null) {
      _lastError = 'No user signed in';
      notifyListeners();
      return 0;
    }

    // Resolve the owner reference (pharmacies live under the owner).
    final DocumentReference ownerRef;
    if (valueOrDefault(userDoc.role, '') == 'Owner') {
      final ref = currentUserReference;
      if (ref == null) {
        _lastError = 'Unable to identify your account';
        notifyListeners();
        return 0;
      }
      ownerRef = ref;
    } else {
      final ref = userDoc.ownerRef;
      if (ref == null) {
        _lastError = 'No owner pharmacy linked to your account';
        notifyListeners();
        return 0;
      }
      ownerRef = ref;
    }

    _isWarming = true;
    _progress = 0.0;
    _recordsCached = 0;
    _lastError = null;
    notifyListeners();

    final steps = <_WarmStep>[
      _WarmStep(
        name: 'Pharmacies',
        query: queryPharmacyRecordOnce(parent: ownerRef),
      ),
      _WarmStep(
        name: 'Product Catalogue',
        query: queryProductMasterRecordOnce(),
      ),
      _WarmStep(
        name: 'Stock Balances',
        query: queryStockBalanceRecordOnce(parent: ownerRef),
      ),
      _WarmStep(
        name: 'Stock Counts',
        query: queryStockCountRecordOnce(parent: ownerRef),
      ),
      _WarmStep(
        name: 'Low Stock Alerts',
        query: queryLowStockAlertRecordOnce(),
      ),
      _WarmStep(
        name: 'Goods Received',
        query: queryGoodsReceivedRecordOnce(parent: ownerRef),
      ),
      _WarmStep(
        name: 'Stock Movements',
        query: queryStockMovementRecordOnce(parent: ownerRef),
      ),
    ];

    int total = 0;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      _currentStep = step.name;
      _progress = i / steps.length;
      notifyListeners();

      try {
        final docs = await step.query;
        total += docs.length;
        _recordsCached = total;
        // Slight delay so the UI can show progress per step
        await Future.delayed(const Duration(milliseconds: 50));
        debugPrint(
            '[CacheWarmer] ${step.name}: ${docs.length} docs cached (total: $total)');
      } catch (e) {
        debugPrint('[CacheWarmer] ${step.name} failed: $e');
        // Continue with other steps — partial warm is better than none
      }
    }

    _progress = 1.0;
    _currentStep = 'Complete';
    _lastWarmedAt = DateTime.now();
    _isWarming = false;
    notifyListeners();

    debugPrint(
        '[CacheWarmer] Cache warm complete — $total records cached across ${steps.length} collections');
    return total;
  }
}

class _WarmStep {
  final String name;
  final Future<List<dynamic>> query;
  _WarmStep({required this.name, required this.query});
}
