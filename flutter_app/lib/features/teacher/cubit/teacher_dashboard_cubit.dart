import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/repositories/clinic_repository.dart';

/// Loads today's clinic visits for the teacher dashboard
/// (`GET /clinic-visits?date=<today>`).
class TeacherDashboardCubit extends Cubit<DataState<List<ClinicVisit>>> {
  TeacherDashboardCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final ClinicRepository _repo;

  static String _today() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.listVisits(date: _today());
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }
}
