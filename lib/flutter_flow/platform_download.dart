/// Cross-platform file download/save abstraction.
///
/// On web (dart:html available): triggers a browser download via Blob + AnchorElement.
/// On mobile/desktop (dart:io available): saves to temp file and opens share sheet.
/// On other platforms: logs a warning (fallback stub).
///
/// Usage:
///   import '/flutter_flow/platform_download.dart';
///   await PlatformDownload.save(
///     bytes: myBytes,
///     fileName: 'report.pdf',
///     mimeType: 'application/pdf',
///   );
///
/// The conditional import resolves at compile time:
/// - If dart.library.html is available → platform_download_web.dart
/// - If dart.library.io is available → platform_download_io.dart
/// - Otherwise → platform_download_stub.dart

export 'platform_download_stub.dart'
    if (dart.library.html) 'platform_download_web.dart'
    if (dart.library.io) 'platform_download_io.dart';
