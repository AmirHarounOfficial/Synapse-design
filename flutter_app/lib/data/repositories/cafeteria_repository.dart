import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/cafeteria_alert.dart';
import '../models/halal_certification.dart';
import '../models/meal.dart';

/// Cafeteria / Allergens / Halal API. Reads are open to authenticated staff;
/// writes (create alert, acknowledge) are role-scoped to cafeteria/nurse on the
/// backend (see `routes/clusters/cafeteria.php`).
class CafeteriaRepository {
  CafeteriaRepository(this._api);

  final ApiClient _api;

  // --- Cafeteria alerts ----------------------------------------------------

  /// GET /cafeteria-alerts?acknowledged=&student_id=  (paginated)
  Future<Paginated<CafeteriaAlert>> alerts({bool? acknowledged, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (acknowledged != null) qp['acknowledged'] = acknowledged;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/cafeteria-alerts', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, CafeteriaAlert.fromJson);
  }

  /// GET /cafeteria-alerts/{id}
  Future<CafeteriaAlert> alert(int id) async {
    final res = await _api.dio.get('/cafeteria-alerts/$id');
    return CafeteriaAlert.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /cafeteria-alerts  (cafeteria/nurse only)
  Future<CafeteriaAlert> createAlert({
    required int schoolId,
    int? studentId,
    required String title,
    required String message,
    String? severity, // info | warning | critical
    bool? isHalalIssue,
    String? createdForDate, // yyyy-MM-dd
  }) async {
    final body = <String, dynamic>{
      'school_id': schoolId,
      'student_id': ?studentId,
      'title': title,
      'message': message,
      'severity': ?severity,
      'is_halal_issue': ?isHalalIssue,
      'created_for_date': ?createdForDate,
    };
    final res = await _api.dio.post('/cafeteria-alerts', data: body);
    return CafeteriaAlert.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /cafeteria-alerts/{id}/acknowledge  (cafeteria/nurse only)
  Future<CafeteriaAlert> acknowledgeAlert(int id) async {
    final res = await _api.dio.post('/cafeteria-alerts/$id/acknowledge');
    return CafeteriaAlert.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // --- Meals ---------------------------------------------------------------

  /// GET /meals?date=&school_id=  (paginated)
  Future<Paginated<Meal>> meals({String? date, int? schoolId}) async {
    final qp = <String, dynamic>{};
    if (date != null && date.isNotEmpty) qp['date'] = date;
    if (schoolId != null) qp['school_id'] = schoolId;
    final res = await _api.dio.get('/meals', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, Meal.fromJson);
  }

  /// GET /meals/{id}
  Future<Meal> meal(int id) async {
    final res = await _api.dio.get('/meals/$id');
    return Meal.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // --- Halal certifications ------------------------------------------------

  /// GET /halal-certifications?school_id=  (paginated, ordered by expiry)
  Future<Paginated<HalalCertification>> halalCertifications({int? schoolId}) async {
    final qp = <String, dynamic>{};
    if (schoolId != null) qp['school_id'] = schoolId;
    final res = await _api.dio.get('/halal-certifications', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, HalalCertification.fromJson);
  }

  /// GET /halal-certifications/{id}
  Future<HalalCertification> halalCertification(int id) async {
    final res = await _api.dio.get('/halal-certifications/$id');
    return HalalCertification.fromJson(
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
      if (status == 404) return 'This record could not be found.';
      if (status == 422) {
        final errors = e.response?.data is Map<String, dynamic>
            ? (e.response!.data as Map<String, dynamic>)['errors']
            : null;
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
