enum FactStatus {
  userStated,
  userConfirmed,
  inferred,
  corrected,
  unknown,
  declined;

  static FactStatus fromString(String? val) {
    switch (val) {
      case 'user_stated':
        return FactStatus.userStated;
      case 'user_confirmed':
        return FactStatus.userConfirmed;
      case 'inferred':
        return FactStatus.inferred;
      case 'corrected':
        return FactStatus.corrected;
      case 'declined':
        return FactStatus.declined;
      default:
        return FactStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case FactStatus.userStated:
        return 'user_stated';
      case FactStatus.userConfirmed:
        return 'user_confirmed';
      case FactStatus.inferred:
        return 'inferred';
      case FactStatus.corrected:
        return 'corrected';
      case FactStatus.declined:
        return 'declined';
      case FactStatus.unknown:
        return 'unknown';
    }
  }
}

class Fact {
  final String fieldId;
  final dynamic value;
  final String valueType;
  final String? originalText;
  final FactStatus status;
  final String? provenance;
  final String? uncertainty;
  final String? _label;
  final bool isExtracted;

  const Fact({
    required this.fieldId,
    required this.value,
    this.valueType = 'text',
    this.originalText,
    this.status = FactStatus.userStated,
    this.provenance = 'user_input',
    this.uncertainty,
    String? label,
    this.isExtracted = false,
  }) : _label = label;

  String get id => fieldId;
  String get label => _label ?? fieldId;

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(
      fieldId: (json['fieldId'] ?? json['id']) as String? ?? '',
      value: json['value'],
      valueType: json['valueType'] as String? ?? 'text',
      originalText: json['originalText'] as String?,
      status: FactStatus.fromString(json['status'] as String?),
      provenance: json['provenance'] as String? ?? 'user_input',
      uncertainty: json['uncertainty'] as String?,
      label: json['label'] as String?,
      isExtracted: json['isExtracted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'fieldId': fieldId,
        'value': value,
        'valueType': valueType,
        'status': status.toJson(),
        'provenance': provenance,
        'isExtracted': isExtracted,
        if (_label != null) 'label': _label,
        if (originalText != null) 'originalText': originalText,
        if (uncertainty != null) 'uncertainty': uncertainty,
      };
}
