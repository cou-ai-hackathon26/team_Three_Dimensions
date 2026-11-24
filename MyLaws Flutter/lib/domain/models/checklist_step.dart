class ChecklistStep {
  final String id;
  final String text;
  final List<String> sourceIds;
  final String? officeId;
  final String? condition;
  final bool completed;
  final List<String> requiredDocuments;
  final List<String> helpfulEvidence;
  final bool needsRecheck;
  final String? _titleBn;
  final String? _titleEn;

  const ChecklistStep({
    required this.id,
    String? text,
    String? titleBn,
    String? titleEn,
    this.sourceIds = const [],
    this.officeId,
    this.condition,
    this.completed = false,
    this.requiredDocuments = const [],
    this.helpfulEvidence = const [],
    this.needsRecheck = false,
  })  : text = text ?? titleBn ?? titleEn ?? '',
        _titleBn = titleBn,
        _titleEn = titleEn;

  String get titleBn => _titleBn ?? text;
  String get titleEn => _titleEn ?? text;

  ChecklistStep copyWith({
    String? text,
    bool? completed,
    bool? needsRecheck,
  }) {
    return ChecklistStep(
      id: id,
      text: text ?? this.text,
      sourceIds: sourceIds,
      officeId: officeId,
      condition: condition,
      completed: completed ?? this.completed,
      requiredDocuments: requiredDocuments,
      helpfulEvidence: helpfulEvidence,
      needsRecheck: needsRecheck ?? this.needsRecheck,
    );
  }

  factory ChecklistStep.fromJson(Map<String, dynamic> json) {
    return ChecklistStep(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      sourceIds: (json['sourceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      officeId: json['officeId'] as String?,
      condition: json['condition'] as String?,
      completed: json['completed'] as bool? ?? false,
      requiredDocuments: (json['requiredDocuments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      helpfulEvidence: (json['helpfulEvidence'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      needsRecheck: json['needsRecheck'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sourceIds': sourceIds,
        if (officeId != null) 'officeId': officeId,
        if (condition != null) 'condition': condition,
        'completed': completed,
        'requiredDocuments': requiredDocuments,
        'helpfulEvidence': helpfulEvidence,
        'needsRecheck': needsRecheck,
      };
}
