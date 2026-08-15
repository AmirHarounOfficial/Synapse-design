import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';

/// Loads the medications list from the API (`GET /medications`).
class MedicationListCubit extends Cubit<DataState<List<Medication>>> {
  MedicationListCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final MedicationRepository _repo;

  Future<void> load({String? status}) async {
    emit(const DataLoading());
    try {
      final page = await _repo.list(status: status);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(MedicationRepository.messageFor(e)));
    }
  }
}
