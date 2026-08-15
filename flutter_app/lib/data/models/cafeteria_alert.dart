/// Cafeteria allergen alert, matching `CafeteriaAlertResource` from the API.
class CafeteriaAlert {
  const CafeteriaAlert({
    required this.id,
    required this.schoolId,
    this.studentId,
    this.createdBy,
    required this.title,
    required this.message,
    this.severity,
    this.isHalalIssue = false,
    this.acknowledged = false,
    this.createdForDate,
  });

  final int id;
  final int schoolId;
  final int? studentId;
  final int? createdBy;
  final String title;
  final String message;
  final String? severity; // info | warning | critical
  final bool isHalalIssue;
  final bool acknowledged;
  final String? createdForDate; // yyyy-MM-dd

  factory CafeteriaAlert.fromJson(Map<String, dynamic> j) => CafeteriaAlert(
        id: (j['id'] as num).toInt(),
        schoolId: (j['school_id'] as num?)?.toInt() ?? 0,
        studentId: (j['student_id'] as num?)?.toInt(),
        createdBy: (j['created_by'] as num?)?.toInt(),
        title: j['title'] as String? ?? '',
        message: j['message'] as String? ?? '',
        severity: j['severity'] as String?,
        isHalalIssue: j['is_halal_issue'] as bool? ?? false,
        acknowledged: j['acknowledged'] as bool? ?? false,
        createdForDate: j['created_for_date'] as String?,
      );
}
