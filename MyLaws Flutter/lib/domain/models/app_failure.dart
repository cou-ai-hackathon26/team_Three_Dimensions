sealed class AppFailure {
  final String message;
  final String? code;
  final String? requestId;
  final String? messageBn;
  final String? messageEn;

  const AppFailure({
    required this.message,
    this.code,
    this.requestId,
    this.messageBn,
    this.messageEn,
  });

  const factory AppFailure.network({
    String? messageBn,
    String? messageEn,
    String? code,
    String? requestId,
  }) = NetworkFailure;

  const factory AppFailure.auth({
    String? messageBn,
    String? messageEn,
    String? code,
    String? requestId,
  }) = AuthFailure;

  const factory AppFailure.quotaExceeded({
    String? messageBn,
    String? messageEn,
    String? code,
    String? requestId,
  }) = QuotaFailure;

  const factory AppFailure.server({
    String? messageBn,
    String? messageEn,
    String? code,
    String? requestId,
  }) = ServiceUnavailableFailure;

  @override
  String toString() => messageBn ?? message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure({
    String message =
        'ইন্টারনেট সংযোগ পাওয়া যাচ্ছে না। আপনার লেখা সংরক্ষিত আছে।',
    String? messageBn,
    String? messageEn,
    String? code,
    String? requestId,
  }) : super(
          message: messageBn ?? message,
          code: code,
          requestId: requestId,
          messageBn: messageBn,
          messageEn: messageEn,
        );
}

class AuthFailure extends AppFailure {
  const AuthFailure({
    String message =
        'আপনার লগইন সেশনের মেয়াদ শেষ হয়েছে। দয়া করে পুনরায় সাইন ইন করুন।',
    String? messageBn,
    String? messageEn,
    String? code = 'AUTH_REQUIRED',
    String? requestId,
  }) : super(
          message: messageBn ?? message,
          code: code,
          requestId: requestId,
          messageBn: messageBn,
          messageEn: messageEn,
        );
}

class QuotaFailure extends AppFailure {
  final int? remaining;
  final String? resetAt;

  const QuotaFailure({
    String message =
        'আজকের অনলাইন প্রশ্নের সীমা শেষ হয়েছে। ইনস্টল করা আইনের তথ্য ও খসড়া আগের মতোই ব্যবহার করতে পারবেন।',
    String? messageBn,
    String? messageEn,
    String? code = 'DAILY_QUOTA_REACHED',
    String? requestId,
    this.remaining = 0,
    this.resetAt,
  }) : super(
          message: messageBn ?? message,
          code: code,
          requestId: requestId,
          messageBn: messageBn,
          messageEn: messageEn,
        );
}

class RateLimitFailure extends AppFailure {
  const RateLimitFailure({
    String message =
        'অল্প সময়ে অতিরিক্ত অনুরোধ পাঠানো হয়েছে। অনুগ্রহ করে কিছুক্ষণ অপেক্ষা করুন।',
    String? messageBn,
    String? messageEn,
    String? code = 'RATE_LIMITED',
    String? requestId,
  }) : super(
          message: messageBn ?? message,
          code: code,
          requestId: requestId,
          messageBn: messageBn,
          messageEn: messageEn,
        );
}

class ServiceUnavailableFailure extends AppFailure {
  const ServiceUnavailableFailure({
    String message =
        'এই মুহূর্তে অনলাইন সহায়তা পাওয়া যাচ্ছে না। একটু পরে আবার চেষ্টা করুন।',
    String? messageBn,
    String? messageEn,
    String? code = 'SERVICE_UNAVAILABLE',
    String? requestId,
  }) : super(
          message: messageBn ?? message,
          code: code,
          requestId: requestId,
          messageBn: messageBn,
          messageEn: messageEn,
        );
}

class PackCorruptFailure extends AppFailure {
  const PackCorruptFailure({
    String message =
        'আইন ভাণ্ডার ফাইলটি ত্রুটিপূর্ণ পাওয়া গেছে। অনুগ্রহ করে পুনরায় ডাউনলোড করুন।',
    String? code = 'PACK_CORRUPT',
  }) : super(message: message, code: code);
}

class StorageFullFailure extends AppFailure {
  const StorageFullFailure({
    String message = 'ফোনে পর্যাপ্ত মেমোরি খালি নেই।',
    String? code = 'STORAGE_FULL',
  }) : super(message: message, code: code);
}

class MigrationFailure extends AppFailure {
  const MigrationFailure({
    String message =
        'পূর্ববর্তী অ্যাপের তথ্য রূপান্তর করা সম্ভব হয়নি। মূল ফাইল সুরক্ষিত রয়েছে।',
    String? code = 'MIGRATION_FAILED',
  }) : super(message: message, code: code);
}
