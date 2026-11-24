import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/config/app_config.dart';
import 'core/data/legal_provisions_catalog.dart';
import 'core/logging/app_logger.dart';
import 'core/services/offline_legal_inference_engine.dart';
import 'data/remote/online_answer_repository.dart';
import 'data/remote/online_api_client.dart';
import 'data/remote/online_auth_repository.dart';
import 'data/remote/online_quota_repository.dart';

/// Production Release entrypoint.
/// STRICT RULE: Fixture adapters are never registered here.
/// Command: flutter build apk --flavor prod --release
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LegalProvisionsCatalog.initialize();
  OfflineLegalInferenceEngine.initialize();
  AppLogger.i(
      'Bootstrap: Starting MyLaws in [RELEASE] production environment.');

  // Standalone Cloudflare Edge API Worker backend
  final apiClient = OnlineApiClient(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: AppConfig.apiBaseUrl,
    ),
  );

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
