/// A scheduled dose template for a medication, matching `MedicationDoseResource`.
class MedicationDose {
  const MedicationDose({
    required this.id,
    required this.medicationId,
    this.scheduledTime,
    this.daysOfWeek = const [],
    this.label,
  });

  final int id;
  final int medicationId;

  /// `HH:mm` formatted scheduled time (the API formats it server-side).
  final String? scheduledTime;
  final List<String> daysOfWeek;
  final String? label;

  factory MedicationDose.fromJson(Map<String, dynamic> j) => MedicationDose(
        id: (j['id'] as num).toInt(),
        medicationId: (j['medication_id'] as num?)?.toInt() ?? 0,
        scheduledTime: j['scheduled_time'] as String?,
        daysOfWeek: (j['days_of_week'] as List? ?? const []).map((e) => e.toString()).toList(),
        label: j['label'] as String?,
      );
}
