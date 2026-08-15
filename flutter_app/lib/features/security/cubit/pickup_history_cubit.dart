import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/pickup.dart';
import '../../../data/repositories/pickup_repository.dart';

/// Loads released pickups for the security pickup-history screen.
class PickupHistoryCubit extends Cubit<DataState<List<Pickup>>> {
  PickupHistoryCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final PickupRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.list(status: 'released');
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(PickupRepository.messageFor(e)));
    }
  }
}
