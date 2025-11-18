import 'dart:async';
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
  final ValueNotifier<double> extractProgress = ValueNotifier(0.0);
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
      extractProgress.value = _loader.extractprogress.value;
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

  void loadH5P({String? refName, String? url}) async {
    String? found = findExistingRef(url: url, refName: refName);

    if (url == null && found == null) {
      h5pErrorLog(message: "⚠️ No URL or refName provided to load H5P.");
      return;
    }

    if (url != null && (found != refName)) {
      // Then change requests[found] to refName because a dummy name was assigned earlier
      int index = requests.value.indexWhere((e) => e.refName == found);

      if (index != -1 && refName != null) {
        H5PRequestModel old = requests.value[index];

        // Replace the existing item with same URL but new refName
        requests.value[index] = H5PRequestModel(
          refName: refName,
          url: old.url,
          error: old.error,
          status: old.status,
          priority: old.priority,
          localPath: old.localPath,
        );

        // Trigger ValueNotifier update
        requests.notifyListeners();

        found = refName; // Update reference for next logic
      }
    }

    if (found != null) {
      H5PRequestModel model =
          requests.value.firstWhere((e) => e.refName == found);
      url = model.url;

      if (model.localPath != null && model.status == H5PFileStatus.downloaded) {
        h5pLog(
            message:
                "⚠️ Already downloaded. Playing local file → ${model.localPath}");
        _loader.extractAndplayH5p(model.localPath ?? "");
      } else {
        playH5pInstatnly(url, refName: refName);
        h5pLog(message: "⚠️ Exists but not downloaded fully. Re-queueing...");
      }
      return;
    } else {
      if (url != null) {
        playH5pInstatnly(url, refName: refName);
      }
    }
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

  void playH5pInstatnly(String url, {String? refName}) async {
    String? localPath = await _loader.loadH5P(url);
    List<H5PRequestModel> currentList =
        List<H5PRequestModel>.from(requests.value);
    currentList.add(H5PRequestModel(
        refName: refName ?? url.substring(url.length - 5),
        url: url,
        localPath: localPath,
        status: H5PFileStatus.downloaded));
    requests.value = List.from(currentList);
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
      if (model.localPath != null && model.localPath!.isNotEmpty) {
        unawaited(_loader.deleteFile(model.localPath ?? ""));
      }
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
    try {
      final current = List<H5PRequestModel>.from(requests.value);

      for (final model in models) {
        if (remove) {
          // 🆕 DELETE LOCAL FILE IF EXISTS
          if (model.localPath != null && model.localPath!.isNotEmpty) {
            unawaited(_loader.deleteFile(model.localPath!));
          }

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
                message:
                    "H5P ⏩ Skipped (already downloaded): ${model.refName}");
            continue;
          }

          // 🔁 If forcing refresh → reset status and trigger re-download
          if (forceRefresh) {
            current[index] = existing.copyWith(status: H5PFileStatus.undefined);

            // 🆕 If refresh: delete old file if it exists
            if (existing.localPath != null && existing.localPath!.isNotEmpty) {
              unawaited(_loader.deleteFile(existing.localPath!));
            }

            h5pLog(message: "H5P 🔄 Force refresh: ${model.refName}");
          } else {
            // Normal update
            current[index] = model;
            h5pLog(
                message: "H5P 🔁 Updated existing request: ${model.refName}");
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
    } catch (e) {
      h5pErrorLog(message: "⚠️ Error in addRequestList: $e");
    }
  }

  void clearAllRequests() {
    try {
      final current = List<H5PRequestModel>.from(requests.value);

      for (final model in current) {
        if (model.localPath != null && model.localPath!.isNotEmpty) {
          unawaited(_loader.deleteFile(model.localPath!));
        }
      }

      requests.value = [];
      h5pLog(message: "H5P 🧹 Cleared all requests + deleted files");
    } catch (e) {
      h5pErrorLog(message: "⚠️ Error in clearing request: $e");
    }
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
