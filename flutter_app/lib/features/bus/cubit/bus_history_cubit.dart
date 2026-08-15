import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/bus_boarding_event.dart';
import '../../../data/repositories/bus_repository.dart';

/// Loads the boarding/deboarding event log for the route-history screen.
/// Aggregates events across the driver's routes (or a single [routeId]).
class BusHistoryCubit extends Cubit<DataState<List<BusBoardingEvent>>> {
  BusHistoryCubit(this._repo, {this.routeId}) : super(const DataLoading()) {
    load();
  }

  final BusRepository _repo;
  final int? routeId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final events = <BusBoardingEvent>[];
      if (routeId != null) {
        events.addAll((await _repo.show(routeId!)).events);
      } else {
        final page = await _repo.list();
        for (final r in page.items) {
          events.addAll((await _repo.show(r.id)).events);
        }
      }
      events.sort((a, b) {
        final da = a.occurredAtDate;
        final db = b.occurredAtDate;
        if (da == null || db == null) return 0;
        return db.compareTo(da);
      });
      emit(DataLoaded(events));
    } catch (e) {
      emit(DataError(BusRepository.messageFor(e)));
    }
  }
}
