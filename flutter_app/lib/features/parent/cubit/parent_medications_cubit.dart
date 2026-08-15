import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/dose_administration.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';

/// A medication together with its administration records, for the parent's
/// read-only medications list.
class ParentMedicationItem {
  const ParentMedicationItem({required this.medication, required this.administrations});

  final Medication medication;
  final List<DoseAdministration> administrations;
}

/// Loads the child's medications for the legacy parent "Medications" tab
/// (`GET /medications` + `GET /dose-administrations`). Unlike the medication
/// *log*, this keeps medications with no doses yet so the full list is shown.
class ParentMedicationsCubit extends Cubit<DataState<List<ParentMedicationItem>>> {
  ParentMedicationsCubit(this._repo, {this.studentId}) : super(const DataLoading()) {
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
      final items = meds.items
          .map((m) => ParentMedicationItem(
                medication: m,
                administrations: byMed[m.id] ?? const [],
              ))
          .toList();
      emit(DataLoaded(items));
    } catch (e) {
      emit(DataError(MedicationRepository.messageFor(e)));
    }
  }
}
