import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/repositories/clinic_repository.dart';

/// Loads the clinic visit log from the API (`GET /clinic-visits`).
class ClinicVisitListCubit extends Cubit<DataState<List<ClinicVisit>>> {
  ClinicVisitListCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final ClinicRepository _repo;

  Future<void> load({String? date, int? studentId}) async {
    emit(const DataLoading());
    try {
      final page = await _repo.listVisits(date: date, studentId: studentId);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }
}
