import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';

/// Loads the authenticated user's notifications (`GET /notifications`) and
/// handles the mark-read action. Shared by the nurse and teacher notification
/// screens.
class NotificationsCubit extends Cubit<DataState<List<AppNotification>>> {
  NotificationsCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final NotificationRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.list();
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(NotificationRepository.messageFor(e)));
    }
  }

  /// Marks one notification read and patches it in place (optimistic-ish:
  /// only emits on success, swapping the server-confirmed record).
  Future<void> markRead(int id) async {
    final current = state;
    if (current is! DataLoaded<List<AppNotification>>) return;
    try {
      final updated = await _repo.markRead(id);
      emit(DataLoaded([
        for (final n in current.data) if (n.id == id) updated else n,
      ]));
    } catch (_) {
      // Keep current state; the UI navigation still proceeds.
    }
  }

  /// Marks every unread notification read.
  Future<void> markAllRead() async {
    final current = state;
    if (current is! DataLoaded<List<AppNotification>>) return;
    final unread = current.data.where((n) => n.isUnread).toList();
    for (final n in unread) {
      await markRead(n.id);
    }
  }
}
