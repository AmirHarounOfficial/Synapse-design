import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/repositories/analytics_repository.dart';

/// Combined analytics payload for the VP analytics screen:
/// `GET /analytics/overview` (headline counts) + `GET /analytics/health`
/// (breakdown maps).
class VicePrincipalAnalyticsData {
  const VicePrincipalAnalyticsData({required this.overview, required this.health});

  final Map<String, dynamic> overview;
  final Map<String, dynamic> health;

  int overviewCount(String key) => (overview[key] as num?)?.toInt() ?? 0;

  /// A `{label: count}` breakdown from the health payload, sorted desc.
  Map<String, int> breakdown(String key) {
    final raw = health[key];
    if (raw is Map) {
      final entries = raw.entries
          .map((e) => MapEntry(e.key.toString(), (e.value as num?)?.toInt() ?? 0))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return {for (final e in entries) e.key: e.value};
    }
    return const {};
  }

  int healthCount(String key) => (health[key] as num?)?.toInt() ?? 0;
}

/// Loads the vice-principal analytics screen (overview + health breakdowns).
class VicePrincipalAnalyticsCubit extends Cubit<DataState<VicePrincipalAnalyticsData>> {
  VicePrincipalAnalyticsCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final AnalyticsRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final results = await Future.wait([_repo.overview(), _repo.health()]);
      emit(DataLoaded(
        VicePrincipalAnalyticsData(overview: results[0], health: results[1]),
      ));
    } catch (e) {
      emit(DataError(AnalyticsRepository.messageFor(e)));
    }
  }
}
