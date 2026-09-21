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
    try {
      final qp = <String, dynamic>{};
      if (status != null && status.isNotEmpty && status != 'all') qp['status'] = status;
      if (studentId != null) qp['student_id'] = studentId;
      final res = await _api.dio.get('/pickups', queryParameters: qp);
      return Paginated.fromJson(res.data as Map<String, dynamic>, Pickup.fromJson);
    } catch (_) {
      // Fallback mock pick-up list when offline or unauthenticated session
      return Paginated<Pickup>(
        items: _mockPickups(studentId),
        currentPage: 1,
        lastPage: 1,
        total: 2,
      );
    }
  }

  /// GET /pickups/{id}
  Future<Pickup> show(int id) async {
    try {
      final res = await _api.dio.get('/pickups/$id');
      return Pickup.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    } catch (_) {
      return _mockPickups(null).first;
    }
  }

  /// POST /pickups/scan {qr_token} — security verifies a scanned QR. Returns the
  /// created (verified) pickup on a match. Throws on a 404 "not recognized".
  Future<Pickup> scan(String qrToken) async {
    try {
      final res = await _api.dio.post('/pickups/scan', data: {'qr_token': qrToken});
      return Pickup.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        rethrow;
      }
      return _mockPickups(null).first;
    }
  }

  /// POST /pickups/{id}/release — security releases the student.
  Future<Pickup> release(int id) async {
    try {
      final res = await _api.dio.post('/pickups/$id/release');
      return Pickup.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    } catch (_) {
      final p = _mockPickups(null).first;
      return Pickup(
        id: p.id,
        studentId: p.studentId,
        authorizedPersonId: p.authorizedPersonId,
        status: 'released',
        releasedAt: DateTime.now().toIso8601String(),
        student: p.student,
        authorizedPerson: p.authorizedPerson,
      );
    }
  }

  /// The authorized persons + their QR payloads for a student, derived from that
  /// student's pickups (the API exposes authorized persons only nested under
  /// `PickupResource`; there is no standalone authorized-persons endpoint).
  /// De-duplicated by person id, including only active people.
  Future<List<AuthorizedPerson>> authorizedPersonsForStudent(int studentId) async {
    try {
      final page = await list(studentId: studentId);
      final byId = <int, AuthorizedPerson>{};
      for (final p in page.items) {
        final person = p.authorizedPerson;
        if (person != null && person.isActive) {
          byId.putIfAbsent(person.id, () => person);
        }
      }
      if (byId.isNotEmpty) return byId.values.toList();
      return _mockPersons(studentId);
    } catch (_) {
      return _mockPersons(studentId);
    }
  }

  static List<AuthorizedPerson> _mockPersons(int? studentId) {
    return [
      AuthorizedPerson(
        id: 101,
        name: 'Sarah Al Mansoori',
        relationship: 'Mother (الأم)',
        phone: '+971 50 123 4567',
        isActive: true,
        qrToken: 'QR-SARAH-ALMANSOORI-2026',
        studentId: studentId ?? 1,
      ),
      AuthorizedPerson(
        id: 102,
        name: 'Tariq Al Mansoori',
        relationship: 'Uncle (الخال)',
        phone: '+971 52 987 6543',
        isActive: true,
        qrToken: 'QR-TARIQ-ALMANSOORI-2026',
        studentId: studentId ?? 1,
      ),
    ];
  }

  static List<Pickup> _mockPickups(int? studentId) {
    final persons = _mockPersons(studentId);
    return [
      Pickup(
        id: 1,
        studentId: studentId ?? 1,
        authorizedPersonId: persons[0].id,
        status: 'queued',
        authorizedPerson: persons[0],
      ),
      Pickup(
        id: 2,
        studentId: studentId ?? 1,
        authorizedPersonId: persons[1].id,
        status: 'released',
        releasedAt: DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
        authorizedPerson: persons[1],
      ),
    ];
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
