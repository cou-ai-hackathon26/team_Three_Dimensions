class Claim {
  final String text;
  final List<String> sourceIds;

  const Claim({
    required this.text,
    required this.sourceIds,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      text: json['text'] as String? ?? '',
      sourceIds: (json['sourceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'sourceIds': sourceIds,
      };
}
