import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';

/// Loads a single medication record from the API (`GET /medications/{id}`).
class MedicationDetailCubit extends Cubit<DataState<Medication>> {
  MedicationDetailCubit(this._repo, this._id) : super(const DataLoading()) {
    load();
  }

  final MedicationRepository _repo;
  final int _id;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final medication = await _repo.show(_id);
      emit(DataLoaded(medication));
    } catch (e) {
      emit(DataError(MedicationRepository.messageFor(e)));
    }
  }

  /// Logs a "given" dose for this medication, then refreshes the record.
  /// Returns null on success or an error message on failure.
  Future<String?> markAsGiven() async {
    final current = state;
    if (current is! DataLoaded<Medication>) return 'Medication not loaded yet.';
    final med = current.data;
    try {
      await _repo.logDose(
        medicationId: med.id,
        studentId: med.studentId,
        status: 'given',
      );
      await load();
      return null;
    } catch (e) {
      return MedicationRepository.messageFor(e);
    }
  }
}
