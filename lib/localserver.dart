import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

Future<HttpServer> startLocalServer(String directory) async {
  final handler = createStaticHandler(
    directory,
    defaultDocument: 'index.html',
    serveFilesOutsidePath: true, // Allows serving files inside subdirectories
  );

  final server =
      await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 8030);

  debugPrint(
      "Error Local server running at: http://${server.address.address}:${server.port}");
  return server;
}
