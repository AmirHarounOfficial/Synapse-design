import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/repositories/analytics_repository.dart';

/// Loads the annual-report rollups (`GET /analytics/annual-report?year=`).
class AnnualReportCubit extends Cubit<DataState<Map<String, dynamic>>> {
  AnnualReportCubit(this._repo, {int? year}) : super(const DataLoading()) {
    load(year: year);
  }

  final AnalyticsRepository _repo;

  Future<void> load({int? year}) async {
    emit(const DataLoading());
    try {
      final data = await _repo.annualReport(year: year);
      emit(DataLoaded(data));
    } catch (e) {
      emit(DataError(AnalyticsRepository.messageFor(e)));
    }
  }
}
