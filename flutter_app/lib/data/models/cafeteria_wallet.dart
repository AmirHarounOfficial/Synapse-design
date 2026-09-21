class CafeteriaWallet {
  const CafeteriaWallet({
    required this.studentId,
    this.studentName = '',
    required this.monthlyBudget,
    required this.dailyLimit,
    required this.monthlySpent,
    required this.todaySpent,
    required this.remainingMonthly,
    required this.remainingDaily,
    this.lastSpentDate,
  });

  final int studentId;
  final String studentName;
  final double monthlyBudget;
  final double dailyLimit;
  final double monthlySpent;
  final double todaySpent;
  final double remainingMonthly;
  final double remainingDaily;
  final String? lastSpentDate;

  factory CafeteriaWallet.fromJson(Map<String, dynamic> json) {
    return CafeteriaWallet(
      studentId: json['student_id'] as int? ?? 0,
      studentName: json['student_name'] as String? ?? '',
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble() ?? 500.0,
      dailyLimit: (json['daily_limit'] as num?)?.toDouble() ?? 25.0,
      monthlySpent: (json['monthly_spent'] as num?)?.toDouble() ?? 0.0,
      todaySpent: (json['today_spent'] as num?)?.toDouble() ?? 0.0,
      remainingMonthly: (json['remaining_monthly'] as num?)?.toDouble() ?? 500.0,
      remainingDaily: (json['remaining_daily'] as num?)?.toDouble() ?? 25.0,
      lastSpentDate: json['last_spent_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'monthly_budget': monthlyBudget,
      'daily_limit': dailyLimit,
      'monthly_spent': monthlySpent,
      'today_spent': todaySpent,
      'remaining_monthly': remainingMonthly,
      'remaining_daily': remainingDaily,
      'last_spent_date': lastSpentDate,
    };
  }
}

class CafeteriaTransaction {
  const CafeteriaTransaction({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.itemName,
    this.category = 'meal',
    this.staffName,
    this.createdAt,
  });

  final int id;
  final int studentId;
  final double amount;
  final String itemName;
  final String category;
  final String? staffName;
  final DateTime? createdAt;

  factory CafeteriaTransaction.fromJson(Map<String, dynamic> json) {
    return CafeteriaTransaction(
      id: json['id'] as int? ?? 0,
      studentId: json['student_id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      itemName: json['item_name'] as String? ?? 'Cafeteria Item',
      category: json['category'] as String? ?? 'meal',
      staffName: json['staff_name'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'amount': amount,
      'item_name': itemName,
      'category': category,
      'staff_name': staffName,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
