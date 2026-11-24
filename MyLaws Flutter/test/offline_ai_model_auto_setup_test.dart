import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mylaws/core/config/app_config.dart';
import 'package:mylaws/core/data/legal_provisions_catalog.dart';
import 'package:mylaws/core/services/model_file_storage/model_file_storage.dart';
import 'package:mylaws/core/services/model_file_storage/model_file_storage_stub.dart';
import 'package:mylaws/core/services/offline_legal_inference_engine.dart';
import 'package:mylaws/data/remote/online_answer_repository.dart';
import 'package:mylaws/data/remote/online_api_client.dart';
import 'package:mylaws/domain/models/answer_request.dart';
import 'package:mylaws/domain/models/answer_response.dart';
import 'package:mylaws/domain/models/pack_state.dart';
import 'package:mylaws/features/downloads/local_model_provider.dart';

class FailingOnlineApiClient extends OnlineApiClient {
  FailingOnlineApiClient() : super(baseUrl: 'http://mock.offline');

  @override
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    throw Exception('SocketException: Connection refused (No Internet / Network Offline)');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    ModelFileStorage.instance = ModelFileStorageStub();
    await LegalProvisionsCatalog.initialize();
    await OfflineLegalInferenceEngine.initialize();
  });

  group('Offline AI Model Auto-Setup & Lifecycle Tests', () {
    test('Initial state is notInstalled and SharedPreferences is respected', () async {
      SharedPreferences.setMockInitialValues({});
      (ModelFileStorage.instance as ModelFileStorageStub).setMockInstalled(false);
      final notifier = LocalAiModelNotifier();
      expect(notifier.state.status, InstallStatus.notInstalled);
      expect(notifier.state.isAutoConfigured, false);
      expect(notifier.state.totalBytes, AppConfig.localModelLightSizeBytes);
    });

    test('Completed download auto-configures local model and activates offline engine', () async {
      SharedPreferences.setMockInitialValues({});
      final mockClient = MockClient.streaming((request, bodyStream) async {
        final stream = Stream<List<int>>.value(
            List.filled(AppConfig.localModelLightSizeBytes, 0));
        return http.StreamedResponse(
          stream,
          200,
          contentLength: AppConfig.localModelLightSizeBytes,
        );
      });
      final notifier = LocalAiModelNotifier(httpClient: mockClient);

      await notifier.startDownload();

      // Fast-forward or wait until completion
      final completer = Completer<void>();
      notifier.addListener((state) {
        if (state.status == InstallStatus.ready && !completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future.timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.status, InstallStatus.ready);
      expect(notifier.state.progress, 1.0);
      expect(notifier.state.isAutoConfigured, true);
      expect(OfflineLegalInferenceEngine.isModelInstalled, true);

      // Check SharedPreferences persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('key_local_ai_model_installed'), true);
    });

    test('Restores ready state on subsequent initialization when already downloaded', () async {
      SharedPreferences.setMockInitialValues({'key_local_ai_model_installed': true});
      (ModelFileStorage.instance as ModelFileStorageStub).setMockInstalled(true);
      final notifier = LocalAiModelNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.status, InstallStatus.ready);
      expect(notifier.state.progress, 1.0);
      expect(notifier.state.isAutoConfigured, true);
      expect(OfflineLegalInferenceEngine.isModelInstalled, true);
    });

    test('Remove model clears persistent flag and deactivates model', () async {
      SharedPreferences.setMockInitialValues({'key_local_ai_model_installed': true});
      (ModelFileStorage.instance as ModelFileStorageStub).setMockInstalled(true);
      final notifier = LocalAiModelNotifier();
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.removeModel();

      expect(notifier.state.status, InstallStatus.notInstalled);
      expect(notifier.state.progress, 0.0);
      expect(notifier.state.isAutoConfigured, false);
      expect(OfflineLegalInferenceEngine.isModelInstalled, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('key_local_ai_model_installed'), false);
    });
  });

  group('Offline Legal Inference Engine Precision Tests', () {
    test('Labour wage query generates on-device Section 123 citation and DIFE draft option', () async {
      await OfflineLegalInferenceEngine.setModelInstalled(true);

      final repo = OnlineAnswerRepository(FailingOnlineApiClient());
      final response = await repo.sendTurn(
        const AnswerRequest(
          requestId: 'req_test_offline_wage',
          originalMessage: 'মালিক গত ৩ মাস ধরে আমার বেতন দিচ্ছে না, আমি কী করব?',
          language: 'bn',
          requestedMode: 'offline',
        ),
      );

      expect(response.outcome, Outcome.answered);
      expect(response.engineProvenance, ProcessingEngine.offlineModel);
      expect(response.problemSummary?.identifiedIssue, contains('বকেয়া মজুরি'));
      expect(response.explanation.any((s) => s.sourceIds.contains('labor-123')), true);
      expect(response.allowedDraftOptions, contains('dife'));
      expect(response.checklist.length, greaterThanOrEqualTo(2));
    });

    test('Police GD query generates on-device CrPC Section 155 citation and GD draft option', () async {
      await OfflineLegalInferenceEngine.setModelInstalled(true);

      final repo = OnlineAnswerRepository(FailingOnlineApiClient());
      final response = await repo.sendTurn(
        const AnswerRequest(
          requestId: 'req_test_offline_gd',
          originalMessage: 'আমার জাতীয় পরিচয়পত্র ও মানিব্যাগ হারিয়ে গেছে, থানায় জিডি করতে হবে',
          language: 'bn',
          requestedMode: 'offline',
        ),
      );

      expect(response.outcome, Outcome.answered);
      expect(response.engineProvenance, ProcessingEngine.offlineModel);
      expect(response.problemSummary?.identifiedIssue, contains('হারানো'));
      expect(response.explanation.any((s) => s.sourceIds.contains('penal-379')), true);
      expect(response.allowedDraftOptions, contains('gd'));
    });

    test('Seamlessly falls back to on-device inference when network is offline during auto-send', () async {
      await OfflineLegalInferenceEngine.setModelInstalled(true);

      final repo = OnlineAnswerRepository(FailingOnlineApiClient());
      final response = await repo.sendTurn(
        const AnswerRequest(
          requestId: 'req_test_network_drop',
          originalMessage: 'অনলাইন শপ থেকে ছেঁড়া পোশাক দিয়েছে, টাকা ফেরত দিচ্ছে না',
          language: 'bn',
          requestedMode: 'online', // Client requested online, but network drops
        ),
      );

      expect(response.outcome, Outcome.answered);
      expect(response.engineProvenance, ProcessingEngine.offlineModel);
      expect(response.problemSummary?.identifiedIssue, contains('ভোক্তা'));
      expect(response.explanation.any((s) => s.sourceIds.contains('consumer-50')), true);
      expect(response.allowedDraftOptions, contains('dncrp'));
    });
  });
}
