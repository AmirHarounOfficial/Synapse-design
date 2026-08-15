import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/counselor_report.dart';
import '../models/counselor_tag.dart';

/// Counselor wellbeing API (confidential — counselor role only on the backend;
/// see `routes/clusters/wellbeing_system.php`). Covers wellbeing tags and
/// generated reports.
class CounselorRepository {
  CounselorRepository(this._api);

  final ApiClient _api;

  // ── Tags ────────────────────────────────────────────────────────────────

  /// GET /counselor-tags?student_id=  (paginated)
  Future<Paginated<CounselorTag>> tags({int? studentId}) async {
    final qp = <String, dynamic>{};
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/counselor-tags', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, CounselorTag.fromJson);
  }

  /// POST /counselor-tags
  Future<CounselorTag> createTag({
    required int studentId,
    List<String> tags = const [],
    String? notes,
    String? context,
  }) async {
    final res = await _api.dio.post('/counselor-tags', data: {
      'student_id': studentId,
      'tags': tags,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (context != null && context.isNotEmpty) 'context': context,
    });
    return CounselorTag.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // ── Reports ─────────────────────────────────────────────────────────────

  /// GET /counselor-reports?status=&student_id=  (paginated)
  Future<Paginated<CounselorReport>> reports({String? status, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/counselor-reports', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, CounselorReport.fromJson);
  }

  /// GET /counselor-reports/{id}
  Future<CounselorReport> showReport(int id) async {
    final res = await _api.dio.get('/counselor-reports/$id');
    return CounselorReport.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /counselor-reports
  Future<CounselorReport> createReport({
    int? studentId,
    required String type,
    String? period,
    String? status,
    bool submittedToParent = false,
    Map<String, dynamic>? content,
  }) async {
    final res = await _api.dio.post('/counselor-reports', data: {
      'student_id': ?studentId,
      'type': type,
      if (period != null && period.isNotEmpty) 'period': period,
      if (status != null && status.isNotEmpty) 'status': status,
      'submitted_to_parent': submittedToParent,
      'content': ?content,
    });
    return CounselorReport.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// Maps Dio failures (incl. 422 validation) to a friendly message for the UI.
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
      if (code == 422) {
        final errors = e.response?.data is Map ? (e.response?.data as Map)['errors'] : null;
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
