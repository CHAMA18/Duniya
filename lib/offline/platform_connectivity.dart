import 'dart:async';
import 'package:flutter/foundation.dart';

/// Platform-specific connectivity hooks.
/// Resolves at compile time:
/// - Web → platform_connectivity_web.dart (uses dart:html)
/// - Other → platform_connectivity_stub.dart (no-op, always online)
export 'platform_connectivity_stub.dart'
    if (dart.library.html) 'platform_connectivity_web.dart';
