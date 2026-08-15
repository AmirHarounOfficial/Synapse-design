/// A student document, matching `DocumentResource` from the API.
class Document {
  const Document({
    required this.id,
    required this.studentId,
    this.type,
    this.title,
    this.filePath,
    this.fileUrl,
    this.status,
    this.expiryDate,
    this.uploadedBy,
    this.reviewedBy,
    this.reviewedAt,
    this.notes,
  });

  final int id;
  final int studentId;
  final String? type;
  final String? title;
  final String? filePath;
  final String? fileUrl;

  /// pending | approved | rejected | incomplete
  final String? status;
  final String? expiryDate;
  final int? uploadedBy;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final String? notes;

  factory Document.fromJson(Map<String, dynamic> j) => Document(
        id: (j['id'] as num).toInt(),
        studentId: (j['student_id'] as num?)?.toInt() ?? 0,
        type: j['type'] as String?,
        title: j['title'] as String?,
        filePath: j['file_path'] as String?,
        fileUrl: j['file_url'] as String?,
        status: j['status'] as String?,
        expiryDate: j['expiry_date'] as String?,
        uploadedBy: (j['uploaded_by'] as num?)?.toInt(),
        reviewedBy: (j['reviewed_by'] as num?)?.toInt(),
        reviewedAt: _parseDate(j['reviewed_at']),
        notes: j['notes'] as String?,
      );

  static DateTime? _parseDate(Object? v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
