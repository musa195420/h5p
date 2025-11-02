// local_webview.dart

// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:virtualh5p/constants.dart';
import 'package:virtualh5p/inappwebview.dart';
import 'package:virtualh5p/localserver.dart';
import 'package:virtualh5p/tempdir.dart';
import 'package:virtualh5p/config.dart';

class LocalWebView extends StatefulWidget {
  const LocalWebView({super.key});

  @override
  _LocalWebViewState createState() => _LocalWebViewState();
}

class _LocalWebViewState extends State<LocalWebView> {
  final ValueNotifier<double> _downloadProgress = ValueNotifier(0);
  final ValueNotifier<String?> _localServerUrl = ValueNotifier(null);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<H5PLoadStatus> _status =
      ValueNotifier<H5PLoadStatus>(H5PLoadStatus.idle);

  final H5PSetup _h5pSetup = H5PSetup();
  InAppWebViewController? _webViewController;
  HttpServer? _currentServer;

  @override
  void initState() {
    super.initState();
    _prepareBaseFiles();
  }

  @override
  void dispose() {
    _closeServer();
    super.dispose();
  }

  Future<void> _closeServer() async {
    if (_currentServer != null) {
      await _currentServer!.close(force: true);
      _currentServer = null;
      debugPrint("🧹 Server closed");
    }
  }

  Future<void> _prepareBaseFiles() async {
    await _h5pSetup.copyBaseFiles();
  }

  Future<void> _loadH5P(String url) async {
    if (_isLoading.value) return;
    _isLoading.value = true;
    _status.value = H5PLoadStatus.downloading;
    _downloadProgress.value = 0;

    try {
      await _closeServer();

      debugPrint("⬇️ Downloading H5P from $url ...");
      await _h5pSetup.downloadAndExtract(
        url,
        onProgress: (p) {
          _downloadProgress.value = p;
        },
      );

      _status.value = H5PLoadStatus.extracting;
      final dir = await _h5pSetup.copyBaseFiles();

      final server = await startLocalServer(dir);
      _currentServer = server;
      _status.value = H5PLoadStatus.ready;

      // final newUrl = "http://${server.address.address}:${server.port}";
      // debugPrint("🌐 Local server running at: $newUrl");
final newUrl = "http://${server.address.address}:${server.port}?t=${DateTime.now().millisecondsSinceEpoch}";
_localServerUrl.value = newUrl;
      _localServerUrl.value = newUrl;
      _downloadProgress.value = 1.0;
    } on DioException catch (e) {
      _status.value = H5PLoadStatus.error;
      String message = 'Network error: ${e.message}';
      if (e.error is SocketException) {
        message = 'No internet connection or host not found.';
      }
      _showSnackBar(message);
    } catch (e) {
      _status.value = H5PLoadStatus.error;
      _showSnackBar('Error loading H5P: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("H5P Local Viewer"),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[50],
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: urls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (_, isLoading, __) {
                    return ElevatedButton(
                      onPressed: isLoading ? null : () => _loadH5P(url),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Load H5P ${index + 1}'),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Status Indicator
          ValueListenableBuilder<H5PLoadStatus>(
            valueListenable: _status,
            builder: (_, status, __) {
              Color color;
              IconData icon;
              switch (status) {
                case H5PLoadStatus.downloading:
                  color = Colors.orange;
                  icon = Icons.download;
                  break;
                case H5PLoadStatus.extracting:
                  color = Colors.amber;
                  icon = Icons.folder_open;
                  break;
                case H5PLoadStatus.ready:
                  color = Colors.green;
                  icon = Icons.check_circle;
                  break;
                case H5PLoadStatus.error:
                  color = Colors.red;
                  icon = Icons.error;
                  break;
                default:
                  color = Colors.grey;
                  icon = Icons.hourglass_empty;
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 40,
                color: color.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Text(status.H5PLABEL, style: TextStyle(color: color)),
                  ],
                ),
              );
            },
          ),

          // Download Progress Bar
          ValueListenableBuilder<double>(
            valueListenable: _downloadProgress,
            builder: (_, value, __) {
              if (value > 0 && value < 1) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.orange),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // WebView
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: _localServerUrl,
              builder: (context, url, _) {
                if (url == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.launch, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Select an H5P file to load",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return LocalH5PWebView(
                  url: url,
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onPageLoaded: () {
                    debugPrint("✅ H5P fully loaded in webview");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
