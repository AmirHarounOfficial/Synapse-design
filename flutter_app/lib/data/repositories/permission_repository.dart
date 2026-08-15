import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/role_capability.dart';

/// Role/permission matrix API (GET/PUT /permissions).
class PermissionRepository {
  PermissionRepository(this._api);

  final ApiClient _api;

  /// GET /permissions -> { role: [ {capability, allowed}, ... ], ... }
  Future<Map<String, List<RoleCapability>>> matrix() async {
    final res = await _api.dio.get('/permissions');
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return data.map((role, caps) => MapEntry(
          role,
          (caps as List? ?? const [])
              .cast<Map<String, dynamic>>()
              .map(RoleCapability.fromJson)
              .toList(),
        ));
  }

  /// PUT /permissions with a list of {role, capability, allowed} changes.
  Future<void> update(
    List<({String role, String capability, bool allowed})> changes,
  ) async {
    await _api.dio.put('/permissions', data: {
      'changes': changes
          .map((c) => {
                'role': c.role,
                'capability': c.capability,
                'allowed': c.allowed,
              })
          .toList(),
    });
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
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
