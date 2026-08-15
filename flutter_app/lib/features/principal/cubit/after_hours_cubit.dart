import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/after_hours_request.dart';
import '../../../data/repositories/after_hours_repository.dart';

/// Loads after-hours access requests (`GET /after-hours-requests`), creates new
/// ones, and approves/denies pending ones.
class AfterHoursCubit extends Cubit<DataState<List<AfterHoursRequest>>> {
  AfterHoursCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final AfterHoursRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.list();
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(AfterHoursRepository.messageFor(e)));
    }
  }

  /// Creates a new request, then reloads. Returns true on success.
  Future<bool> create({
    required String reason,
    String? windowStart,
    String? windowEnd,
  }) async {
    try {
      await _repo.create(reason: reason, windowStart: windowStart, windowEnd: windowEnd);
      await load();
      return true;
    } catch (e) {
      emit(DataError(AfterHoursRepository.messageFor(e)));
      return false;
    }
  }

  /// Approves or denies a pending request, then reloads. Returns true on
  /// success.
  Future<bool> respond(int id, String status) async {
    try {
      await _repo.respond(id, status);
      await load();
      return true;
    } catch (e) {
      emit(DataError(AfterHoursRepository.messageFor(e)));
      return false;
    }
  }
}
