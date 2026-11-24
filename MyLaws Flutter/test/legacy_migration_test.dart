import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mylaws/data/local/legacy_migration_service.dart';
import 'package:mylaws/domain/repositories/migration_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Legacy Kotlin Migration Pipeline Tests', () {
    late Directory tempDir;
    late File legacyFile;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = Directory.systemTemp.createTempSync('mylaws_migration_test_');
      legacyFile = File('${tempDir.path}/case.enc');
    });

    tearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('Reports no legacy data when case.enc does not exist', () async {
      final service = LegacyMigrationService(
        // Pass null or mock DB when testing non-existent file path
        dynamicDbMock(),
        customLegacyFilePath: legacyFile.path,
      );

      final hasPending = await service.hasPendingMigration();
      expect(hasPending, false);

      final result = await service.runMigration();
      expect(result.status, MigrationStatus.noLegacyDataFound);
      expect(result.migratedCasesCount, 0);
    });

    test('Detects pending migration when legacy file is present', () async {
      // Seed synthetic legacy case
      final samplePayload = {
        'caseId': 'legacy_case_001',
        'title': 'Kotlin Migration Test Case',
        'turns': [
          {'id': 't1', 'role': 'user', 'text': 'আমার বেতন বকেয়া'},
        ],
      };

      // Write synthetic encrypted payload (12-byte IV + UTF8 JSON)
      final iv = List<int>.filled(12, 0);
      final jsonBytes = utf8.encode(jsonEncode(samplePayload));
      legacyFile.writeAsBytesSync([...iv, ...jsonBytes]);

      final service = LegacyMigrationService(
        dynamicDbMock(),
        customLegacyFilePath: legacyFile.path,
      );

      final hasPending = await service.hasPendingMigration();
      expect(hasPending, true);
    });

    test('Idempotency: running migration twice reports alreadyMigrated',
        () async {
      SharedPreferences.setMockInitialValues({
        'key_migration_completed_v1': true,
      });

      final service = LegacyMigrationService(
        dynamicDbMock(),
        customLegacyFilePath: legacyFile.path,
      );

      final hasPending = await service.hasPendingMigration();
      expect(hasPending, false);

      final result = await service.runMigration();
      expect(result.status, MigrationStatus.alreadyMigrated);
      expect(result.migratedCasesCount, 0);
    });
  });
}

// Minimal dynamic mock for DB executor in unit test
dynamic dynamicDbMock() {
  return null;
}
