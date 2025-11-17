import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lumi_h5p/config.dart';
import 'package:lumi_h5p/h5p_loader.dart';
import 'package:lumi_h5p/local_web_view.dart';

import '../models/h5p_request_model.dart';

class LumiH5PController {
  final H5PLoader _loader = H5PLoader();
  bool _isQueueRunning = false;
  final ValueNotifier<List<H5PRequestModel>> requests =
      ValueNotifier<List<H5PRequestModel>>([]);
  // persistent notifiers (UI can safely listen from start)
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<H5PLoadStatus> status = ValueNotifier(H5PLoadStatus.idle);
  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final ValueNotifier<double> extractprogress = ValueNotifier(0.0);
  final ValueNotifier<String?> localServerUrl = ValueNotifier(null);

  void _attachLoader() {
    // link loader notifiers to controller ones
    _loader.isLoading.addListener(() {
      isLoading.value = _loader.isLoading.value;
    });
    _loader.status.addListener(() {
      status.value = _loader.status.value;
    });

    _loader.downloadprogress.addListener(() {
      downloadProgress.value = _loader.downloadprogress.value;
    });
    _loader.extractprogress.addListener(() {
      extractprogress.value = _loader.extractprogress.value;
    });
    _loader.localServerUrl.addListener(() {
      localServerUrl.value = _loader.localServerUrl.value;
    });
  }

  Future<void> _processQueue() async {
    if (_isQueueRunning) return;
    _isQueueRunning = true;

    while (true) {
      List<H5PRequestModel> currentList =
          List<H5PRequestModel>.from(requests.value);
      if (currentList.isEmpty) break;

      // Get next pending (undefined or failed)
      final nextIndex = currentList.indexWhere((e) =>
          e.status == H5PFileStatus.undefined ||
          e.status == H5PFileStatus.failed);

      if (nextIndex == -1) break;
      final model = currentList[nextIndex];

      h5pLog(message: "🚀 Downloading queued H5P: ${model.refName}");

// FIX: update using the current list model
      currentList[nextIndex] = currentList[nextIndex].copyWith(
        status: H5PFileStatus.downloading,
      );
      requests.value = List.from(currentList);

      try {
        final localPath =
            await _loader.downloadInbackground(model.url, model.refName);

        // FIX: update using the current list model again
        currentList[nextIndex] = currentList[nextIndex].copyWith(
          status: H5PFileStatus.downloaded,
          localPath: localPath,
        );

        h5pLog(message: "✅ Downloaded: ${model.refName} → $localPath");
      } catch (e) {
        currentList[nextIndex] = currentList[nextIndex].copyWith(
          status: H5PFileStatus.failed,
          error: e.toString(),
        );
      }

      requests.value = List.from(currentList);
    }

    _isQueueRunning = false;
    h5pLog(message: "🏁 H5P queue complete");
  }

  void loadH5P(String url, {String? refName}) {
    String? found = findExistingRef(url: url, refName: refName);
    if (found != null) {
      final model = requests.value.firstWhere((e) => e.refName == found);

      if (model.localPath != null) {
        h5pLog(
            message:
                "⚠️ Already downloaded. Playing local file → ${model.localPath}");
        _loader.extractAndplayH5p(model.localPath!);
      } else {
        h5pLog(message: "⚠️ Exists but not downloaded fully. Re-queueing...");
        _loader.loadH5P(url);
      }
      return;
    }
    _loader.loadH5P(url);
  }

  String? findExistingRef({String? url, String? refName}) {
    List<H5PRequestModel> list = requests.value;

    // Check by URL
    if (url != null) {
      try {
        final match = list.firstWhere((e) => e.url == url);
        return match.refName;
      } catch (_) {}
    }

    // Check by refName
    if (refName != null) {
      try {
        final match = list.firstWhere((e) => e.refName == refName);
        return match.refName;
      } catch (_) {}
    }

    return null;
  }

  void showdownloadedfile(String refName) {
    final model = requests.value.firstWhere((e) => e.refName == refName,
        orElse: () => H5PRequestModel(refName: '', url: ''));

    if (model.refName.isEmpty || model.localPath == null) {
      h5pErrorLog(message: "⚠️ File not available for display: $refName");
      return;
    }

    final localFile = File(model.localPath!);
    if (!localFile.existsSync()) {
      h5pErrorLog(message: "⚠️ Missing file on disk: ${model.localPath}");
      return;
    }
  }

  void addRequest(H5PRequestModel model, {bool remove = false}) {
    final current = List<H5PRequestModel>.from(requests.value);

    if (remove) {
      current.removeWhere((e) => e.refName == model.refName);
      h5pLog(message: "H5P Removed request: ${model.refName}");
    } else {
      // check if it already exists -> update instead
      final index = current.indexWhere((e) => e.refName == model.refName);
      if (index != -1) {
        current[index] = model;
        h5pLog(message: "H5P Updated existing request: ${model.refName}");
      } else {
        current.add(model);
        h5pLog(message: "H5P Added new request: ${model.refName}");
      }
      current.sort((a, b) => b.priority.compareTo(a.priority));
      requests.value = current;

      // Start queue if not already running
      _processQueue();
    }

    requests.value = current; // notify listeners
  }

  void addRequestList(
    List<H5PRequestModel> models, {
    bool remove = false,
    bool forceRefresh = false,
  }) {
    final current = List<H5PRequestModel>.from(requests.value);

    for (final model in models) {
      if (remove) {
        current.removeWhere((e) => e.refName == model.refName);
        h5pLog(message: "H5P ❌ Removed request: ${model.refName}");
        continue;
      }

      final index = current.indexWhere((e) => e.refName == model.refName);

      if (index != -1) {
        final existing = current[index];

        final isSameUrl = existing.url == model.url;
        final isDownloaded = existing.status == H5PFileStatus.downloaded;

        // 🚫 Skip if already downloaded and not forcing refresh
        if (isDownloaded && isSameUrl && !forceRefresh) {
          h5pLog(
              message: "H5P ⏩ Skipped (already downloaded): ${model.refName}");
          continue;
        }

        // 🔁 If forcing refresh → reset status and trigger re-download
        if (forceRefresh) {
          current[index] = existing.copyWith(status: H5PFileStatus.undefined);
          h5pLog(message: "H5P 🔄 Force refresh: ${model.refName}");
        } else {
          // Normal update
          current[index] = model;
          h5pLog(message: "H5P 🔁 Updated existing request: ${model.refName}");
        }
      } else {
        // ➕ New request
        current.add(model);
        h5pLog(message: "H5P ➕ Added new request: ${model.refName}");
      }
    }

    // Keep priority order
    current.sort((a, b) => b.priority.compareTo(a.priority));

    requests.value = List.from(current);

    // Start queue
    _processQueue();
  }

  void clearAllRequests() {
    requests.value = [];
  }
}

class H5pWebView extends StatefulWidget {
  final LumiH5PController controller;
  final bool listenToEvents;
  final void Function(Map<String, dynamic> event)? onXApiEvent;

  const H5pWebView({
    super.key,
    required this.controller,
    this.listenToEvents = false,
    this.onXApiEvent,
  });

  @override
  State<H5pWebView> createState() => _H5pWebViewState();
}

class _H5pWebViewState extends State<H5pWebView> {
  @override
  void initState() {
    super.initState();

    widget.controller._attachLoader();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.controller._loader.localServerUrl,
      builder: (_, url, __) {
        if (url == null) return const SizedBox.shrink();
        return LocalH5PWebView(
          url: url,
          listenToEvents: widget.listenToEvents,
          onXApiEvent: widget.onXApiEvent,
        );
      },
    );
  }
}
