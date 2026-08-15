/// A clinic visit, matching `ClinicVisitResource` from the API.
class ClinicVisit {
  const ClinicVisit({
    required this.id,
    required this.studentId,
    this.schoolId,
    this.nurseId,
    this.reason,
    this.reasonAr,
    this.notes,
    this.severity,
    this.isEmergency = false,
    this.visitedAt,
    this.outcome,
    this.photoUrl,
  });

  final int id;
  final int studentId;
  final int? schoolId;
  final int? nurseId;
  final String? reason;
  final String? reasonAr;
  final String? notes;
  final String? severity;
  final bool isEmergency;
  final DateTime? visitedAt;
  final String? outcome;
  final String? photoUrl;

  factory ClinicVisit.fromJson(Map<String, dynamic> j) => ClinicVisit(
        id: (j['id'] as num).toInt(),
        studentId: (j['student_id'] as num?)?.toInt() ?? 0,
        schoolId: (j['school_id'] as num?)?.toInt(),
        nurseId: (j['nurse_id'] as num?)?.toInt(),
        reason: j['reason'] as String?,
        reasonAr: j['reason_ar'] as String?,
        notes: j['notes'] as String?,
        severity: j['severity'] as String?,
        isEmergency: j['is_emergency'] as bool? ?? false,
        visitedAt: _parseDate(j['visited_at']),
        outcome: j['outcome'] as String?,
        photoUrl: j['photo_url'] as String?,
      );

  static DateTime? _parseDate(Object? v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
