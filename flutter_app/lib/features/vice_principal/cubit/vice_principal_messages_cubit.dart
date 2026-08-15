import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/message_repository.dart';

/// Loads the internal message list (`GET /messages`) and sends new messages
/// (`POST /messages`) / replies (`POST /messages/{id}/reply`).
class VicePrincipalMessagesCubit extends Cubit<DataState<List<Message>>> {
  VicePrincipalMessagesCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final MessageRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.list();
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(MessageRepository.messageFor(e)));
    }
  }

  /// Sends a new message, then reloads the list. Returns `null` on success or a
  /// friendly error message on failure.
  Future<String?> send({
    required String subject,
    required String body,
    required String category,
    int? recipientId,
  }) async {
    try {
      await _repo.send(
        subject: subject,
        body: body,
        category: category,
        recipientId: recipientId,
      );
      await load();
      return null;
    } catch (e) {
      return MessageRepository.messageFor(e);
    }
  }

  /// Replies to a thread, then reloads. Returns `null` on success.
  Future<String?> reply(int id, String body) async {
    try {
      await _repo.reply(id, body);
      await load();
      return null;
    } catch (e) {
      return MessageRepository.messageFor(e);
    }
  }
}
