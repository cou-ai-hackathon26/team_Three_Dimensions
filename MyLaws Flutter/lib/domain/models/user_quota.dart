class UserQuota {
  final int dailyLimit;
  final int usedToday;
  final int remaining;
  final bool canQuery;
  final String? resetAt;
  final String? store;

  const UserQuota({
    required this.dailyLimit,
    required this.usedToday,
    required this.remaining,
    required this.canQuery,
    this.resetAt,
    this.store,
  });

  /// Fraction of daily quota remaining (0.0 to 1.0)
  double get progress =>
      dailyLimit > 0 ? (remaining / dailyLimit).clamp(0.0, 1.0) : 0.0;

  /// Whether the user has exhausted their questions today
  bool get isExhausted => remaining <= 0 || !canQuery;

  UserQuota copyWith({
    int? dailyLimit,
    int? usedToday,
    int? remaining,
    bool? canQuery,
    String? resetAt,
    String? store,
  }) {
    return UserQuota(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      usedToday: usedToday ?? this.usedToday,
      remaining: remaining ?? this.remaining,
      canQuery: canQuery ?? this.canQuery,
      resetAt: resetAt ?? this.resetAt,
      store: store ?? this.store,
    );
  }

  factory UserQuota.fromJson(Map<String, dynamic> json) {
    return UserQuota(
      dailyLimit: json['dailyLimit'] as int? ?? 30,
      usedToday: json['usedToday'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 30,
      canQuery: json['canQuery'] as bool? ?? true,
      resetAt: json['resetAt'] as String?,
      store: json['store'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyLimit': dailyLimit,
        'usedToday': usedToday,
        'remaining': remaining,
        'canQuery': canQuery,
        if (resetAt != null) 'resetAt': resetAt,
        if (store != null) 'store': store,
      };
}
