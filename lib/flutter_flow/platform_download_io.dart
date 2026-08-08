import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mobile/desktop implementation: saves bytes to a temporary file and
/// opens the system share sheet so the user can save or send the file.
Future<void> save({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType, name: fileName)],
      text: 'Duniya — $fileName',
    );
  } catch (e) {
    debugPrint('[PlatformDownload] Save failed: $e');
  }
}
