import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/pickup.dart';
import '../../../data/repositories/pickup_repository.dart';

/// Loads the pickup queue (pending + verified). Used by the security pickups
/// queue screen.
class PickupQueueCubit extends Cubit<DataState<List<Pickup>>> {
  PickupQueueCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final PickupRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      // The queue is everything not yet released; fetch the latest page and
      // filter out released/denied client-side so both sections render.
      final page = await _repo.list();
      final queue = page.items
          .where((p) => p.status == 'pending' || p.status == 'verified')
          .toList();
      emit(DataLoaded(queue));
    } catch (e) {
      emit(DataError(PickupRepository.messageFor(e)));
    }
  }
}
