import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/weather_advisory.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/system_repository.dart';

/// Aggregated data for the principal dashboard: today's clinic-visit count, the
/// active weather advisory (if any), and the count of active advisories used for
/// the "Active alerts" tile.
class PrincipalDashboardData {
  const PrincipalDashboardData({
    required this.clinicVisitsToday,
    required this.activeAdvisory,
    required this.activeAlerts,
  });

  final int clinicVisitsToday;
  final WeatherAdvisory? activeAdvisory;
  final int activeAlerts;
}

/// Loads the principal dashboard: today's clinic visits
/// (`GET /clinic-visits?date=<today>`) and active weather advisories
/// (`GET /weather-advisories?active=true`).
class PrincipalDashboardCubit extends Cubit<DataState<PrincipalDashboardData>> {
  PrincipalDashboardCubit(this._systemRepo, this._clinicRepo)
      : super(const DataLoading()) {
    load();
  }

  final SystemRepository _systemRepo;
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
      final advisories = await _systemRepo.advisories(active: true);
      final visits = await _clinicRepo.listVisits(date: _today());
      emit(DataLoaded(PrincipalDashboardData(
        clinicVisitsToday: visits.total,
        activeAdvisory: advisories.items.isEmpty ? null : advisories.items.first,
        activeAlerts: advisories.total,
      )));
    } catch (e) {
      emit(DataError(SystemRepository.messageFor(e)));
    }
  }
}
