import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/weather_advisory.dart';
import '../../../data/repositories/system_repository.dart';

/// Loads the current active advisory (`GET /weather-advisories?active=1`) and
/// handles issuing/lifting advisories for the principal screen. The loaded
/// value is the active advisory, or null when none is active.
class WeatherAdvisoryCubit extends Cubit<DataState<WeatherAdvisory?>> {
  WeatherAdvisoryCubit(this._repo) : super(const DataLoading()) {
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

  /// Issues (creates) a new active advisory. Returns null on success or an
  /// error message on failure (so the screen can surface a snackbar).
  Future<String?> issue({
    required String kind,
    String? severity,
    required String message,
  }) async {
    try {
      final advisory = await _repo.createAdvisory(
        kind: kind,
        severity: severity,
        message: message,
        active: true,
      );
      emit(DataLoaded(advisory));
      return null;
    } catch (e) {
      return SystemRepository.messageFor(e);
    }
  }

  /// Lifts (deactivates) the current advisory. Returns null on success or an
  /// error message on failure.
  Future<String?> lift() async {
    final current = state;
    if (current is! DataLoaded<WeatherAdvisory?> || current.data == null) {
      return null;
    }
    try {
      await _repo.setAdvisoryActive(current.data!.id, false);
      emit(const DataLoaded(null));
      return null;
    } catch (e) {
      return SystemRepository.messageFor(e);
    }
  }
}
