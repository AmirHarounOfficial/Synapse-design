import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/paginated.dart';
import '../models/equipment_item.dart';

/// Clinic equipment/supply checklist API (GET/PUT /equipment-items).
class EquipmentRepository {
  EquipmentRepository(this._api);

  final ApiClient _api;

  /// GET /equipment-items?category=  (paginated)
  Future<Paginated<EquipmentItem>> list({String? category}) async {
    final qp = <String, dynamic>{};
    if (category != null && category.isNotEmpty) qp['category'] = category;
    final res = await _api.dio.get('/equipment-items', queryParameters: qp);
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, EquipmentItem.fromJson);
  }

  /// PUT /equipment-items/{id}
  Future<EquipmentItem> update(int id, {String? status, String? location}) async {
    final res = await _api.dio.put('/equipment-items/$id', data: {
      'status': ?status,
      'location': ?location,
    });
    return EquipmentItem.fromJson(
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
      if (status == 404) return 'This item could not be found.';
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
