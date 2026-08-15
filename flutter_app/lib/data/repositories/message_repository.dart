import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/message.dart';

/// Internal messaging API (GET/POST /messages).
class MessageRepository {
  MessageRepository(this._api);

  final ApiClient _api;

  /// GET /messages?status=&category=  (paginated, newest first)
  Future<Paginated<Message>> list({String? status, String? category}) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (category != null && category.isNotEmpty) qp['category'] = category;
    final res = await _api.dio.get('/messages', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, Message.fromJson);
  }

  /// GET /messages/{id}
  Future<Message> show(int id) async {
    final res = await _api.dio.get('/messages/$id');
    return Message.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /messages
  Future<Message> send({
    required String subject,
    required String body,
    required String category,
    int? recipientId,
  }) async {
    final res = await _api.dio.post('/messages', data: {
      'subject': subject,
      'body': body,
      'category': category,
      'recipient_id': ?recipientId,
    });
    return Message.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /messages/{id}/read
  Future<Message> markRead(int id) async {
    final res = await _api.dio.post('/messages/$id/read');
    return Message.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /messages/{id}/reply
  Future<Message> reply(int id, String body) async {
    final res = await _api.dio.post('/messages/$id/reply', data: {'body': body});
    return Message.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
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
      if (status == 404) return 'This message could not be found.';
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
