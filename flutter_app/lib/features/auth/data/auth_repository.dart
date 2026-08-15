import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/auth_user.dart';

/// Auth API calls + token lifecycle. Throws [AuthException] with a friendly
/// message on failure (so screens can show it inline).
class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  bool get isLoggedIn => _api.hasToken;

  Future<AuthUser> login(String email, String password) async {
    try {
      final res = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = res.data['token'] as String;
      await _api.setToken(token);
      return AuthUser.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<AuthUser> me() async {
    final res = await _api.dio.get('/auth/me');
    return AuthUser.fromJson(res.data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } on DioException {
      // Ignore network errors on logout; clear the token regardless.
    }
    await _api.clearToken();
  }

  String _messageFor(DioException e) {
    final status = e.response?.statusCode;
    if (status == 422 || status == 401) {
      final errors = e.response?.data is Map ? e.response!.data['errors'] : null;
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      return 'Invalid email or password';
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot reach the server. Is the backend running?';
    }
    return 'Something went wrong. Please try again.';
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
