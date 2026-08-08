import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_connectivity.dart';

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
  StreamSubscription? _onlineSub;
  StreamSubscription? _offlineSub;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Initialise the service and start listening to network events.
  /// Safe to call multiple times — only the first call has effect.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _isOnline = isOnline; // from platform_connectivity (conditional)
    _onlineSub = onOnline.listen(_handleOnline);
    _offlineSub = onOffline.listen(_handleOffline);

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
  void refresh() {
    final wasOnline = _isOnline;
    _isOnline = isOnline; // re-read from platform
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
