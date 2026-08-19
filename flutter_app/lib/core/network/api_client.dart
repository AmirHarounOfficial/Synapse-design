// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin Dio wrapper for the SchooKeep Laravel API with real-time terminal stdout logging.
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
          // Use print so Flutter Web stdout forwards directly to terminal
          print('🌐 [API REQUEST] ${options.method} ${options.uri}');
          if (options.data != null) {
            print('   Payload: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ [API RESPONSE ${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (e, handler) {
          print('❌ [API ERROR ${e.response?.statusCode}] ${e.requestOptions.method} ${e.requestOptions.uri}');
          print('   Details: ${e.message}');
          if (e.response?.data != null) {
            print('   Response Data: ${e.response?.data}');
          }
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
    defaultValue: 'https://api.schookeep.com/api',
  );

  final SharedPreferences _prefs;
  late final Dio _dio;

  Dio get dio => _dio;

  String? get token => _prefs.getString(_tokenKey);
  bool get hasToken => (token ?? '').isNotEmpty;

  Future<void> setToken(String token) => _prefs.setString(_tokenKey, token);
  Future<void> clearToken() => _prefs.remove(_tokenKey);
}
