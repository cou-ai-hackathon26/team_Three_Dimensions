import 'dart:io';

void main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 5000 : 5000;
  final webDir = Directory('build/web');
  if (!webDir.existsSync()) {
    print('ERROR: build/web does not exist. Run flutter build web first.');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('====================================================');
  print('  MyLaws Flutter Web App is LIVE:');
  print('  URL: http://localhost:$port');
  print('====================================================');

  await for (HttpRequest req in server) {
    var reqPath = req.uri.path;
    if (reqPath == '/' || reqPath.isEmpty) {
      reqPath = '/index.html';
    }

    final sanitized = reqPath.startsWith('/') ? reqPath.substring(1) : reqPath;
    final file = File('${webDir.path}/$sanitized');

    if (await file.exists()) {
      final ext = sanitized.split('.').last.toLowerCase();
      final mime = switch (ext) {
        'html' => 'text/html; charset=utf-8',
        'js' => 'application/javascript; charset=utf-8',
        'mjs' => 'application/javascript; charset=utf-8',
        'wasm' => 'application/wasm',
        'json' => 'application/json',
        'css' => 'text/css; charset=utf-8',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        'svg' => 'image/svg+xml',
        'otf' => 'font/otf',
        'ttf' => 'font/ttf',
        'woff' => 'font/woff',
        'woff2' => 'font/woff2',
        _ => 'application/octet-stream',
      };

      req.response.headers.set('Content-Type', mime);
      req.response.headers.set('Access-Control-Allow-Origin', '*');
      req.response.headers
          .set('Cross-Origin-Opener-Policy', 'same-origin-allow-popups');
      req.response.headers.set(
          'Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0');
      req.response.headers.set('Pragma', 'no-cache');
      await file.openRead().pipe(req.response);
    } else {
      // SPA Fallback for client-side routing (GoRouter)
      final indexFile = File('${webDir.path}/index.html');
      req.response.headers.set('Content-Type', 'text/html; charset=utf-8');
      req.response.headers.set('Access-Control-Allow-Origin', '*');
      req.response.headers
          .set('Cross-Origin-Opener-Policy', 'same-origin-allow-popups');
      await indexFile.openRead().pipe(req.response);
    }
  }
}
