enum MigrationStatus {
  noLegacyDataFound,
  success,
  alreadyMigrated,
  corrupted,
  failure,
}

class MigrationResult {
  final MigrationStatus status;
  final int migratedCasesCount;
  final String message;

  const MigrationResult({
    required this.status,
    required this.migratedCasesCount,
    required this.message,
  });
}

abstract class MigrationRepository {
  /// Checks if legacy Kotlin data exists on this device
  Future<bool> hasLegacyData();

  /// Performs migration of case.enc into local Drift database
  Future<bool> migrateLegacyData();

  /// Checks if legacy migration is still pending
  Future<bool> hasPendingMigration();

  /// Runs migration and returns detailed status result
  Future<MigrationResult> runMigration();
}
