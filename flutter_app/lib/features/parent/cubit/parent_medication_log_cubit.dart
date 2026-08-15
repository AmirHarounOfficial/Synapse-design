import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/dose_administration.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';

/// A medication together with its administration records, for the read-only
/// parent log grouped by medication.
class MedicationLogGroup {
  const MedicationLogGroup({required this.medication, required this.administrations});

  final Medication medication;
  final List<DoseAdministration> administrations;
}

/// Loads the parent's read-only medication administration log. Groups dose
/// administrations under their medication (`GET /medications` +
/// `GET /dose-administrations`).
class ParentMedicationLogCubit extends Cubit<DataState<List<MedicationLogGroup>>> {
  ParentMedicationLogCubit(this._repo, {this.studentId}) : super(const DataLoading()) {
    load();
  }

  final MedicationRepository _repo;
  final int? studentId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final meds = await _repo.list(studentId: studentId);
      final admins = await _repo.doseAdministrations(studentId: studentId);
      final byMed = <int, List<DoseAdministration>>{};
      for (final a in admins.items) {
        byMed.putIfAbsent(a.medicationId, () => []).add(a);
      }
      final groups = meds.items
          .map((m) => MedicationLogGroup(
                medication: m,
                administrations: byMed[m.id] ?? const [],
              ))
          .where((g) => g.administrations.isNotEmpty)
          .toList();
      emit(DataLoaded(groups));
    } catch (e) {
      emit(DataError(MedicationRepository.messageFor(e)));
    }
  }
}
