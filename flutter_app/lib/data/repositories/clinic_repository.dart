import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/clinic_visit.dart';
import '../models/emergency_consent.dart';

/// Clinic visits + emergency consents API (see `routes/clusters/clinic.php`).
/// Reads are open to authenticated staff; clinic-visit writes are nurse-only,
/// emergency-consent responses are parent-only.
class ClinicRepository {
  ClinicRepository(this._api);

  final ApiClient _api;

  // ---- Clinic visits ----

  /// GET /clinic-visits?date=&student_id=  (paginated, newest first)
  Future<Paginated<ClinicVisit>> listVisits({String? date, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (date != null && date.isNotEmpty) qp['date'] = date;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/clinic-visits', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, ClinicVisit.fromJson);
  }

  /// GET /clinic-visits/{id}
  Future<ClinicVisit> showVisit(int id) async {
    final res = await _api.dio.get('/clinic-visits/$id');
    return ClinicVisit.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /clinic-visits  (nurse-only). `nurse_id`/`visited_at` are filled in
  /// by the backend when omitted.
  Future<ClinicVisit> createVisit({
    required int studentId,
    required int schoolId,
    required String reason,
    String? notes,
    String? severity,
    bool isEmergency = false,
    String? outcome,
    String? photoUrl,
  }) async {
    final res = await _api.dio.post('/clinic-visits', data: {
      'student_id': studentId,
      'school_id': schoolId,
      'reason': reason,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (severity != null && severity.isNotEmpty) 'severity': severity,
      'is_emergency': isEmergency,
      if (outcome != null && outcome.isNotEmpty) 'outcome': outcome,
      if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
    });
    return ClinicVisit.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // ---- Emergency consents ----

  /// GET /emergency-consents?status=&student_id=  (paginated, newest first)
  Future<Paginated<EmergencyConsent>> listConsents({String? status, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/emergency-consents', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, EmergencyConsent.fromJson);
  }

  /// GET /emergency-consents/{id}
  Future<EmergencyConsent> showConsent(int id) async {
    final res = await _api.dio.get('/emergency-consents/$id');
    return EmergencyConsent.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /emergency-consents/{id}/respond  (parent-only). [status] is
  /// `approved` or `declined`.
  Future<EmergencyConsent> respondConsent(int id, String status) async {
    final res = await _api.dio.post('/emergency-consents/$id/respond', data: {'status': status});
    return EmergencyConsent.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
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
      if (status == 422) {
        final errors = e.response?.data is Map ? (e.response!.data as Map)['errors'] : null;
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
