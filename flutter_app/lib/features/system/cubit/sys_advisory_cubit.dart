import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/weather_advisory.dart';
import '../../../data/repositories/system_repository.dart';

/// Fetches the currently active weather advisory for the system banner
/// (`GET /weather-advisories?active=1`). The loaded value is the active
/// advisory, or null when none is active.
class SysAdvisoryCubit extends Cubit<DataState<WeatherAdvisory?>> {
  SysAdvisoryCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final SystemRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final advisory = await _repo.activeAdvisory();
      emit(DataLoaded(advisory));
    } catch (e) {
      emit(DataError(SystemRepository.messageFor(e)));
    }
  }
}
