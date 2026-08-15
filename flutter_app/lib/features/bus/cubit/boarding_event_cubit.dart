import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/bus_repository.dart';

/// State for recording a single boarding/deboarding event.
sealed class BoardingEventState {
  const BoardingEventState();
}

class BoardingEventIdle extends BoardingEventState {
  const BoardingEventIdle();
}

class BoardingEventSending extends BoardingEventState {
  const BoardingEventSending();
}

class BoardingEventDone extends BoardingEventState {
  const BoardingEventDone();
}

class BoardingEventFailed extends BoardingEventState {
  const BoardingEventFailed(this.message);
  final String message;
}

/// Records a boarding or deboarding event via `POST /bus-routes/{id}/events`.
class BoardingEventCubit extends Cubit<BoardingEventState> {
  BoardingEventCubit(this._repo) : super(const BoardingEventIdle());

  final BusRepository _repo;

  Future<void> record({
    required int routeId,
    required int studentId,
    required bool boarding,
    String? stopName,
  }) async {
    emit(const BoardingEventSending());
    try {
      await _repo.recordEvent(
        routeId: routeId,
        studentId: studentId,
        type: boarding ? 'boarding' : 'deboarding',
        status: boarding ? 'boarded' : 'deboarded',
        stopName: stopName,
      );
      emit(const BoardingEventDone());
    } catch (e) {
      emit(BoardingEventFailed(BusRepository.messageFor(e)));
    }
  }
}
