import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:virtualh5p/config.dart';

HttpServer? _activeServer; // keep a global reference

Future<HttpServer> startLocalServer(String directory) async {
  // If server is already running, close it first
  if (_activeServer != null) {
    try {
      debugPrint('🧹 Closing previous local server...');
      await _activeServer!.close(force: true);
      _activeServer = null;
    } catch (e) {
      debugPrint('⚠️ Error closing previous server: $e');
    }
  }

  // Create a static file handler
  final handler = createStaticHandler(
    directory,
    defaultDocument: 'index.html',
    serveFilesOutsidePath: true,
  );

  // Try to start the new server
  try {
    final server = await shelf_io.serve(
      handler,
      InternetAddress.loopbackIPv4,
      h5pPort,
      shared: true, // allow multiple bindings safely
    );

    _activeServer = server;
    debugPrint(
        '🌐 Local server running at: http://${server.address.address}:${server.port}');
    return server;
  } catch (e) {
    debugPrint('❌ Failed to start server: $e');
    rethrow;
  }
}

Future<void> stopLocalServer() async {
  if (_activeServer != null) {
    debugPrint('🛑 Stopping local server...');
    await _activeServer!.close(force: true);
    _activeServer = null;
  }
}
