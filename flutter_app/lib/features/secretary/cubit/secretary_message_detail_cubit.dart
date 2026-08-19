import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/message_repository.dart';

class SecretaryMessageDetailCubit extends Cubit<DataState<Message>> {
  SecretaryMessageDetailCubit(this._repo, this.id) : super(const DataLoading()) {
    load();
  }

  final MessageRepository _repo;
  final int id;

  Future<void> load() async {
    if (isClosed) return;
    emit(const DataLoading());
    try {
      final message = await _repo.show(id);
      if (isClosed) return;
      emit(DataLoaded(message));
      if (message.status == 'unread') {
        try {
          final updated = await _repo.markRead(id);
          if (!isClosed) emit(DataLoaded(updated));
        } catch (_) {
          // Non-fatal if marking read fails
        }
      }
    } catch (e) {
      if (!isClosed) emit(DataError(MessageRepository.messageFor(e)));
    }
  }

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
