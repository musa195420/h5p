import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lumi_h5p/config.dart';
import 'package:lumi_h5p/h5p_loader.dart';
import 'package:lumi_h5p/local_web_view.dart';

import '../models/h5p_request_model.dart';

class LumiH5PController {
  H5PLoader? _loader;
  bool _isQueueRunning = false;
  final ValueNotifier<List<H5PRequestModel>> requests =
      ValueNotifier<List<H5PRequestModel>>([]);
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

  Future<void> _processQueue() async {
    if (_isQueueRunning) return;
    _isQueueRunning = true;

    while (true) {
      final currentList = List<H5PRequestModel>.from(requests.value);
      if (currentList.isEmpty) break;

      // Get next pending (undefined or failed)
      final nextIndex = currentList.indexWhere((e) =>
          e.status == H5PFileStatus.undefined ||
          e.status == H5PFileStatus.failed);

      if (nextIndex == -1) break;
      final model = currentList[nextIndex];

      debugPrint("🚀 Downloading queued H5P: ${model.refName}");

      // Update to downloading
      currentList[nextIndex] =
          model.copyWith(status: H5PFileStatus.downloading);
      requests.value = currentList;

      try {
        final localPath =
            await _loader!.downloadInbackground(model.url, model.refName);

        // Mark as downloaded and store local path
        currentList[nextIndex] = model.copyWith(
          status: H5PFileStatus.downloaded,
          localPath: localPath,
        );
        debugPrint("✅ Downloaded: ${model.refName} → $localPath");
      } catch (e) {
        currentList[nextIndex] = model.copyWith(
          status: H5PFileStatus.failed,
          error: e.toString(),
        );
        debugPrint("❌ Failed: ${model.refName} → $e");
      }

      requests.value = currentList;
    }

    _isQueueRunning = false;
    debugPrint("🏁 H5P queue complete");
  }

  bool get isReady => _loader != null;

  void loadH5P(String url) {
    if (!isReady) {
      debugPrint("⚠️ H5PController not ready yet.");
      return;
    }
    _loader!.loadH5P(url);
  }

  void showdownloadedfile(String refName) {
    final model = requests.value.firstWhere((e) => e.refName == refName,
        orElse: () => H5PRequestModel(refName: '', url: ''));

    if (model.refName.isEmpty || model.localPath == null) {
      debugPrint("⚠️ File not available for display: $refName");
      return;
    }

    final localFile = File(model.localPath!);
    if (!localFile.existsSync()) {
      debugPrint("⚠️ Missing file on disk: ${model.localPath}");
      return;
    }
  }

  void addRequest(H5PRequestModel model, {bool remove = false}) {
    final current = List<H5PRequestModel>.from(requests.value);

    if (remove) {
      current.removeWhere((e) => e.refName == model.refName);
      debugPrint("H5P Removed request: ${model.refName}");
    } else {
      // check if it already exists -> update instead
      final index = current.indexWhere((e) => e.refName == model.refName);
      if (index != -1) {
        current[index] = model;
        debugPrint("H5P Updated existing request: ${model.refName}");
      } else {
        current.add(model);
        debugPrint("H5P Added new request: ${model.refName}");
      }
      current.sort((a, b) => b.priority.compareTo(a.priority));
      requests.value = current;

      // Start queue if not already running
      _processQueue();
    }

    requests.value = current; // notify listeners
  }

  void addRequestList(List<H5PRequestModel> models, {bool remove = false}) {
    final current = List<H5PRequestModel>.from(requests.value);

    for (final model in models) {
      if (remove) {
        current.removeWhere((e) => e.refName == model.refName);
        debugPrint("H5P ❌ Removed request: ${model.refName}");
      } else {
        final index = current.indexWhere((e) => e.refName == model.refName);
        if (index != -1) {
          current[index] = model;
          debugPrint("H5P 🔁 Updated existing request: ${model.refName}");
        } else {
          current.add(model);
          debugPrint("H5P ➕ Added new request: ${model.refName}");
        }
        current.sort((a, b) => b.priority.compareTo(a.priority));
        requests.value = current;

        // Start queue if not already running
        _processQueue();
      }
    }

    // Sort by priority (higher first)
    current.sort((a, b) => b.priority.compareTo(a.priority));

    requests.value = current;
  }

  void clearAllRequests() {
    requests.value = [];
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
