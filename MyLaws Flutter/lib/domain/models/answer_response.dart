import 'fact.dart';
import 'checklist_step.dart';
import 'claim.dart';
import 'clarification_question.dart';
import 'user_quota.dart';

enum ProcessingEngine {
  onlineMeta,
  onlineGuidedFallback,
  offlineModel,
  offlineGuided,
  demoFixture;

  static ProcessingEngine fromString(String? val) {
    switch (val) {
      case 'online_meta':
        return ProcessingEngine.onlineMeta;
      case 'online_guided_fallback':
        return ProcessingEngine.onlineGuidedFallback;
      case 'offline_model':
        return ProcessingEngine.offlineModel;
      case 'offline_guided':
        return ProcessingEngine.offlineGuided;
      case 'demo_fixture':
      default:
        return ProcessingEngine.demoFixture;
    }
  }

  String toJson() {
    switch (this) {
      case ProcessingEngine.onlineMeta:
        return 'online_meta';
      case ProcessingEngine.onlineGuidedFallback:
        return 'online_guided_fallback';
      case ProcessingEngine.offlineModel:
        return 'offline_model';
      case ProcessingEngine.offlineGuided:
        return 'offline_guided';
      case ProcessingEngine.demoFixture:
        return 'demo_fixture';
    }
  }

  String get labelBn {
    switch (this) {
      case ProcessingEngine.onlineMeta:
        return 'অনলাইন সহকারী (Meta AI)';
      case ProcessingEngine.onlineGuidedFallback:
        return 'অনলাইন নির্দেশিকা';
      case ProcessingEngine.offlineModel:
        return 'অফলাইন মডেল';
      case ProcessingEngine.offlineGuided:
        return 'অফলাইন আইন ভাণ্ডার';
      case ProcessingEngine.demoFixture:
        return 'নমুনা মোড (Dev)';
    }
  }

  String get labelEn {
    switch (this) {
      case ProcessingEngine.onlineMeta:
        return 'Online Assistant (Meta AI)';
      case ProcessingEngine.onlineGuidedFallback:
        return 'Online Guided';
      case ProcessingEngine.offlineModel:
        return 'Offline Model';
      case ProcessingEngine.offlineGuided:
        return 'Offline Law Pack';
      case ProcessingEngine.demoFixture:
        return 'Sample Mode (Dev)';
    }
  }
}

enum Outcome {
  answered,
  clarificationNeeded,
  insufficientSources,
  unsupportedScope,
  emergencyReferral;

  static Outcome fromString(String? val) {
    switch (val) {
      case 'clarification_needed':
        return Outcome.clarificationNeeded;
      case 'insufficient_sources':
        return Outcome.insufficientSources;
      case 'unsupported_scope':
        return Outcome.unsupportedScope;
      case 'emergency_referral':
        return Outcome.emergencyReferral;
      case 'answered':
      default:
        return Outcome.answered;
    }
  }

  String toJson() {
    switch (this) {
      case Outcome.answered:
        return 'answered';
      case Outcome.clarificationNeeded:
        return 'clarification_needed';
      case Outcome.insufficientSources:
        return 'insufficient_sources';
      case Outcome.unsupportedScope:
        return 'unsupported_scope';
      case Outcome.emergencyReferral:
        return 'emergency_referral';
    }
  }
}

enum Intent {
  newIssue,
  clarificationAnswer,
  followUpExplain,
  correction,
  addFact,
  draftRequest,
  thanks,
  languageChange,
  other;

  static Intent fromString(String? val) {
    switch (val) {
      case 'clarification_answer':
        return Intent.clarificationAnswer;
      case 'follow_up_explain':
        return Intent.followUpExplain;
      case 'correction':
        return Intent.correction;
      case 'add_fact':
        return Intent.addFact;
      case 'draft_request':
        return Intent.draftRequest;
      case 'thanks':
        return Intent.thanks;
      case 'language_change':
        return Intent.languageChange;
      case 'other':
        return Intent.other;
      case 'new_issue':
      default:
        return Intent.newIssue;
    }
  }

  String toJson() {
    switch (this) {
      case Intent.newIssue:
        return 'new_issue';
      case Intent.clarificationAnswer:
        return 'clarification_answer';
      case Intent.followUpExplain:
        return 'follow_up_explain';
      case Intent.correction:
        return 'correction';
      case Intent.addFact:
        return Intent.addFact.name;
      case Intent.draftRequest:
        return 'draft_request';
      case Intent.thanks:
        return 'thanks';
      case Intent.languageChange:
        return 'language_change';
      case Intent.other:
        return 'other';
    }
  }
}

class ProblemSummary {
  final String identifiedIssue;
  final String understanding;
  final List<String> additionalInfoNeeded;

  const ProblemSummary({
    required this.identifiedIssue,
    required this.understanding,
    this.additionalInfoNeeded = const [],
  });

  factory ProblemSummary.fromJson(Map<String, dynamic> json) {
    return ProblemSummary(
      identifiedIssue: json['identifiedIssue'] as String? ?? '',
      understanding: json['understanding'] as String? ?? '',
      additionalInfoNeeded: (json['additionalInfoNeeded'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'identifiedIssue': identifiedIssue,
        'understanding': understanding,
        'additionalInfoNeeded': additionalInfoNeeded,
      };
}

class PlainLanguageExplanation {
  final String? heading;
  final String meaning;
  final List<String> userRightsAndOptions;
  final String whatToDoNext;

  const PlainLanguageExplanation({
    this.heading,
    required this.meaning,
    this.userRightsAndOptions = const [],
    required this.whatToDoNext,
  });

  factory PlainLanguageExplanation.fromJson(Map<String, dynamic> json) {
    return PlainLanguageExplanation(
      heading: json['heading'] as String?,
      meaning: json['meaning'] as String? ?? '',
      userRightsAndOptions: (json['userRightsAndOptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      whatToDoNext: json['whatToDoNext'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (heading != null) 'heading': heading,
        'meaning': meaning,
        'userRightsAndOptions': userRightsAndOptions,
        'whatToDoNext': whatToDoNext,
      };
}

class DraftOffer {
  final String prompt;
  final String documentType;
  final String documentTitle;
  final String description;

  const DraftOffer({
    required this.prompt,
    required this.documentType,
    required this.documentTitle,
    required this.description,
  });

  factory DraftOffer.fromJson(Map<String, dynamic> json) {
    return DraftOffer(
      prompt: json['prompt'] as String? ?? '',
      documentType: json['documentType'] as String? ?? 'gd',
      documentTitle: json['documentTitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'documentType': documentType,
        'documentTitle': documentTitle,
        'description': description,
      };
}

class AnswerResponse {
  final int schemaVersion;
  final String answerId;
  final String? caseId;
  final String? turnId;
  final int revision;
  final String? supersedesAnswerId;
  final ProcessingEngine engineProvenance;
  final Outcome outcome;
  final Intent intent;
  final String status;
  final List<String> questions;
  final List<ClarificationQuestion> clarificationQuestions;
  final List<Fact> userFacts;
  final List<ChecklistStep> checklist;
  final List<Claim> explanation;
  final List<String> limitations;
  final String sourcePackVersion;
  final List<String> allowedDraftOptions;
  final ProblemSummary? problemSummary;
  final PlainLanguageExplanation? plainLanguageExplanation;
  final DraftOffer? draftOffer;
  final UserQuota? userQuota;

  const AnswerResponse({
    this.schemaVersion = 1,
    required this.answerId,
    this.caseId,
    this.turnId,
    this.revision = 1,
    this.supersedesAnswerId,
    required this.engineProvenance,
    required this.outcome,
    this.intent = Intent.newIssue,
    required this.status,
    this.questions = const [],
    this.clarificationQuestions = const [],
    this.userFacts = const [],
    this.checklist = const [],
    this.explanation = const [],
    this.limitations = const [],
    required this.sourcePackVersion,
    this.allowedDraftOptions = const [],
    this.problemSummary,
    this.plainLanguageExplanation,
    this.draftOffer,
    this.userQuota,
  });

  factory AnswerResponse.fromJson(Map<String, dynamic> json) {
    return AnswerResponse(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      answerId: json['answerId'] as String? ?? '',
      caseId: json['caseId'] as String?,
      turnId: json['turnId'] as String?,
      revision: json['revision'] as int? ?? 1,
      supersedesAnswerId: json['supersedesAnswerId'] as String?,
      engineProvenance:
          ProcessingEngine.fromString(json['engineProvenance'] as String?),
      outcome: Outcome.fromString(json['outcome'] as String?),
      intent: Intent.fromString(json['intent'] as String?),
      status: json['status'] as String? ?? 'completed',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      clarificationQuestions: (json['clarificationQuestions'] as List<dynamic>?)
              ?.map((e) =>
                  ClarificationQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userFacts: (json['userFacts'] as List<dynamic>?)
              ?.map((e) => Fact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      checklist: (json['checklist'] as List<dynamic>?)
              ?.map((e) => ChecklistStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      explanation: (json['explanation'] as List<dynamic>?)
              ?.map((e) => Claim.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      limitations: (json['limitations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sourcePackVersion: json['sourcePackVersion'] as String? ?? '',
      allowedDraftOptions: (json['allowedDraftOptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      problemSummary: json['problemSummary'] != null
          ? ProblemSummary.fromJson(
              json['problemSummary'] as Map<String, dynamic>)
          : null,
      plainLanguageExplanation: json['plainLanguageExplanation'] != null
          ? PlainLanguageExplanation.fromJson(
              json['plainLanguageExplanation'] as Map<String, dynamic>)
          : null,
      draftOffer: json['draftOffer'] != null
          ? DraftOffer.fromJson(json['draftOffer'] as Map<String, dynamic>)
          : (json['allowedDraftOptions'] != null &&
                  (json['allowedDraftOptions'] as List).isNotEmpty
              ? _synthesizeDraftOffer(
                  (json['allowedDraftOptions'] as List).first.toString())
              : null),
      userQuota: json['userQuota'] != null
          ? UserQuota.fromJson(json['userQuota'] as Map<String, dynamic>)
          : null,
    );
  }

  static DraftOffer? _synthesizeDraftOffer(String type) {
    switch (type.toLowerCase()) {
      case 'dife':
        return const DraftOffer(
          prompt:
              'বকেয়া মজুরি আদায়ে কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তরে (DIFE) আনুষ্ঠানিক অভিযোগ প্রস্তুত করতে চান?',
          documentType: 'dife',
          documentTitle:
              'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE) অভিযোগ',
          description:
              'বকেয়া বেতন ও শ্রম অধিকার লঙ্ঘনের বিরুদ্ধে শ্রম আইন ২০০৬ অনুযায়ী শ্রম পরিদর্শক বরাবর অভিযোগ দাখিল করুন।',
        );
      case 'dncrp':
        return const DraftOffer(
          prompt:
              'জাতীয় ভোক্তা-অধিকার সংরক্ষণ অধিদপ্তরে আনুষ্ঠানিক অভিযোগ দাখিল করতে চান?',
          documentType: 'dncrp',
          documentTitle: 'ভোক্তা-অধিকার সংরক্ষণ অধিদপ্তর (DNCRP) অভিযোগ',
          description:
              'ভোক্তা-অধিকার সংরক্ষণ আইন ২০০৯ অনুযায়ী পণ্য বা সেবায় প্রতারণার বিরুদ্ধে প্রতিকার ও জরিমানা আদায়ের আবেদন।',
        );
      case 'domestic_violence':
        return const DraftOffer(
          prompt:
              'পারিবারিক সহিংসতা প্রতিরোধ আইনে সুরক্ষা ও ক্ষতিপূরণের দরখাস্ত প্রস্তুত করতে চান?',
          documentType: 'domestic_violence',
          documentTitle: 'পারিবারিক সহিংসতা সুরক্ষা ও ক্ষতিপূরণ আবেদন',
          description:
              'পারিবারিক সহিংসতা (প্রতিরোধ ও সুরক্ষা) আইন ২০১০ অনুযায়ী সুরক্ষা আদেশ ও অন্তর্বর্তী ক্ষতিপূরণ প্রার্থনা।',
        );
      case 'family_maintenance':
        return const DraftOffer(
          prompt:
              'পারিবারিক আদালতে দেনমোহর ও ভরণপোষণের আরজি প্রস্তুত করতে চান?',
          documentType: 'family_maintenance',
          documentTitle: 'দেনমোহর ও ভরণপোষণ মোকদ্দমার আরজি',
          description:
              'পারিবারিক আদালত আইন ২০২৩ অনুযায়ী বকেয়া দেনমোহর ও নিয়মিত খোরপোষ আদায়ের আরজি।',
        );
      case 'land_mutation':
        return const DraftOffer(
          prompt:
              'সহকারী কমিশনার (ভূমি) বরাবর ই-নামজারি ও জমাভাগ আবেদন করতে চান?',
          documentType: 'land_mutation',
          documentTitle: 'ই-নামজারি ও জমাভাগ দরখাস্ত (AC Land)',
          description:
              'রাষ্ট্রীয় অধিগ্রহণ ও প্রজাস্বত্ব আইন ১৯৫০ অনুযায়ী উত্তরাধিকার সূত্রে প্রাপ্ত জমির নামজারি আবেদন।',
        );
      case 'land_crime_complaint':
        return const DraftOffer(
          prompt:
              'কৃষিজমির অবৈধ মাটি কাটা বন্ধ ও শান্তিভঙ্গ রোধে জরুরি দরখাস্ত প্রস্তুত করতে চান?',
          documentType: 'land_crime_complaint',
          documentTitle: 'অবৈধ মাটি কাটা ও শান্তিভঙ্গ রোধে দরখাস্ত (UNO)',
          description:
              'ভূমি অপরাধ প্রতিরোধ ও প্রতিকার আইন ২০২৩ অনুযায়ী কৃষিজমির সুরক্ষা ও শান্তি বজায় রাখার আবেদন।',
        );
      case 'possession_recovery':
        return const DraftOffer(
          prompt:
              'বেদখলকৃত জমির দখল পুনরুদ্ধারে ৯ ধারার মোকদ্দমার আরজি প্রস্তুত করতে চান?',
          documentType: 'possession_recovery',
          documentTitle: 'সুনির্দিষ্ট প্রতিকার আইন ৯ ধারা দখল পুনরুদ্ধার আরজি',
          description:
              'সুনির্দিষ্ট প্রতিকার আইন ১৮৭৭ অনুযায়ী বিনা সম্মতিতে বেদখলকৃত স্থাবর সম্পত্তির দখল পাওয়ার মোকদ্দমা।',
        );
      case 'cheque_dishonour':
        return const DraftOffer(
          prompt:
              'এনআই এক্ট ১৩৮ অনুযায়ী চেক ডিজঅনারের ৩০ দিনের আইনি নোটিশ প্রস্তুত করতে চান?',
          documentType: 'cheque_dishonour',
          documentTitle: 'চেক ডিজঅনার ৩০ দিনের সংবিধিবদ্ধ আইনি নোটিশ',
          description:
              'হস্তান্তরযোগ্য দলিল আইন ১৮৮১-এর ধারা ১৩৮ অনুযায়ী ব্যাংক চেক প্রত্যাখ্যাত হওয়ায় টাকা পরিশোধের আইনি নোটিশ।',
        );
      case 'bail_petition':
        return const DraftOffer(
          prompt:
              'বিজ্ঞ ম্যাজিস্ট্রেট আদালতে নিয়মিত জামিনের দরখাস্ত প্রস্তুত করতে চান?',
          documentType: 'bail_petition',
          documentTitle: 'বিজ্ঞ আদালতে নিয়মিত জামিনের আবেদন (CrPC 496/497)',
          description:
              'ফৌজদারি কার্যবিধি আইনের ৪৯৬ ও ৪৯৭ ধারা অনুযায়ী পুলিশ হেফাজতে বা জেলহাজতে প্রেরিত আসামির নিয়মিত জামিনের আবেদন।',
        );
      case 'gd':
      default:
        return const DraftOffer(
          prompt:
              'নিরাপত্তা নিশ্চিত করতে নিকটস্থ থানায় সাধারণ ডায়েরি (GD) করতে চান?',
          documentType: 'gd',
          documentTitle: 'থানায় সাধারণ ডায়েরি (General Diary - GD)',
          description:
              'ভবিষ্যত আইনি নিরাপত্তা ও পুলিশি তদন্তের জন্য নিকটস্থ থানায় দাখিলযোগ্য সাধারণ ডায়েরির আবেদনপত্র।',
        );
    }
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'answerId': answerId,
        if (caseId != null) 'caseId': caseId,
        if (turnId != null) 'turnId': turnId,
        'revision': revision,
        if (supersedesAnswerId != null)
          'supersedesAnswerId': supersedesAnswerId,
        'engineProvenance': engineProvenance.toJson(),
        'outcome': outcome.toJson(),
        'intent': intent.toJson(),
        'status': status,
        'questions': questions,
        'clarificationQuestions':
            clarificationQuestions.map((e) => e.toJson()).toList(),
        'userFacts': userFacts.map((e) => e.toJson()).toList(),
        'checklist': checklist.map((e) => e.toJson()).toList(),
        'explanation': explanation.map((e) => e.toJson()).toList(),
        'limitations': limitations,
        'sourcePackVersion': sourcePackVersion,
        'allowedDraftOptions': allowedDraftOptions,
        if (problemSummary != null) 'problemSummary': problemSummary!.toJson(),
        if (plainLanguageExplanation != null)
          'plainLanguageExplanation': plainLanguageExplanation!.toJson(),
        if (draftOffer != null) 'draftOffer': draftOffer!.toJson(),
        if (userQuota != null) 'userQuota': userQuota!.toJson(),
      };
}
