import 'dart:html' as html;

Future<void> downloadStaticFile({
  required String path,
  required String fileName,
}) async {
  final link = html.AnchorElement(href: path)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body?.append(link);
  link.click();
  link.remove();
}
