// config.dart

// ignore_for_file: non_constant_identifier_names

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


int h5pPort=8030;