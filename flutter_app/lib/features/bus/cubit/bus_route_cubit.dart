import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/bus_route.dart';
import '../../../data/repositories/bus_repository.dart';

/// Loads the active bus route (with its manifest of events) for the driver's
/// route-overview screen. If no [routeId] is given, the first route is used.
class BusRouteCubit extends Cubit<DataState<BusRoute>> {
  BusRouteCubit(this._repo, {this.routeId}) : super(const DataLoading()) {
    load();
  }

  final BusRepository _repo;
  final int? routeId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      if (routeId != null) {
        emit(DataLoaded(await _repo.show(routeId!)));
        return;
      }
      final page = await _repo.list();
      if (page.items.isEmpty) {
        emit(const DataError('No bus routes are assigned yet.'));
        return;
      }
      // The list resource omits events; fetch the full route for the manifest.
      final full = await _repo.show(page.items.first.id);
      emit(DataLoaded(full));
    } catch (e) {
      emit(DataError(BusRepository.messageFor(e)));
    }
  }
}
