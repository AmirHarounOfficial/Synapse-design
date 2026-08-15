import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/equipment_item.dart';
import '../../../data/repositories/equipment_repository.dart';

/// Loads the clinic equipment checklist (`GET /equipment-items`) and applies
/// status changes (`PUT /equipment-items/{id}`).
class VicePrincipalEquipmentCubit extends Cubit<DataState<List<EquipmentItem>>> {
  VicePrincipalEquipmentCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final EquipmentRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.list();
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(EquipmentRepository.messageFor(e)));
    }
  }

  /// Updates an item's status and swaps it into the loaded list in place.
  /// Returns `null` on success, or a friendly error message on failure.
  Future<String?> updateStatus(int id, String status) async {
    try {
      final updated = await _repo.update(id, status: status);
      final current = state;
      if (current is DataLoaded<List<EquipmentItem>>) {
        emit(DataLoaded([
          for (final item in current.data) item.id == id ? updated : item,
        ]));
      }
      return null;
    } catch (e) {
      return EquipmentRepository.messageFor(e);
    }
  }
}
