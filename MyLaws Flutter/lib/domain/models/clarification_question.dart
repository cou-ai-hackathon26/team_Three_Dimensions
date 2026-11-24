class ClarificationOption {
  final String value;
  final String labelEn;
  final String labelBn;

  const ClarificationOption({
    required this.value,
    required this.labelEn,
    required this.labelBn,
  });

  factory ClarificationOption.fromJson(Map<String, dynamic> json) {
    final label = json['label'];
    if (label is Map) {
      return ClarificationOption(
        value: json['value']?.toString() ?? '',
        labelEn: label['en']?.toString() ?? '',
        labelBn: label['bn']?.toString() ?? '',
      );
    }
    return ClarificationOption(
      value: json['value']?.toString() ?? '',
      labelEn: json['labelEn']?.toString() ?? '',
      labelBn: json['labelBn']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': {
          'en': labelEn,
          'bn': labelBn,
        },
      };
}

class ClarificationQuestion {
  final String id;
  final String fieldId;
  final String questionEn;
  final String questionBn;
  final String importanceEn;
  final String importanceBn;
  final String answerType;
  final List<ClarificationOption> options;
  final bool allowUnknown;

  const ClarificationQuestion({
    required this.id,
    required this.fieldId,
    required this.questionEn,
    required this.questionBn,
    required this.importanceEn,
    required this.importanceBn,
    this.answerType = 'text',
    this.options = const [],
    this.allowUnknown = true,
  });

  String get questionText => questionBn.isNotEmpty ? questionBn : questionEn;

  factory ClarificationQuestion.fromJson(Map<String, dynamic> json) {
    String qEn = '';
    String qBn = '';
    final q = json['question'];
    if (q is Map) {
      qEn = q['en']?.toString() ?? '';
      qBn = q['bn']?.toString() ?? '';
    } else {
      qEn = json['questionEn']?.toString() ?? '';
      qBn = json['questionBn']?.toString() ?? '';
    }

    String impEn = '';
    String impBn = '';
    final imp = json['importance'];
    if (imp is Map) {
      impEn = imp['en']?.toString() ?? '';
      impBn = imp['bn']?.toString() ?? '';
    } else {
      impEn = json['importanceEn']?.toString() ?? '';
      impBn = json['importanceBn']?.toString() ?? '';
    }

    return ClarificationQuestion(
      id: json['id'] as String? ?? '',
      fieldId: json['fieldId'] as String? ?? '',
      questionEn: qEn,
      questionBn: qBn,
      importanceEn: impEn,
      importanceBn: impBn,
      answerType: json['answerType'] as String? ?? 'text',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) =>
                  ClarificationOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      allowUnknown: json['allowUnknown'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fieldId': fieldId,
        'question': {
          'en': questionEn,
          'bn': questionBn,
        },
        'importance': {
          'en': importanceEn,
          'bn': importanceBn,
        },
        'answerType': answerType,
        'options': options.map((e) => e.toJson()).toList(),
        'allowUnknown': allowUnknown,
      };
}
