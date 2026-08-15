/// An in-app notification for the authenticated user, matching
/// `AppNotificationResource` from the API.
class AppNotification {
  const AppNotification({
    required this.id,
    this.userId,
    this.type,
    this.title,
    this.body,
    this.data = const {},
    this.readAt,
    this.createdAt,
  });

  final int id;
  final int? userId;
  final String? type; // medication | emergency | document | system | weather | clinic | ...
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: (j['id'] as num).toInt(),
        userId: (j['user_id'] as num?)?.toInt(),
        type: j['type'] as String?,
        title: j['title'] as String?,
        body: j['body'] as String?,
        data: (j['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        readAt: _date(j['read_at']),
        createdAt: _date(j['created_at']),
      );

  static DateTime? _date(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
}
