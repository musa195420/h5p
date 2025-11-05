import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'config.dart';
import 'local_server.dart';
import 'tempdir.dart';

class H5PLoader {
  /// Progress notifier (0 → 1)
  final ValueNotifier<double> downloadProgress = ValueNotifier(0);

  /// Current local server URL (null until ready)
  final ValueNotifier<String?> localServerUrl = ValueNotifier(null);

  /// Whether a load process is ongoing
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// Current load status (downloading, extracting, ready, error, etc.)
  final ValueNotifier<H5PLoadStatus> status =
      ValueNotifier<H5PLoadStatus>(H5PLoadStatus.idle);

  final H5PSetup _h5pSetup = H5PSetup();
  HttpServer? _currentServer;

  Future<void> prepareBaseFiles() async {
    await _h5pSetup.copyBaseFiles();
  }

  Future<void> closeServer() async {
    if (_currentServer != null) {
      await _currentServer!.close(force: true);
      _currentServer = null;
      debugPrint("🧹 Server closed");
    }
  }

  Future<void> loadH5P(String url) async {
    if (isLoading.value) return;
    isLoading.value = true;
    status.value = H5PLoadStatus.downloading;
    downloadProgress.value = 0;

    try {
      await closeServer();

      debugPrint("⬇️ Downloading H5P from $url ...");
      await _h5pSetup.downloadAndExtract(
        url,
        onProgress: (p) => downloadProgress.value = p,
      );

      status.value = H5PLoadStatus.extracting;
      final dir = await _h5pSetup.copyBaseFiles();

      final server = await startLocalServer(dir);
      _currentServer = server;
      status.value = H5PLoadStatus.ready;

      final newUrl =
          "http://${server.address.address}:${server.port}?t=${DateTime.now().millisecondsSinceEpoch}";
      localServerUrl.value = newUrl;
      downloadProgress.value = 1.0;

      debugPrint("🌐 Local server running at: $newUrl");
    } on DioException catch (e) {
      status.value = H5PLoadStatus.error;
      String message = 'Network error: ${e.message}';
      if (e.error is SocketException) {
        message = 'No internet connection or host not found.';
      }
      debugPrint("❌ $message");
    } catch (e) {
      status.value = H5PLoadStatus.error;
      debugPrint('❌ Error loading H5P: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
