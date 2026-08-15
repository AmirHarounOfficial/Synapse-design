import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/models/dose_administration.dart';
import '../../../data/models/medication.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/document_repository.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/repositories/student_repository.dart';

/// One upcoming-dose row: the administration joined to its medication and the
/// student it belongs to (names resolved from the student directory).
class UpcomingDose {
  const UpcomingDose({required this.administration, this.medication, this.student});

  final DoseAdministration administration;
  final Medication? medication;
  final Student? student;

  String get studentName => student?.name ?? 'Student #${administration.studentId}';
  String get initials => student?.initials ?? '?';
  String get medicationLabel =>
      medication?.displayName ?? 'Medication #${administration.medicationId}';

  /// Pending administrations are surfaced as "urgent" on the dashboard.
  bool get isUrgent => administration.status == 'pending';
}

/// One recent-visit row joined to its student for display.
class RecentVisit {
  const RecentVisit({required this.visit, this.student});

  final ClinicVisit visit;
  final Student? student;

  String get studentName => student?.name ?? 'Student #${visit.studentId}';
}

/// Aggregated view-model for the nurse dashboard.
class NurseDashboardData {
  const NurseDashboardData({
    required this.medicationCount,
    required this.pendingMedicationCount,
    required this.visitsTodayCount,
    required this.pendingDocumentCount,
    required this.pendingPhysicianApprovals,
    required this.upcomingDoses,
    required this.recentVisits,
  });

  final int medicationCount;
  final int pendingMedicationCount;
  final int visitsTodayCount;
  final int pendingDocumentCount;
  final int pendingPhysicianApprovals;
  final List<UpcomingDose> upcomingDoses;
  final List<RecentVisit> recentVisits;
}

/// Loads and aggregates the nurse dashboard from the medications, dose, clinic
/// and document list endpoints. Counts are derived from the list responses.
class NurseDashboardCubit extends Cubit<DataState<NurseDashboardData>> {
  NurseDashboardCubit(this._meds, this._clinic, this._documents, this._students)
      : super(const DataLoading()) {
    load();
  }

  final MedicationRepository _meds;
  final ClinicRepository _clinic;
  final DocumentRepository _documents;
  final StudentRepository _students;

  static String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final today = _today();
      final medsPage = await _meds.list();
      final dosesPage = await _meds.doseAdministrations(date: today);
      final visitsPage = await _clinic.listVisits(date: today);
      final pendingDocsPage = await _documents.list(status: 'pending');
      final studentsPage = await _students.list();

      final medsById = {for (final m in medsPage.items) m.id: m};
      final studentsById = {for (final s in studentsPage.items) s.id: s};

      final pendingMeds = medsPage.items.where((m) => m.isPending).toList();
      // Physician approvals: medications that still need a physician sign-off.
      final pendingPhysician = medsPage.items
          .where((m) => m.requiresPhysician && m.isPending)
          .length;

      // Upcoming doses = today's administrations not yet given (newest first).
      final upcoming = dosesPage.items
          .where((d) => d.status != 'given')
          .map((d) => UpcomingDose(
                administration: d,
                medication: medsById[d.medicationId],
                student: studentsById[d.studentId],
              ))
          .toList();

      final recent = visitsPage.items
          .take(2)
          .map((v) => RecentVisit(visit: v, student: studentsById[v.studentId]))
          .toList();

      emit(DataLoaded(NurseDashboardData(
        medicationCount: medsPage.items.length,
        pendingMedicationCount: pendingMeds.length,
        visitsTodayCount: visitsPage.items.length,
        // Documents from parents still awaiting nurse review.
        pendingDocumentCount: pendingDocsPage.total,
        pendingPhysicianApprovals: pendingPhysician,
        upcomingDoses: upcoming,
        recentVisits: recent,
      )));
    } catch (e) {
      emit(DataError(MedicationRepository.messageFor(e)));
    }
  }
}
