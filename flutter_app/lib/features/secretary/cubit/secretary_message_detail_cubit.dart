import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/message_repository.dart';

/// Loads a single message (`GET /messages/{id}`), marks it read on open when
/// unread (`POST /messages/{id}/read`), and sends replies
/// (`POST /messages/{id}/reply`).
class SecretaryMessageDetailCubit extends Cubit<DataState<Message>> {
  SecretaryMessageDetailCubit(this._repo, this.id) : super(const DataLoading()) {
    load();
  }

  final MessageRepository _repo;
  final int id;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final message = await _repo.show(id);
      emit(DataLoaded(message));
      // Mark read on open when unread; refresh the loaded record in place.
      if (message.status == 'unread') {
        try {
          final updated = await _repo.markRead(id);
          if (!isClosed) emit(DataLoaded(updated));
        } catch (_) {
          // Non-fatal: leave the message as-is if marking read fails.
        }
      }
    } catch (e) {
      emit(DataError(MessageRepository.messageFor(e)));
    }
  }

  /// Sends a reply. Returns true on success.
  Future<bool> reply(String body) async {
    if (body.trim().isEmpty) return false;
    try {
      await _repo.reply(id, body.trim());
      return true;
    } catch (_) {
      return false;
    }
  }
}
