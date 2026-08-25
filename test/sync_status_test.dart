import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/offline/offline_sync_service.dart';

/// ═══════════════════════════════════════════════════════════════════
///   Offline Sync Status Model — Unit Tests
///   The status label drives the floating sync chip users rely on.
/// ═══════════════════════════════════════════════════════════════════
void main() {
  group('SyncStatus.isFullySynced', () {
    test('true only when nothing pending and not syncing', () {
      expect(SyncStatus(pendingWrites: 0, isSyncing: false, lastSyncedAt: null)
          .isFullySynced, isTrue);
    });

    test('false while writes are pending', () {
      expect(
          SyncStatus(
                  pendingWrites: 3,
                  isSyncing: false,
                  lastSyncedAt: DateTime.now())
              .isFullySynced,
          isFalse);
    });

    test('false while a flush is running', () {
      expect(
          SyncStatus(pendingWrites: 0, isSyncing: true, lastSyncedAt: null)
              .isFullySynced,
          isFalse);
    });
  });

  group('SyncStatus.statusLabel', () {
    test('syncing takes precedence', () {
      expect(
          SyncStatus(
                  pendingWrites: 5, isSyncing: true, lastSyncedAt: null)
              .statusLabel,
          'Syncing…');
    });

    test('pending count is shown when idle', () {
      expect(
          SyncStatus(
                  pendingWrites: 5, isSyncing: false, lastSyncedAt: null)
              .statusLabel,
          '5 pending');
    });

    test('all synced when clean', () {
      expect(
          SyncStatus(
                  pendingWrites: 0, isSyncing: false, lastSyncedAt: null)
              .statusLabel,
          'All synced');
    });
  });

  group('SyncStatus.toString', () {
    test('is debug-readable', () {
      final s = SyncStatus(
          pendingWrites: 2,
          isSyncing: false,
          lastSyncedAt: DateTime(2026, 1, 1));
      expect(s.toString(), contains('pending=2'));
      expect(s.toString(), contains('syncing=false'));
    });
  });
}
