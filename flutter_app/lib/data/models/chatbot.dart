/// A single message inside a chatbot conversation.
class ChatbotMessage {
  const ChatbotMessage({
    required this.id,
    required this.conversationId,
    this.sender,
    this.body,
    this.createdAt,
  });

  final int id;
  final int conversationId;

  /// bot | parent | staff
  final String? sender;
  final String? body;
  final DateTime? createdAt;

  factory ChatbotMessage.fromJson(Map<String, dynamic> j) => ChatbotMessage(
        id: (j['id'] as num).toInt(),
        conversationId: (j['conversation_id'] as num?)?.toInt() ?? 0,
        sender: j['sender'] as String?,
        body: j['body'] as String?,
        createdAt: _parseDate(j['created_at']),
      );

  static DateTime? _parseDate(Object? v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}

/// A parent<->staff chatbot conversation, matching `ChatbotConversationResource`.
class ChatbotConversation {
  const ChatbotConversation({
    required this.id,
    this.parentName,
    this.subject,
    this.status,
    this.priority,
    this.assignedTo,
    this.messageCount = 0,
    this.firstMessage,
    this.latestMessage,
    this.messages = const [],
  });

  final int id;
  final String? parentName;
  final String? subject;

  /// pending | assigned | resolved
  final String? status;

  /// low | normal | high
  final String? priority;
  final int? assignedTo;
  final int messageCount;
  final String? firstMessage;
  final String? latestMessage;

  /// Populated by `show`; empty on list responses.
  final List<ChatbotMessage> messages;

  factory ChatbotConversation.fromJson(Map<String, dynamic> j) => ChatbotConversation(
        id: (j['id'] as num).toInt(),
        parentName: j['parent_name'] as String?,
        subject: j['subject'] as String?,
        status: j['status'] as String?,
        priority: j['priority'] as String?,
        assignedTo: (j['assigned_to'] as num?)?.toInt(),
        messageCount: (j['message_count'] as num?)?.toInt() ?? 0,
        firstMessage: j['first_message'] as String?,
        latestMessage: j['latest_message'] as String?,
        messages: (j['messages'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(ChatbotMessage.fromJson)
            .toList(),
      );
}
