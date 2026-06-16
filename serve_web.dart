import 'dart:io';
import 'dart:async';

const PORT = 3000;
const WEB_DIR = 'build/web';

final MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.map': 'application/json',
};

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, PORT);
  print('Duniya Flutter web app serving on http://0.0.0.0:$PORT');

  await for (final request in server) {
    try {
      String path = request.uri.path;
      if (path == '/') path = '/index.html';

      final filePath = '$WEB_DIR$path';
      final file = File(filePath);

      if (await file.exists()) {
        final ext = filePath.substring(filePath.lastIndexOf('.')).toLowerCase();
        final contentType = MIME_TYPES[ext] ?? 'application/octet-stream';
        request.response
          ..headers.contentType = ContentType.parse(contentType)
          ..headers.set('Access-Control-Allow-Origin', '*');
        await file.openRead().pipe(request.response);
      } else {
        // SPA fallback
        final indexFile = File('$WEB_DIR/index.html');
        if (await indexFile.exists()) {
          request.response.headers.contentType = ContentType.html;
          await indexFile.openRead().pipe(request.response);
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..close();
        }
      }
    } catch (e) {
      print('Error: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..close();
    }
  }
}
