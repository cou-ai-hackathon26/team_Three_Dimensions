import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/models/app_failure.dart';

class OnlineApiClient {
  final String baseUrl;
  final String fallbackUrl;
  final http.Client _client;
  String? Function()? _tokenProvider;

  OnlineApiClient({
    this.baseUrl = AppConfig.apiBaseUrl,
    this.fallbackUrl = AppConfig.remoteApiBaseUrl,
    http.Client? client,
    String? Function()? tokenProvider,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider;

  void updateTokenProvider(String? Function() provider) {
    _tokenProvider = provider;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Platform': 'flutter-android',
      'X-Client-Version': '1.0.0-pilot',
    };

    final token = _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    AppLogger.d('GET $path');

    try {
      final res = await _client
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));

      return _handleResponse(res);
    } catch (e) {
      if (fallbackUrl.isNotEmpty && baseUrl != fallbackUrl) {
        try {
          final fallbackUri = Uri.parse('$fallbackUrl$path');
          final res = await _client
              .get(fallbackUri, headers: _buildHeaders())
              .timeout(const Duration(seconds: 15));
          return _handleResponse(res);
        } catch (_) {}
      }

      if (e is TimeoutException) {
        throw const AppFailure.network(
          messageBn:
              'সার্ভারের সাথে সংযোগ স্থাপন করতে দেরি হচ্ছে। অনুগ্রহ করে আপনার ইন্টারনেট যাচাই করুন।',
          messageEn: 'Request timed out. Please check your network connection.',
        );
      }
      if (e is AppFailure) rethrow;
      throw AppFailure.network(
        messageBn: 'নেটওয়ার্ক সংযোগ ত্রুটি ঘটেছে।',
        messageEn: 'Network connection error: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    AppLogger.d('POST $path');

    try {
      final res = await _client
          .post(
            uri,
            headers: _buildHeaders(),
            body: jsonEncode(body),
          )
          .timeout(AppConfig.onlineApiTimeout);

      return _handleResponse(res);
    } catch (e) {
      if (fallbackUrl.isNotEmpty && baseUrl != fallbackUrl) {
        try {
          final fallbackUri = Uri.parse('$fallbackUrl$path');
          final res = await _client
              .post(
                fallbackUri,
                headers: _buildHeaders(),
                body: jsonEncode(body),
              )
              .timeout(AppConfig.onlineApiTimeout);
          return _handleResponse(res);
        } catch (_) {}
      }

      if (e is TimeoutException) {
        throw const AppFailure.network(
          messageBn:
              'আইনি বিশ্লেষণ সম্পন্ন হতে অতিরিক্ত সময় লাগছে। অনুগ্রহ করে পুনরায় চেষ্টা করুন।',
          messageEn: 'Analysis timed out. Please try again.',
        );
      }
      if (e is AppFailure) rethrow;
      throw AppFailure.network(
        messageBn: 'সার্ভারে অনুরোধ পাঠানো সম্ভব হয়নি।',
        messageEn: 'Could not send request: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    AppLogger.d('DELETE $path');

    try {
      final res = await _client
          .delete(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));

      return _handleResponse(res);
    } on TimeoutException {
      throw const AppFailure.network(
        messageBn: 'অনুরোধের সময় শেষ হয়ে গেছে।',
        messageEn: 'Request timed out.',
      );
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw AppFailure.network(
        messageBn: 'অ্যাকাউন্ট মোছা সম্ভব হয়নি।',
        messageEn: 'Deletion request failed: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    final statusCode = res.statusCode;
    Map<String, dynamic> body = {};

    try {
      if (res.bodyBytes.isNotEmpty) {
        body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {}

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    if (statusCode == 401) {
      throw AppFailure.auth(
        messageBn:
            body['message'] as String? ?? 'অনুগ্রহ করে পুনরায় সাইন ইন করুন।',
        messageEn: body['messageEn'] as String? ??
            'Authentication expired or invalid.',
      );
    }

    if (statusCode == 429) {
      throw AppFailure.quotaExceeded(
        messageBn:
            body['message'] as String? ?? 'দৈনিক প্রশ্ন করার কোটা শেষ হয়েছে।',
        messageEn:
            body['messageEn'] as String? ?? 'Daily query quota exceeded.',
      );
    }

    if (statusCode == 503) {
      throw AppFailure.server(
        messageBn: body['message'] as String? ??
            'সার্ভার রক্ষণাবেক্ষণ চলছে। কিছুক্ষণ পর চেষ্টা করুন।',
        messageEn:
            body['messageEn'] as String? ?? 'Service temporarily unavailable.',
      );
    }

    throw AppFailure.server(
      messageBn:
          body['message'] as String? ?? 'সার্ভার ত্রুটি ঘটেছে ($statusCode)।',
      messageEn: body['messageEn'] as String? ?? 'Server error ($statusCode)',
    );
  }
}
