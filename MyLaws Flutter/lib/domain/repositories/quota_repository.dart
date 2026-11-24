import '../models/user_quota.dart';

abstract class QuotaRepository {
  /// Stream or fetch the authoritative daily quota
  Future<UserQuota> getQuota();

  /// Observe live quota updates
  Stream<UserQuota> watchQuota();

  /// Record one user query, decrementing the remaining count
  Future<UserQuota> recordQuery();

  /// Update the live quota state from an external response
  void updateQuota(UserQuota quota);
}
