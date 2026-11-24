import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mylaws/core/config/app_config.dart';
import 'package:mylaws/core/services/model_file_storage/model_file_storage.dart';
import 'package:mylaws/core/services/model_file_storage/model_file_storage_stub.dart';
import 'package:mylaws/domain/models/pack_state.dart';
import 'package:mylaws/features/downloads/local_model_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ModelFileStorage.instance = ModelFileStorageStub();
  });

  group('Local AI Model Notifier & Integrity Tests', () {
    test('Default model configuration has exact size, URL and SHA-256', () {
      final notifier = LocalAiModelNotifier();
      final state = notifier.state;

      expect(state.status, InstallStatus.notInstalled);
      expect(state.totalBytes, AppConfig.localModelLightSizeBytes);
      expect(state.progress, 0.0);
      expect(state.downloadUrl, AppConfig.localModelLightR2Url);
      expect(state.expectedSha256, AppConfig.localModelLightSha256);
    });

    test('Start download updates status to downloading with mock stream', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        final stream = Stream<List<int>>.periodic(
          const Duration(milliseconds: 10),
          (count) => List.filled(1024 * 1024, 0),
        ).take(5);
        return http.StreamedResponse(
          stream,
          200,
          contentLength: AppConfig.localModelLightSizeBytes,
        );
      });

      final notifier = LocalAiModelNotifier(httpClient: mockClient);
      await notifier.startDownload();

      expect(notifier.state.status, InstallStatus.downloading);

      await notifier.cancelDownload();
      expect(notifier.state.status, InstallStatus.notInstalled);
    });

    test('Pause and resume download maintains progress without resetting', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        final stream = Stream<List<int>>.periodic(
          const Duration(milliseconds: 10),
          (count) => List.filled(1024 * 1024, 0),
        ).take(10);
        return http.StreamedResponse(
          stream,
          200,
          contentLength: AppConfig.localModelLightSizeBytes,
        );
      });

      final notifier = LocalAiModelNotifier(httpClient: mockClient);
      await notifier.startDownload();
      expect(notifier.state.status, InstallStatus.downloading);

      await notifier.pauseDownload();
      expect(notifier.state.status, InstallStatus.paused);
      final pausedProgress = notifier.state.progress;
      final pausedBytes = notifier.state.downloadedBytes;

      await notifier.resumeDownload();
      expect(notifier.state.status, InstallStatus.downloading);
      expect(notifier.state.progress, greaterThanOrEqualTo(pausedProgress));
      expect(notifier.state.downloadedBytes, greaterThanOrEqualTo(pausedBytes));

      await notifier.cancelDownload();
      expect(notifier.state.status, InstallStatus.notInstalled);
    });

    test('Formatted progress and remaining text produce human-readable strings',
        () {
      const state = LocalAiModelState(
        totalBytes: 807694464, // ~770 MB
        downloadedBytes: 201923616, // ~192 MB (25%)
        progress: 0.25,
        status: InstallStatus.downloading,
      );

      final bnProgress = state.getProgressSummary(isBn: true);
      final enProgress = state.getProgressSummary(isBn: false);

      expect(bnProgress, contains('MB'));
      expect(bnProgress, contains('২৫%'));
      expect(enProgress, contains('193 MB / 770 MB (25%)'));

      final bnRemaining = state.getRemainingText(isBn: true);
      expect(bnRemaining, contains('গতি'));
      expect(bnRemaining, contains('বাকি'));
    });

    test('Remove model cleans up storage and resets state', () async {
      final notifier = LocalAiModelNotifier();
      await notifier.removeModel();

      expect(notifier.state.status, InstallStatus.notInstalled);
      expect(notifier.state.progress, 0.0);
      expect(notifier.state.downloadedBytes, 0);
    });
  });
}
