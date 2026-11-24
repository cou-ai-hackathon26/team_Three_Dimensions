import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/data/legal_provisions_catalog.dart';
import 'core/logging/app_logger.dart';
import 'data/fixtures/demo_fixture_adapter.dart';

/// Development entrypoint using pure synthetic fixtures (demo_fixture provenance).
/// Command: flutter run --flavor dev -t lib/main_dev.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LegalProvisionsCatalog.initialize();
  AppLogger.i(
      'Bootstrap: Starting MyLaws in [DEV] flavor with isolated demo fixtures.');

  final fixtureAdapter = DemoFixtureAdapter();

  runApp(
    ProviderScope(
      overrides: [
        demoFixtureAdapterProvider.overrideWithValue(fixtureAdapter),
        authRepositoryProvider.overrideWithValue(fixtureAdapter),
        answerRepositoryProvider.overrideWithValue(fixtureAdapter),
        sourceRepositoryProvider.overrideWithValue(fixtureAdapter),
        officeRepositoryProvider.overrideWithValue(fixtureAdapter),
        draftRepositoryProvider.overrideWithValue(fixtureAdapter),
        packRepositoryProvider.overrideWithValue(fixtureAdapter),
        quotaRepositoryProvider.overrideWithValue(fixtureAdapter),
        settingsRepositoryProvider.overrideWithValue(fixtureAdapter),
      ],
      child: const MyLawsApp(),
    ),
  );
}
