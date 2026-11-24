import '../../core/logging/app_logger.dart';
import '../../core/services/offline_legal_inference_engine.dart';
import '../../domain/models/answer_request.dart';
import '../../domain/models/answer_response.dart';
import '../../domain/repositories/answer_repository.dart';
import 'online_api_client.dart';

class OnlineAnswerRepository implements AnswerRepository {
  final OnlineApiClient _client;
  final Map<String, bool> _cancelledRequests = {};

  OnlineAnswerRepository(this._client);

  @override
  Future<AnswerResponse> sendTurn(AnswerRequest request) async {
    _cancelledRequests[request.requestId] = false;

    // 1. If explicit offline mode requested, run directly on-device without network latency
    if (request.requestedMode == 'offline' &&
        OfflineLegalInferenceEngine.isAvailable()) {
      AppLogger.i(
          'Offline mode requested. Executing on-device Local AI Model inference.');
      _cancelledRequests.remove(request.requestId);
      return await OfflineLegalInferenceEngine.generateOfflineAnswer(request);
    }

    try {
      final json = await _client.post('/api/v1/answer', request.toJson());

      if (_cancelledRequests[request.requestId] == true) {
        _cancelledRequests.remove(request.requestId);
        throw Exception('Request cancelled by user');
      }

      _cancelledRequests.remove(request.requestId);
      return AnswerResponse.fromJson(json);
    } catch (e) {
      if (_cancelledRequests[request.requestId] == true) {
        _cancelledRequests.remove(request.requestId);
        rethrow;
      }

      AppLogger.w(
          'Online API turn failed or offline ($e). Executing seamless on-device local legal reasoning.');

      // Seamless On-Device Inference Fallback
      if (OfflineLegalInferenceEngine.isAvailable()) {
        _cancelledRequests.remove(request.requestId);
        return await OfflineLegalInferenceEngine.generateOfflineAnswer(request);
      }

      _cancelledRequests.remove(request.requestId);
      rethrow;
    }
  }

  @override
  void cancel(String requestId) {
    _cancelledRequests[requestId] = true;
  }
}
