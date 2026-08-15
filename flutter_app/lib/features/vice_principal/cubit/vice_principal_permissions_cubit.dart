import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/role_capability.dart';
import '../../../data/repositories/permission_repository.dart';

/// Loads the role/capability matrix (`GET /permissions`) for the read-only
/// VP permissions view.
class VicePrincipalPermissionsCubit
    extends Cubit<DataState<Map<String, List<RoleCapability>>>> {
  VicePrincipalPermissionsCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final PermissionRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      emit(DataLoaded(await _repo.matrix()));
    } catch (e) {
      emit(DataError(PermissionRepository.messageFor(e)));
    }
  }
}
