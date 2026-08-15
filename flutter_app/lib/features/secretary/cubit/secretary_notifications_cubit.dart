import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';

/// Loads the authenticated secretary's in-app notifications
/// (`GET /notifications`) and marks them read (`POST /notifications/{id}/read`).
/// Mirrors the parent notifications cubit, kept in the secretary feature.
class SecretaryNotificationsCubit extends Cubit<DataState<List<AppNotification>>> {
  SecretaryNotificationsCubit(this._repo) : super(const DataLoading()) {
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

  /// Marks a single notification read and updates it in place.
  Future<void> markRead(int id) async {
    final current = state;
    if (current is! DataLoaded<List<AppNotification>>) return;
    final item = current.data.firstWhere(
      (n) => n.id == id,
      orElse: () => current.data.first,
    );
    if (!item.isUnread) return;
    try {
      final updated = await _repo.markRead(id);
      final next = [
        for (final n in current.data) n.id == id ? updated : n,
      ];
      emit(DataLoaded(next));
    } catch (_) {
      // Leave state unchanged on failure; the unread dot stays.
    }
  }
}
