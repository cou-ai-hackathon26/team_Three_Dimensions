import 'fact.dart';

class AnswerRequest {
  final String requestId;
  final String? idempotencyKey;
  final String? caseId;
  final String? turnId;
  final int parentRevision;
  final String originalMessage;
  final String language;
  final String? answerLanguage;
  final List<Fact> facts;
  final List<Map<String, String>> conversationHistory;
  final String? location;
  final String? date;
  final bool recordHistory;
  final String requestedMode;

  const AnswerRequest({
    required this.requestId,
    this.idempotencyKey,
    this.caseId,
    this.turnId,
    this.parentRevision = 0,
    required this.originalMessage,
    this.language = 'bn',
    this.answerLanguage,
    this.facts = const [],
    this.conversationHistory = const [],
    this.location,
    this.date,
    this.recordHistory = true,
    this.requestedMode = 'online',
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': '1.0',
        'requestId': requestId,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
        if (caseId != null) 'caseId': caseId,
        if (turnId != null) 'turnId': turnId,
        'parentRevision': parentRevision,
        'originalMessage': originalMessage,
        'language': language,
        if (answerLanguage != null) 'answerLanguage': answerLanguage,
        'facts': facts.map((e) => e.toJson()).toList(),
        'conversationHistory': conversationHistory,
        if (location != null) 'location': location,
        if (date != null) 'date': date,
        'recordHistory': recordHistory,
        'requestedMode': requestedMode,
      };

  factory AnswerRequest.fromJson(Map<String, dynamic> json) {
    return AnswerRequest(
      requestId: json['requestId'] as String? ?? '',
      idempotencyKey: json['idempotencyKey'] as String?,
      caseId: json['caseId'] as String?,
      turnId: json['turnId'] as String?,
      parentRevision: json['parentRevision'] as int? ?? 0,
      originalMessage: json['originalMessage'] as String? ?? '',
      language: json['language'] as String? ?? 'bn',
      answerLanguage: json['answerLanguage'] as String?,
      facts: (json['facts'] as List<dynamic>?)
              ?.map((e) => Fact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      conversationHistory: (json['conversationHistory'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [],
      location: json['location'] as String?,
      date: json['date'] as String?,
      recordHistory: json['recordHistory'] as bool? ?? true,
      requestedMode: json['requestedMode'] as String? ?? 'online',
    );
  }
}
