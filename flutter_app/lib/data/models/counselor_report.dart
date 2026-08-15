/// A counselor-generated wellbeing report, matching `CounselorReportResource`
/// from the API.
class CounselorReport {
  const CounselorReport({
    required this.id,
    this.studentId,
    this.counselorId,
    required this.type,
    this.period,
    this.status,
    this.submittedToParent = false,
    this.generatedAt,
    this.content = const {},
    this.createdAt,
  });

  final int id;
  final int? studentId;
  final int? counselorId;
  final String type; // individual | class | ...
  final String? period;
  final String? status; // draft | with_secretary | sent_to_parent | ...
  final bool submittedToParent;
  final DateTime? generatedAt;
  final Map<String, dynamic> content;
  final DateTime? createdAt;

  factory CounselorReport.fromJson(Map<String, dynamic> j) => CounselorReport(
        id: (j['id'] as num).toInt(),
        studentId: (j['student_id'] as num?)?.toInt(),
        counselorId: (j['counselor_id'] as num?)?.toInt(),
        type: j['type'] as String? ?? '',
        period: j['period'] as String?,
        status: j['status'] as String?,
        submittedToParent: j['submitted_to_parent'] as bool? ?? false,
        generatedAt: _date(j['generated_at']),
        content: (j['content'] as Map?)?.cast<String, dynamic>() ?? const {},
        createdAt: _date(j['created_at']),
      );

  static DateTime? _date(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
}
