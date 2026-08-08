import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Fallback stub for platforms where neither dart:html nor dart:io are
/// available (shouldn't happen in practice — every Flutter target has
/// one or the other). Logs a warning and does nothing.
Future<void> save({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) async {
  debugPrint(
      '[PlatformDownload] No platform implementation available for $fileName '
      '(${bytes.length} bytes, $mimeType)');
}
