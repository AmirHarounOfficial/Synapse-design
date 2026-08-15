import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/staff.dart';

/// Staff directory API (GET/POST/PUT /staff).
class StaffRepository {
  StaffRepository(this._api);

  final ApiClient _api;

  /// GET /staff?role=  (paginated)
  Future<Paginated<Staff>> list({String? role}) async {
    final qp = <String, dynamic>{};
    if (role != null && role.isNotEmpty) qp['role'] = role;
    final res = await _api.dio.get('/staff', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, Staff.fromJson);
  }

  /// GET /staff/{id}
  Future<Staff> show(int id) async {
    final res = await _api.dio.get('/staff/$id');
    return Staff.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /staff
  Future<Staff> create({
    required String name,
    required String email,
    required String role,
    String? phone,
    String? title,
  }) async {
    final res = await _api.dio.post('/staff', data: {
      'name': name,
      'email': email,
      'role': role,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (title != null && title.isNotEmpty) 'title': title,
    });
    return Staff.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// PUT /staff/{id}
  Future<Staff> update(
    int id, {
    String? name,
    String? role,
    String? phone,
    String? title,
    bool? isActive,
  }) async {
    final res = await _api.dio.put('/staff/$id', data: {
      'name': ?name,
      'role': ?role,
      'phone': ?phone,
      'title': ?title,
      'is_active': ?isActive,
    });
    return Staff.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /staff/{id}/deactivate
  Future<Staff> deactivate(int id) async {
    final res = await _api.dio.post('/staff/$id/deactivate');
    return Staff.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
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
      if (status == 404) return 'This staff member could not be found.';
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
