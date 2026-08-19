import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/message_repository.dart';

class SecretaryMessagesInboxCubit extends Cubit<DataState<List<Message>>> {
  SecretaryMessagesInboxCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final MessageRepository _repo;

  Future<void> load() async {
    if (isClosed) return;
    emit(const DataLoading());
    try {
      final page = await _repo.list();
      if (!isClosed) emit(DataLoaded(page.items));
    } catch (e) {
      if (!isClosed) emit(DataError(MessageRepository.messageFor(e)));
    }
  }
}
