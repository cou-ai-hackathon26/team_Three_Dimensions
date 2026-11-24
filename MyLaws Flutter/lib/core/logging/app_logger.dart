import 'package:flutter/foundation.dart';

class AppLogger {
  static final RegExp _phoneRegex = RegExp(r'(?:\+8801|01)\d{9}');
  static final RegExp _emailRegex =
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  static final RegExp _tokenRegex =
      RegExp(r'Bearer\s+[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*');

  /// Redacts sensitive information from any log string
  static String redact(String message) {
    return message
        .replaceAll(_tokenRegex, 'Bearer [REDACTED_TOKEN]')
        .replaceAll(_phoneRegex, '[REDACTED_PHONE]')
        .replaceAll(_emailRegex, '[REDACTED_EMAIL]');
  }

  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final t = tag != null ? '[$tag] ' : '';
      debugPrint('$t${redact(message)}');
    }
  }

  static void i(String message, [String? tag]) => info(message, tag);
  static void d(String message, [String? tag]) => info(message, tag);
  static void w(String message, [String? tag]) => info(message, tag);

  static void error(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[ERROR] ${redact(message)}');
      if (error != null) debugPrint('Exception: $error');
      if (stack != null) debugPrint('StackTrace: $stack');
    }
  }

  static void e(String message, [Object? err, StackTrace? stack]) =>
      AppLogger.error(message, err, stack);
}
