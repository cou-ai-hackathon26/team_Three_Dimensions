class OfficeRecord {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? territory;
  final String? issueScope;
  final List<String> sourceIds;
  final String? verificationDate;
  final String status;

  const OfficeRecord({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.territory,
    this.issueScope,
    this.sourceIds = const [],
    this.verificationDate,
    this.status = 'authoritative',
  });

  factory OfficeRecord.fromJson(Map<String, dynamic> json) {
    return OfficeRecord(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      territory: json['territory'] as String?,
      issueScope: json['issueScope'] as String?,
      sourceIds: (json['sourceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      verificationDate: json['verificationDate'] as String?,
      status: json['status'] as String? ?? 'authoritative',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (address != null) 'address': address,
        if (phone != null) 'phone': phone,
        if (territory != null) 'territory': territory,
        if (issueScope != null) 'issueScope': issueScope,
        'sourceIds': sourceIds,
        if (verificationDate != null) 'verificationDate': verificationDate,
        'status': status,
      };
}
