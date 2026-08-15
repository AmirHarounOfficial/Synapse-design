import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/student.dart';

/// Students API. Reads are open to all authenticated staff; writes are
/// admin-only on the backend (see `routes/clusters/students.php`).
class StudentRepository {
  StudentRepository(this._api);

  final ApiClient _api;

  /// GET /students?q=&grade=&school_id=  (paginated)
  Future<Paginated<Student>> list({String? query, String? grade, int? schoolId}) async {
    final qp = <String, dynamic>{};
    if (query != null && query.isNotEmpty) qp['q'] = query;
    if (grade != null && grade.isNotEmpty && grade != 'all') qp['grade'] = grade;
    if (schoolId != null) qp['school_id'] = schoolId;
    final res = await _api.dio.get('/students', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, Student.fromJson);
  }

  /// GET /students/{id}
  Future<Student> show(int id) async {
    final res = await _api.dio.get('/students/$id');
    return Student.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// Maps Dio failures to a friendly message for the UI.
  static String messageFor(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Cannot reach the server. Is the backend running?';
      }
      if (e.response?.statusCode == 401) return 'Your session expired. Please sign in again.';
      if (e.response?.statusCode == 403) return 'You don\'t have access to this.';
    }
    return 'Something went wrong. Please try again.';
  }
}
