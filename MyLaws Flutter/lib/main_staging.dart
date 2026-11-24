import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'data/remote/online_answer_repository.dart';
import 'data/remote/online_api_client.dart';
import 'data/remote/online_auth_repository.dart';
import 'data/remote/online_quota_repository.dart';

/// Staging entrypoint targeting staging or preview deployed backend.
/// Command: flutter run --flavor staging -t lib/main_staging.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.i('Bootstrap: Starting MyLaws in [STAGING] flavor.');

  final apiClient = OnlineApiClient(baseUrl: AppConfig.apiBaseUrl);
  final authRepo = OnlineAuthRepository(apiClient);
  final answerRepo = OnlineAnswerRepository(apiClient);
  final quotaRepo = OnlineQuotaRepository(apiClient);

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        answerRepositoryProvider.overrideWithValue(answerRepo),
        quotaRepositoryProvider.overrideWithValue(quotaRepo),
      ],
      child: const MyLawsApp(),
    ),
  );
}
