import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/document.dart';

/// Student documents API (see `routes/clusters/clinic.php`). Reads are open to
/// authenticated staff; upload is open to authenticated users; the review
/// action is nurse/physician-only.
class DocumentRepository {
  DocumentRepository(this._api);

  final ApiClient _api;

  /// GET /documents?status=&student_id=  (paginated, newest first)
  Future<Paginated<Document>> list({String? status, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/documents', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, Document.fromJson);
  }

  /// GET /documents/{id}
  Future<Document> show(int id) async {
    final res = await _api.dio.get('/documents/$id');
    return Document.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// Multipart upload to `POST /documents`. Stores the file on the backend's
  /// local disk and creates a pending [Document]. Returns the created record
  /// (its `fileUrl` points at the served file).
  Future<Document> upload({
    required String filePath,
    int? studentId,
    String type = 'other',
    String? title,
    String? expiryDate,
  }) async {
    final form = FormData.fromMap({
      'type': type,
      'student_id': ?studentId,
      if (title != null && title.isNotEmpty) 'title': title,
      if (expiryDate != null && expiryDate.isNotEmpty) 'expiry_date': expiryDate,
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _api.dio.post('/documents', data: form);
    return Document.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// Multipart upload from in-memory [bytes] to `POST /documents`. Works on
  /// every platform (mobile and web) since it never touches a file path.
  /// [onProgress] reports bytes sent / total for a live progress bar.
  Future<Document> uploadBytes({
    required List<int> bytes,
    required String filename,
    required int studentId,
    String type = 'other',
    String? title,
    String? expiryDate,
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData.fromMap({
      'type': type,
      'student_id': studentId,
      if (title != null && title.isNotEmpty) 'title': title,
      if (expiryDate != null && expiryDate.isNotEmpty) 'expiry_date': expiryDate,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _api.dio.post(
      '/documents',
      data: form,
      onSendProgress: onProgress,
    );
    return Document.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /documents/{id}/review  (nurse/physician). [status] is `approved`
  /// or `rejected`; [notes] is optional.
  Future<Document> review(int id, String status, {String? notes}) async {
    final res = await _api.dio.post('/documents/$id/review', data: {
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return Document.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
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
      if (status == 404) return 'This document could not be found.';
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
