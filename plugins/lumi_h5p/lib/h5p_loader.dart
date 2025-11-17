import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'config.dart';
import 'local_server.dart';
import 'tempdir.dart';

class H5PLoader {
  /// Progress notifier (0 → 1)
  final ValueNotifier<double> progress = ValueNotifier(0);

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

  Future<String> downloadInbackground(String url, String refName) async {
    return await _h5pSetup.downloadFileForLater(url, refName);
  }

  Future<void> loadH5P(String url) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      await closeServer();

      // 1️⃣ Download stage
      status.value = H5PLoadStatus.downloading;
      progress.value = 0;
      final tempH5pPath = await _h5pSetup.downloadH5P(url,
          onProgress: (p) => progress.value = p);

      // 2️⃣ Extract stage
      status.value = H5PLoadStatus.extracting;
      progress.value = 0;
      await _h5pSetup.extractH5P(tempH5pPath,
          onProgress: (p) => progress.value = p);

      // 3️⃣ Start local server
      final dir = await _h5pSetup.copyBaseFiles();
      final server = await startLocalServer(dir);
      _currentServer = server;

      status.value = H5PLoadStatus.ready;
      localServerUrl.value =
          "http://${server.address.address}:${server.port}?t=${DateTime.now().millisecondsSinceEpoch}";

      progress.value = 1.0;
      debugPrint("🌐 Local server running at: ${localServerUrl.value}");
    } catch (e) {
      status.value = H5PLoadStatus.error;
      debugPrint("❌ Error loading H5P: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
