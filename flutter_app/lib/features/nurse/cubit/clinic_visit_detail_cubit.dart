import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/repositories/clinic_repository.dart';

/// Loads a single clinic visit from the API (`GET /clinic-visits/{id}`).
class ClinicVisitDetailCubit extends Cubit<DataState<ClinicVisit>> {
  ClinicVisitDetailCubit(this._repo, this._id) : super(const DataLoading()) {
    load();
  }

  final ClinicRepository _repo;
  final int _id;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final visit = await _repo.showVisit(_id);
      emit(DataLoaded(visit));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }
}
