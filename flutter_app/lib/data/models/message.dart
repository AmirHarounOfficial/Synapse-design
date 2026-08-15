/// An internal message, matching `MessageResource` from the API.
class Message {
  const Message({
    required this.id,
    required this.schoolId,
    this.senderId,
    this.senderName,
    this.recipientId,
    this.category,
    this.subject,
    this.body,
    this.status,
    this.parentMessageId,
    this.readAt,
    this.createdAt,
  });

  final int id;
  final int schoolId;
  final int? senderId;
  final String? senderName;
  final int? recipientId;
  final String? category;
  final String? subject;
  final String? body;

  /// unread | read (and any other server-defined status)
  final String? status;
  final int? parentMessageId;
  final DateTime? readAt;
  final DateTime? createdAt;

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: (j['id'] as num).toInt(),
        schoolId: (j['school_id'] as num?)?.toInt() ?? 0,
        senderId: (j['sender_id'] as num?)?.toInt(),
        senderName: j['sender_name'] as String?,
        recipientId: (j['recipient_id'] as num?)?.toInt(),
        category: j['category'] as String?,
        subject: j['subject'] as String?,
        body: j['body'] as String?,
        status: j['status'] as String?,
        parentMessageId: (j['parent_message_id'] as num?)?.toInt(),
        readAt: _parseDate(j['read_at']),
        createdAt: _parseDate(j['created_at']),
      );

  static DateTime? _parseDate(Object? v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
