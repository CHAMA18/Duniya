import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Tracks the device's online/offline status on web and notifies listeners.
///
/// Hooks into `window.onOnline` / `window.onOffline` events which fire
/// when the browser detects a network status change (wifi disconnect,
/// airplane mode, cable unplug, etc.).
///
/// Usage:
///   final service = OfflineConnectivityService();
///   service.isOnline; // → bool
///   service.onStatusChange.listen((isOnline) { ... });
///
/// Note: This implementation uses dart:html, so it only works on web.
/// The app already uses dart:html elsewhere (batches_widget.dart,
/// download_inventory_template.dart), so this is consistent.
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

    if (kIsWeb) {
      _initWeb();
    } else {
      // Non-web: assume online (mobile/desktop use Firebase's own retries).
      _isOnline = true;
      debugPrint(
          '[OfflineConnectivityService] Non-web init — assuming online');
    }
  }

  void _initWeb() {
    try {
      _isOnline = html.window.navigator.onLine ?? true;
      // Listen to the browser's online/offline events.
      _onlineSub = html.window.onOnline.listen(_handleOnline);
      _offlineSub = html.window.onOffline.listen(_handleOffline);
      debugPrint(
          '[OfflineConnectivityService] Web init — online: $_isOnline');
    } catch (e) {
      debugPrint(
          '[OfflineConnectivityService] Web init failed: $e — assuming online');
      _isOnline = true;
    }
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
    if (kIsWeb) {
      try {
        final wasOnline = _isOnline;
        _isOnline = html.window.navigator.onLine ?? true;
        if (wasOnline != _isOnline) {
          notifyListeners();
        }
      } catch (_) {
        // ignore
      }
    }
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _offlineSub?.cancel();
    super.dispose();
  }
}
