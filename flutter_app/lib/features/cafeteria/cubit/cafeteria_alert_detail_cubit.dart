import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/cafeteria_alert.dart';
import '../../../data/repositories/cafeteria_repository.dart';

/// Loads a single cafeteria alert (`GET /cafeteria-alerts/{id}`) and handles
/// the acknowledge/confirm action (`POST .../acknowledge`).
class CafeteriaAlertDetailCubit extends Cubit<DataState<CafeteriaAlert>> {
  CafeteriaAlertDetailCubit(this._repo, this.id) : super(const DataLoading()) {
    load();
  }

  final CafeteriaRepository _repo;
  final int id;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      emit(DataLoaded(await _repo.alert(id)));
    } catch (e) {
      emit(DataError(CafeteriaRepository.messageFor(e)));
    }
  }

  /// Acknowledge/confirm this alert. Returns null on success, an error message
  /// on failure (so the screen can show the mapped error).
  Future<String?> acknowledge() async {
    try {
      emit(DataLoaded(await _repo.acknowledgeAlert(id)));
      return null;
    } catch (e) {
      return CafeteriaRepository.messageFor(e);
    }
  }
}
