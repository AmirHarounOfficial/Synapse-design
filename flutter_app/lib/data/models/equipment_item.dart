/// A clinic equipment / supply item, matching `EquipmentItemResource`.
class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.name,
    this.category,
    this.location,
    this.status,
    this.lastCheckedAt,
    this.checkedBy,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? category;
  final String? location;

  /// ok | low | expired | missing
  final String? status;
  final DateTime? lastCheckedAt;
  final int? checkedBy;
  final DateTime? createdAt;

  factory EquipmentItem.fromJson(Map<String, dynamic> j) => EquipmentItem(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
        category: j['category'] as String?,
        location: j['location'] as String?,
        status: j['status'] as String?,
        lastCheckedAt: _parseDate(j['last_checked_at']),
        checkedBy: (j['checked_by'] as num?)?.toInt(),
        createdAt: _parseDate(j['created_at']),
      );

  static DateTime? _parseDate(Object? v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
