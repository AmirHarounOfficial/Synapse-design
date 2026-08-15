import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/dose_administration.dart';
import '../models/medication.dart';

/// Medications API. Reads are open to authenticated staff; physician approval
/// (approve/decline) is role-scoped to physicians and dose logging to nurses on
/// the backend (see `routes/clusters/medications.php`).
class MedicationRepository {
  MedicationRepository(this._api);

  final ApiClient _api;

  /// GET /medications?status=&student_id=  (paginated)
  Future<Paginated<Medication>> list({String? status, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status != 'all') qp['status'] = status;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/medications', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, Medication.fromJson);
  }

  /// GET /students/{student}/medications  (non-paginated collection)
  Future<List<Medication>> forStudent(int studentId) async {
    final res = await _api.dio.get('/students/$studentId/medications');
    final data = ((res.data as Map<String, dynamic>)['data'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    return data.map(Medication.fromJson).toList();
  }

  /// GET /medications/{id}
  Future<Medication> show(int id) async {
    final res = await _api.dio.get('/medications/$id');
    return Medication.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /medications
  Future<Medication> create({
    required int studentId,
    required String name,
    required String dosage,
    String? route,
    String? instructions,
    String? status,
    String? prescribedBy,
    bool? requiresPhysician,
    int? supplyCount,
    int? lowSupplyThreshold,
    String? startDate,
    String? endDate,
    bool? isHalalSensitive,
  }) async {
    final body = <String, dynamic>{
      'student_id': studentId,
      'name': name,
      'dosage': dosage,
      'route': ?route,
      'instructions': ?instructions,
      'status': ?status,
      'prescribed_by': ?prescribedBy,
      'requires_physician': ?requiresPhysician,
      'supply_count': ?supplyCount,
      'low_supply_threshold': ?lowSupplyThreshold,
      'start_date': ?startDate,
      'end_date': ?endDate,
      'is_halal_sensitive': ?isHalalSensitive,
    };
    final res = await _api.dio.post('/medications', data: body);
    return Medication.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /medications/{id}/approve  (physician only)
  Future<Medication> approve(int id) async {
    final res = await _api.dio.post('/medications/$id/approve');
    return Medication.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /medications/{id}/decline  (physician only)
  Future<Medication> decline(int id) async {
    final res = await _api.dio.post('/medications/$id/decline');
    return Medication.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// GET /dose-administrations?date=&student_id=  (paginated)
  Future<Paginated<DoseAdministration>> doseAdministrations({String? date, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (date != null && date.isNotEmpty) qp['date'] = date;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/dose-administrations', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, DoseAdministration.fromJson);
  }

  /// POST /dose-administrations — log a dose  (nurse only)
  Future<DoseAdministration> logDose({
    required int medicationId,
    required int studentId,
    required String status, // given|missed|refused|conflict|pending
    String? scheduledFor,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'medication_id': medicationId,
      'student_id': studentId,
      'status': status,
      'scheduled_for': ?scheduledFor,
      'notes': ?notes,
    };
    final res = await _api.dio.post('/dose-administrations', data: body);
    return DoseAdministration.fromJson(
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
