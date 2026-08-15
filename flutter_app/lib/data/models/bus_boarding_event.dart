import 'student.dart';

/// A bus boarding/deboarding event, matching `BusBoardingEventResource`.
class BusBoardingEvent {
  const BusBoardingEvent({
    required this.id,
    required this.busRouteId,
    required this.studentId,
    required this.type,
    required this.status,
    this.occurredAt,
    this.parentNotified = false,
    this.stopName,
    this.student,
  });

  final int id;
  final int busRouteId;
  final int studentId;
  final String type; // boarding | deboarding
  final String status; // boarded | deboarded | absent | pending
  final String? occurredAt;
  final bool parentNotified;
  final String? stopName;
  final Student? student;

  bool get isBoarding => type == 'boarding';
  bool get isBoarded => status == 'boarded';
  bool get isDeboarded => status == 'deboarded';

  DateTime? get occurredAtDate => occurredAt == null ? null : DateTime.tryParse(occurredAt!);

  factory BusBoardingEvent.fromJson(Map<String, dynamic> j) {
    final studentJson = j['student'];
    final student = studentJson is Map<String, dynamic> && studentJson.isNotEmpty
        ? Student.fromJson(studentJson)
        : null;
    return BusBoardingEvent(
      id: (j['id'] as num).toInt(),
      busRouteId: (j['bus_route_id'] as num?)?.toInt() ?? 0,
      studentId: (j['student_id'] as num?)?.toInt() ?? 0,
      type: j['type'] as String? ?? 'boarding',
      status: j['status'] as String? ?? 'pending',
      occurredAt: j['occurred_at'] as String?,
      parentNotified: j['parent_notified'] as bool? ?? false,
      stopName: j['stop_name'] as String?,
      student: student,
    );
  }
}
