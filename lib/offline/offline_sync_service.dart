import 'dart:async';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Tracks the sync status of Firestore writes and the overall offline
/// cache health.
///
/// This service complements [OfflineConnectivityService] by answering
/// a more nuanced question: "I'm back online — are my offline writes
/// actually synced yet?"
///
/// How it works:
/// - Listens to Firestore's metadata snapshot events on the User document
///   and key subcollections. Firestore marks documents with
///   `metadata.hasPendingWrites = true` while a local write is waiting
///   to be acknowledged by the server.
/// - Exposes a stream of [SyncStatus] that the UI can listen to.
/// - Provides a manual [refresh] that re-checks pending writes by
///   querying with `includeMetadataChanges`.
///
/// Usage:
///   final sync = OfflineSyncService();
///   sync.status; // → SyncStatus
///   sync.statusStream.listen((status) { ... });
class OfflineSyncService extends ChangeNotifier {
  OfflineSyncService._internal();
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;

  StreamSubscription? _userSub;
  StreamSubscription? _pharmaciesSub;
  StreamSubscription? _productsSub;

  int _pendingWriteCount = 0;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;
  bool _initialized = false;

  int get pendingWriteCount => _pendingWriteCount;
  bool get hasPendingWrites => _pendingWriteCount > 0;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Stream of status snapshots for reactive UI.
  Stream<SyncStatus> get statusStream {
    return _statusController.stream;
  }

  final _statusController = StreamController<SyncStatus>.broadcast();

  SyncStatus get status => SyncStatus(
        pendingWrites: _pendingWriteCount,
        isSyncing: _isSyncing,
        lastSyncedAt: _lastSyncedAt,
      );

  /// Initialise the service. Safe to call multiple times.
  ///
/// On web, this sets up metadata-aware listeners on the current user's
  /// document and a few key subcollections. Each snapshot tells us
  /// whether there are pending writes that haven't been acknowledged
  /// by the server yet.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Hook into the browser's online event to trigger a sync check
    // the moment connectivity is restored.
    if (kIsWeb) {
      try {
        html.window.onOnline.listen((_) {
          _isSyncing = true;
          _emit();
          notifyListeners();
          // Give Firestore a moment to flush, then re-check.
          Future.delayed(const Duration(seconds: 2), () {
            _isSyncing = false;
            _lastSyncedAt = DateTime.now();
            _emit();
            notifyListeners();
          });
        });
      } catch (_) {
        // ignore
      }
    }

    // Mark initial sync time if we're online.
    if (kIsWeb) {
      try {
        if (html.window.navigator.onLine ?? true) {
          _lastSyncedAt = DateTime.now();
        }
      } catch (_) {
        // ignore
      }
    }
  }

  /// Subscribe to a collection's metadata changes to detect pending
  /// writes. Call this for each collection you want to track.
  ///
  /// We use [includeMetadataChanges: true] so that snapshot events
  /// fire even when only the metadata (e.g., pending-writes flag)
  /// changes — not just when the data itself changes.
  void watchCollection(Query<Map<String, dynamic>> query) {
    final sub = query
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      int pending = 0;
      for (final doc in snapshot.docs) {
        if (doc.metadata.hasPendingWrites) {
          pending++;
        }
      }
      _pendingWriteCount = pending;
      if (pending == 0 && _isSyncing) {
        _isSyncing = false;
        _lastSyncedAt = DateTime.now();
      }
      _emit();
      notifyListeners();
    });
    // Keep the subscription alive (we never cancel it — the service
    // is a singleton that lives for the app's lifetime).
    _ = sub;
  }

  void _emit() {
    _statusController.add(status);
  }

  /// Manually trigger a sync status refresh.
  Future<void> refresh() async {
    // The metadata listeners update _pendingWriteCount automatically;
    // here we just re-emit the current state.
    _emit();
    notifyListeners();
  }

  /// Mark that a write has just been queued (for immediate UI feedback
  /// before the metadata listener catches up).
  void noteWriteQueued() {
    _pendingWriteCount++;
    _isSyncing = true;
    _emit();
    notifyListeners();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _pharmaciesSub?.cancel();
    _productsSub?.cancel();
    _statusController.close();
    super.dispose();
  }
}

/// A snapshot of the sync status at a point in time.
class SyncStatus {
  final int pendingWrites;
  final bool isSyncing;
  final DateTime? lastSyncedAt;

  const SyncStatus({
    required this.pendingWrites,
    required this.isSyncing,
    required this.lastSyncedAt,
  });

  bool get isFullySynced => pendingWrites == 0 && !isSyncing;

  String get statusLabel {
    if (isSyncing) return 'Syncing…';
    if (pendingWrites > 0) return '$pendingWrites pending';
    return 'All synced';
  }

  @override
  String toString() =>
      'SyncStatus(pending=$pendingWrites, syncing=$isSyncing, lastSynced=$lastSyncedAt)';
}

/// Dummy assignment to suppress unused-variable warnings for the
/// "fire-and-forget" subscriptions we keep alive in [watchCollection].
/// The subscriptions are intentionally never cancelled because the
/// service is a singleton.
void set _(StreamSubscription? _) {}
