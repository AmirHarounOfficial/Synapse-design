import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/audit_log.dart';
import '../models/weather_advisory.dart';

/// System-level API: weather advisories (read: all; write: principal) and audit
/// logs (principal/admin only). See `routes/clusters/wellbeing_system.php`.
class SystemRepository {
  SystemRepository(this._api);

  final ApiClient _api;

  // ── Weather advisories ────────────────────────────────────────────────────

  /// GET /weather-advisories?active=  (paginated, newest first)
  Future<Paginated<WeatherAdvisory>> advisories({bool? active}) async {
    final qp = <String, dynamic>{};
    if (active != null) qp['active'] = active;
    final res = await _api.dio.get('/weather-advisories', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, WeatherAdvisory.fromJson);
  }

  /// Convenience: the most recent active advisory, or null if none.
  Future<WeatherAdvisory?> activeAdvisory() async {
    final page = await advisories(active: true);
    return page.items.isEmpty ? null : page.items.first;
  }

  /// POST /weather-advisories
  Future<WeatherAdvisory> createAdvisory({
    int? schoolId,
    required String kind,
    String? severity,
    required String message,
    String? messageAr,
    bool active = true,
    DateTime? startsAt,
    DateTime? endsAt,
  }) async {
    final res = await _api.dio.post('/weather-advisories', data: {
      'school_id': ?schoolId,
      'kind': kind,
      if (severity != null && severity.isNotEmpty) 'severity': severity,
      'message': message,
      if (messageAr != null && messageAr.isNotEmpty) 'message_ar': messageAr,
      'active': active,
      if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
      if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
    });
    return WeatherAdvisory.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// PATCH /weather-advisories/{id} — used to lift (deactivate) an advisory.
  Future<WeatherAdvisory> setAdvisoryActive(int id, bool active) async {
    final res = await _api.dio.patch('/weather-advisories/$id', data: {'active': active});
    return WeatherAdvisory.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // ── Audit logs ────────────────────────────────────────────────────────────

  /// GET /audit-logs?action=  (paginated, newest first)
  Future<Paginated<AuditLog>> auditLogs({String? action}) async {
    final qp = <String, dynamic>{};
    if (action != null && action.isNotEmpty && action != 'all') qp['action'] = action;
    final res = await _api.dio.get('/audit-logs', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, AuditLog.fromJson);
  }

  /// Maps Dio failures (incl. 422 validation) to a friendly message for the UI.
  static String messageFor(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Cannot reach the server. Is the backend running?';
      }
      final code = e.response?.statusCode;
      if (code == 401) return 'Your session expired. Please sign in again.';
      if (code == 403) return 'You don\'t have access to this.';
      if (code == 422) {
        final errors = e.response?.data is Map ? (e.response?.data as Map)['errors'] : null;
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        return 'Please check the form and try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
