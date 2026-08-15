import 'dose_administration.dart';
import 'medication_dose.dart';

/// A medication record, matching `MedicationResource` from the API.
class Medication {
  const Medication({
    required this.id,
    required this.studentId,
    required this.name,
    this.nameAr,
    this.dosage,
    this.route,
    this.instructions,
    this.status,
    this.prescribedBy,
    this.requiresPhysician = false,
    this.approvedBy,
    this.approvedAt,
    this.supplyCount,
    this.lowSupplyThreshold,
    this.startDate,
    this.endDate,
    this.isHalalSensitive = false,
    this.doses = const [],
    this.administrations = const [],
  });

  final int id;
  final int studentId;
  final String name;
  final String? nameAr;
  final String? dosage;
  final String? route;
  final String? instructions;

  /// pending | approved | declined | active …
  final String? status;
  final String? prescribedBy;
  final bool requiresPhysician;
  final int? approvedBy;
  final String? approvedAt; // ISO-8601
  final int? supplyCount;
  final int? lowSupplyThreshold;
  final String? startDate; // yyyy-MM-dd
  final String? endDate; // yyyy-MM-dd
  final bool isHalalSensitive;

  final List<MedicationDose> doses;
  final List<DoseAdministration> administrations;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';

  /// Whether the supply is at or below its configured low-supply threshold.
  bool get isLowSupply {
    final count = supplyCount;
    final threshold = lowSupplyThreshold;
    if (count == null || threshold == null) return false;
    return count <= threshold;
  }

  /// "Name dosage" for display (e.g. "Albuterol Inhaler 90mcg").
  String get displayName => (dosage == null || dosage!.isEmpty) ? name : '$name $dosage';

  factory Medication.fromJson(Map<String, dynamic> j) => Medication(
        id: (j['id'] as num).toInt(),
        studentId: (j['student_id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        nameAr: j['name_ar'] as String?,
        dosage: j['dosage'] as String?,
        route: j['route'] as String?,
        instructions: j['instructions'] as String?,
        status: j['status'] as String?,
        prescribedBy: j['prescribed_by'] as String?,
        requiresPhysician: j['requires_physician'] as bool? ?? false,
        approvedBy: (j['approved_by'] as num?)?.toInt(),
        approvedAt: j['approved_at'] as String?,
        supplyCount: (j['supply_count'] as num?)?.toInt(),
        lowSupplyThreshold: (j['low_supply_threshold'] as num?)?.toInt(),
        startDate: j['start_date'] as String?,
        endDate: j['end_date'] as String?,
        isHalalSensitive: j['is_halal_sensitive'] as bool? ?? false,
        doses: (j['doses'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(MedicationDose.fromJson)
            .toList(),
        administrations: (j['administrations'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(DoseAdministration.fromJson)
            .toList(),
      );
}
