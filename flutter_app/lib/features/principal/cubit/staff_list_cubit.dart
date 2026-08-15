import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/staff.dart';
import '../../../data/repositories/staff_repository.dart';

/// Loads the staff directory from the API (`GET /staff`), optionally filtered
/// by role.
class StaffListCubit extends Cubit<DataState<List<Staff>>> {
  StaffListCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final StaffRepository _repo;

  Future<void> load({String? role}) async {
    emit(const DataLoading());
    try {
      final page = await _repo.list(role: role);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(StaffRepository.messageFor(e)));
    }
  }
}
