import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin Dio wrapper for the SchooKeep Laravel API.
///
/// Base URL defaults to the local `php artisan serve` address and can be
/// overridden at build/run time with `--dart-define=API_BASE_URL=...`.
/// The bearer token is read from [SharedPreferences] and attached to every
/// request; a 401 clears it.
class ApiClient {
  ApiClient(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          if (e.response?.statusCode == 401) {
            _prefs.remove(_tokenKey);
          }
          handler.next(e);
        },
      ),
    );
  }

  static const String _tokenKey = 'schookeep_token';
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  final SharedPreferences _prefs;
  late final Dio _dio;

  Dio get dio => _dio;

  String? get token => _prefs.getString(_tokenKey);
  bool get hasToken => (token ?? '').isNotEmpty;

  Future<void> setToken(String token) => _prefs.setString(_tokenKey, token);
  Future<void> clearToken() => _prefs.remove(_tokenKey);
}
