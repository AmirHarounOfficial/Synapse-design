import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/repositories/analytics_repository.dart';

/// The two analytics payloads the principal dashboard renders together.
class HealthAnalyticsData {
  const HealthAnalyticsData({required this.overview, required this.health});

  final Map<String, dynamic> overview;
  final Map<String, dynamic> health;
}

/// Loads the FERPA-safe aggregate analytics (`GET /analytics/overview` and
/// `GET /analytics/health`).
class HealthAnalyticsCubit extends Cubit<DataState<HealthAnalyticsData>> {
  HealthAnalyticsCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final AnalyticsRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final overview = await _repo.overview();
      final health = await _repo.health();
      emit(DataLoaded(HealthAnalyticsData(overview: overview, health: health)));
    } catch (e) {
      emit(DataError(AnalyticsRepository.messageFor(e)));
    }
  }
}
