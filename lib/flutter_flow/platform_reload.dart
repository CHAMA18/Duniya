/// Cross-platform page reload abstraction.
///
/// On web (dart:html available): calls `html.window.location.reload()`.
/// On mobile/desktop (dart:io available): no-op — caller should fall
///   back to a higher-level restart (e.g. restart app process).
/// On other platforms: no-op stub.
///
/// Usage:
///   import '/flutter_flow/platform_reload.dart';
///   await reloadPage();
///
/// The conditional import resolves at compile time:
/// - If dart.library.html is available → platform_reload_web.dart
/// - If dart.library.io is available → platform_reload_io.dart
/// - Otherwise → platform_reload_stub.dart

export 'platform_reload_stub.dart'
    if (dart.library.html) 'platform_reload_web.dart'
    if (dart.library.io) 'platform_reload_io.dart';
