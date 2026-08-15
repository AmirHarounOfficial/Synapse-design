import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/chatbot.dart';
import '../../../data/repositories/chatbot_repository.dart';

/// Loads the chatbot escalation queue (`GET /chatbot-conversations`).
class SecretaryChatbotQueueCubit extends Cubit<DataState<List<ChatbotConversation>>> {
  SecretaryChatbotQueueCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final ChatbotRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.list();
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(ChatbotRepository.messageFor(e)));
    }
  }
}
