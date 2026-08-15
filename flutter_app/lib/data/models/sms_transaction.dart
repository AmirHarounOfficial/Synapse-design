/// A single SMS wallet ledger entry, matching `SmsTransactionResource`.
class SmsTransaction {
  const SmsTransaction({
    required this.id,
    this.type,
    this.credits = 0,
    this.description,
    this.createdAt,
  });

  final int id;

  /// topup | debit
  final String? type;
  final int credits;
  final String? description;
  final DateTime? createdAt;

  factory SmsTransaction.fromJson(Map<String, dynamic> j) => SmsTransaction(
        id: (j['id'] as num).toInt(),
        type: j['type'] as String?,
        credits: (j['credits'] as num?)?.toInt() ?? 0,
        description: j['description'] as String?,
        createdAt: _parseDate(j['created_at']),
      );

  static DateTime? _parseDate(Object? v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
