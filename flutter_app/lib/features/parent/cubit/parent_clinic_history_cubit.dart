import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/repositories/clinic_repository.dart';

/// Loads a child's clinic visit history (`GET /clinic-visits`).
class ParentClinicHistoryCubit extends Cubit<DataState<List<ClinicVisit>>> {
  ParentClinicHistoryCubit(this._repo, {this.studentId}) : super(const DataLoading()) {
    load();
  }

  final ClinicRepository _repo;
  final int? studentId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.listVisits(studentId: studentId);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }
}
