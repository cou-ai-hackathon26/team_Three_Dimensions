enum InstallStatus {
  notInstalled,
  downloading,
  paused,
  ready,
  needsUpdate,
  incompatible,
  interrupted,
  corrupt,
  lowStorage,
  lowMemory,
  guidedOnly,
  failure;

  static InstallStatus fromString(String? val) {
    switch (val) {
      case 'downloading':
        return InstallStatus.downloading;
      case 'paused':
        return InstallStatus.paused;
      case 'ready':
        return InstallStatus.ready;
      case 'needs_update':
        return InstallStatus.needsUpdate;
      case 'incompatible':
        return InstallStatus.incompatible;
      case 'interrupted':
        return InstallStatus.interrupted;
      case 'corrupt':
        return InstallStatus.corrupt;
      case 'low_storage':
        return InstallStatus.lowStorage;
      case 'low_memory':
        return InstallStatus.lowMemory;
      case 'guided_only':
        return InstallStatus.guidedOnly;
      case 'failure':
        return InstallStatus.failure;
      case 'not_installed':
      default:
        return InstallStatus.notInstalled;
    }
  }

  String toJson() => name;
}

class PackState {
  final String id;
  final String? modelVersion;
  final String? legalVersion;
  final String? indexVersion;
  final String? templateVersion;
  final InstallStatus status;
  final bool compatible;
  final List<String> coverage;
  final int sizeBytes;
  final int freeBytesRequired;
  final int completedBytes;
  final String? sha256;
  final String? error;

  const PackState({
    required this.id,
    this.modelVersion,
    this.legalVersion,
    this.indexVersion,
    this.templateVersion,
    this.status = InstallStatus.notInstalled,
    this.compatible = true,
    this.coverage = const [],
    this.sizeBytes = 0,
    this.freeBytesRequired = 0,
    this.completedBytes = 0,
    this.sha256,
    this.error,
  });

  double get progress =>
      sizeBytes > 0 ? (completedBytes / sizeBytes).clamp(0.0, 1.0) : 0.0;
  double get downloadProgress => progress;
  bool get isInstalled => status == InstallStatus.ready;

  PackState copyWith({
    String? id,
    String? modelVersion,
    String? legalVersion,
    String? indexVersion,
    String? templateVersion,
    InstallStatus? status,
    bool? compatible,
    List<String>? coverage,
    int? sizeBytes,
    int? freeBytesRequired,
    int? completedBytes,
    String? sha256,
    String? error,
  }) {
    return PackState(
      id: id ?? this.id,
      modelVersion: modelVersion ?? this.modelVersion,
      legalVersion: legalVersion ?? this.legalVersion,
      indexVersion: indexVersion ?? this.indexVersion,
      templateVersion: templateVersion ?? this.templateVersion,
      status: status ?? this.status,
      compatible: compatible ?? this.compatible,
      coverage: coverage ?? this.coverage,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      freeBytesRequired: freeBytesRequired ?? this.freeBytesRequired,
      completedBytes: completedBytes ?? this.completedBytes,
      sha256: sha256 ?? this.sha256,
      error: error ?? this.error,
    );
  }

  factory PackState.fromJson(Map<String, dynamic> json) {
    return PackState(
      id: json['id'] as String? ?? '',
      modelVersion: json['modelVersion'] as String?,
      legalVersion: json['legalVersion'] as String?,
      indexVersion: json['indexVersion'] as String?,
      templateVersion: json['templateVersion'] as String?,
      status: InstallStatus.fromString(json['status'] as String?),
      compatible: json['compatible'] as bool? ?? true,
      coverage: (json['coverage'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      freeBytesRequired: json['freeBytesRequired'] as int? ?? 0,
      completedBytes: json['completedBytes'] as int? ?? 0,
      sha256: json['sha256'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (modelVersion != null) 'modelVersion': modelVersion,
        if (legalVersion != null) 'legalVersion': legalVersion,
        if (indexVersion != null) 'indexVersion': indexVersion,
        if (templateVersion != null) 'templateVersion': templateVersion,
        'status': status.toJson(),
        'compatible': compatible,
        'coverage': coverage,
        'sizeBytes': sizeBytes,
        'freeBytesRequired': freeBytesRequired,
        'completedBytes': completedBytes,
        if (sha256 != null) 'sha256': sha256,
        if (error != null) 'error': error,
      };
}
