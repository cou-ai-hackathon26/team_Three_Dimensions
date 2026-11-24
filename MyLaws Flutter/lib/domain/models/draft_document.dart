import 'fact.dart';

enum DocumentType {
  gd,
  cheque_dishonour,
  dife,
  dncrp,
  domestic_violence,
  family_maintenance,
  land_mutation,
  land_crime_complaint,
  possession_recovery,
  bail_petition;

  static DocumentType fromString(String? val) {
    if (val == null) return DocumentType.gd;
    final normalized = val.trim().toLowerCase();
    switch (normalized) {
      case 'cheque_dishonour':
      case 'chequedishonour':
      case 'cheque':
      case 'dishonour':
        return DocumentType.cheque_dishonour;
      case 'bail_petition':
      case 'bailpetition':
      case 'bail':
        return DocumentType.bail_petition;
      case 'domestic_violence':
      case 'domesticviolence':
        return DocumentType.domestic_violence;
      case 'family_maintenance':
      case 'familymaintenance':
        return DocumentType.family_maintenance;
      case 'land_mutation':
      case 'landmutation':
        return DocumentType.land_mutation;
      case 'land_crime_complaint':
      case 'landcrimecomplaint':
        return DocumentType.land_crime_complaint;
      case 'possession_recovery':
      case 'possessionrecovery':
      case 'civil_court':
      case 'civilcourt':
        return DocumentType.possession_recovery;
      case 'dife':
        return DocumentType.dife;
      case 'dncrp':
        return DocumentType.dncrp;
      case 'gd':
      default:
        return DocumentType.gd;
    }
  }

  String toJson() => name;

  String get titleBn {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'চেক ডিজঅনার নোটিশ (এনআই এক্ট ১৩৮ অনুযায়ী ৩০ দিনের আইনি নোটিশ)';
      case DocumentType.bail_petition:
        return 'বিজ্ঞ আদালতে ফৌজদারি কার্যবিধি অনুযায়ী নিয়মিত জামিনের দরখাস্ত';
      case DocumentType.domestic_violence:
        return 'পারিবারিক সহিংসতা প্রতিরোধ ও সুরক্ষা আইনে সুরক্ষা ও ক্ষতিপূরণের দরখাস্ত';
      case DocumentType.family_maintenance:
        return 'পারিবারিক আদালত আইন অনুযায়ী দেনমোহর ও ভরণপোষণের মোকদ্দমার আরজি';
      case DocumentType.land_mutation:
        return 'উত্তরাধিকার সূত্রে প্রাপ্ত জমির ই-নামজারি ও জমাভাগ আবেদন';
      case DocumentType.land_crime_complaint:
        return 'কৃষিজমির অবৈধ মাটি কাটা বন্ধ ও শান্তিভঙ্গ রোধে জরুরি দরখাস্ত';
      case DocumentType.possession_recovery:
        return 'সুনির্দিষ্ট প্রতিকার আইনে বেদখলকৃত জমির দখল পুনরুদ্ধারের আরজি';
      case DocumentType.gd:
        return 'সাধারণ ডায়েরি (GD) করার জন্য আবেদন';
      case DocumentType.dncrp:
        return 'ভোক্তা অধিকার সংরক্ষণ আইন অনুযায়ী লিখিত অভিযোগ';
      case DocumentType.dife:
        return 'বকেয়া মজুরি ও শ্রম অধিকার সুরক্ষার লক্ষ্যে লিখিত অভিযোগ';
    }
  }

  String get titleEn {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'Statutory 30-Day Cheque Dishonour Legal Notice under Section 138 NI Act';
      case DocumentType.bail_petition:
        return 'Criminal Regular / Urgent Bail Petition under Section 496/497 CrPC';
      case DocumentType.domestic_violence:
        return 'Application for Protection & Compensation Order under Domestic Violence Act 2010';
      case DocumentType.family_maintenance:
        return 'Suit Plaint for Dower & Maintenance under Family Courts Act 2023';
      case DocumentType.land_mutation:
        return 'Application for Inheritance Land Mutation & Khatiyan Separation';
      case DocumentType.land_crime_complaint:
        return 'Complaint against Illegal Topsoil Excavation under Land Crime Redress Act 2023';
      case DocumentType.possession_recovery:
        return 'Summary Suit for Recovery of Immovable Property under Section 9 Specific Relief Act';
      case DocumentType.gd:
        return 'Application for Police General Diary (GD)';
      case DocumentType.dncrp:
        return 'Written Consumer Complaint under Consumers\' Right Protection Act 2009';
      case DocumentType.dife:
        return 'Labour Rights & Unpaid Wages Complaint to DIFE';
    }
  }

  String get category {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'notice';
      case DocumentType.bail_petition:
      case DocumentType.domestic_violence:
      case DocumentType.family_maintenance:
      case DocumentType.possession_recovery:
        return 'court';
      case DocumentType.gd:
        return 'police';
      case DocumentType.dncrp:
      case DocumentType.dife:
      case DocumentType.land_mutation:
      case DocumentType.land_crime_complaint:
        return 'admin';
    }
  }

  String get categoryLabelBn {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'আইনি নোটিশ';
      case DocumentType.bail_petition:
        return 'ম্যাজিস্ট্রেট আদালত';
      case DocumentType.domestic_violence:
        return 'আদালত পিটিশন';
      case DocumentType.family_maintenance:
        return 'পারিবারিক আদালত';
      case DocumentType.land_mutation:
        return 'ভূমি প্রশাসন';
      case DocumentType.land_crime_complaint:
        return 'উপজেলা প্রশাসন';
      case DocumentType.possession_recovery:
        return 'দেওয়ানি আদালত';
      case DocumentType.gd:
        return 'থানা ও পুলিশ';
      case DocumentType.dncrp:
        return 'ভোক্তা অধিকার';
      case DocumentType.dife:
        return 'শ্রম অধিকার';
    }
  }

  String get categoryLabelEn {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'Legal Notice';
      case DocumentType.bail_petition:
        return 'Magistrate Court';
      case DocumentType.domestic_violence:
        return 'Court Petition';
      case DocumentType.family_maintenance:
        return 'Family Court';
      case DocumentType.land_mutation:
        return 'Land Administration';
      case DocumentType.land_crime_complaint:
        return 'Upazila Administration';
      case DocumentType.possession_recovery:
        return 'Civil Court';
      case DocumentType.gd:
        return 'Police Station';
      case DocumentType.dncrp:
        return 'Consumer Rights';
      case DocumentType.dife:
        return 'Labour Inspection';
    }
  }

  String get recipientDefaultBn {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'চেক প্রদানকারী ব্যক্তি / প্রতিষ্ঠানের ব্যবস্থাপনা কর্তৃপক্ষ';
      case DocumentType.bail_petition:
        return 'বিজ্ঞ চিফ মেট্রোপলিটন / জুডিশিয়াল ম্যাজিস্ট্রেট আদালত';
      case DocumentType.domestic_violence:
        return 'বিজ্ঞ চিফ মেট্রোপলিটন / জুডিশিয়াল ম্যাজিস্ট্রেট আদালত';
      case DocumentType.family_maintenance:
        return 'বিজ্ঞ সহকারী জজ ও পারিবারিক আদালত';
      case DocumentType.land_mutation:
        return 'সহকারী কমিশনার (ভূমি) / AC Land, উপজেলা ভূমি অফিস';
      case DocumentType.land_crime_complaint:
        return 'উপজেলা নির্বাহী অফিসার (UNO) / জেলা প্রশাসক (DC)';
      case DocumentType.possession_recovery:
        return 'বিজ্ঞ সহকারী জজ আদালত';
      case DocumentType.gd:
        return 'ভারপ্রাপ্ত কর্মকর্তা (OC), সংশ্লিষ্ট থানা, বাংলাদেশ পুলিশ';
      case DocumentType.dncrp:
        return 'মহাপরিচালক / জেলা উপপরিচালক, জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তর (DNCRP)';
      case DocumentType.dife:
        return 'মহাপরিদর্শক / আঞ্চলিক উপ-মহাপরিদর্শক, কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE)';
    }
  }

  String get recipientDefaultEn {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'Drawer of Dishonoured Cheque / Debtor';
      case DocumentType.bail_petition:
        return 'Court of Chief Metropolitan / Judicial Magistrate';
      case DocumentType.domestic_violence:
        return 'Court of Chief Judicial / Metropolitan Magistrate';
      case DocumentType.family_maintenance:
        return 'Court of Assistant Judge & Family Court';
      case DocumentType.land_mutation:
        return 'Assistant Commissioner (Land), Upazila Land Office';
      case DocumentType.land_crime_complaint:
        return 'Upazila Nirbahi Officer (UNO) / Deputy Commissioner';
      case DocumentType.possession_recovery:
        return 'Court of Assistant Judge (Civil Jurisdiction)';
      case DocumentType.gd:
        return 'Officer-in-Charge (OC), Police Station';
      case DocumentType.dncrp:
        return 'Director General / Deputy Director, DNCRP';
      case DocumentType.dife:
        return 'Inspector General, DIFE (Ministry of Labour)';
    }
  }

  String get shortDescBn {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'ব্যাংক চেক বাউন্স বা প্রত্যাখ্যাত হওয়ার ৩০ দিনের মধ্যে এনআই অ্যাক্টের ১৩৮ ধারা অনুযায়ী প্রেরিত বাধ্যতামূলক রেজিস্ট্রি আইনি নোটিশ।';
      case DocumentType.bail_petition:
        return 'পুলিশ কর্তৃক গ্রেপ্তারপূর্বক জেলহাজতে প্রেরিত আসামির পক্ষে ফৌজদারি কার্যবিধির ৪৯৬/৪৯৭ ধারায় নিয়মিত জামিন প্রার্থনায় আবেদন।';
      case DocumentType.domestic_violence:
        return 'পারিবারিক সহিংসতা ও নির্যাতনের বিরুদ্ধে আদালতের সুরক্ষা আদেশ ও ক্ষতিপূরণের পিটিশন আরজি।';
      case DocumentType.family_maintenance:
        return 'স্বামীর নিকট থেকে বকেয়া দেনমোহর ও বিগত এবং চলমান খোরপোশ আদায়ের জন্য পারিবারিক আদালতের আরজি।';
      case DocumentType.land_mutation:
        return 'বাবার মৃত্যুর পর ওয়ারিশান সনদের ভিত্তিতে সহকারী কমিশনার (ভূমি) বরাবর নিজ নামে নামজারি আবেদন।';
      case DocumentType.land_crime_complaint:
        return 'ড্রেজার দিয়ে কৃষিজমির টপসয়েল কাটা বা ভরাট বন্ধে উপজেলা প্রশাসন বরাবর লিখিত অভিযোগ।';
      case DocumentType.possession_recovery:
        return 'বলপ্রয়োগে দখলচ্যুত হওয়ার ৬ মাসের মধ্যে স্বত্ব প্রমাণের বাধ্যবাধকতা ছাড়া দখল পুনরুদ্ধারের আরজি।';
      case DocumentType.gd:
        return 'হুমকি, ব্ল্যাকমেইল, দলিল বা গুরুত্বপূর্ণ সামগ্রী হারানোর বিষয়ে থানায় সাধারণ ডায়েরির আবেদন।';
      case DocumentType.dncrp:
        return 'ভেজাল, মেয়াদোত্তীর্ণ পণ্য, প্রতারণা বা অতিরিক্ত মূল্যের বিরুদ্ধে ভোক্তা অধিকারের লিখিত অভিযোগ।';
      case DocumentType.dife:
        return 'শ্রম আইন অনুযায়ী বকেয়া বেতন, ওভারটাইম ও ক্ষতিপূরণ আদায়ে শ্রম পরিদর্শক বরাবর অভিযোগ।';
    }
  }

  String get shortDescEn {
    switch (this) {
      case DocumentType.cheque_dishonour:
        return 'Mandatory 30-day statutory demand notice served to the cheque drawer under Section 138 of the Negotiable Instruments Act 1881.';
      case DocumentType.bail_petition:
        return 'Petition for criminal bail under Section 496/497 of CrPC on behalf of an accused remanded to judicial custody.';
      case DocumentType.domestic_violence:
        return 'Petition for court protection order and monetary relief against domestic violence.';
      case DocumentType.family_maintenance:
        return 'Plaint for recovering prompt/deferred dower and ongoing maintenance from husband.';
      case DocumentType.land_mutation:
        return 'Formal application for mutation of inherited land title at the AC Land office.';
      case DocumentType.land_crime_complaint:
        return 'Petition to administrative authorities to halt unauthorized topsoil dredging.';
      case DocumentType.possession_recovery:
        return 'Summary suit plaint to recover peaceful possession within 6 months of eviction.';
      case DocumentType.gd:
        return 'General Diary entry application for threats, loss of documents, or intimidation.';
      case DocumentType.dncrp:
        return 'Formal complaint against deceptive trade practices, expired goods, or overcharging.';
      case DocumentType.dife:
        return 'Administrative complaint for non-payment of wages and statutory labour entitlements.';
    }
  }

  bool get isCourtPetition => category == 'court';

  List<String> get requiredFieldKeys {
    const common = [
      'name',
      'contact',
      'address',
      'recipient',
      'place',
      'date',
      'chronology',
      'assistance',
      'applicationDate',
    ];

    switch (this) {
      case DocumentType.cheque_dishonour:
        return [
          'name',
          'contact',
          'address',
          'recipient',
          'respondent',
          'place',
          'chequeNo',
          'dishonourDate',
          'amount',
          'chronology',
          'assistance',
          'applicationDate',
        ];
      case DocumentType.bail_petition:
        return [
          'name',
          'contact',
          'address',
          'recipient',
          'respondent',
          'place',
          'date',
          'caseNo',
          'sections',
          'chronology',
          'assistance',
          'applicationDate',
        ];
      case DocumentType.domestic_violence:
      case DocumentType.family_maintenance:
        return [
          'name',
          'contact',
          'address',
          'recipient',
          'respondent',
          'place',
          'date',
          'amount',
          'chronology',
          'assistance',
          'applicationDate',
        ];
      case DocumentType.land_mutation:
        return [
          'name',
          'contact',
          'address',
          'recipient',
          'place',
          'khatianDag',
          'chronology',
          'assistance',
          'applicationDate',
        ];
      case DocumentType.land_crime_complaint:
      case DocumentType.possession_recovery:
        return [
          'name',
          'contact',
          'address',
          'recipient',
          'respondent',
          'place',
          'date',
          'khatianDag',
          'chronology',
          'assistance',
          'applicationDate',
        ];
      case DocumentType.dife:
        return [...common, 'role', 'period', 'amount'];
      case DocumentType.dncrp:
        return [...common, 'respondent', 'amount'];
      case DocumentType.gd:
        return common;
    }
  }
}

enum DraftStatus {
  inProgress,
  reviewed;

  static DraftStatus fromString(String? val) {
    switch (val) {
      case 'reviewed':
        return DraftStatus.reviewed;
      case 'inProgress':
      case 'incomplete':
      default:
        return DraftStatus.inProgress;
    }
  }
}

class DraftDocument {
  static const Map<String, String> draftFieldLabels = {
    'name': 'আবেদনকারী / বাদীর নাম',
    'contact': 'মোবাইল নম্বর',
    'address': 'বর্তমান ঠিকানা',
    'recipient': 'প্রাপক ও অধিক্ষেত্র (আদালত / দপ্তর)',
    'respondent': 'প্রতিপক্ষ / বিবাদীর নাম ও ঠিকানা',
    'place': 'ঘটনা / কর্মস্থল / নালিশি সম্পত্তির অবস্থান',
    'date': 'ঘটনার তারিখ ও সময়',
    'role': 'পদবী ও চাকরির সময়কাল',
    'period': 'বকেয়া মজুরির সময়কাল',
    'amount': 'দাবিকৃত বা ক্ষতির আর্থিক পরিমাণ',
    'khatianDag': 'খতিয়ান, দাগ, মৌজা ও ভূমির পরিমাণ',
    'chequeNo': 'চেকের নম্বর, তারিখ ও ব্যাংকের নাম',
    'dishonourDate': 'চেক ডিজঅনার মেমোর তারিখ',
    'caseNo': 'মামলা / জিআর / এজাহার (FIR) নম্বর',
    'sections': 'মামলায় আরোপিত পেনাল কোড ধারা',
    'chronology': 'ঘটনা বা বিরোধের পূর্ণ বিবরণ',
    'assistance': 'প্রার্থিত প্রতিকার বা সুরক্ষা আদেশ',
    'attachments': 'সংযুক্ত নথিপত্র',
    'applicationDate': 'আবেদনের তারিখ',
  };

  final String id;
  final String templateId;
  final String templateVersion;
  final DocumentType type;
  final List<Fact> facts;
  final String recipient;
  final List<String> paragraphs;
  final List<String> unresolvedPlaceholders;
  final String reviewStatus;
  final String sourcePackVersion;
  final String exportStatus;

  final String? _title;
  final String? _subject;
  final String? _body;
  final String? _applicantName;
  final String? _applicantPhone;
  final String? _applicantAddress;
  final String? _officeName;
  final DraftStatus? _status;

  const DraftDocument({
    required this.id,
    this.templateId = '',
    this.templateVersion = '2.0.0',
    required this.type,
    this.facts = const [],
    required this.recipient,
    this.paragraphs = const [],
    this.unresolvedPlaceholders = const [],
    this.reviewStatus = 'incomplete',
    this.sourcePackVersion = 'bd-pilot-2026-11-03.2',
    this.exportStatus = 'never_exported',
    String? title,
    String? subject,
    String? body,
    String? applicantName,
    String? applicantPhone,
    String? applicantAddress,
    String? officeName,
    DraftStatus? status,
  })  : _title = title,
        _subject = subject,
        _body = body,
        _applicantName = applicantName,
        _applicantPhone = applicantPhone,
        _applicantAddress = applicantAddress,
        _officeName = officeName,
        _status = status;

  String get title => _title ?? type.titleBn;
  String get subject =>
      _subject ?? (paragraphs.isNotEmpty ? paragraphs.first : type.titleBn);
  String get body => _body ?? paragraphs.join('\n\n');
  String get applicantName =>
      _applicantName ??
      facts
          .where((f) => f.id == 'name' || f.id == 'applicant_name')
          .firstOrNull
          ?.value
          ?.toString() ??
      '';
  String get applicantPhone =>
      _applicantPhone ??
      facts
          .where((f) => f.id == 'contact' || f.id == 'applicant_phone')
          .firstOrNull
          ?.value
          ?.toString() ??
      '';
  String get applicantAddress =>
      _applicantAddress ??
      facts
          .where((f) => f.id == 'address' || f.id == 'applicant_address')
          .firstOrNull
          ?.value
          ?.toString() ??
      '';
  String get officeName => _officeName ?? recipient;
  DraftStatus get status =>
      _status ??
      (reviewStatus == 'reviewed'
          ? DraftStatus.reviewed
          : DraftStatus.inProgress);

  bool get isReadyToExport =>
      unresolvedPlaceholders.isEmpty && reviewStatus == 'reviewed';

  DraftDocument copyWith({
    String? id,
    String? templateId,
    String? templateVersion,
    DocumentType? type,
    List<Fact>? facts,
    String? recipient,
    List<String>? paragraphs,
    List<String>? unresolvedPlaceholders,
    String? reviewStatus,
    String? sourcePackVersion,
    String? exportStatus,
    String? title,
    String? subject,
    String? body,
    String? applicantName,
    String? applicantPhone,
    String? applicantAddress,
    String? officeName,
    DraftStatus? status,
  }) {
    return DraftDocument(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      templateVersion: templateVersion ?? this.templateVersion,
      type: type ?? this.type,
      facts: facts ?? this.facts,
      recipient: recipient ?? this.recipient,
      paragraphs: paragraphs ?? this.paragraphs,
      unresolvedPlaceholders:
          unresolvedPlaceholders ?? this.unresolvedPlaceholders,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      sourcePackVersion: sourcePackVersion ?? this.sourcePackVersion,
      exportStatus: exportStatus ?? this.exportStatus,
      title: title ?? _title,
      subject: subject ?? _subject,
      body: body ?? _body,
      applicantName: applicantName ?? _applicantName,
      applicantPhone: applicantPhone ?? _applicantPhone,
      applicantAddress: applicantAddress ?? _applicantAddress,
      officeName: officeName ?? _officeName,
      status: status ?? _status,
    );
  }

  factory DraftDocument.fromJson(Map<String, dynamic> json) {
    final rawFacts = json['facts'];
    List<Fact> parsedFacts = [];
    if (rawFacts is Map && rawFacts['fields'] is List) {
      parsedFacts = (rawFacts['fields'] as List)
          .map((e) => Fact.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawFacts is List) {
      parsedFacts = rawFacts
          .map((e) => Fact.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DraftDocument(
      id: json['id'] as String? ?? '',
      templateId: json['templateId'] as String? ?? '',
      templateVersion: json['templateVersion'] as String? ?? '2.0.0',
      type: DocumentType.fromString(json['type'] as String?),
      facts: parsedFacts,
      recipient: json['recipient'] as String? ?? '',
      paragraphs: (json['paragraphs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      unresolvedPlaceholders: (json['unresolvedPlaceholders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      reviewStatus: json['reviewStatus'] as String? ?? 'incomplete',
      sourcePackVersion: json['sourcePackVersion'] as String? ?? '',
      exportStatus: json['exportStatus'] as String? ?? 'never_exported',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateId': templateId,
        'templateVersion': templateVersion,
        'type': type.toJson(),
        'facts': {
          'fields': facts.map((e) => e.toJson()).toList(),
        },
        'recipient': recipient,
        'paragraphs': paragraphs,
        'unresolvedPlaceholders': unresolvedPlaceholders,
        'reviewStatus': reviewStatus,
        'sourcePackVersion': sourcePackVersion,
        'exportStatus': exportStatus,
      };

  // =========================================================================
  // VERBATIM AUTHORITATIVE BENGALI LEGAL TEMPLATE GENERATION
  // =========================================================================

  static String _cleanAmount(String raw) {
    if (raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    if (RegExp(r'টাকা|bdt|tk|\/-', caseSensitive: false).hasMatch(trimmed)) {
      return trimmed;
    }
    return '$trimmed টাকা';
  }

  static String _cleanDate(String raw) {
    if (raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    if (trimmed.startsWith('গত ')) {
      return trimmed;
    }
    return 'গত $trimmed';
  }

  static String _resolveValue(
    String key,
    Map<String, String> values,
    List<String> unresolved,
  ) {
    final val = values[key]?.trim();
    if (val != null && val.isNotEmpty && !val.startsWith('[')) {
      return val;
    }
    unresolved.add(key);
    final label = draftFieldLabels[key] ?? key;
    return '[$label লিখুন]';
  }

  /// Returns the chronological, formatted paragraphs for the specified legal document type.
  static List<String> getTemplateParagraphs(
    DocumentType type, {
    Map<String, String>? factsMap,
    String? recipientOverride,
    List<String>? unresolvedCollector,
  }) {
    final values = Map<String, String>.from(factsMap ?? {});
    final unresolved = unresolvedCollector ?? <String>[];

    String v(String key) => _resolveValue(key, values, unresolved);

    final rawRecipient = recipientOverride?.trim().isNotEmpty == true
        ? recipientOverride!.trim()
        : values['recipient']?.trim();

    final recipient = (rawRecipient != null &&
            rawRecipient.isNotEmpty &&
            !rawRecipient.startsWith('['))
        ? rawRecipient
        : type.recipientDefaultBn;

    final rawDate = values['applicationDate']?.trim();
    final dateDisplay =
        (rawDate != null && rawDate.isNotEmpty && !rawDate.startsWith('['))
            ? rawDate
            : '[আবেদনের তারিখ লিখুন]';

    switch (type) {
      // 1. DOMESTIC VIOLENCE PROTECTION & RELIEF
      case DocumentType.domestic_violence:
        return [
          'মোকাম: $recipient',
          'পারিবারিক সহিংসতা বিবিধ পিটিশন মোকদ্দমা নং: ________________ / ২০২__',
          'দরখাস্তকারী / নির্যাতিতা:\n${v('name')}\nবর্তমান ঠিকানা: ${v('address')}\nমোবাইল নম্বর: ${v('contact')}',
          'বনাম',
          'প্রতিপক্ষ / অভিযুক্ত:\n${v('respondent')}\nঘটনা/অবস্থান: ${v('place')}',
          'বিষয়: পারিবারিক সহিংসতা (প্রতিরোধ ও সুরক্ষা) আইন, ২০১০-এর ধারা ১৪, ১৫ ও ১৬ অনুযায়ী সুরক্ষা আদেশ (Protection Order), নিরাপদ বাসস্থান (Residence Order) এবং জরুরি চিকিৎসা ও অন্তর্বর্তীকালীন আর্থিক ক্ষতিপূরণের প্রার্থনায় পিটিশন আরজি।',
          'বিনীত নিবেদন এই যে, দরখাস্তকারী নিম্নবর্ণিত মর্মে বিজ্ঞ আদালতের সদয় বিবেচনার জন্য আরজি পেশ করিতেছেন—',
          '১. পক্ষগণের পরিচয় ও পারিবারিক সম্পর্ক:\nদরখাস্তকারী একজন আইনসম্মত নাগরিক ও সংক্ষুব্ধ ব্যক্তি (Aggrieved Person) এবং প্রতিপক্ষের সহিত বৈধ পারিবারিক সম্পর্কে আবদ্ধ।',
          '২. ঘটনার সময় ও স্থান:\n${_cleanDate(v('date'))} তারিখে ${v('place')} এলাকায় প্রতিপক্ষ কর্তৃক দরখাস্তকারী শারীরিক, মানসিক ও মৌখিক পারিবারিক সহিংসতার শিকার হন।',
          '৩. সহিংসতার ধারাবাহিক বিবরণ ও নির্যাতন:\n${v('chronology')}',
          '৪. আর্থিক ক্ষতি ও চিকিৎসা ব্যয়:\nপ্রতিপক্ষের অন্যায় মারধর ও শারীরিক নির্যাতনের ফলে দরখাস্তকারীর আনুমানিক ${_cleanAmount(v('amount'))} চিকিৎসা ব্যয় ও আর্থিক ক্ষতি সাধিত হইয়াছে।',
          '৫. আশু আদালতের সুরক্ষার আবশ্যকতা:\nদরখাস্তকারীর জীবন ও শারীরিক নিরাপত্তা বর্তমানে চরম ঝুঁকিতে রহিয়াছে। অবিলম্বে আদালতের সুরক্ষা আদেশ ব্যতিরেকে দরখাস্তকারীর জীবন রক্ষা করা অসম্ভব হইয়া পড়িয়াছে।',
          'অতএব বিনীত প্রার্থনা এই যে, বিজ্ঞ আদালত উপরোক্ত বিষয়াদি পর্যালোচনা করিয়া—\nক. পারিবারিক সহিংসতা (প্রতিরোধ ও সুরক্ষা) আইন, ২০১০-এর ধারা ১৪ অনুযায়ী প্রতিপক্ষ যেন দরখাস্তকারীর সহিত কোনো প্রকার সহিংস আচরণ করিতে না পারে তজ্জন্য অবিলম্বে সুরক্ষা আদেশ জারি করিতে;\nখ. ধারা ১৫ অনুযায়ী দরখাস্তকারীর নিরাপদ বাসস্থান নিশ্চিত করিতে;\nগ. ধারা ১৬ অনুযায়ী প্রয়োজনীয় অন্তর্বর্তীকালীন চিকিৎসা ব্যয় বাবদ নগদ ক্ষতিপূরণের আদেশ দানে বিজ্ঞ আদালতের সদয় মর্জি হয়।',
          'হলফনামা / সত্যপাঠ:\nআমি শপথপূর্বক ঘোষণা করিতেছি যে, অত্র দরখাস্তের বর্ণিত তথ্যাবলি আমার জ্ঞান ও বিশ্বাসমতে সত্য এবং কোনো তথ্য গোপন করা হয় নাই।',
          'সংযুক্ত প্রমাণাদি:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. সরকারি হাসপাতালের চিকিৎসা ব্যবস্থাপত্র ও আঘাতের ছবি, ২. জাতীয় পরিচয়পত্রের অনুলিপি, ৩. স্থানীয় সালিশের তথ্য (যদি থাকে)'}',
          'আবেদনের তারিখ: $dateDisplay',
          'দরখাস্তকারীর স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'দরখাস্তকারী'})',
        ];

      // 2. FAMILY MAINTENANCE & DOWER
      case DocumentType.family_maintenance:
        return [
          'মোকাম: $recipient',
          'পারিবারিক মোকদ্দমা নং: ________________ / ২০২__',
          'বাদী:\n${v('name')}\nবর্তমান ঠিকানা: ${v('address')}\nমোবাইল নম্বর: ${v('contact')}',
          'বনাম',
          'বিবাদী:\n${v('respondent')}\nঠিকানা: ${v('place')}',
          'বিষয়: পারিবারিক আদালত আইন, ২০২৩ (২০২৩ সনের ২৬ নং আইন)-এর ধারা ৫ ও ৬ অনুযায়ী দেনমোহর এবং বিগত ও চলমান ভরণপোষণ (খোরপোশ) আদায়ের আরজি।',
          'মোকদ্দমার মূল্যায়ন: দাবিকৃত দেনমোহর ও বকেয়া খোরপোশ বাবদ মোট ${_cleanAmount(v('amount'))}। কোর্ট ফি আইন মোতাবেক নির্ধারিত ফি দাখিল করা হইল।',
          'বিনীত নিবেদন এই যে, বাদী নিম্নবর্ণিত মর্মে বিজ্ঞ আদালতের সুবিচারের জন্য আরজি দাখিল করিতেছেন—',
          '১. পক্ষগণের বিবাহ ও কাবিননামা:\nবাদী ও বিবাদীর মধ্যে ইসলামি শরিয়ত মোতাবেক রেজিস্ট্রি কাবিননামা মূলে বিবাহ অনুষ্ঠিত হয় এবং উক্ত বিবাহ অদ্যাবধি বলবৎ রহিয়াছে।',
          '২. অধিক্ষেত্র ও বাদীর বর্তমান বসবাস:\nবিবাদী দীর্ঘদিন যাবত বাদীকে অবহেলা করিয়া ভরণপোষণ প্রদানে বিরত রহিয়াছেন। পারিবারিক আদালত আইন ২০২৩-এর ধারা ৬ অনুযায়ী বাদী বর্তমানে যে এলাকায় বাবার বাড়ি বা আশ্রয়ে বসবাস করিতেছেন (${v('address')}), উক্ত এলাকা এই আদালতের আঞ্চলিক অধিক্ষেত্রভুক্ত।',
          '৩. পাওনা দেনমোহর ও খোরপোশের সুনির্দিষ্ট হিসাব:\n${_cleanAmount(v('amount'))}\nবিবাদী উপযুক্ত সামর্থ্যবান হওয়া সত্ত্বেও বাদীর আইনসঙ্গত তলবি/স্থগিত দেনমোহর এবং দৈনিক আহার-বস্ত্রের ভরণপোষণ প্রদান করিতেছেন না।',
          '৪. মোকদ্দমার কারণ (Cause of Action):\n${_cleanDate(v('date'))} তারিখে বিবাদী শেষবার বাদীকে ভরণপোষণ দিতে অস্বীকার করে এবং ${v('chronology')}',
          'অতএব বিনীত প্রার্থনা এই যে, বিজ্ঞ আদালত বাদীর আরজি গ্রহণ করিয়া—\nক. বিবাদীর নিকট হইতে বাদীর আইনসম্মত দেনমোহরের পাওনা ডিক্রি করিতে;\nখ. বিগত দিনের বকেয়া খোরপোশ এবং মোকদ্দমা চলাকালীন ও ভবিষ্যৎ নিয়মিত মাসিক উপযুক্ত হারে খোরপোশের আদেশ দানে বিজ্ঞ আদালতের সদয় মর্জি হয়।',
          'সত্যপাঠ (CPC Order VI Rule 15 ও পারিবারিক আদালত আইন ২০২৩ অনুযায়ী):\nআমি শপথপূর্বক বলিতেছি যে, অত্র আরজির ১ হইতে ৪ দফার বিবরণ আমার জ্ঞান ও বিশ্বাসমতে সত্য এবং অবশিষ্ট দফার বিবরণ আইনজীবীর পরামর্শমতে সঠিক জানিয়া অদ্য $dateDisplay তারিখে নিজ নাম দস্তখত করিলাম।',
          'সংযুক্ত দালিলিক প্রমাণাদি:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. রেজিস্ট্রি কাবিননামার সহি মোহরযুক্ত নকল, ২. ইউনিয়ন পরিষদ/পৌরসভার সালিশি নোটিশ, ৩. জাতীয় পরিচয়পত্রের অনুলিপি'}',
          'বাদীর স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'বাদী'})',
        ];

      // 3. LAND MUTATION & INHERITANCE
      case DocumentType.land_mutation:
        return [
          'বরাবর\n$recipient',
          'বিষয়: রাষ্ট্রীয় অধিগ্রহণ ও প্রজাস্বত্ব আইন, ১৯৫০ (State Acquisition & Tenancy Act, 1950)-এর ধারা ১৪৩এ এবং ভূমি ব্যবস্থাপনা ম্যানুয়াল অনুযায়ী পিতার মৃত্যুর পর ওয়ারিশান সূত্রে প্রাপ্ত জমির ই-নামজারি ও নতুন খতিয়ান প্রস্তুতের আবেদন।',
          'মহোদয়,\nবিনীত নিবেদন এই যে, আমি নিম্নস্বাক্ষরকারী আবেদনকারী আপনার কার্যালয়ের সদয় সুবিবেচনার জন্য প্রার্থনা জানাইতেছি যে—',
          '১. আবেদনকারীর পরিচয় ও ওয়ারিশান স্বত্ব:\nআমি ${v('name')}, পিতা: মরহুম পূর্ববর্তী রেকর্ডীয় মালিক। পিতার মৃত্যুর পর আমি ও অন্যান্য বৈধ ওয়ারিশগণ মুসলিম ফারায়েজ ও পারিবারিক আইন অনুযায়ী নালিশি সম্পত্তির নিরঙ্কুশ উত্তরাধিকারী হইয়াছি।',
          '২. নালিশি ভূমির তফসিল পরিচয়:\nমৌজা ও এলাকা: ${v('place')}\nখতিয়ান, দাগ ও ভূমির পরিমাণ: ${v('khatianDag')}',
          '৩. ঘটনার বিবরণ ও নামজারির প্রয়োজনীয়তা:\n${v('chronology')}\nপিতার মৃত্যুর পর নিজ নামে সরকারি রেকর্ড হালনাগাদ ও ই-নামজারি সম্পন্ন করিয়া সরকারের অনুকূলে নিয়মিত ভূমি উন্নয়ন কর (খাজনা) দাখিলা প্রদানের জন্য নামজারি আবশ্যক হইয়া পড়িয়াছে।',
          '৪. প্রার্থিত প্রতিকার:\n${values['assistance']?.isNotEmpty == true ? values['assistance']! : 'সরজমিন তদন্ত ও শুনানি অন্তে পিতার নামীয় খতিয়ান সংশোধনপূর্বক আবেদনকারীর নামে পৃথক জোত/খতিয়ান সৃজন করা হউক।'}',
          'অতএব মহোদয়ের সমীপে বিনীত প্রার্থনা, সংযুক্ত নথিপত্র ও মূল ওয়ারিশান সনদ যাচাইপূর্বক রাষ্ট্রীয় অধিগ্রহণ ও প্রজাস্বত্ব আইনের বিধান অনুযায়ী আবেদনকারীর নামে যথারীতি নামজারি খতিয়ান জারি ও ডিসিআর (DCR) প্রদানের আদেশ দানে সদয় মর্জি হয়।',
          'সংযুক্ত নথিপত্র:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. মূল ওয়ারিশান সনদ, ২. পিতার মূল মৃত্যু সনদ, ৩. সিএস/এসএ/আরএস খতিয়ান ও মূল দলিলের কপি, ৪. হালনাগাদ ভূমি উন্নয়ন কর (খাজনা) দাখিলা, ৫. এনআইডি ও ছবি'}',
          'আবেদনের তারিখ: $dateDisplay',
          'বিনীত নিবেদক: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'আবেদনকারী'})',
        ];

      // 4. LAND CRIME PREVENTION COMPLAINT
      case DocumentType.land_crime_complaint:
        return [
          'বরাবর\n$recipient',
          'বিষয়: ভূমি অপরাধ প্রতিরোধ ও প্রতিকার আইন, ২০২৩-এর ধারা ১৩ ও ১৯ অনুযায়ী কৃষিজমির উপরিভাগের উর্বর মাটি (টপসয়েল) অবৈধভাবে কাটা/ভরাট বন্ধ, পরিবেশ রক্ষা ও শান্তিভঙ্গ রোধে জরুরি অভিযোগ।',
          'মহোদয়,\nবিনীত নিবেদন এই যে, আমি ${v('name')}, বর্তমান ঠিকানা: ${v('address')}, মোবাইল: ${v('contact')}। আপনার সদয় দৃষ্টি আকর্ষণপূর্বক জানাইতেছি যে—',
          '১. ঘটনাস্থল ও নালিশি জমির তফসিল:\nঅবস্থান: ${v('place')}\nখতিয়ান ও দাগ নম্বর: ${v('khatianDag')}',
          '২. অভিযুক্ত ব্যক্তি / ভূমি দখলদার:\n${v('respondent')}',
          '৩. ভূমি অপরাধের সুস্পষ্ট বিবরণ:\n${v('chronology')}\nপ্রতিপক্ষ জেলা প্রশাসনের কোনো বৈধ অনুমতি ব্যতিরেকে ক্ষমতার অপব্যবহার করিয়া ভারী ড্রেজার ও এক্সকাভেটর দিয়া কৃষিজমির উর্বর টপসয়েল কাটিয়া বিক্রি করিতেছে / অবৈধভাবে বালু ভরাট করিয়া ফসলি জমির স্থায়ী পরিবেশগত ক্ষতিসাধন করিতেছে।',
          '৪. জরুরি প্রশাসনিক হস্তক্ষেপের আইনি আবশ্যকতা:\nঅবিলম্বে প্রশাসনিক হস্তক্ষেপ ব্যতিরেকে জমির ভৌগোলিক রূপান্তর ও আইনশৃঙ্খলার চরম অবনতি ঘটিবে। ভূমি অপরাধ প্রতিরোধ ও প্রতিকার আইন ২০২৩-এর ধারা ১৩ অনুযায়ী জেলা প্রশাসকের অনুমতি ব্যতিরেকে কৃষিজমির উপরিভাগের উর্বর মাটি কাটা বা শ্রেণি পরিবর্তন শাস্তিযোগ্য জামিন-অযোগ্য অপরাধ।',
          'অতএব মহোদয়ের নিকট আকুল প্রার্থনা, অবিলম্বে সরেজমিন মোবাইল কোর্ট (ভ্রাম্যমাণ আদালত) পরিচালনাপূর্বক অবৈধ মাটি কাটার কাজে ব্যবহৃত ড্রেজার ও যানবাহন জব্দ করিয়া কাজ তাৎক্ষণিক বন্ধের নির্দেশ দানে এবং দোষীদের বিরুদ্ধে আইনানুগ ব্যবস্থা গ্রহণে সদয় মর্জি হয়।',
          'সংযুক্ত প্রমাণাদি:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. ভূমির মালিকানার খতিয়ান ও খাজনা দাখিলা, ২. ঘটনাস্থলে অবৈধ মাটি কাটার স্পষ্ট স্থিরচিত্র ও ভিডিও'}',
          'আবেদনের তারিখ: $dateDisplay',
          'আবেদনকারীর স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'আবেদনকারী'})',
        ];

      // 5. SUMMARY SUIT FOR POSSESSION RECOVERY
      case DocumentType.possession_recovery:
        return [
          'মোকাম: $recipient',
          'দেওয়ানি মোকদ্দমা নং: ________________ / ২০২__',
          'বাদী:\n${v('name')}\nবর্তমান ঠিকানা: ${v('address')}, মোবাইল: ${v('contact')}',
          'বনাম',
          'বিবাদী:\n${v('respondent')}\nঠিকানা: ${v('place')}',
          'বিষয়: সুনির্দিষ্ট প্রতিকার আইন, ১৮৭৭ (Specific Relief Act, 1877)-এর ধারা ৯ অনুযায়ী স্বত্ব প্রমাণ ব্যতিরেকে বলপ্রয়োগে বেদখলকৃত স্থাবর সম্পত্তির দখল পুনরুদ্ধারের সংক্ষিপ্ত দেওয়ানি আরজি।',
          'মোকদ্দমার মূল্যায়ন: নালিশি জমির বার্ষিক মুনাফা/মূল্যমান বিবেচনাপূর্বক সুনির্দিষ্ট প্রতিকার আইনের ৯ ধারা অনুযায়ী নির্ধারিত অ্যাডভেলোরেম কোর্ট ফির অর্ধেক ফি দাখিল করা হইল।',
          'বিনীত নিবেদন এই যে, বাদী নিম্নরূপ আর্জি পেশ করিতেছেন—',
          '১. বাদীর পূর্ববর্তী শান্তিপূর্ণ অবিচ্ছিন্ন দখল:\nবাদী নালিশি তফসিলে বর্ণিত ভূমিতে দীর্ঘকাল যাবৎ বৈধ, প্রকাশ্য ও শান্তিপূর্ণ দখলে নিয়োজিত ছিলেন।',
          '২. বলপ্রয়োগে বেআইনি দখলচ্যুতির বিবরণ ও সংবিধিবদ্ধ ৬ মাসের তামাদি সীমা:\n${_cleanDate(v('date'))} তারিখে বিবাদী বাদীর বিনা সম্মতিতে এবং উপযুক্ত আইনের প্রক্রিয়া ব্যতিরেকে লাঠিয়াল বাহিনী দ্বারা জোরপূর্বক বাদীর বৈধ দখল উচ্ছেদ করিয়া সম্পত্তি দখল করিয়াছে। ঘটনাটি তামাদি আইনের ৩ অনুচ্ছেদ ও ৯ ধারা অনুযায়ী ৬ মাসের সংবিধিবদ্ধ সময়সীমার মধ্যে সংঘটিত হইয়াছে।',
          '৩. ঘটনার পটভূমি ও দখলচ্যুতি:\n${v('chronology')}',
          '৪. নালিশি সম্পত্তির তফসিল ও চৌহদ্দি:\nমৌজা ও এলাকা: ${v('place')}\nখতিয়ান ও দাগ নম্বর: ${v('khatianDag')}\nচৌহদ্দি: উত্তরে বিবাদীর জমি, দক্ষিণে রাস্তা, পূর্বে সরকারি খাল, পশ্চিমে অপর জোতদার।',
          '৫. স্বত্ব প্রমাণ ব্যতিরেকে দখল পুনরুদ্ধারের অধিকার:\nসুনির্দিষ্ট প্রতিকার আইনের ধারা ৯-এর বিধান অনুযায়ী স্বত্ব বা টাইটেল প্রমাণ ব্যতিরেকে কেবল বেআইনি উচ্ছেদ ও পূর্ববর্তী শান্তিপূর্ণ দখলের ভিত্তিতে বাদীর দখল প্রত্যর্পণ পাইবার আইনানুগ অধিকার রহিয়াছে।',
          'অতএব বিনীত প্রার্থনা এই যে, বিজ্ঞ আদালত নালিশি সম্পত্তির দখল বিবাদীর নিকট হইতে উচ্ছেদ করিয়া বাদীর অনুকূলে দখল প্রত্যর্পণ করার ডিক্রি দানে বিজ্ঞ আদালতের সদয় মর্জি হয়।',
          'সত্যপাঠ (Verification CPC Order VI Rule 15):\nআমি শপথপূর্বক বলিতেছি যে, অত্র আরজির ১ হইতে ৫ দফার বিবরণ আমার জ্ঞান ও চাক্ষুষ বাস্তব সত্য এবং অদ্য $dateDisplay তারিখে সুস্থ মস্তিষ্কে অত্র আরজিতে নিজ নাম দস্তখত করিলাম।',
          'সংযুক্ত প্রমাণাদি:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. পূর্ববর্তী দখলের প্রমাণপত্র (হোল্ডিং ট্যাক্স রসিদ, বিদ্যুৎ বিলের কপি), ২. স্থানীয় গণ্যমান্য ব্যক্তিদের প্রত্যয়নপত্র, ৩. থানায় দায়েরকৃত পূর্বের অভিযোগের কপি'}',
          'বাদীর স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'বাদী'})',
        ];

      // 6. POLICE GENERAL DIARY (GD)
      case DocumentType.gd:
        return [
          'বরাবর\n$recipient',
          'বিষয়: ভবিষ্যৎ নিরাপত্তা বিধান, সতর্কতা ও আইনি সুরক্ষার্থে সাধারণ ডায়েরি (GD) ভুক্তির আবেদন।',
          'মহোদয়,\nবিনীত নিবেদন এই যে, আমি নিম্নস্বাক্ষরকারী আবেদনকারী আপনার থানার সদয় অবগতির জন্য জানাইতেছি যে—',
          '১. আবেদনকারীর পরিচয়:\nনাম: ${v('name')}\nবর্তমান ঠিকানা: ${v('address')}\nমোবাইল নম্বর: ${v('contact')}',
          '২. প্রতিপক্ষ / অভিযুক্ত / সন্দেহভাজনদের বিবরণ:\n${values['respondent']?.isNotEmpty == true ? values['respondent']! : 'জ্ঞাত / অজ্ঞাতনামা ব্যক্তিগণ'}',
          '৩. ঘটনার সময় ও স্থান:\n${_cleanDate(v('date'))} তারিখে ${v('place')} এলাকায়।',
          '৪. ঘটনার বিস্তারিত বিবরণ ও ভীতির কারণ:\n${v('chronology')}\nউক্ত ঘটনার প্রেক্ষিতে আমি ও আমার পরিবারের সদস্যগণ চরম নিরাপত্তাহীনতায় ভুগিতেছি এবং ভবিষ্যতে প্রাণনাশ বা জানমালের গুরুতর ক্ষতির আশঙ্কা করিতেছি।',
          '৫. প্রার্থিত প্রতিকার:\n${values['assistance']?.isNotEmpty == true ? values['assistance']! : 'উপরোক্ত বিষয়টি থানার সাধারণ ডায়েরি (GD) রেজিস্টারে যথাযথভাবে লিপিবদ্ধ করত আমাকে একটি জিডি নম্বর সম্বলিত অনুলিপি প্রদান করিতে এবং প্রয়োজনীয় পুলিশি নজরদারি ও আইনি সুরক্ষার ব্যবস্থা গ্রহণে আপনার সদয় মর্জি হয়।'}',
          'অতএব মহোদয়ের সমীপে বিনীত প্রার্থনা, উক্ত বিষয়টি সাধারণ ডায়েরি হিসেবে নথিভুক্ত করিয়া আইনগত ব্যবস্থা গ্রহণে আপনার সদয় মর্জি হয়।',
          'সংযুক্ত নথিপত্র:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : 'জাতীয় পরিচয়পত্রের অনুলিপি ও সংশ্লিষ্ট প্রমাণের কপি'}',
          'আবেদনের তারিখ: $dateDisplay',
          'আবেদনকারীর স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'আবেদনকারী'})',
        ];

      // 7. CONSUMER RIGHTS COMPLAINT (DNCRP)
      case DocumentType.dncrp:
        return [
          'বরাবর\n$recipient',
          'বিষয়: ভোক্তা অধিকার সংরক্ষণ আইন, ২০০৯-এর ধারা ৬০ অনুযায়ী প্রতারণা, ভেজাল/মেয়াদোত্তীর্ণ পণ্য বিক্রয় এবং আর্থিক ক্ষতির বিরুদ্ধে লিখিত অভিযোগ।',
          'মহোদয়,\nবিনীত নিবেদন এই যে, আমি একজন সংক্ষুব্ধ সাধারণ ভোক্তা হিসেবে আপনার দপ্তরে সুবিচারের জন্য নিম্নরূপ অভিযোগ পেশ করিতেছি—',
          '১. অভিযোগকারীর বিবরণ:\nনাম: ${v('name')}\nবর্তমান ঠিকানা: ${v('address')}\nমোবাইল: ${v('contact')}',
          '২. অভিযুক্ত প্রতিষ্ঠান / বিক্রেতার বিবরণ:\n${v('respondent')}\nপ্রতিষ্ঠানের অবস্থান / ঠিকানা: ${v('place')}',
          '৩. পণ্য/সেবা ক্রয়ের তারিখ ও ক্যাশ মেমোর বিবরণ:\nক্রয়ের তারিখ: ${_cleanDate(v('date'))}\nপ্রতারিত/দাবিকৃত আর্থিক পরিমাণ: ${_cleanAmount(v('amount'))}',
          '৪. ভোক্তা অধিকার লঙ্ঘনের সুনির্দিষ্ট অভিযোগ:\n${v('chronology')}\nঅভিযুক্ত প্রতিষ্ঠান ভোক্তা অধিকার সংরক্ষণ আইন, ২০০৯-এর ধারা ৩৭/৩৮/৪০/৪১/৪২/৪৫ অনুযায়ী নির্ধারিত আইন লঙ্ঘন করিয়া প্রতারণামূলক ব্যবসা পরিচালনা করিয়াছে।',
          '৫. সংবিধিবদ্ধ ৩০ দিনের সময়সীমা ও ২৫% প্রণোদনা:\nধারা ৬০ অনুযায়ী ঘটনার ৩০ (ত্রিশ) দিনের মধ্যে অত্র অভিযোগ দাখিল করা হইল। এছাড়াও ধারা ৭৬(৪) অনুযায়ী আদায়কৃত প্রশাসনিক জরিমানার ২৫% অংশ অভিযোগকারী হিসেবে পাওয়ার আইনগত অধিকার রহিয়াছে।',
          '৬. প্রার্থিত প্রতিকার:\n${values['assistance']?.isNotEmpty == true ? values['assistance']! : 'অভিযোগটি আমলে নিয়া অভিযুক্ত প্রতিষ্ঠানের বিরুদ্ধে তদন্তপূর্বক আইনানুগ ব্যবস্থা গ্রহণ, আর্থিক জরিমানা আরোপ এবং ধারা ৭৬(৪) অনুযায়ী আরোপিত জরিমানার ২৫% অভিযোগকারীকে প্রদানের আদেশ দানে সদয় মর্জি হয়।'}',
          'অতএব মহোদয়ের নিকট বিনীত প্রার্থনা, ন্যায়বিচার নিশ্চিতকল্পে প্রয়োজনীয় আইনানুগ ব্যবস্থা গ্রহণে সদয় মর্জি হয়।',
          'সংযুক্ত দালিলিক প্রমাণাদি:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. ক্রয়ের মূল ক্যাশ মেমো / মানি রসিদ, ২. পণ্যের মোড়ক ও মেয়াদোত্তীর্ণ তারিখের স্পষ্ট ছবি, ৩. জাতীয় পরিচয়পত্রের অনুলিপি'}',
          'আবেদনের তারিখ: $dateDisplay',
          'অভিযোগকারীর স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'অভিযোগকারী'})',
        ];

      // 8. LABOUR INSPECTION COMPLAINT (DIFE)
      case DocumentType.dife:
        final respondentVal = values['respondent']?.isNotEmpty == true
            ? values['respondent']!
            : (values['place']?.isNotEmpty == true
                ? values['place']!
                : 'কারখানা কর্তৃপক্ষ / মালিকপক্ষ');
        return [
          'বরাবর\n$recipient',
          'বিষয়: বাংলাদেশ শ্রম আইন, ২০০৬-এর ধারা ১২১, ১২৩ ও ১৩২ অনুযায়ী বকেয়া মজুরি ও আইনানুগ ক্ষতিপূরণ আদায়ের লক্ষ্যে লিখিত অভিযোগ।',
          'মহোদয়,\nবিনীত নিবেদন এই যে, আমি নিম্নস্বাক্ষরকারী শ্রমিক আপনার অধিদপ্তরের সদয় হস্তক্ষেপ ও আইনানুগ প্রতিকার প্রার্থনায় জানাইতেছি যে—',
          '১. শ্রমিকের পরিচয় ও চাকরির বিবরণ:\nনাম: ${v('name')}\nবর্তমান ঠিকানা: ${v('address')}, মোবাইল: ${v('contact')}\nপদবী ও চাকরির সময়কাল: ${v('role')}',
          '২. অভিযুক্ত কারখানা / প্রতিষ্ঠানের বিবরণ:\nমালিক/ব্যবস্থাপনা কর্তৃপক্ষ: $respondentVal\nকারখানা/প্রতিষ্ঠানের অবস্থান: ${v('place')}',
          '৩. বকেয়া মজুরির সুনির্দিষ্ট হিসাব ও সময়কাল:\nবকেয়ার সময়কাল: ${v('period')}\nসর্বমোট বকেয়া মজুরির পরিমাণ: ${_cleanAmount(v('amount'))}',
          '৪. শ্রম আইন লঙ্ঘনের বিবরণ:\n${v('chronology')}\nবাংলাদেশ শ্রম আইন ২০০৬-এর ১২১ ও ১২৩ ধারা অনুযায়ী পরবর্তী মাসের ৭ কার্যদিবসের মধ্যে মজুরি পরিশোধের আইনি বাধ্যবাধকতা থাকা সত্ত্বেও মালিকপক্ষ তাহা অমান্য করিয়াছে। বারবার অনুরোধ সত্ত্বেও মজুরি পরিশোধ করা হয় নাই।',
          '৫. প্রার্থিত প্রতিকার:\n${values['assistance']?.isNotEmpty == true ? values['assistance']! : 'উক্ত প্রতিষ্ঠানে অবিলম্বে শ্রম পরিদর্শক প্রেরণপূর্বক সরজমিন পরিদর্শন করিয়া শ্রম আইনের বিধান অনুযায়ী শ্রমিকের সমুদয় বকেয়া মজুরি আদায়ের নির্দেশ দানে এবং সংশ্লিষ্ট প্রতিষ্ঠানের বিরুদ্ধে আইনি ব্যবস্থা গ্রহণে আপনার সদয় মর্জি হয়।'}',
          'অতএব মহোদয়ের নিকট আকুল প্রার্থনা, উক্ত বিষয়ে যথাযথ আইনানুগ ব্যবস্থা গ্রহণে আপনার সদয় মর্জি হয়।',
          'সংযুক্ত নথিপত্র:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. কারখানা পরিচয়পত্র (ID Card) ও নিয়োগপত্র, ২. পূর্ববর্তী বেতন রসিদ বা ব্যাংক স্টেটমেন্ট, ৩. এনআইডি কপি'}',
          'আবেদনের তারিখ: $dateDisplay',
          'অভিযোগকারী শ্রমিকের স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'অভিযোগকারী শ্রমিক'})',
        ];

      // 9. CHEQUE DISHONOUR 30-DAY STATUTORY LEGAL NOTICE (NI ACT 138)
      case DocumentType.cheque_dishonour:
        final chequeNoVal = values['chequeNo']?.isNotEmpty == true
            ? values['chequeNo']!
            : '[চেকের নম্বর, তারিখ ও ব্যাংকের নাম লিখুন]';
        final dishonourDateVal = values['dishonourDate']?.isNotEmpty == true
            ? values['dishonourDate']!
            : '[চেক ডিজঅনার মেমোর তারিখ লিখুন]';
        return [
          'রেজিস্ট্রি এ/ডি ডাকযোগে প্রেরিত সংবিধিবদ্ধ আইনি নোটিশ',
          'প্রাপক (নোটিশ গ্রহীতা / দেনাদার):\n${v('recipient')}\nঠিকানা: ${v('respondent')}',
          'প্রেরক (চেক প্রাপক / পাওনাদার):\n${v('name')}\nঠিকানা: ${v('address')}\nমোবাইল নম্বর: ${v('contact')}',
          'বিষয়: ১৮৮১ সালের হস্তান্তরযোগ্য দলিল আইন (Negotiable Instruments Act, 1881)-এর ধারা ১৩৮ অনুযায়ী ইস্যুকৃত ব্যাংক চেক ডিজঅনার বা প্রত্যাখ্যাত হওয়ায় টাকা পরিশোধের জন্য সংবিধিবদ্ধ ৩০ (ত্রিশ) দিনের আইনি নোটিশ।',
          'জনাব / মহোদয়,\nআমার পক্ষ হইতে আপনার অবগতি ও অবিলম্বে প্রয়োজনীয় ব্যবস্থা গ্রহণের নিমিত্তে এই মর্মে সংবিধিবদ্ধ আইনি নোটিশ প্রদান করা যাইতেছে যে—',
          '১. দেনা ও চেক ইস্যুর পটভূমি:\nআপনার সহিত ব্যবসায়িক লেনদেন ও পাওনা বাবদ আপনি অত্র নোটিশ প্রেরকের অনুকূলে ${_cleanAmount(v('amount'))} পরিশোধের নিমিত্তে একটি অ্যাকাউন্ট পেয়ি চেক প্রদান করেন। চেকের বিবরণ: $chequeNoVal।',
          '২. ব্যাংকে উপস্থাপন ও অপর্যাপ্ত তহবিল হেতু ডিজঅনার:\nউক্ত চেকটি নগদায়নের জন্য নোটিশ প্রেরক নিজ ব্যাংক হিসাবে জমা প্রদান করিলে সংশ্লিষ্ট ব্যাংক শাখা (${v('place')}) কর্তৃক গত $dishonourDateVal তারিখে "তহবিল অপ্রতুল" (Insufficient Funds / Exceeds Arrangement) মর্মে চেকটি ডিজঅনার করে এবং ব্যাংক মেমোর মাধ্যমে ফেরত প্রদান করে।',
          '৩. চেক ডিজঅনার হওয়ার কারণ ও লেনদেনের বিবরণ:\n${v('chronology')}',
          '৪. সংবিধিবদ্ধ ৩০ দিনের আইনি আলটিমেটাম:\nহস্তান্তরযোগ্য দলিল আইন, ১৮৮১ (সংশোধিত)-এর ধারা ১৩৮(খ) অনুযায়ী অত্র আইনি নোটিশ প্রাপ্তির ৩০ (ত্রিশ) দিনের মধ্যে চেকের সম্পূর্ণ টাকা (${_cleanAmount(v('amount'))}) নোটিশ প্রেরককে পরিশোধ করার জন্য আপনাকে চূড়ান্তভাবে অনুরোধ করা যাইতেছে।',
          '৫. আইনানুগ ব্যবস্থার সতর্কতা:\nযদি আপনি অত্র নোটিশ গ্রহণের ৩০ (ত্রিশ) দিনের মধ্যে উক্ত সমুদয় টাকা পরিশোধে ব্যর্থ হন, তবে আপনার বিরুদ্ধে এনআই অ্যাক্টের ১৩৮ ধারা অনুযায়ী বিজ্ঞ আদালতে ফৌজদারি মোকদ্দমা দায়ের করা হইবে। উক্ত অপরাধে আইনের বিধান অনুযায়ী আপনার অনধিক ১ (এক) বৎসর কারাদণ্ড বা চেকের টাকার ৩ (তিন) গুণ পর্যন্ত অর্থদণ্ড বা উভয় দণ্ড হইতে পারে।',
          'সংযুক্ত প্রমাণাদি:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. ডিজঅনারকৃত মূল চেকের সত্যায়িত ফটোকপি, ২. ব্যাংকের ডিজঅনার স্লিপ/মেমোর কপি, ৩. নোটিশ প্রেরকের এনআইডি কপি'}',
          'নোটিশ প্রেরণের তারিখ: $dateDisplay',
          'নোটিশ প্রেরকের স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'নোটিশ প্রেরক / আইনজীবী'})',
        ];

      // 10. CRIMINAL REGULAR / URGENT BAIL PETITION (CRPC 496/497)
      case DocumentType.bail_petition:
        final caseNoVal = values['caseNo']?.isNotEmpty == true
            ? values['caseNo']!
            : '[মামলা / জিআর / এফআইআর নম্বর লিখুন]';
        final sectionsVal = values['sections']?.isNotEmpty == true
            ? values['sections']!
            : '[পেনাল কোডের ধারা, যেমন ধারা ৩৭৯/৪২০/৩২৩/৫০৬ লিখুন]';
        return [
          'মোকাম: $recipient',
          'ফৌজদারি বিবিধ / নিয়মিত জামিন দরখাস্ত নং: ________________ / ২০২__',
          'থানা: ${v('place')}, মামলা / জিআর নং: $caseNoVal, ধারা: $sectionsVal',
          'সরকার / রাষ্ট্রপক্ষ .................................................... বাদী',
          '— বনাম —',
          'আসামি:\n${v('name')}\nবর্তমান অবস্থান: বিজ্ঞ আদালতের মাধ্যমে জেলহাজতে / পুলিশ হেফাজতে\nস্থায়ী ঠিকানা: ${v('address')}',
          'বিষয়: ফৌজদারি কার্যবিধি, ১৮৯৮ (CrPC)-এর ধারা ৪৯৬ ও ৪৯৭ অনুযায়ী হাজতি আসামির নিয়মিত / অন্তর্বর্তীকালীন জামিন মঞ্জুরের সনির্বন্ধ প্রার্থনা।',
          'বিনীত নিবেদন এই যে, অত্র মামলার হাজতি আসামির পক্ষে বিজ্ঞ আদালতের সুবিচারের জন্য নিম্নরূপ আবেদন পেশ করা হইতেছে—',
          '১. গ্রেপ্তারের পটভূমি ও আসামির নির্দোষিতা:\nআসামিকে ${_cleanDate(v('date'))} তারিখে সংশ্লিষ্ট থানা পুলিশ কর্তৃক গ্রেপ্তারপূর্বক বিজ্ঞ আদালতে সোপর্দ করা হয় এবং বর্তমানে আসামি জেলহাজতে আটক রহিয়াছেন। এজাহারে আনীত অভিযোগ সম্পূর্ণ মিথ্যা, বানোয়াট ও উদ্দেশ্যপ্রণোদিত। আসামি উক্ত ঘটনার সহিত কোনোভাবেই জড়িত নহেন এবং শত্রুভাবাপন্ন হইয়া তাঁহাকে মামলায় জড়ানো হইয়াছে।',
          '২. মামলার প্রকৃত ঘটনা ও আত্মপক্ষ সমর্থন:\n${v('chronology')}',
          '৩. আসামির সামাজিক মর্যাদা ও দায়বদ্ধতা:\nআসামি সমাজের একজন শান্তিপ্রিয়, আইনমান্যকারী নাগরিক। তিনি পরিবারের একমাত্র উপার্জনক্ষম ব্যক্তি / বয়োবৃদ্ধ / গুরুতর অসুস্থ / নিয়মিত শিক্ষার্থী। আসামির অনুপস্থিতিতে তাঁহার পরিবার চরম অর্থকষ্ট ও মানবিক বিপর্যয়ের সম্মুখীন হইয়াছে।',
          '৪. সাক্ষ্য বিনষ্ট না করা ও শর্তপালনের নিশ্চয়তা:\nআসামি আদালতের কোনো বিচারিক প্রক্রিয়ায় হস্তক্ষেপ বা সাক্ষ্য প্রমাণ বিনষ্ট করিবেন না। বিজ্ঞ আদালত কর্তৃক নির্ধারিত যেকোনো শর্তে স্থানীয় জামিনদারগণের মাধ্যমে বেইল বন্ড (Bail Bond) দাখিলে প্রস্তুত রহিয়াছেন এবং তিনি কোনো অবস্থাতেই পলাতক হইবেন না।',
          'অতএব বিনীত প্রার্থনা এই যে, বিজ্ঞ আদালত উপরোক্ত পারিপার্শ্বিক অবস্থা, নথিপত্র এবং আইনের বিধান বিবেচনাপূর্বক মোকদ্দমা নিষ্পত্তির চূড়ান্ত দিন পর্যন্ত হাজতি আসামির জামিন মঞ্জুর করিতে বিজ্ঞ আদালতের সদয় মর্জি হয়।',
          'হলফনামা / তদ্বিরকারীর সত্যপাঠ:\nআমি শপথপূর্বক বলিতেছি যে, আমি আসামির আত্মীয়/তদ্বিরকারী এবং অত্র দরখাস্তের বর্ণিত তথ্যাবলি আমার জ্ঞান ও বিশ্বাসমতে সত্য।',
          'সংযুক্ত নথিপত্র:\n${values['attachments']?.isNotEmpty == true ? values['attachments']! : '১. এজাহার (FIR) ও জব্দ তালিকার অনুলিপি, ২. চিকিৎসা সনদপত্র / শিক্ষার্থী পরিচয়পত্র (প্রযোজ্য ক্ষেত্রে), ৩. স্থানীয় স্থায়ী ঠিকানার প্রমাণপত্র ও এনআইডি'}',
          'আবেদনের তারিখ: $dateDisplay',
          'আবেদনকারী / নিয়োজিত আইনজীবীর স্বাক্ষর: ____________________\n(${values['name']?.isNotEmpty == true ? values['name']! : 'আসামির পক্ষে আইনজীবী / তদ্বিরকারী'})',
        ];
    }
  }

  /// Returns the complete assembled Bengali legal plain text of the document.
  static String getTemplateText(
    DocumentType type, {
    Map<String, String>? factsMap,
    String? recipientOverride,
  }) {
    return getTemplateParagraphs(
      type,
      factsMap: factsMap,
      recipientOverride: recipientOverride,
    ).join('\n\n');
  }

  /// Creates a ready-to-use DraftDocument instance with pre-populated paragraphs and facts.
  static DraftDocument createDefault({
    required DocumentType type,
    List<Fact>? facts,
    String? id,
    String? recipientOverride,
  }) {
    final unresolved = <String>[];
    final factsList = facts ?? const [];
    final factsMap = <String, String>{};
    for (final f in factsList) {
      if (f.value != null) {
        factsMap[f.fieldId] = f.value.toString();
      }
    }

    final paragraphs = getTemplateParagraphs(
      type,
      factsMap: factsMap,
      recipientOverride: recipientOverride,
      unresolvedCollector: unresolved,
    );

    final resolvedRecipient = recipientOverride?.isNotEmpty == true
        ? recipientOverride!
        : (factsMap['recipient']?.isNotEmpty == true
            ? factsMap['recipient']!
            : type.recipientDefaultBn);

    return DraftDocument(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      templateId: '${type.name}-application-v2',
      templateVersion: '2.0.0',
      type: type,
      facts: factsList,
      recipient: resolvedRecipient,
      paragraphs: paragraphs,
      unresolvedPlaceholders: unresolved,
      reviewStatus: unresolved.isEmpty ? 'needs_review' : 'incomplete',
      sourcePackVersion: 'bd-pilot-2026-11-03.2',
      exportStatus: 'never_exported',
    );
  }
}
