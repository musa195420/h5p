// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:virtualh5p/localserver.dart';
import 'package:virtualh5p/tempdir.dart';

class LocalWebView extends StatefulWidget {
  @override
  _LocalWebViewState createState() => _LocalWebViewState();
}

class _LocalWebViewState extends State<LocalWebView> {
  final Completer<InAppWebViewController> _controller = Completer();
  String? _localServerUrl;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    String localDir = await copyWebFolder();
    var server = await startLocalServer(localDir);

    setState(() {
      _localServerUrl = "http://${server.address.address}:${server.port}";
    });
  }

  void _setupJavaScriptChannels(InAppWebViewController controller) {
    // Add JavaScript Channels if needed
  }

  void _injectJavaScriptLogging(InAppWebViewController controller) {
    controller.evaluateJavascript(
      source: "console.log('JavaScript Logging Enabled');",
    );
  }

  void _showBlockingSnackbar(String host) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Access to $host is blocked")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Local H5P Viewer")),
      body: _localServerUrl == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(_localServerUrl!)),
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
                    _setupJavaScriptChannels(controller);
                  },
                  onLoadStart: (controller, url) {
                    setState(() => _loadingProgress = 0);
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() => _loadingProgress = progress / 100);
                  },
                  onLoadStop: (controller, url) {
                    _injectJavaScriptLogging(controller);
                    setState(() => _loadingProgress = 1);
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    debugPrint("Console: Error ${consoleMessage.message}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Console: ${consoleMessage.message}")),
                    );
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    debugPrint("HTTP Error $statusCode: $description");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("HTTP Error $statusCode: $description")),
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
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    final host = navigationAction.request.url?.host;
                    if (host?.contains('youtube.com') == true) {
                      _showBlockingSnackbar(host!);
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                ),
                if (_loadingProgress < 1)
                  LinearProgressIndicator(
                    value: _loadingProgress,
                    color: Colors.blue,
                  ),
              ],
            ),
    );
  }
}
