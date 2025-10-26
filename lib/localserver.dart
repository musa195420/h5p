import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

List<String> urls = [
  'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/interactive-video-2-618.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9pbnRlcmFjdGl2ZS12aWRlby0yLTYxOC5oNXAiLCJpYXQiOjE3NjE0OTk1ODQsImV4cCI6MTc5MzAzNTU4NH0.IXZFu3w9SkevH5w59aiwsk4kBDYwY08hhnetdU0eIGs',
  'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Test%20mcq.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9UZXN0IG1jcS5oNXAiLCJpYXQiOjE3NjE0OTk1OTMsImV4cCI6MTc5MzAzNTU5M30.Fb4dOMKXjTB47Ht1ot7PLcsw6qHbDWJ5FSZL8Q5Meq8'
]; // local_server.dart
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
      8030,
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

/// Optionally, stop the server manually when needed
Future<void> stopLocalServer() async {
  if (_activeServer != null) {
    debugPrint('🛑 Stopping local server...');
    await _activeServer!.close(force: true);
    _activeServer = null;
  }
}
