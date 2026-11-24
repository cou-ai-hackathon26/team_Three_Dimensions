import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/models/user_quota.dart';
import '../../domain/repositories/quota_repository.dart';
import 'online_api_client.dart';

class OnlineQuotaRepository implements QuotaRepository {
  final OnlineApiClient _client;
  final _quotaController = StreamController<UserQuota>.broadcast();
  UserQuota? _latestQuota;
  static const int kDailyLimit = 30;

  OnlineQuotaRepository(this._client) {
    _initQuota();
  }

  /// Calculates the current calendar date in Bangladesh Standard Time (BST = UTC+6)
  String _getTodayBstDate() {
    final bstNow = DateTime.now().toUtc().add(const Duration(hours: 6));
    final year = bstNow.year.toString().padLeft(4, '0');
    final month = bstNow.month.toString().padLeft(2, '0');
    final day = bstNow.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Calculates upcoming midnight in Bangladesh Standard Time (BST)
  String _getNextBstMidnightIso() {
    final bstNow = DateTime.now().toUtc().add(const Duration(hours: 6));
    final nextMidnightBst = DateTime.utc(bstNow.year, bstNow.month, bstNow.day)
        .add(const Duration(days: 1));
    final nextMidnightUtc = nextMidnightBst.subtract(const Duration(hours: 6));
    return nextMidnightUtc.toIso8601String();
  }

  Future<void> _initQuota() async {
    try {
      final quota = await _loadLocalQuota();
      _latestQuota = quota;
      _quotaController.add(quota);
      // Synchronize in background with server
      _syncRemoteQuota().ignore();
    } catch (e) {
      AppLogger.w('Failed to initialize local quota: $e');
    }
  }

  Future<UserQuota> _loadLocalQuota() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayBstDate();
    final savedDate = prefs.getString('quota_date');

    int usedToday;
    if (savedDate != today) {
      // Midnight has passed in Bangladesh! Reset daily count to 0 for the new day
      usedToday = 0;
      await prefs.setString('quota_date', today);
      await prefs.setInt('quota_used_today', 0);
    } else {
      usedToday = prefs.getInt('quota_used_today') ?? 0;
    }

    final remaining = (kDailyLimit - usedToday).clamp(0, kDailyLimit);
    final quota = UserQuota(
      dailyLimit: kDailyLimit,
      usedToday: usedToday,
      remaining: remaining,
      canQuery: remaining > 0,
      resetAt: _getNextBstMidnightIso(),
      store: 'cloudflare_d1_persistent',
    );
    return quota;
  }

  Future<void> _syncRemoteQuota() async {
    try {
      final json = await _client.get('/api/v1/user/quota');
      final remoteDailyLimit =
          (json['dailyLimit'] as num?)?.toInt() ?? kDailyLimit;
      final remoteUsed = (json['usedToday'] as num?)?.toInt() ?? 0;

      if (_latestQuota != null) {
        // Respect the higher count between local and server to avoid quota bypass
        final actualUsed = _latestQuota!.usedToday > remoteUsed
            ? _latestQuota!.usedToday
            : remoteUsed;
        final actualRem =
            (remoteDailyLimit - actualUsed).clamp(0, remoteDailyLimit);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('quota_used_today', actualUsed);
        final merged = _latestQuota!.copyWith(
          dailyLimit: remoteDailyLimit,
          usedToday: actualUsed,
          remaining: actualRem,
          canQuery: actualRem > 0,
          resetAt: json['resetAt'] as String? ?? _latestQuota!.resetAt,
        );
        _latestQuota = merged;
        _quotaController.add(merged);
      }
    } catch (_) {}
  }

  @override
  Future<UserQuota> getQuota() async {
    final quota = await _loadLocalQuota();
    _latestQuota = quota;
    _quotaController.add(quota);
    return quota;
  }

  @override
  Stream<UserQuota> watchQuota() {
    if (_latestQuota != null) {
      scheduleMicrotask(() => _quotaController.add(_latestQuota!));
    } else {
      getQuota().ignore();
    }
    return _quotaController.stream;
  }

  @override
  Future<UserQuota> recordQuery() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayBstDate();
    final savedDate = prefs.getString('quota_date');

    int used = 0;
    if (savedDate != today) {
      used = 1;
      await prefs.setString('quota_date', today);
    } else {
      final current = prefs.getInt('quota_used_today') ?? 0;
      used = current + 1;
    }

    await prefs.setInt('quota_used_today', used);
    final remaining = (kDailyLimit - used).clamp(0, kDailyLimit);
    final quota = UserQuota(
      dailyLimit: kDailyLimit,
      usedToday: used,
      remaining: remaining,
      canQuery: remaining > 0,
      resetAt: _getNextBstMidnightIso(),
      store: 'cloudflare_d1_persistent',
    );
    _latestQuota = quota;
    _quotaController.add(quota);
    AppLogger.i(
        'Citizen query recorded. Remaining quota: ${quota.remaining}/${quota.dailyLimit}');
    return quota;
  }

  @override
  void updateQuota(UserQuota quota) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayBstDate();
      final savedDate = prefs.getString('quota_date');
      final localUsed = (savedDate == today) ? (prefs.getInt('quota_used_today') ?? 0) : 0;
      // Always retain the higher query count to prevent static backend payloads from regressing quota
      final effectiveUsed = quota.usedToday > localUsed ? quota.usedToday : localUsed;
      await prefs.setString('quota_date', today);
      await prefs.setInt('quota_used_today', effectiveUsed);

      final effectiveRemaining = (kDailyLimit - effectiveUsed).clamp(0, kDailyLimit);
      final merged = quota.copyWith(
        dailyLimit: kDailyLimit,
        usedToday: effectiveUsed,
        remaining: effectiveRemaining,
        canQuery: effectiveRemaining > 0,
        resetAt: _getNextBstMidnightIso(),
      );
      _latestQuota = merged;
      _quotaController.add(merged);
    } catch (_) {
      _latestQuota = quota;
      _quotaController.add(quota);
    }
  }
}
