import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/authorized_person.dart';
import '../models/pickup.dart';

/// Pickups API (see `routes/clusters/pickup_bus.php`). Reads are open to any
/// authenticated staff; `scan` and `release` are security-only on the backend.
class PickupRepository {
  PickupRepository(this._api);

  final ApiClient _api;

  /// GET /pickups?status=&student_id=  (paginated, 50/page)
  Future<Paginated<Pickup>> list({String? status, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status != 'all') qp['status'] = status;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/pickups', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, Pickup.fromJson);
  }

  /// GET /pickups/{id}
  Future<Pickup> show(int id) async {
    final res = await _api.dio.get('/pickups/$id');
    return Pickup.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /pickups/scan {qr_token} — security verifies a scanned QR. Returns the
  /// created (verified) pickup on a match. Throws on a 404 "not recognized".
  Future<Pickup> scan(String qrToken) async {
    final res = await _api.dio.post('/pickups/scan', data: {'qr_token': qrToken});
    return Pickup.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /pickups/{id}/release — security releases the student.
  Future<Pickup> release(int id) async {
    final res = await _api.dio.post('/pickups/$id/release');
    return Pickup.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// The authorized persons + their QR payloads for a student, derived from that
  /// student's pickups (the API exposes authorized persons only nested under
  /// `PickupResource`; there is no standalone authorized-persons endpoint).
  /// De-duplicated by person id, including only active people.
  Future<List<AuthorizedPerson>> authorizedPersonsForStudent(int studentId) async {
    final page = await list(studentId: studentId);
    final byId = <int, AuthorizedPerson>{};
    for (final p in page.items) {
      final person = p.authorizedPerson;
      if (person != null && person.isActive) {
        byId.putIfAbsent(person.id, () => person);
      }
    }
    return byId.values.toList();
  }

  /// True when the failure was a 404 (QR not recognized / inactive person).
  static bool isNotRecognized(Object e) =>
      e is DioException && e.response?.statusCode == 404;

  /// Maps Dio failures to a friendly message for the UI.
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
      if (code == 404) return 'QR code not recognized or person is inactive.';
      if (code == 422) {
        final errors = e.response?.data is Map ? (e.response?.data as Map)['errors'] : null;
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
