// local_webview_widget.dart

// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LocalH5PWebView extends StatefulWidget {
  final String url;
  final void Function(InAppWebViewController)? onWebViewCreated;
  final void Function()? onPageLoaded;
  final bool listenToEvents; // ✅ Constructor flag
  final void Function(Map<String, dynamic> xApiEvent)? onXApiEvent;

  const LocalH5PWebView({
    super.key,
    required this.url,
    this.onWebViewCreated,
    this.onPageLoaded,
    this.listenToEvents = false,
    this.onXApiEvent,
  });

  @override
  State<LocalH5PWebView> createState() => _LocalH5PWebViewState();
}

class _LocalH5PWebViewState extends State<LocalH5PWebView> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          key: ValueKey(widget.url),
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            allowContentAccess: true,
            allowFileAccess: true,
            cacheEnabled: false,
            clearCache: true,
            clearSessionCache: true,
            domStorageEnabled: true,
            iframeCsp: "",
            mixedContentMode: MixedContentMode.fromNativeValue(1),
            useShouldInterceptRequest: true,
            transparentBackground: true,
          ),
          onWebViewCreated: (controller) {
            widget.onWebViewCreated?.call(controller);
            if (widget.listenToEvents) {
              controller.addJavaScriptHandler(
                handlerName: 'h5pEvent',
                callback: (args) {
                  if (args.isNotEmpty) {
                    final jsonStr = args[0] as String;
                    final Map<String, dynamic> jsonData =
                        Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
                    widget.onXApiEvent?.call(jsonData);
                  }
                },
              );
            }
          },
          onLoadStart: (controller, url) {
            debugPrint("🚀 Loading started: $url");
            setState(() => _progress = 0);
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
          onProgressChanged: (controller, progress) {
            setState(() => _progress = progress / 100);
            if (progress == 100) {
              debugPrint("✅ Page fully loaded");
              widget.onPageLoaded?.call();
            }
          },
          onLoadStop: (controller, url) {
            debugPrint("🏁 Load completed: $url");
            _injectJavaScriptLogging(controller);
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint(
                "Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}");
          },
        ),
        if (_progress < 1)
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
      ],
    );
  }

  void _injectJavaScriptLogging(InAppWebViewController controller) {
    final listenEvents = widget.listenToEvents ? 'true' : 'false';

    final script = """
  console.log('JavaScript Logging Enabled');

  function attachListener() {
    if (window.H5P && H5P.externalDispatcher) {
      console.log('🔥 H5P READY – Attaching xAPI listener!');
      H5P.externalDispatcher.on('xAPI', function(event) {
        console.log('📡 H5P xAPI Event:', event.data.statement);

        if ($listenEvents && window.flutter_inappwebview) {
          // Send JSON string
          window.flutter_inappwebview.callHandler(
            'h5pEvent',
            JSON.stringify(event.data.statement)
          );
        }
      });
    } else {
      console.log('⏳ H5P NOT READY – retrying...');
      setTimeout(attachListener, 500);
    }
  }

  attachListener();
  """;

    controller.evaluateJavascript(source: script);
  }

  void _showBlockingSnackbar(String host) {
    _showSnackBar("Access to $host is blocked");
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
}
