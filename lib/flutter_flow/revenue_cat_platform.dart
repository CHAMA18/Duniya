// Conditional export for platform detection.
// On web (dart.library.html), use the stub that returns false.
// On native (dart.library.io), use the real Platform checks.
export 'revenue_cat_platform_stub.dart'
    if (dart.library.io) 'revenue_cat_platform_io.dart';
