import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/sms_transaction.dart';

/// SMS credit wallet API (GET /sms-wallet, POST /sms-wallet/topup).
class SmsWalletRepository {
  SmsWalletRepository(this._api);

  final ApiClient _api;

  /// GET /sms-wallet -> { balance_credits, transactions: [...] }
  Future<({int balanceCredits, List<SmsTransaction> transactions})> get() async {
    final res = await _api.dio.get('/sms-wallet');
    return _parse(res.data);
  }

  /// POST /sms-wallet/topup { credits }
  Future<({int balanceCredits, List<SmsTransaction> transactions})> topup(
      int credits) async {
    final res = await _api.dio.post('/sms-wallet/topup', data: {'credits': credits});
    return _parse(res.data);
  }

  static ({int balanceCredits, List<SmsTransaction> transactions}) _parse(Object? data) {
    final map = data as Map<String, dynamic>? ?? const {};
    final inner = map['data'] is Map<String, dynamic>
        ? map['data'] as Map<String, dynamic>
        : map;
    final txns = (inner['transactions'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(SmsTransaction.fromJson)
        .toList();
    return (
      balanceCredits: (inner['balance_credits'] as num?)?.toInt() ?? 0,
      transactions: txns,
    );
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
      if (status == 422) {
        final errors = e.response?.data is Map ? (e.response!.data as Map)['errors'] : null;
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
