class SourceRecord {
  final String id;
  final String type;
  final String originalText;
  final String title;
  final String provisionPath;
  final String? officialUrl;
  final String? verifiedDate;
  final String? effectiveDate;
  final String recordVersion;
  final String packVersion;
  final String? plainExplanation;
  final String? legalStatus;
  final String? reviewStatus;
  final List<String> keywords;
  final List<String> categories;
  final String? actNameBn;
  final String? actNameEn;
  final String? section;
  final String? titleEn;
  final String? plainExplanationEn;
  final String? cautionBn;
  final String? cautionEn;

  const SourceRecord({
    required this.id,
    this.type = 'authoritative',
    required this.originalText,
    required this.title,
    required this.provisionPath,
    this.officialUrl,
    this.verifiedDate,
    this.effectiveDate,
    required this.recordVersion,
    required this.packVersion,
    this.plainExplanation,
    this.legalStatus = 'in_force',
    this.reviewStatus = 'machine_checked',
    this.keywords = const [],
    this.categories = const [],
    this.actNameBn,
    this.actNameEn,
    this.section,
    this.titleEn,
    this.plainExplanationEn,
    this.cautionBn,
    this.cautionEn,
  });

  String getActName(bool isBangla) =>
      isBangla ? (actNameBn ?? title) : (actNameEn ?? actNameBn ?? title);

  String getTitle(bool isBangla) => isBangla ? title : (titleEn ?? title);

  String getSection(bool isBangla) {
    if (isBangla) {
      if (provisionPath.isNotEmpty) {
        final prefix = provisionPath.split('—')[0].split('-')[0].trim();
        if (prefix.contains('ধারা') ||
            prefix.contains('দফা') ||
            prefix.contains('অনুচ্ছেদ') ||
            prefix.contains('বিধি') ||
            prefix.contains('অর্ডার')) {
          return prefix;
        }
      }
      if (section != null && section!.isNotEmpty) {
        return section!
            .replaceAll(RegExp(r'\bSection\s*', caseSensitive: false), 'ধারা ')
            .replaceAll(
                RegExp(r'\bArticle\s*', caseSensitive: false), 'অনুচ্ছেদ ')
            .replaceAll(RegExp(r'\bClause\s*', caseSensitive: false), 'দফা ')
            .replaceAll(RegExp(r'\bOrder\s*', caseSensitive: false), 'অর্ডার ')
            .replaceAll(RegExp(r'\bRule\s*', caseSensitive: false), 'বিধি ');
      }
      return provisionPath;
    } else {
      if (section != null && section!.isNotEmpty) {
        return section!;
      }
      if (provisionPath.isNotEmpty) {
        final prefix = provisionPath.split('—')[0].split('-')[0].trim();
        return prefix
            .replaceAll('ধারা', 'Section')
            .replaceAll('অনুচ্ছেদ', 'Article')
            .replaceAll('দফা', 'Clause')
            .replaceAll('অর্ডার', 'Order')
            .replaceAll('বিধি', 'Rule');
      }
      return '';
    }
  }

  String getPlainExplanation(bool isBangla) => isBangla
      ? (plainExplanation ?? '')
      : (plainExplanationEn ?? plainExplanation ?? '');

  String getCaution(bool isBangla) =>
      isBangla ? (cautionBn ?? '') : (cautionEn ?? cautionBn ?? '');

  SourceRecord copyWith({
    String? id,
    String? type,
    String? originalText,
    String? title,
    String? provisionPath,
    String? officialUrl,
    String? verifiedDate,
    String? effectiveDate,
    String? recordVersion,
    String? packVersion,
    String? plainExplanation,
    String? legalStatus,
    String? reviewStatus,
    List<String>? keywords,
    List<String>? categories,
    String? actNameBn,
    String? actNameEn,
    String? section,
    String? titleEn,
    String? plainExplanationEn,
    String? cautionBn,
    String? cautionEn,
  }) {
    return SourceRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      originalText: originalText ?? this.originalText,
      title: title ?? this.title,
      provisionPath: provisionPath ?? this.provisionPath,
      officialUrl: officialUrl ?? this.officialUrl,
      verifiedDate: verifiedDate ?? this.verifiedDate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      recordVersion: recordVersion ?? this.recordVersion,
      packVersion: packVersion ?? this.packVersion,
      plainExplanation: plainExplanation ?? this.plainExplanation,
      legalStatus: legalStatus ?? this.legalStatus,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      keywords: keywords ?? this.keywords,
      categories: categories ?? this.categories,
      actNameBn: actNameBn ?? this.actNameBn,
      actNameEn: actNameEn ?? this.actNameEn,
      section: section ?? this.section,
      titleEn: titleEn ?? this.titleEn,
      plainExplanationEn: plainExplanationEn ?? this.plainExplanationEn,
      cautionBn: cautionBn ?? this.cautionBn,
      cautionEn: cautionEn ?? this.cautionEn,
    );
  }

  factory SourceRecord.fromJson(Map<String, dynamic> json) {
    return SourceRecord(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'authoritative',
      originalText:
          json['originalText'] as String? ?? json['quote'] as String? ?? '',
      title: json['title'] is Map
          ? (json['title']['bn'] as String? ?? '')
          : (json['title'] as String? ?? ''),
      provisionPath: json['provisionPath'] as String? ??
          json['section'] as String? ??
          json['sectionNumber'] as String? ??
          '',
      officialUrl:
          json['officialUrl'] as String? ?? json['sourceUrl'] as String?,
      verifiedDate:
          json['verifiedDate'] as String? ?? json['checkedOn'] as String?,
      effectiveDate: json['effectiveDate'] as String?,
      recordVersion: json['recordVersion'] as String? ?? '1.0',
      packVersion: json['packVersion'] as String? ?? '',
      plainExplanation: json['plainExplanation'] is Map
          ? (json['plainExplanation']['bn'] as String?)
          : (json['plainExplanation'] as String?),
      legalStatus: json['legalStatus'] as String? ?? 'in_force',
      reviewStatus: json['reviewStatus'] as String? ?? 'machine_checked',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      actNameBn: json['actNameBn'] as String? ??
          (json['act'] is Map ? json['act']['bn'] as String? : null),
      actNameEn: json['actNameEn'] as String? ??
          (json['act'] is Map ? json['act']['en'] as String? : null),
      section: json['section'] as String? ?? json['sectionNumber'] as String?,
      titleEn: json['title'] is Map
          ? (json['title']['en'] as String?)
          : (json['titleEn'] as String?),
      plainExplanationEn: json['plainExplanation'] is Map
          ? (json['plainExplanation']['en'] as String?)
          : (json['plainExplanationEn'] as String?),
      cautionBn: json['caution'] is Map
          ? (json['caution']['bn'] as String?)
          : (json['cautionBn'] as String?),
      cautionEn: json['caution'] is Map
          ? (json['caution']['en'] as String?)
          : (json['cautionEn'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'originalText': originalText,
        'title': title,
        'provisionPath': provisionPath,
        if (officialUrl != null) 'officialUrl': officialUrl,
        if (verifiedDate != null) 'verifiedDate': verifiedDate,
        if (effectiveDate != null) 'effectiveDate': effectiveDate,
        'recordVersion': recordVersion,
        'packVersion': packVersion,
        if (plainExplanation != null) 'plainExplanation': plainExplanation,
        if (legalStatus != null) 'legalStatus': legalStatus,
        if (reviewStatus != null) 'reviewStatus': reviewStatus,
        'keywords': keywords,
        'categories': categories,
      };
}
