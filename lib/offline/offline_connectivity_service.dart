import 'dart:async';
import 'package:flutter/foundation.dart';
// Prefix-imported so the platform-level `isOnline` / `onOnline` /
// `onOffline` symbols are NOT shadowed by this class's own
// `bool get isOnline` getter. Without the prefix, `_isOnline = isOnline`
// would be a self-assignment (the getter returns `_isOnline`), so the
// service would never actually read the browser's online status at
// startup — a fresh load while already offline would fail to fire the
// banner until the *next* online↔offline transition.
import 'platform_connectivity.dart' as pc;

/// Tracks the device's online/offline status and notifies listeners.
///
/// On web, hooks into `window.onOnline` / `window.onOffline` events via
/// the conditional platform_connectivity import.
/// On mobile/desktop, the stub always reports online (Firebase handles
/// its own retries).
///
/// Usage:
///   final service = OfflineConnectivityService();
///   service.isOnline; // → bool
class OfflineConnectivityService extends ChangeNotifier {
  OfflineConnectivityService._internal();
  static final OfflineConnectivityService _instance =
      OfflineConnectivityService._internal();
  factory OfflineConnectivityService() => _instance;

  bool _isOnline = true;
  bool _initialized = false;
  StreamSubscription<dynamic>? _onlineSub;
  StreamSubscription<dynamic>? _offlineSub;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Initialise the service and start listening to network events.
  /// Safe to call multiple times — only the first call has effect.
  ///
  /// Reads the **platform** online status (not the class's own getter)
  /// so a fresh load while already offline is detected immediately.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _isOnline = pc.isOnline; // read from platform_connectivity
    _onlineSub = pc.onOnline.listen(_handleOnline);
    _offlineSub = pc.onOffline.listen(_handleOffline);

    debugPrint(
        '[OfflineConnectivityService] Init — online: $_isOnline (web: $kIsWeb)');
  }

  void _handleOnline(_) {
    if (!_isOnline) {
      _isOnline = true;
      debugPrint('[OfflineConnectivityService] Network: ONLINE');
      notifyListeners();
    }
  }

  void _handleOffline(_) {
    if (_isOnline) {
      _isOnline = false;
      debugPrint('[OfflineConnectivityService] Network: OFFLINE');
      notifyListeners();
    }
  }

  /// Force-refresh the status (e.g. after a failed network call).
  /// Re-reads the platform-level status so transient browser hiccups
  /// are reflected even when no online/offline event has fired.
  void refresh() {
    final wasOnline = _isOnline;
    _isOnline = pc.isOnline; // re-read from platform
    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _offlineSub?.cancel();
    super.dispose();
  }
}
