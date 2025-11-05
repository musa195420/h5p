library;

/// 🧠 Main entry point for the VirtualH5P package.
///
/// This library lets you load, extract, and serve H5P content locally
/// using an embedded HTTP server and display it inside a WebView.
///
/// Example usage:
/// ```dart
/// final h5p = LumiH5P();
/// await h5p.init();
/// await h5p.load("https://example.com/sample.h5p");
/// runApp(MaterialApp(home: h5p.widget()));
/// ```
import 'package:flutter/material.dart';

import 'config.dart';
import 'h5p_loader.dart';
import 'local_web_view.dart';

/// Main controller for initializing, loading, and displaying H5P content.
class LumiH5P {
  final H5PLoader _loader = H5PLoader();

  /// Initialize the base files and local server.
  Future<void> init() async {
    await _loader.prepareBaseFiles();
  }

  /// Load an H5P package from a given URL (zip file).
  Future<void> load(String url) async {
    await _loader.loadH5P(url);
  }

  /// Returns the current status of the H5P loader.
  ValueNotifier<H5PLoadStatus> get status => _loader.status;

  /// Returns the current download progress (0.0–1.0).
  ValueNotifier<double> get downloadProgress => _loader.downloadProgress;

  /// Returns the local server URL hosting the extracted H5P content.
  ValueNotifier<String?> get localServerUrl => _loader.localServerUrl;

  /// Build the WebView widget showing the currently loaded H5P content.
  Widget widget() {
    return ValueListenableBuilder<String?>(
      valueListenable: _loader.localServerUrl,
      builder: (context, url, _) {
        if (url == null) {
          return const Center(
            child: Text(
              "No H5P content loaded yet",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return LocalH5PWebView(
          url: url,
          onWebViewCreated: (controller) {
            debugPrint("🌐 WebView initialized");
          },
          onPageLoaded: () {
            debugPrint("✅ H5P page loaded successfully");
          },
        );
      },
    );
  }

  /// Stop and close the local server.
  Future<void> dispose() async {
    await _loader.closeServer();
  }
}
