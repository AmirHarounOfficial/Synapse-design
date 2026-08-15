/// An emergency consent request, matching `EmergencyConsentResource`.
class EmergencyConsent {
  const EmergencyConsent({
    required this.id,
    required this.studentId,
    this.clinicVisitId,
    this.requestedBy,
    this.parentId,
    this.status,
    this.details,
    this.respondedAt,
  });

  final int id;
  final int studentId;
  final int? clinicVisitId;
  final int? requestedBy;
  final int? parentId;

  /// pending | approved | declined
  final String? status;
  final String? details;
  final DateTime? respondedAt;

  bool get isPending => status == null || status == 'pending';

  factory EmergencyConsent.fromJson(Map<String, dynamic> j) => EmergencyConsent(
        id: (j['id'] as num).toInt(),
        studentId: (j['student_id'] as num?)?.toInt() ?? 0,
        clinicVisitId: (j['clinic_visit_id'] as num?)?.toInt(),
        requestedBy: (j['requested_by'] as num?)?.toInt(),
        parentId: (j['parent_id'] as num?)?.toInt(),
        status: j['status'] as String?,
        details: j['details'] as String?,
        respondedAt: _parseDate(j['responded_at']),
      );

  static DateTime? _parseDate(Object? v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
