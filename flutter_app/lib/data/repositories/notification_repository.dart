import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/app_notification.dart';

/// In-app notifications API. Owner-scoped on the backend — `GET /notifications`
/// returns the authenticated user's notifications (see
/// `routes/clusters/wellbeing_system.php`).
class NotificationRepository {
  NotificationRepository(this._api);

  final ApiClient _api;

  /// GET /notifications  (paginated, newest first)
  Future<Paginated<AppNotification>> list() async {
    final res = await _api.dio.get('/notifications');
    return Paginated.fromJson(res.data as Map<String, dynamic>, AppNotification.fromJson);
  }

  /// POST /notifications/{id}/read
  Future<AppNotification> markRead(int id) async {
    final res = await _api.dio.post('/notifications/$id/read');
    return AppNotification.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// Maps Dio failures to a friendly message for the UI.
  static String messageFor(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Cannot reach the server. Is the backend running?';
      }
      if (e.response?.statusCode == 401) return 'Your session expired. Please sign in again.';
      if (e.response?.statusCode == 403) return 'You don\'t have access to this.';
    }
    return 'Something went wrong. Please try again.';
  }
}
