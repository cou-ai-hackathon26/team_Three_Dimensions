import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/data/local/offline_pack_service.dart';

void main() {
  group('Offline Pack Pipeline & Checksum Integrity Tests', () {
    test('Verifies valid SHA-256 checksum correctly', () {
      final sampleData =
          utf8.encode('Bangladesh Labour Act 2006 Corpus Payload');
      final validHash = sha256.convert(sampleData).toString();

      final result = OfflinePackService.verifyChecksum(sampleData, validHash);
      expect(result, true, reason: 'Matching hash must pass verification');
    });

    test('Rejects tampered payload or mismatched SHA-256 hash', () {
      final sampleData =
          utf8.encode('Bangladesh Labour Act 2006 Corpus Payload');
      const tamperedHash =
          'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

      final result =
          OfflinePackService.verifyChecksum(sampleData, tamperedHash);
      expect(result, false,
          reason: 'Tampered or mismatched hash must fail safely');
    });

    test('Is case-insensitive for hex digests', () {
      final sampleData = utf8.encode('Test Case Insensitive Hash');
      final validHash = sha256.convert(sampleData).toString().toUpperCase();

      final result = OfflinePackService.verifyChecksum(sampleData, validHash);
      expect(result, true);
    });
  });
}
