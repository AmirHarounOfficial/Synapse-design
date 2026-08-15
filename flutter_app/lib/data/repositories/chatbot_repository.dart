import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/chatbot.dart';

/// Parent chatbot API (GET/POST /chatbot-conversations).
class ChatbotRepository {
  ChatbotRepository(this._api);

  final ApiClient _api;

  /// GET /chatbot-conversations?status=  (paginated)
  Future<Paginated<ChatbotConversation>> list({String? status}) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    final res = await _api.dio.get('/chatbot-conversations', queryParameters: qp);
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, ChatbotConversation.fromJson);
  }

  /// GET /chatbot-conversations/{id}  (includes nested messages)
  Future<ChatbotConversation> show(int id) async {
    final res = await _api.dio.get('/chatbot-conversations/$id');
    return ChatbotConversation.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /chatbot-conversations/{id}/messages
  Future<ChatbotMessage> postMessage(int conversationId, String body) async {
    final res = await _api.dio
        .post('/chatbot-conversations/$conversationId/messages', data: {'body': body});
    return ChatbotMessage.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /chatbot-conversations
  Future<ChatbotConversation> start({
    required String subject,
    required String body,
  }) async {
    final res = await _api.dio.post('/chatbot-conversations', data: {
      'subject': subject,
      'body': body,
    });
    return ChatbotConversation.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// Maps Dio failures to a friendly message for the UI.
  static String messageFor(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Cannot reach the server. Is the backend running?';
      }
      final status = e.response?.statusCode;
      if (status == 401) return 'Your session expired. Please sign in again.';
      if (status == 403) return 'You don\'t have access to this.';
      if (status == 404) return 'This conversation could not be found.';
      if (status == 422) {
        final errors = e.response?.data is Map ? (e.response!.data as Map)['errors'] : null;
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
