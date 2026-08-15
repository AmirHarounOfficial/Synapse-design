import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/bus_boarding_event.dart';
import '../models/bus_route.dart';

/// Bus routes API (see `routes/clusters/pickup_bus.php`). Reads are open to any
/// authenticated staff; recording events is `bus_driver`-only on the backend.
class BusRepository {
  BusRepository(this._api);

  final ApiClient _api;

  /// GET /bus-routes?period=&status=  (paginated, 50/page)
  Future<Paginated<BusRoute>> list({String? period, String? status}) async {
    final qp = <String, dynamic>{};
    if (period != null && period.isNotEmpty) qp['period'] = period;
    if (status != null && status.isNotEmpty) qp['status'] = status;
    final res = await _api.dio.get('/bus-routes', queryParameters: qp);
    return Paginated.fromJson(res.data as Map<String, dynamic>, BusRoute.fromJson);
  }

  /// GET /bus-routes/{id} — includes the route's events (with their students).
  Future<BusRoute> show(int id) async {
    final res = await _api.dio.get('/bus-routes/$id');
    return BusRoute.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// POST /bus-routes/{routeId}/events — driver records a boarding/deboarding.
  Future<BusBoardingEvent> recordEvent({
    required int routeId,
    required int studentId,
    required String type, // boarding | deboarding
    required String status, // boarded | deboarded | absent | pending
    String? stopName,
  }) async {
    final res = await _api.dio.post('/bus-routes/$routeId/events', data: {
      'student_id': studentId,
      'type': type,
      'status': status,
      'stop_name': ?stopName,
    });
    return BusBoardingEvent.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  /// Maps Dio failures to a friendly message for the UI.
  static String messageFor(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Cannot reach the server. Is the backend running?';
      }
      final code = e.response?.statusCode;
      if (code == 401) return 'Your session expired. Please sign in again.';
      if (code == 403) return 'You don\'t have access to this.';
      if (code == 422) {
        final errors = e.response?.data is Map ? (e.response?.data as Map)['errors'] : null;
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
