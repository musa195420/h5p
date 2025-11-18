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

  // MAIN STATE
  final ValueNotifier<List<H5PRequestModel>> requests =
      ValueNotifier<List<H5PRequestModel>>(const []);

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<H5PLoadStatus> status = ValueNotifier(H5PLoadStatus.idle);
  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final ValueNotifier<double> extractProgress = ValueNotifier(0.0);
  final ValueNotifier<String?> localServerUrl = ValueNotifier(null);

  LumiH5PController() {
    _attachLoader();
  }

  // --------------------
  // PERFORMANCE HELPERS
  // --------------------

  void _updateRequests(List<H5PRequestModel> list) {
    // unmodifiable list = safer + no accidental mutation
    requests.value = List.unmodifiable(list);
  }

  void _safeStartQueue() {
    if (!_isQueueRunning) _processQueue();
  }

  List<H5PRequestModel> _copy() => List<H5PRequestModel>.from(requests.value);

  // --------------------
  // ATTACH NOTIFIERS
  // --------------------

  void _attachLoader() {
    _loader.isLoading
        .addListener(() => isLoading.value = _loader.isLoading.value);
    _loader.status.addListener(() => status.value = _loader.status.value);
    _loader.downloadprogress.addListener(
        () => downloadProgress.value = _loader.downloadprogress.value);
    _loader.extractprogress.addListener(
        () => extractProgress.value = _loader.extractprogress.value);
    _loader.localServerUrl
        .addListener(() => localServerUrl.value = _loader.localServerUrl.value);
  }

  // --------------------
  // QUEUE PROCESSOR
  // --------------------

  Future<void> _processQueue() async {
    if (_isQueueRunning) return;
    _isQueueRunning = true;

    while (true) {
      final list = _copy();

      final nextIndex = list.indexWhere((e) =>
          e.status == H5PFileStatus.undefined ||
          e.status == H5PFileStatus.failed);

      if (nextIndex == -1) break;

      final original = list[nextIndex];
      list[nextIndex] = original.copyWith(status: H5PFileStatus.downloading);
      _updateRequests(list);

      try {
        final path =
            await _loader.downloadInbackground(original.url, original.refName);

        list[nextIndex] = original.copyWith(
          status: H5PFileStatus.downloaded,
          localPath: path,
        );
      } catch (e) {
        list[nextIndex] = original.copyWith(
          status: H5PFileStatus.failed,
          error: e.toString(),
        );
      }

      _updateRequests(list);
    }

    _isQueueRunning = false;
  }

  // --------------------
  // FINDING
  // --------------------

  String? findExistingRef({String? url, String? refName}) {
    for (final r in requests.value) {
      if (url != null && r.url == url) return r.refName;
      if (refName != null && r.refName == refName) return r.refName;
    }
    return null;
  }

  // --------------------
  // LOADING H5P
  // --------------------

  void loadH5P({String? refName, String? url}) async {
    String? match = findExistingRef(url: url, refName: refName);

    // nothing found
    if (url == null && match == null) {
      h5pErrorLog(message: "⚠ No URL or refName provided.");
      return;
    }

    // existing with dummy name → rename
    if (url != null && match != refName) {
      final list = _copy();
      final index = list.indexWhere((e) => e.refName == match);
      if (index != -1 && refName != null) {
        final old = list[index];
        list[index] = old.copyWith(refName: refName);
        _updateRequests(list);
        match = refName;
      }
    }

    // already exists
    if (match != null) {
      final model = requests.value.firstWhere((e) => e.refName == match);
      url = model.url;

      if (model.localPath != null && model.status == H5PFileStatus.downloaded) {
        _loader.extractAndplayH5p(model.localPath!);
        return;
      }

      // fallback: instant play & requeue
      playH5pInstantly(url, refName: refName);
      return;
    }

    // fresh load
    if (url != null) playH5pInstantly(url, refName: refName);
  }

  // --------------------
  // INSTANT PLAY
  // --------------------

  void playH5pInstantly(String url, {String? refName}) async {
    final path = await _loader.loadH5P(url);

    final list = _copy();
    list.add(H5PRequestModel(
      refName: refName ?? url.substring(url.length - 5),
      url: url,
      localPath: path,
      status: H5PFileStatus.downloaded,
    ));

    _updateRequests(list);
  }

  // --------------------
  // SHOW DOWNLOADED FILE
  // --------------------

  Future<void> showdownloadedfile(String refName) async {
    final model = requests.value.firstWhere(
      (e) => e.refName == refName,
      orElse: () => H5PRequestModel(refName: '', url: ''),
    );

    if (model.refName.isEmpty || model.localPath == null) {
      h5pErrorLog(message: "File not available: $refName");
      return;
    }

    final file = File(model.localPath!);
    if (!await file.exists()) {
      h5pErrorLog(message: "Missing file: ${model.localPath}");
      return;
    }

    // your viewer implementation…
  }

  // --------------------
  // ADD / REMOVE SINGLE
  // --------------------

  void addRequest(H5PRequestModel model, {bool remove = false}) async {
    final list = _copy();

    if (remove) {
      if (model.localPath != null) {
        unawaited(_loader.deleteFile(model.localPath!));
      }
      list.removeWhere((e) => e.refName == model.refName);
      _updateRequests(list);
      return;
    }

    final index = list.indexWhere((e) => e.refName == model.refName);
    if (index != -1) {
      list[index] = model;
    } else {
      list.add(model);
    }

    list.sort((a, b) => b.priority.compareTo(a.priority));
    _updateRequests(list);
    _safeStartQueue();
  }

  // --------------------
  // ADD / REMOVE LIST BULK
  // --------------------

  void addRequestList(
    List<H5PRequestModel> models, {
    bool remove = false,
    bool forceRefresh = false,
  }) {
    final list = _copy();

    for (final m in models) {
      if (remove) {
        if (m.localPath != null) {
          unawaited(_loader.deleteFile(m.localPath!));
        }
        list.removeWhere((e) => e.refName == m.refName);
        continue;
      }

      final index = list.indexWhere((e) => e.refName == m.refName);

      if (index != -1) {
        final old = list[index];

        if (!forceRefresh &&
            old.status == H5PFileStatus.downloaded &&
            old.url == m.url) {
          continue; // skip already downloaded
        }

        if (forceRefresh) {
          if (old.localPath != null) {
            unawaited(_loader.deleteFile(old.localPath!));
          }
          list[index] = old.copyWith(status: H5PFileStatus.undefined);
        } else {
          list[index] = m;
        }
      } else {
        list.add(m);
      }
    }

    list.sort((a, b) => b.priority.compareTo(a.priority));
    _updateRequests(list);
    _safeStartQueue();
  }

  // --------------------
  // CLEAR ALL
  // --------------------

  void clearAllRequests() {
    final list = _copy();
    for (final m in list) {
      if (m.localPath != null) {
        unawaited(_loader.deleteFile(m.localPath!));
      }
    }
    _updateRequests(const []);
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
