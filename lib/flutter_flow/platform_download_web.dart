import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

/// Web implementation: triggers a browser download using Blob + AnchorElement.
Future<void> save({
  required Uint8List bytes,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final link = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  // Some browsers ignore a click on a detached anchor, while others cancel
  // the download if its Blob URL is revoked in the same event turn.
  html.document.body?.append(link);
  link.click();
  link.remove();
  await Future<void>.delayed(const Duration(seconds: 1));
  html.Url.revokeObjectUrl(url);
}
