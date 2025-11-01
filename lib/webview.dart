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

  final H5PSetup _h5pSetup = H5PSetup();
  final Completer<InAppWebViewController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _prepareBaseFiles();
  }

  Future<void> _prepareBaseFiles() async {
    await _h5pSetup.copyBaseFiles();
  }

  Future<void> _loadH5P(String url) async {
    _downloadProgress.value = 0;

    try {
      await _h5pSetup.downloadAndExtract(url, onProgress: (p) {
        _downloadProgress.value = p;
      });

      final dir = await _h5pSetup.copyBaseFiles();
      final server = await startLocalServer(dir);

      _localServerUrl.value = "http://${server.address.address}:${server.port}";
      _downloadProgress.value = 1.0;
    } on DioException catch (e) {
      String message = 'Network error: ${e.message}';
      if (e.error is SocketException) {
        message = 'No internet connection or host not found.';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Error loading H5P: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
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
      appBar: AppBar(title: const Text("H5P Local Viewer")),
      body: Column(
        children: [
          // URL selector buttons
          Wrap(
            spacing: 8,
            children: urls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              return ElevatedButton(
                onPressed: () => _loadH5P(url),
                child: Text('Load H5P ${index + 1}'),
              );
            }).toList(),
          ),

          // Download progress bar
          ValueListenableBuilder<double>(
            valueListenable: _downloadProgress,
            builder: (_, value, __) {
              if (value > 0 && value < 1) {
                return LinearProgressIndicator(value: value, color: Colors.orange);
              }
              return const SizedBox.shrink();
            },
          ),

          // WebView + loading overlay
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: _localServerUrl,
              builder: (context, url, _) {
                if (url == null) {
                  return const Center(child: Text("Select a file to load"));
                }
                return Stack(
                  children: [
                    inappwebView(url),
                    ValueListenableBuilder<double>(
                      valueListenable: _loadingProgress,
                      builder: (_, p, __) {
                        if (p < 1) return LinearProgressIndicator(value: p);
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


  inappwebView(String url) {
    return InAppWebView(
     key: ValueKey(url),
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        allowContentAccess: true,
        allowFileAccess: true,
        //domStorageEnabled: true,
        iframeCsp: "",
        mixedContentMode: MixedContentMode.fromNativeValue(1),
        useShouldInterceptRequest: true,
      ),
      onWebViewCreated: (controller) {
        _controller.complete(controller);
      //  _setupJavaScriptChannels(controller);
      },
      onLoadStart: (controller, url) {
       _loadingProgress.value = 0;
      },
      onProgressChanged: (controller, progress) {
        _loadingProgress.value = progress / 100;
      },
      onLoadStop: (controller, url) {
        _injectJavaScriptLogging(controller);
        _loadingProgress.value = 1;
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint("Console: Error ${consoleMessage.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Console: ${consoleMessage.message}")),
        );
      },
      onLoadHttpError: (controller, url, statusCode, description) {
        debugPrint("HTTP Error $statusCode: $description");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("HTTP Error $statusCode: $description")),
        );
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        debugPrint(
            "Received HTTP Error: ${errorResponse.statusCode} - ${errorResponse.reasonPhrase}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Received HTTP Error: ${errorResponse.statusCode} - ${errorResponse.reasonPhrase}")),
        );
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
