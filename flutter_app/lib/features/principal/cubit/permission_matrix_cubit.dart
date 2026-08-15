import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/role_capability.dart';
import '../../../data/repositories/permission_repository.dart';

/// Loads the role/capability matrix (`GET /permissions`) and persists edits
/// (`PUT /permissions`).
class PermissionMatrixCubit extends Cubit<DataState<Map<String, List<RoleCapability>>>> {
  PermissionMatrixCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final PermissionRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final matrix = await _repo.matrix();
      emit(DataLoaded(matrix));
    } catch (e) {
      emit(DataError(PermissionRepository.messageFor(e)));
    }
  }

  /// Persists the collected toggle changes, then reloads. Returns true on
  /// success (leaving the loaded state untouched on failure).
  Future<bool> save(
    List<({String role, String capability, bool allowed})> changes,
  ) async {
    try {
      await _repo.update(changes);
      await load();
      return true;
    } catch (e) {
      emit(DataError(PermissionRepository.messageFor(e)));
      return false;
    }
  }
}
