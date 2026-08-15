import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/repositories/clinic_repository.dart';

/// Summary figures for the vice-principal (deputy) dashboard. Currently the only
/// API-backed figure is today's clinic-visit count.
class VicePrincipalDashboardData {
  const VicePrincipalDashboardData({required this.clinicVisitsToday});

  final int clinicVisitsToday;
}

/// Loads the deputy dashboard summary: today's clinic-visit count
/// (`GET /clinic-visits?date=<today>`).
class VicePrincipalDashboardCubit extends Cubit<DataState<VicePrincipalDashboardData>> {
  VicePrincipalDashboardCubit(this._clinicRepo) : super(const DataLoading()) {
    load();
  }

  final ClinicRepository _clinicRepo;

  static String _today() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final visits = await _clinicRepo.listVisits(date: _today());
      emit(DataLoaded(VicePrincipalDashboardData(clinicVisitsToday: visits.total)));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }
}
