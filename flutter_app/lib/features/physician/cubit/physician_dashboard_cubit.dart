import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/models/medication.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/repositories/student_repository.dart';

/// A medication awaiting physician sign-off, joined to its student.
class PendingProtocol {
  const PendingProtocol({required this.medication, this.student});

  final Medication medication;
  final Student? student;

  String get studentName => student?.name ?? 'Student #${medication.studentId}';
  String get medicationLabel => medication.displayName;
  String get dose => medication.dosage ?? '';
  String get proposedBy => medication.prescribedBy ?? '';
}

/// An emergency clinic visit surfaced as a clinical escalation.
class Escalation {
  const Escalation({required this.visit, this.student});

  final ClinicVisit visit;
  final Student? student;

  String get studentName => student?.name ?? 'Student #${visit.studentId}';
  String get grade => student?.grade ?? '';
  String get issue => visit.reason ?? '';
  DateTime? get at => visit.visitedAt;
}

/// Aggregated view-model for the physician dashboard.
class PhysicianDashboardData {
  const PhysicianDashboardData({
    required this.pendingProtocols,
    required this.escalations,
  });

  final List<PendingProtocol> pendingProtocols;
  final List<Escalation> escalations;
}

/// Loads the physician dashboard: medications awaiting approval (pending +
/// requires_physician) and today's emergency clinic visits as escalations.
/// Reports awaiting co-signature have no backing endpoint and stay static.
class PhysicianDashboardCubit extends Cubit<DataState<PhysicianDashboardData>> {
  PhysicianDashboardCubit(this._meds, this._clinic, this._students)
      : super(const DataLoading()) {
    load();
  }

  final MedicationRepository _meds;
  final ClinicRepository _clinic;
  final StudentRepository _students;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final pendingMeds = await _meds.list(status: 'pending');
      final visits = await _clinic.listVisits();
      final studentsPage = await _students.list();
      final studentsById = {for (final s in studentsPage.items) s.id: s};

      final protocols = pendingMeds.items
          .where((m) => m.requiresPhysician)
          .map((m) => PendingProtocol(medication: m, student: studentsById[m.studentId]))
          .toList();

      final escalations = visits.items
          .where((v) => v.isEmergency)
          .map((v) => Escalation(visit: v, student: studentsById[v.studentId]))
          .toList();

      emit(DataLoaded(PhysicianDashboardData(
        pendingProtocols: protocols,
        escalations: escalations,
      )));
    } catch (e) {
      emit(DataError(MedicationRepository.messageFor(e)));
    }
  }
}
