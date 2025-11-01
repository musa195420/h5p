// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:virtualh5p/constants.dart';
import 'package:virtualh5p/localserver.dart';
import 'package:virtualh5p/tempdir.dart';
import 'package:dio/dio.dart';

class LocalWebView extends StatefulWidget {
  const LocalWebView({super.key});

  @override
  _LocalWebViewState createState() => _LocalWebViewState();
}

class _LocalWebViewState extends State<LocalWebView> {
  final ValueNotifier<double> _downloadProgress = ValueNotifier(0);
  final ValueNotifier<double> _loadingProgress = ValueNotifier(0);
  final ValueNotifier<String?> _localServerUrl = ValueNotifier(null);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

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
    if (_isLoading.value) return; // Prevent multiple simultaneous loads
    
    _isLoading.value = true;
    _downloadProgress.value = 0;
    _loadingProgress.value = 0;

    try {
      // Close previous server
      await _closeServer();

      debugPrint("⬇️ Downloading H5P from $url ...");
      await _h5pSetup.downloadAndExtract(url, onProgress: (p) {
        _downloadProgress.value = p;
      });

      final dir = await _h5pSetup.copyBaseFiles();
      final server = await startLocalServer(dir);
      _currentServer = server;

      final newUrl = "http://${server.address.address}:${server.port}";
      debugPrint("🌐 Local server running at: $newUrl");

      // Update URL and reset WebView
      _localServerUrl.value = newUrl;
      _downloadProgress.value = 1.0;

      // Force WebView reload with new URL
      if (_webViewController != null) {
        debugPrint("🔄 Loading new URL in WebView: $newUrl");
        await _webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(newUrl)),
        );
      }

    } on DioException catch (e) {
      String message = 'Network error: ${e.message}';
      if (e.error is SocketException) {
        message = 'No internet connection or host not found.';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Error loading H5P: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _injectJavaScriptLogging(InAppWebViewController controller) {
    controller.evaluateJavascript(
      source: "console.log('JavaScript Logging Enabled');",
    );
  }

  void _showBlockingSnackbar(String host) {
    _showSnackBar("Access to $host is blocked");
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
          // URL selector buttons with loading state
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

          // Download progress bar
          ValueListenableBuilder<double>(
            valueListenable: _downloadProgress,
            builder: (_, value, __) {
              if (value > 0 && value < 1) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Status indicator
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (_, isLoading, __) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isLoading ? 40 : 0,
                child: isLoading
                    ? const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('Loading H5P content...'),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),

          // WebView + loading overlay
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
                return Stack(
                  children: [
                    _buildWebView(url),
                    ValueListenableBuilder<double>(
                      valueListenable: _loadingProgress,
                      builder: (_, p, __) {
                        if (p < 1) {
                          return LinearProgressIndicator(
                            value: p,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView(String url) {
    return InAppWebView(
      key: ValueKey(url), // This ensures WebView recreates when URL changes
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        allowContentAccess: true,
        allowFileAccess: true,
        domStorageEnabled: true,
        iframeCsp: "",
        mixedContentMode: MixedContentMode.fromNativeValue(1),
        useShouldInterceptRequest: true,
        transparentBackground: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        debugPrint("🎯 WebView created for URL: $url");
      },
      onLoadStart: (controller, url) {
        debugPrint("🚀 Loading started: $url");
        _loadingProgress.value = 0;
      },
      onProgressChanged: (controller, progress) {
        _loadingProgress.value = progress / 100;
        if (progress == 100) {
          debugPrint("✅ Page fully loaded");
        }
      },
      onLoadStop: (controller, url) {
        _injectJavaScriptLogging(controller);
        _loadingProgress.value = 1;
        debugPrint("🏁 Load completed: $url");
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint("Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}");
      },
      onLoadHttpError: (controller, url, statusCode, description) {
        debugPrint("❌ HTTP Error $statusCode: $description for $url");
        _showSnackBar("Failed to load content: $description");
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final host = navigationAction.request.url?.host;
        if (host?.contains('youtube.com') == true) {
          _showBlockingSnackbar(host!);
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}