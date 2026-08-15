import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/chatbot.dart';
import '../../../data/repositories/chatbot_repository.dart';

/// Loads a chatbot conversation with its message thread
/// (`GET /chatbot-conversations/{id}`) and posts staff replies
/// (`POST /chatbot-conversations/{id}/messages`).
class SecretaryChatbotThreadCubit extends Cubit<DataState<ChatbotConversation>> {
  SecretaryChatbotThreadCubit(this._repo, this.id) : super(const DataLoading()) {
    load();
  }

  final ChatbotRepository _repo;
  final int id;

  bool sending = false;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final conversation = await _repo.show(id);
      emit(DataLoaded(conversation));
    } catch (e) {
      emit(DataError(ChatbotRepository.messageFor(e)));
    }
  }

  /// Posts a reply and appends the returned message to the thread. Returns true
  /// on success.
  Future<bool> sendReply(String body) async {
    final current = state;
    if (current is! DataLoaded<ChatbotConversation>) return false;
    if (body.trim().isEmpty || sending) return false;
    sending = true;
    try {
      final message = await _repo.postMessage(id, body.trim());
      final convo = current.data;
      final next = ChatbotConversation(
        id: convo.id,
        parentName: convo.parentName,
        subject: convo.subject,
        status: convo.status,
        priority: convo.priority,
        assignedTo: convo.assignedTo,
        messageCount: convo.messageCount + 1,
        firstMessage: convo.firstMessage,
        latestMessage: message.body,
        messages: [...convo.messages, message],
      );
      sending = false;
      if (!isClosed) emit(DataLoaded(next));
      return true;
    } catch (_) {
      sending = false;
      return false;
    }
  }
}
