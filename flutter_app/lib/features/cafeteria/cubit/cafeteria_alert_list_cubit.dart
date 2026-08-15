import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/cafeteria_alert.dart';
import '../../../data/repositories/cafeteria_repository.dart';

/// Loads the cafeteria allergen-alert list (`GET /cafeteria-alerts`).
/// Defaults to the unacknowledged alerts the role still needs to action.
class CafeteriaAlertListCubit extends Cubit<DataState<List<CafeteriaAlert>>> {
  CafeteriaAlertListCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final CafeteriaRepository _repo;

  Future<void> load({bool? acknowledged}) async {
    emit(const DataLoading());
    try {
      final page = await _repo.alerts(acknowledged: acknowledged);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(CafeteriaRepository.messageFor(e)));
    }
  }

  /// Acknowledge an alert and refresh the list on success.
  Future<bool> acknowledge(int id) async {
    try {
      await _repo.acknowledgeAlert(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
