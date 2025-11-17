// config.dart

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';

enum H5PLoadStatus {
  idle,
  downloading,
  extracting,
  ready,
  error,
}

extension H5PLoadStatusText on H5PLoadStatus {
  String get H5PLABEL {
    switch (this) {
      case H5PLoadStatus.downloading:
        return "Downloading...";
      case H5PLoadStatus.extracting:
        return "Extracting...";
      case H5PLoadStatus.ready:
        return "Ready!";
      case H5PLoadStatus.error:
        return "Error";
      default:
        return "Idle";
    }
  }
}

int h5pPort = 8030;

bool h5pDebug = false;
bool h5pError = false;
void h5pLog({required String message, String? TAG}) {
  if (h5pDebug) {
    debugPrint("LUMI H5P ${TAG != null ? "[$TAG]" : ""}: $message");
  }
}

void h5pErrorLog({required String message, String? TAG}) {
  if (h5pError) {
    debugPrint("LUMI H5P Error ${TAG != null ? "[$TAG]" : ""}: $message");
  }
}
