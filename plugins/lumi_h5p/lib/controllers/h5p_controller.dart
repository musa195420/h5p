import 'package:flutter/material.dart';
import 'package:lumi_h5p/config.dart';
import 'package:lumi_h5p/h5p_loader.dart';
import 'package:lumi_h5p/local_web_view.dart';

class LumiH5PController {
  H5PLoader? _loader;

  // persistent notifiers (UI can safely listen from start)
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<H5PLoadStatus> status = ValueNotifier(H5PLoadStatus.idle);
  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final ValueNotifier<String?> localServerUrl = ValueNotifier(null);

  void _attachLoader(H5PLoader loader) {
    _loader = loader;

    // link loader notifiers to controller ones
    loader.isLoading.addListener(() {
      isLoading.value = loader.isLoading.value;
    });
    loader.status.addListener(() {
      status.value = loader.status.value;
    });
    loader.downloadProgress.addListener(() {
      downloadProgress.value = loader.downloadProgress.value;
    });
    loader.localServerUrl.addListener(() {
      localServerUrl.value = loader.localServerUrl.value;
    });
  }

  bool get isReady => _loader != null;

  void loadH5P(String url) {
    if (!isReady) {
      debugPrint("⚠️ H5PController not ready yet.");
      return;
    }
    _loader!.loadH5P(url);
  }
}

class H5pWebView extends StatefulWidget {
  final LumiH5PController controller;

  const H5pWebView({super.key, required this.controller});

  @override
  State<H5pWebView> createState() => _H5pWebViewState();
}

class _H5pWebViewState extends State<H5pWebView> {
  late final H5PLoader _loader;

  @override
  void initState() {
    super.initState();
    _loader = H5PLoader();
    widget.controller._attachLoader(_loader);
    _loader.prepareBaseFiles();
  }

  @override
  void dispose() {
    _loader.closeServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _loader.localServerUrl,
      builder: (_, url, __) {
        if (url == null) return const SizedBox.shrink();
        return LocalH5PWebView(url: url);
      },
    );
  }
}
