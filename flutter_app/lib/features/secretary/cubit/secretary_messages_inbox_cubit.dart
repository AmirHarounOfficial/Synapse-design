import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/message_repository.dart';

/// Loads the secretary's message inbox (`GET /messages`). Category filtering
/// for the tab chips is applied client-side over the loaded page.
class SecretaryMessagesInboxCubit extends Cubit<DataState<List<Message>>> {
  SecretaryMessagesInboxCubit(this._repo) : super(const DataLoading()) {
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
}
