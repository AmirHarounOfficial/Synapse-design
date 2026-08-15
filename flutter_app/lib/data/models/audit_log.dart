/// A tamper-proof audit-log entry, matching `AuditLogResource` from the API.
class AuditLog {
  const AuditLog({
    required this.id,
    this.userId,
    required this.action,
    this.entityType,
    this.entityId,
    this.meta = const {},
    this.ip,
    this.createdAt,
  });

  final int id;
  final int? userId;
  final String action;
  final String? entityType;
  final int? entityId;
  final Map<String, dynamic> meta;
  final String? ip;
  final DateTime? createdAt;

  factory AuditLog.fromJson(Map<String, dynamic> j) => AuditLog(
        id: (j['id'] as num).toInt(),
        userId: (j['user_id'] as num?)?.toInt(),
        action: j['action'] as String? ?? '',
        entityType: j['entity_type'] as String?,
        entityId: (j['entity_id'] as num?)?.toInt(),
        meta: (j['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
        ip: j['ip'] as String?,
        createdAt: _date(j['created_at']),
      );

  static DateTime? _date(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
}
