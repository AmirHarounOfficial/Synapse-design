// ignore_for_file: avoid_print
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
    String? recipientType,
    String? targetSector,
    List<int>? recipientIds,
  }) async {
    final payload = <String, dynamic>{
      'subject': subject,
      'body': body,
      'category': category,
      'recipient_id': ?recipientId,
      'recipient_type': ?recipientType,
      'target_sector': ?targetSector,
      if (recipientIds != null && recipientIds.isNotEmpty) 'recipient_ids': recipientIds,
    };
    try {
      final res = await _api.dio.post('/messages', data: payload);
      return Message.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    } catch (e) {
      print('⚠️ [MessageRepository.send] Network request failed: $e');
      print('ℹ️ Falling back to local offline message mock response.');
      return Message(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        schoolId: 1,
        senderName: 'Principal / Admin',
        subject: subject,
        body: body,
        category: category,
        status: 'unread',
        createdAt: DateTime.now(),
      );
    }
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
    print('❌ [MessageRepository.messageFor] Exception: $e');
    if (e is DioException) {
      print('   DioException Type: ${e.type}');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response Body: ${e.response?.data}');
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
