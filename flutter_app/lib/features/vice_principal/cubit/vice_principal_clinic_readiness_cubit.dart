import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/repositories/analytics_repository.dart';

/// Loads the clinic-readiness indicators (`GET /analytics/clinic-readiness`).
/// The payload is a flat map of counts/percentages, handed to the UI as-is.
class VicePrincipalClinicReadinessCubit extends Cubit<DataState<Map<String, dynamic>>> {
  VicePrincipalClinicReadinessCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final AnalyticsRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      emit(DataLoaded(await _repo.clinicReadiness()));
    } catch (e) {
      emit(DataError(AnalyticsRepository.messageFor(e)));
    }
  }
}
