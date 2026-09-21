import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/cafeteria_alert.dart';
import '../models/cafeteria_wallet.dart';
import '../models/halal_certification.dart';
import '../models/meal.dart';

/// Cafeteria / Allergens / Halal / Wallet API. Reads are open to authenticated staff;
/// writes (create alert, acknowledge, wallet charge) are role-scoped.
class CafeteriaRepository {
  CafeteriaRepository(this._api);

  final ApiClient _api;

  // In-memory mock wallet cache for offline mode
  final Map<int, CafeteriaWallet> _mockWallets = {};
  final Map<int, List<CafeteriaTransaction>> _mockTransactions = {};

  // --- Cafeteria Wallet & Budget -------------------------------------------

  /// GET /cafeteria/wallet/{studentId}
  Future<CafeteriaWallet> getWallet(int studentId) async {
    try {
      final res = await _api.dio.get('/cafeteria/wallet/$studentId');
      final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final wallet = CafeteriaWallet.fromJson(data);
      _mockWallets[studentId] = wallet;
      return wallet;
    } catch (_) {
      // Fallback mock wallet
      if (_mockWallets.containsKey(studentId)) {
        return _mockWallets[studentId]!;
      }
      final fallback = CafeteriaWallet(
        studentId: studentId,
        studentName: 'Student #$studentId',
        monthlyBudget: 600.0,
        dailyLimit: 30.0,
        monthlySpent: 145.5,
        todaySpent: 12.0,
        remainingMonthly: 454.5,
        remainingDaily: 18.0,
        lastSpentDate: DateTime.now().toIso8601String().split('T').first,
      );
      _mockWallets[studentId] = fallback;
      return fallback;
    }
  }

  /// POST /cafeteria/wallet/{studentId}  (Parent sets monthly budget & daily limit)
  Future<CafeteriaWallet> updateWallet(
    int studentId, {
    required double monthlyBudget,
    required double dailyLimit,
  }) async {
    try {
      final res = await _api.dio.post('/cafeteria/wallet/$studentId', data: {
        'monthly_budget': monthlyBudget,
        'daily_limit': dailyLimit,
      });
      final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final updated = CafeteriaWallet.fromJson(data);
      _mockWallets[studentId] = updated;
      return updated;
    } catch (_) {
      final current = await getWallet(studentId);
      final remMonthly = (monthlyBudget - current.monthlySpent).clamp(0.0, double.infinity);
      final remDaily = (dailyLimit - current.todaySpent).clamp(0.0, remMonthly);
      final updated = CafeteriaWallet(
        studentId: current.studentId,
        studentName: current.studentName,
        monthlyBudget: monthlyBudget,
        dailyLimit: dailyLimit,
        monthlySpent: current.monthlySpent,
        todaySpent: current.todaySpent,
        remainingMonthly: remMonthly,
        remainingDaily: remDaily,
        lastSpentDate: current.lastSpentDate,
      );
      _mockWallets[studentId] = updated;
      return updated;
    }
  }

  /// POST /cafeteria/wallet/{studentId}/charge  (Cafeteria staff charges a purchase)
  Future<CafeteriaWallet> chargePurchase(
    int studentId, {
    required double amount,
    required String itemName,
    String category = 'meal',
    String? staffName,
  }) async {
    try {
      final res = await _api.dio.post('/cafeteria/wallet/$studentId/charge', data: {
        'amount': amount,
        'item_name': itemName,
        'category': category,
        'staff_name': staffName ?? 'Cafeteria Staff',
      });
      final walletData = (res.data as Map<String, dynamic>)['wallet'] as Map<String, dynamic>;
      final wallet = CafeteriaWallet.fromJson(walletData);
      _mockWallets[studentId] = wallet;
      return wallet;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 422) {
        final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String?;
        throw Exception(msg ?? 'Transaction rejected by limit checks.');
      }
      final wallet = await getWallet(studentId);
      if (amount > wallet.remainingDaily) {
        throw Exception('Transaction exceeds daily spending limit of ${wallet.dailyLimit.toStringAsFixed(2)} AED.');
      }
      if (amount > wallet.remainingMonthly) {
        throw Exception('Transaction exceeds remaining monthly budget of ${wallet.remainingMonthly.toStringAsFixed(2)} AED.');
      }

      final newToday = wallet.todaySpent + amount;
      final newMonthly = wallet.monthlySpent + amount;
      final remMonthly = (wallet.monthlyBudget - newMonthly).clamp(0.0, double.infinity);
      final remDaily = (wallet.dailyLimit - newToday).clamp(0.0, remMonthly);

      final updated = CafeteriaWallet(
        studentId: wallet.studentId,
        studentName: wallet.studentName,
        monthlyBudget: wallet.monthlyBudget,
        dailyLimit: wallet.dailyLimit,
        monthlySpent: newMonthly,
        todaySpent: newToday,
        remainingMonthly: remMonthly,
        remainingDaily: remDaily,
        lastSpentDate: DateTime.now().toIso8601String().split('T').first,
      );
      _mockWallets[studentId] = updated;

      final list = _mockTransactions.putIfAbsent(studentId, () => []);
      list.insert(
        0,
        CafeteriaTransaction(
          id: DateTime.now().millisecondsSinceEpoch,
          studentId: studentId,
          amount: amount,
          itemName: itemName,
          category: category,
          staffName: staffName ?? 'Chef Ahmed (Main Cafeteria)',
          createdAt: DateTime.now(),
        ),
      );

      return updated;
    }
  }

  /// GET /cafeteria/wallet/{studentId}/transactions
  Future<List<CafeteriaTransaction>> getTransactions(int studentId) async {
    try {
      final res = await _api.dio.get('/cafeteria/wallet/$studentId/transactions');
      final list = (res.data as Map<String, dynamic>)['data'] as List;
      return list.map((e) => CafeteriaTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      if (_mockTransactions.containsKey(studentId)) {
        return _mockTransactions[studentId]!;
      }
      final initial = [
        CafeteriaTransaction(
          id: 1,
          studentId: studentId,
          amount: 12.0,
          itemName: 'Grilled Chicken Sandwich & Apple Juice',
          category: 'meal',
          staffName: 'Chef Ahmed (Main Cafeteria)',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        CafeteriaTransaction(
          id: 2,
          studentId: studentId,
          amount: 8.5,
          itemName: 'Fresh Fruit Salad & Yogurt',
          category: 'snack',
          staffName: 'Chef Ahmed (Main Cafeteria)',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        CafeteriaTransaction(
          id: 3,
          studentId: studentId,
          amount: 25.0,
          itemName: 'Hot Lunch Meal Deal + Water',
          category: 'meal',
          staffName: 'Chef Ahmed (Main Cafeteria)',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      _mockTransactions[studentId] = initial;
      return initial;
    }
  }

  // --- Cafeteria alerts ----------------------------------------------------

  /// GET /cafeteria-alerts?acknowledged=&student_id=  (paginated)
  Future<Paginated<CafeteriaAlert>> alerts({bool? acknowledged, int? studentId}) async {
    final qp = <String, dynamic>{};
    if (acknowledged != null) qp['acknowledged'] = acknowledged;
    if (studentId != null) qp['student_id'] = studentId;
    final res = await _api.dio.get('/cafeteria-alerts', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, CafeteriaAlert.fromJson);
  }

  /// GET /cafeteria-alerts/{id}
  Future<CafeteriaAlert> alert(int id) async {
    final res = await _api.dio.get('/cafeteria-alerts/$id');
    return CafeteriaAlert.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /cafeteria-alerts  (cafeteria/nurse only)
  Future<CafeteriaAlert> createAlert({
    required int schoolId,
    int? studentId,
    required String title,
    required String message,
    String? severity, // info | warning | critical
    bool? isHalalIssue,
    String? createdForDate, // yyyy-MM-dd
  }) async {
    final body = <String, dynamic>{
      'school_id': schoolId,
      'student_id': ?studentId,
      'title': title,
      'message': message,
      'severity': ?severity,
      'is_halal_issue': ?isHalalIssue,
      'created_for_date': ?createdForDate,
    };
    final res = await _api.dio.post('/cafeteria-alerts', data: body);
    return CafeteriaAlert.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /cafeteria-alerts/{id}/acknowledge  (cafeteria/nurse only)
  Future<CafeteriaAlert> acknowledgeAlert(int id) async {
    final res = await _api.dio.post('/cafeteria-alerts/$id/acknowledge');
    return CafeteriaAlert.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // --- Meals ---------------------------------------------------------------

  /// GET /meals?date=&school_id=  (paginated)
  Future<Paginated<Meal>> meals({String? date, int? schoolId}) async {
    final qp = <String, dynamic>{};
    if (date != null && date.isNotEmpty) qp['date'] = date;
    if (schoolId != null) qp['school_id'] = schoolId;
    final res = await _api.dio.get('/meals', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, Meal.fromJson);
  }

  /// GET /meals/{id}
  Future<Meal> meal(int id) async {
    final res = await _api.dio.get('/meals/$id');
    return Meal.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  // --- Halal certifications ------------------------------------------------

  /// GET /halal-certifications?school_id=  (paginated, ordered by expiry)
  Future<Paginated<HalalCertification>> halalCertifications({int? schoolId}) async {
    final qp = <String, dynamic>{};
    if (schoolId != null) qp['school_id'] = schoolId;
    final res = await _api.dio.get('/halal-certifications', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, HalalCertification.fromJson);
  }

  /// GET /halal-certifications/{id}
  Future<HalalCertification> halalCertification(int id) async {
    final res = await _api.dio.get('/halal-certifications/$id');
    return HalalCertification.fromJson(
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// Maps Dio failures to a friendly message for the UI.
  static String messageFor(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Cannot reach the server. Is the backend running?';
      }
      final status = e.response?.statusCode;
      if (status == 401) return 'Your session expired. Please sign in again.';
      if (status == 403) return 'You don\'t have access to this.';
      if (status == 404) return 'This record could not be found.';
      if (status == 422) {
        final errors = e.response?.data is Map<String, dynamic>
            ? (e.response!.data as Map<String, dynamic>)['errors']
            : null;
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        return 'Please check the form and try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
