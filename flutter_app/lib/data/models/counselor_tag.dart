/// A confidential wellbeing tag logged by a counselor, matching
/// `CounselorTagResource` from the API.
class CounselorTag {
  const CounselorTag({
    required this.id,
    required this.studentId,
    this.counselorId,
    this.tags = const [],
    this.notes,
    this.context,
    this.taggedAt,
    this.createdAt,
  });

  final int id;
  final int? studentId;
  final int? counselorId;
  final List<String> tags;
  final String? notes;
  final String? context;
  final DateTime? taggedAt;
  final DateTime? createdAt;

  factory CounselorTag.fromJson(Map<String, dynamic> j) => CounselorTag(
        id: (j['id'] as num).toInt(),
        studentId: (j['student_id'] as num?)?.toInt(),
        counselorId: (j['counselor_id'] as num?)?.toInt(),
        tags: (j['tags'] as List? ?? const []).map((e) => e.toString()).toList(),
        notes: j['notes'] as String?,
        context: j['context'] as String?,
        taggedAt: _date(j['tagged_at']),
        createdAt: _date(j['created_at']),
      );

  static DateTime? _date(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
}
