import 'authorized_person.dart';
import 'student.dart';

/// A student pickup, matching `PickupResource` from the API.
class Pickup {
  const Pickup({
    required this.id,
    required this.studentId,
    this.authorizedPersonId,
    this.securityGuardId,
    this.method,
    required this.status,
    this.releasedAt,
    this.notes,
    this.student,
    this.authorizedPerson,
  });

  final int id;
  final int studentId;
  final int? authorizedPersonId;
  final int? securityGuardId;
  final String? method; // qr | manual
  final String status; // pending | verified | released | denied
  final String? releasedAt;
  final String? notes;
  final Student? student;
  final AuthorizedPerson? authorizedPerson;

  bool get isReleased => status == 'released';
  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isQr => method == 'qr';

  factory Pickup.fromJson(Map<String, dynamic> j) {
    final studentJson = j['student'];
    final student = studentJson is Map<String, dynamic> && studentJson.isNotEmpty
        ? Student.fromJson(studentJson)
        : null;

    final personJson = j['authorized_person'];
    final person = personJson is Map<String, dynamic> && personJson.isNotEmpty
        ? AuthorizedPerson.fromJson(
            personJson,
            studentId: (j['student_id'] as num?)?.toInt(),
            studentName: student?.name,
          )
        : null;

    return Pickup(
      id: (j['id'] as num).toInt(),
      studentId: (j['student_id'] as num?)?.toInt() ?? 0,
      authorizedPersonId: (j['authorized_person_id'] as num?)?.toInt(),
      securityGuardId: (j['security_guard_id'] as num?)?.toInt(),
      method: j['method'] as String?,
      status: j['status'] as String? ?? 'pending',
      releasedAt: j['released_at'] as String?,
      notes: j['notes'] as String?,
      student: student,
      authorizedPerson: person,
    );
  }
}
