import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/after_hours_request.dart';

/// After-hours access requests API (GET/POST /after-hours-requests).
class AfterHoursRepository {
  AfterHoursRepository(this._api);

  final ApiClient _api;

  /// GET /after-hours-requests  (paginated)
  Future<Paginated<AfterHoursRequest>> list() async {
    final res = await _api.dio.get('/after-hours-requests');
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, AfterHoursRequest.fromJson);
  }

  /// POST /after-hours-requests
  Future<AfterHoursRequest> create({
    required String reason,
    String? windowStart,
    String? windowEnd,
  }) async {
    final res = await _api.dio.post('/after-hours-requests', data: {
      'reason': reason,
      if (windowStart != null && windowStart.isNotEmpty) 'window_start': windowStart,
      if (windowEnd != null && windowEnd.isNotEmpty) 'window_end': windowEnd,
    });
    return AfterHoursRequest.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /after-hours-requests/{id}/respond { status }
  Future<AfterHoursRequest> respond(int id, String status) async {
    final res = await _api.dio
        .post('/after-hours-requests/$id/respond', data: {'status': status});
    return AfterHoursRequest.fromJson(
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
      if (status == 404) return 'This request could not be found.';
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
