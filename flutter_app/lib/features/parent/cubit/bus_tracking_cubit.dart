import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/bus_boarding_event.dart';
import '../../../data/models/bus_route.dart';
import '../../../data/repositories/bus_repository.dart';

/// What the parent bus-tracking screen needs: the route plus the most recent
/// boarding event (for the "boarded at … " status line).
class BusTrackingData {
  const BusTrackingData({required this.route, this.latestBoarding});
  final BusRoute route;
  final BusBoardingEvent? latestBoarding;
}

/// Loads the bus route the parent is tracking. The backend does not expose live
/// GPS coordinates, so the screen falls back to a static UAE coordinate for the
/// map marker (and notes this in the UI).
class BusTrackingCubit extends Cubit<DataState<BusTrackingData>> {
  BusTrackingCubit(this._repo, {this.routeId}) : super(const DataLoading()) {
    load();
  }

  final BusRepository _repo;
  final int? routeId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      BusRoute route;
      if (routeId != null) {
        route = await _repo.show(routeId!);
      } else {
        final page = await _repo.list();
        if (page.items.isEmpty) {
          emit(const DataError('No bus route is available to track right now.'));
          return;
        }
        route = await _repo.show(page.items.first.id);
      }

      BusBoardingEvent? latest;
      for (final e in route.events) {
        if (e.type == 'boarding') {
          if (latest == null ||
              (e.occurredAtDate != null &&
                  latest.occurredAtDate != null &&
                  e.occurredAtDate!.isAfter(latest.occurredAtDate!))) {
            latest = e;
          }
        }
      }
      emit(DataLoaded(BusTrackingData(route: route, latestBoarding: latest)));
    } catch (e) {
      emit(DataError(BusRepository.messageFor(e)));
    }
  }
}
