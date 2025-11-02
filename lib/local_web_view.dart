// local_webview_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LocalH5PWebView extends StatefulWidget {
  final String url;
  final void Function(InAppWebViewController)? onWebViewCreated;
  final void Function()? onPageLoaded;

  const LocalH5PWebView({
    super.key,
    required this.url,
    this.onWebViewCreated,
    this.onPageLoaded,
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
            debugPrint("Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}");
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
    controller.evaluateJavascript(
      source: "console.log('JavaScript Logging Enabled');",
    );
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
