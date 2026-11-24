import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/core/logging/app_logger.dart';

void main() {
  group('Privacy & Sensitive Data Redaction Tests', () {
    test('Redacts Bangladesh mobile numbers from logs', () {
      const raw = 'User phone is 01712345678 and alternative is +8801812345678';
      final redacted = AppLogger.redact(raw);

      expect(redacted, isNot(contains('01712345678')));
      expect(redacted, isNot(contains('+8801812345678')));
      expect(redacted, contains('[REDACTED_PHONE]'));
    });

    test('Redacts user email addresses from logs', () {
      const raw =
          'Contact applicant at citizen.applicant@example.com for notice';
      final redacted = AppLogger.redact(raw);

      expect(redacted, isNot(contains('citizen.applicant@example.com')));
      expect(redacted, contains('[REDACTED_EMAIL]'));
    });

    test('Redacts Bearer authorization tokens from logs', () {
      const raw =
          'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJ1c2VyIn0.sig';
      final redacted = AppLogger.redact(raw);

      expect(redacted, isNot(contains('eyJhbGciOiJSUzI1NiI')));
      expect(redacted, contains('Bearer [REDACTED_TOKEN]'));
    });
  });
}
