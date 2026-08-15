/// An after-hours access request, matching `AfterHoursRequestResource`.
class AfterHoursRequest {
  const AfterHoursRequest({
    required this.id,
    this.requesterName,
    this.reason,
    this.status,
    this.windowStart,
    this.windowEnd,
    this.createdAt,
  });

  final int id;
  final String? requesterName;
  final String? reason;

  /// pending | approved | denied
  final String? status;
  final DateTime? windowStart;
  final DateTime? windowEnd;
  final DateTime? createdAt;

  factory AfterHoursRequest.fromJson(Map<String, dynamic> j) => AfterHoursRequest(
        id: (j['id'] as num).toInt(),
        requesterName: j['requester_name'] as String?,
        reason: j['reason'] as String?,
        status: j['status'] as String?,
        windowStart: _parseDate(j['window_start']),
        windowEnd: _parseDate(j['window_end']),
        createdAt: _parseDate(j['created_at']),
      );

  static DateTime? _parseDate(Object? v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
