import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/audit_log.dart';
import '../../../data/repositories/system_repository.dart';

/// Loads the tamper-proof audit log from the API (`GET /audit-logs`).
class AuditLogCubit extends Cubit<DataState<List<AuditLog>>> {
  AuditLogCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final SystemRepository _repo;

  Future<void> load({String? action}) async {
    emit(const DataLoading());
    try {
      final page = await _repo.auditLogs(action: action);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(SystemRepository.messageFor(e)));
    }
  }
}
