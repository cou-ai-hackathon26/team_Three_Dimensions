import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/repositories/migration_repository.dart';
import 'database.dart';

class LegacyMigrationService implements MigrationRepository {
  static const String _prefMigrationCompleted = 'key_migration_completed_v1';
  final AppDatabase? _db;
  final String? _customLegacyFilePath;

  LegacyMigrationService(this._db, {String? customLegacyFilePath})
      : _customLegacyFilePath = customLegacyFilePath;

  @override
  Future<bool> hasPendingMigration() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_prefMigrationCompleted) ?? false;
    if (completed) return false;

    final legacyFile = await _resolveLegacyFile();
    return legacyFile != null && await legacyFile.exists();
  }

  Future<File?> _resolveLegacyFile() async {
    final customPath = _customLegacyFilePath;
    if (customPath != null) {
      return File(customPath);
    }
    // On Android, legacy Kotlin app stored encrypted case file at:
    // /data/data/bd.mylaws.app/files/case.enc or context.filesDir/case.enc
    try {
      final defaultFile = File('/data/data/bd.mylaws.app/files/case.enc');
      if (await defaultFile.exists()) return defaultFile;
    } catch (_) {}
    return null;
  }

  @override
  Future<MigrationResult> runMigration() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyDone = prefs.getBool(_prefMigrationCompleted) ?? false;
    if (alreadyDone) {
      return const MigrationResult(
        status: MigrationStatus.alreadyMigrated,
        migratedCasesCount: 0,
        message: 'Legacy migration already completed previously.',
      );
    }

    final file = await _resolveLegacyFile();
    if (file == null || !(await file.exists())) {
      await prefs.setBool(_prefMigrationCompleted, true);
      return const MigrationResult(
        status: MigrationStatus.noLegacyDataFound,
        migratedCasesCount: 0,
        message: 'No legacy case.enc file found on device.',
      );
    }

    AppLogger.i(
        'Found legacy Kotlin case.enc at ${file.path}. Starting migration...');

    try {
      final bytes = await file.readAsBytes();
      if (bytes.length < 16) {
        throw const FormatException(
            'Legacy encrypted payload is corrupted or too short');
      }

      // Parse JSON from decrypted payload or fallback plaintext migration container
      // Note: In native Android, AES-GCM decryption uses AndroidKeyStore key alias "case_key".
      // When imported, the decrypted bytes or decoded JSON is formatted as:
      // {"caseId": "...", "title": "...", "turns": [...], "facts": [...]}
      String payloadString;
      try {
        payloadString = utf8.decode(bytes);
      } catch (_) {
        // If encrypted binary, strip IV (12 bytes) and attempt payload decode
        payloadString = utf8.decode(bytes.sublist(12), allowMalformed: true);
      }

      final json = jsonDecode(payloadString) as Map<String, dynamic>;
      final caseId = json['caseId'] as String? ?? 'legacy_migrated_case';
      final title = json['title'] as String? ?? 'Migrated Case from Kotlin App';
      final turns = json['turns'] as List<dynamic>? ?? [];

      // Insert case into Drift database
      int importedTurns = 0;
      final db = _db;
      if (db != null) {
        await db.into(db.cases).insertOnConflictUpdate(
              CasesCompanion.insert(
                id: caseId,
                title: title,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

        // Insert chat turns
        for (final t in turns) {
          if (t is Map<String, dynamic>) {
            await db.into(db.chatTurns).insertOnConflictUpdate(
                  ChatTurnsCompanion.insert(
                    id: t['id'] as String? ?? 'legacy_turn_${importedTurns++}',
                    caseId: caseId,
                    role: t['role'] as String? ?? 'user',
                    textContent: t['text'] as String? ?? '',
                    responseJson: Value(t['response'] != null
                        ? jsonEncode(t['response'])
                        : null),
                    timestamp: DateTime.now(),
                  ),
                );
          }
        }
      }

      await prefs.setBool(_prefMigrationCompleted, true);
      AppLogger.i(
          'Legacy migration finished successfully for caseId=$caseId ($importedTurns turns).');

      return MigrationResult(
        status: MigrationStatus.success,
        migratedCasesCount: 1,
        message:
            'Successfully migrated 1 legacy case ($importedTurns turns) into Flutter database.',
      );
    } catch (e, st) {
      AppLogger.e('Failed to migrate legacy Kotlin data: $e', e, st);
      return MigrationResult(
        status: MigrationStatus.failure,
        migratedCasesCount: 0,
        message: 'Failed to migrate legacy data: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasLegacyData() => hasPendingMigration();

  @override
  Future<bool> migrateLegacyData() async {
    final res = await runMigration();
    return res.status == MigrationStatus.success ||
        res.status == MigrationStatus.alreadyMigrated;
  }
}
