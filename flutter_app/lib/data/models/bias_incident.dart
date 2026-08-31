/// Model representing an anti-racism, discrimination, or bias incident report.
class BiasIncident {
  const BiasIncident({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.reporterRole, // 'teacher' | 'bus_driver' | 'counselor' | 'anonymous'
    required this.reporterName,
    required this.location, // 'classroom' | 'bus' | 'cafeteria' | 'hallway' | 'online' | 'other'
    this.busRouteNumber,
    required this.category, // 'verbal_slur' | 'exclusion' | 'harassment' | 'symbol_graffiti' | 'religious_ethnic_bias' | 'other'
    required this.severity, // 'low' | 'medium' | 'high' | 'critical'
    required this.status, // 'submitted' | 'under_review' | 'action_plan_active' | 'resolved'
    required this.description,
    this.immediateActionTaken,
    this.witnesses,
    this.counselorNotes,
    this.resolutionPlan,
    required this.createdAt,
    this.resolvedAt,
  });

  final int id;
  final int studentId;
  final String studentName;
  final String reporterRole;
  final String reporterName;
  final String location;
  final String? busRouteNumber;
  final String category;
  final String severity;
  final String status;
  final String description;
  final String? immediateActionTaken;
  final String? witnesses;
  final String? counselorNotes;
  final String? resolutionPlan;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  factory BiasIncident.fromJson(Map<String, dynamic> j) => BiasIncident(
        id: (j['id'] as num).toInt(),
        studentId: (j['student_id'] as num).toInt(),
        studentName: j['student_name'] as String? ?? 'Unknown Student',
        reporterRole: j['reporter_role'] as String? ?? 'teacher',
        reporterName: j['reporter_name'] as String? ?? 'Staff Member',
        location: j['location'] as String? ?? 'classroom',
        busRouteNumber: j['bus_route_number'] as String?,
        category: j['category'] as String? ?? 'verbal_slur',
        severity: j['severity'] as String? ?? 'medium',
        status: j['status'] as String? ?? 'submitted',
        description: j['description'] as String? ?? '',
        immediateActionTaken: j['immediate_action_taken'] as String?,
        witnesses: j['witnesses'] as String?,
        counselorNotes: j['counselor_notes'] as String?,
        resolutionPlan: j['resolution_plan'] as String?,
        createdAt: _date(j['created_at']) ?? DateTime.now(),
        resolvedAt: _date(j['resolved_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'student_name': studentName,
        'reporter_role': reporterRole,
        'reporter_name': reporterName,
        'location': location,
        if (busRouteNumber != null) 'bus_route_number': busRouteNumber,
        'category': category,
        'severity': severity,
        'status': status,
        'description': description,
        if (immediateActionTaken != null) 'immediate_action_taken': immediateActionTaken,
        if (witnesses != null) 'witnesses': witnesses,
        if (counselorNotes != null) 'counselor_notes': counselorNotes,
        if (resolutionPlan != null) 'resolution_plan': resolutionPlan,
        'created_at': createdAt.toIso8601String(),
        if (resolvedAt != null) 'resolved_at': resolvedAt!.toIso8601String(),
      };

  BiasIncident copyWith({
    int? id,
    int? studentId,
    String? studentName,
    String? reporterRole,
    String? reporterName,
    String? location,
    String? busRouteNumber,
    String? category,
    String? severity,
    String? status,
    String? description,
    String? immediateActionTaken,
    String? witnesses,
    String? counselorNotes,
    String? resolutionPlan,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return BiasIncident(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      reporterRole: reporterRole ?? this.reporterRole,
      reporterName: reporterName ?? this.reporterName,
      location: location ?? this.location,
      busRouteNumber: busRouteNumber ?? this.busRouteNumber,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      description: description ?? this.description,
      immediateActionTaken: immediateActionTaken ?? this.immediateActionTaken,
      witnesses: witnesses ?? this.witnesses,
      counselorNotes: counselorNotes ?? this.counselorNotes,
      resolutionPlan: resolutionPlan ?? this.resolutionPlan,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  static DateTime? _date(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
}
