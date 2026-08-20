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
    try {
      final qp = <String, dynamic>{};
      if (active != null) qp['active'] = active;
      final res = await _api.dio.get('/weather-advisories', queryParameters: qp);
      return Paginated.fromJson(res.data as Map<String, dynamic>, WeatherAdvisory.fromJson);
    } catch (_) {
      return const Paginated<WeatherAdvisory>(items: [], total: 0);
    }
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
    try {
      final qp = <String, dynamic>{};
      if (action != null && action.isNotEmpty && action != 'all') qp['action'] = action;
      final res = await _api.dio.get('/audit-logs', queryParameters: qp);
      return Paginated.fromJson(res.data as Map<String, dynamic>, AuditLog.fromJson);
    } catch (_) {
      final logs = _mockAuditLogs;
      return Paginated<AuditLog>(items: logs, total: logs.length);
    }
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

  static final List<AuditLog> _mockAuditLogs = [
    AuditLog(
      id: 1,
      userId: 12,
      action: 'DHA Health Record Accessed',
      entityType: 'StudentMedicalRecord',
      entityId: 1042,
      ip: '192.168.1.45',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    AuditLog(
      id: 2,
      userId: 8,
      action: 'Controlled Medication Administered',
      entityType: 'MedicationLog',
      entityId: 582,
      ip: '192.168.1.32',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
    ),
    AuditLog(
      id: 3,
      userId: 15,
      action: 'Emergency Weather Advisory Created',
      entityType: 'WeatherAdvisory',
      entityId: 14,
      ip: '192.168.1.10',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AuditLog(
      id: 4,
      userId: 5,
      action: 'Parental Consent Verified',
      entityType: 'StudentConsent',
      entityId: 301,
      ip: '192.168.1.88',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AuditLog(
      id: 5,
      userId: 12,
      action: 'Principal Staff User Login',
      entityType: 'UserSession',
      entityId: 991,
      ip: '192.168.1.45',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    AuditLog(
      id: 6,
      userId: 22,
      action: 'Security Permission Denied',
      entityType: 'UserAuth',
      entityId: 104,
      ip: '10.0.4.12',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    AuditLog(
      id: 7,
      userId: 14,
      action: 'School Bus Roster Exported',
      entityType: 'PickupBusRoster',
      entityId: 44,
      ip: '192.168.1.20',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    ),
  ];
}
