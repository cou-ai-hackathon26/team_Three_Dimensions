import '../models/answer_request.dart';
import '../models/answer_response.dart';

abstract class AnswerRepository {
  /// Submit a conversational turn or legal question
  Future<AnswerResponse> sendTurn(AnswerRequest request);

  /// Cancel an ongoing request attempt
  void cancel(String requestId);
}
