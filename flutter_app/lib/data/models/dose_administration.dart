/// A logged administration of a dose, matching `DoseAdministrationResource`.
class DoseAdministration {
  const DoseAdministration({
    required this.id,
    required this.medicationId,
    required this.studentId,
    this.administeredBy,
    this.scheduledFor,
    this.administeredAt,
    this.status,
    this.notes,
  });

  final int id;
  final int medicationId;
  final int studentId;
  final int? administeredBy;

  /// ISO-8601 timestamps from the API.
  final String? scheduledFor;
  final String? administeredAt;

  /// given | missed | refused | conflict | pending
  final String? status;
  final String? notes;

  factory DoseAdministration.fromJson(Map<String, dynamic> j) => DoseAdministration(
        id: (j['id'] as num).toInt(),
        medicationId: (j['medication_id'] as num?)?.toInt() ?? 0,
        studentId: (j['student_id'] as num?)?.toInt() ?? 0,
        administeredBy: (j['administered_by'] as num?)?.toInt(),
        scheduledFor: j['scheduled_for'] as String?,
        administeredAt: j['administered_at'] as String?,
        status: j['status'] as String?,
        notes: j['notes'] as String?,
      );
}
