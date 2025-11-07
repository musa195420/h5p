/// Enum representing the status of an H5P file.
enum H5PFileStatus {
  downloaded,
  failed,
  downloading,
  active,
  undefined,
}

/// Model class for handling H5P file requests.
class H5PRequestModel {
  final String refName;
  final String url;
  final String? error;
  final H5PFileStatus status;
  final int priority;

  /// Local path where the downloaded .h5p file is stored
  final String? localPath;

  H5PRequestModel({
    required this.refName,
    required this.url,
    this.error,
    this.status = H5PFileStatus.undefined,
    this.priority = 0,
    this.localPath,
  });

  /// Create from JSON
  factory H5PRequestModel.fromJson(Map<String, dynamic> json) {
    return H5PRequestModel(
      refName: json['refName'] as String,
      url: json['url'] as String,
      error: json['error'] as String?,
      status: H5PFileStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'undefined'),
        orElse: () => H5PFileStatus.undefined,
      ),
      priority: json['priority'] ?? 0,
      localPath: json['localPath'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'refName': refName,
        'url': url,
        'error': error,
        'status': status.name,
        'priority': priority,
        'localPath': localPath,
      };

  /// Copy model with updated fields
  H5PRequestModel copyWith({
    String? refName,
    String? url,
    String? error,
    H5PFileStatus? status,
    int? priority,
    String? localPath,
  }) {
    return H5PRequestModel(
      refName: refName ?? this.refName,
      url: url ?? this.url,
      error: error ?? this.error,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      localPath: localPath ?? this.localPath,
    );
  }

  @override
  String toString() {
    return 'H5PRequestModel(refName: $refName, url: $url, error: $error, '
        'status: $status, priority: $priority, localPath: $localPath)';
  }
}
