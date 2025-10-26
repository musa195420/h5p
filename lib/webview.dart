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
  List<String> urls = [
    'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Interactive%20Video.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9JbnRlcmFjdGl2ZSBWaWRlby5oNXAiLCJpYXQiOjE3NjE1MDM4NTksImV4cCI6MTc5MzAzOTg1OX0.qMAJYEY4IsrCjhQnFFlz2jA-H0OBJyJtXiwsj5nL35k',
    'https://rmnzqinspzgmvgxistyi.supabase.co/storage/v1/object/sign/h5p/test/Test%20mcq.h5p?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9lYTlmZWZkMS01MGQxLTQzZDgtOGUxMC1lNjBiZmNlZmNmMWMiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJoNXAvdGVzdC9UZXN0IG1jcS5oNXAiLCJpYXQiOjE3NjE0OTk1OTMsImV4cCI6MTc5MzAzNTU5M30.Fb4dOMKXjTB47Ht1ot7PLcsw6qHbDWJ5FSZL8Q5Meq8'
  ]; //

  final Completer<InAppWebViewController> _controller = Completer();
  String? _localServerUrl;
  double _loadingProgress = 0;
  double _downloadProgress = 0;
  final H5PSetup _h5pSetup = H5PSetup();
  @override
  void initState() {
    super.initState();
    _prepareBaseFiles();
  }

  Future<void> _prepareBaseFiles() async {
    await _h5pSetup.copyBaseFiles();
  }

  Future<void> _loadH5P(String url) async {
    setState(() => _downloadProgress = 0);
    await _h5pSetup.downloadAndExtract(url, onProgress: (p) {
      setState(() => _downloadProgress = p);
    });

    final dir = await _h5pSetup.copyBaseFiles();
    var server = await startLocalServer(dir);

    setState(() {
      _localServerUrl = "http://${server.address.address}:${server.port}";
      _downloadProgress = 1.0;
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
          if (_downloadProgress > 0 && _downloadProgress < 1)
            LinearProgressIndicator(
              value: _downloadProgress,
              color: Colors.orange,
            ),
          Expanded(
            child: _localServerUrl == null
                ? const Center(child: Text("Select a file to load"))
                : Stack(
                    children: [
                      inappwebView(),
                      if (_loadingProgress < 1 && _localServerUrl != null)
                        LinearProgressIndicator(value: _loadingProgress),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  inappwebView() {
    return InAppWebView(
      key: ValueKey(_localServerUrl),
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
