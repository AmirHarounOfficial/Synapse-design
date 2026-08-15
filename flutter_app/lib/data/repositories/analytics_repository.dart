import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

/// Analytics/reporting API. Endpoints return raw JSON objects, so these
/// methods hand back decoded maps for the UI to read directly.
class AnalyticsRepository {
  AnalyticsRepository(this._api);

  final ApiClient _api;

  /// GET /analytics/overview
  Future<Map<String, dynamic>> overview() => _getMap('/analytics/overview');

  /// GET /analytics/health
  Future<Map<String, dynamic>> health() => _getMap('/analytics/health');

  /// GET /analytics/clinic-readiness
  Future<Map<String, dynamic>> clinicReadiness() =>
      _getMap('/analytics/clinic-readiness');

  /// GET /analytics/annual-report?year=
  Future<Map<String, dynamic>> annualReport({int? year}) {
    final qp = <String, dynamic>{};
    if (year != null) qp['year'] = year;
    return _getMap('/analytics/annual-report', queryParameters: qp);
  }

  /// POST /students/promote?from_grade=
  Future<Map<String, dynamic>> promoteStudents({String? fromGrade}) async {
    final res = await _api.dio.post('/students/promote', data: {
      if (fromGrade != null && fromGrade.isNotEmpty) 'from_grade': fromGrade,
    });
    return _unwrap(res.data);
  }

  Future<Map<String, dynamic>> _getMap(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await _api.dio.get(path, queryParameters: queryParameters);
    return _unwrap(res.data);
  }

  /// Returns the `data` envelope if present, otherwise the raw map.
  static Map<String, dynamic> _unwrap(Object? data) {
    final map = data as Map<String, dynamic>? ?? const {};
    final inner = map['data'];
    if (inner is Map<String, dynamic>) return inner;
    return map;
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
    }
    return 'Something went wrong. Please try again.';
  }
}
