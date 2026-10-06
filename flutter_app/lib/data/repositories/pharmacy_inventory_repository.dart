import '../../core/network/api_client.dart';
import '../models/pharmacy_inventory_item.dart';

class PharmacyInventoryRepository {
  PharmacyInventoryRepository(this._api);
  final ApiClient _api;

  Future<List<PharmacyInventoryItem>> list({
    String? search,
    String? category,
    String? status,
    int? studentId,
  }) async {
    final res = await _api.dio.get(
      '/pharmacy-inventory',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category != 'all') 'category': category,
        if (status != null && status != 'all') 'status': status,
        'student_id': ?studentId,
      },
    );
    return (res.data['data'] as List)
        .map(
          (j) => PharmacyInventoryItem.fromJson(Map<String, dynamic>.from(j)),
        )
        .toList();
  }

  Future<PharmacyInventoryItem> create(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/pharmacy-inventory', data: data);
    return PharmacyInventoryItem.fromJson(
      Map<String, dynamic>.from(res.data['data']),
    );
  }

  Future<PharmacyInventoryItem> update(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await _api.dio.put('/pharmacy-inventory/$id', data: data);
    return PharmacyInventoryItem.fromJson(
      Map<String, dynamic>.from(res.data['data']),
    );
  }

  Future<PharmacyInventoryItem> adjustStock(
    int id,
    int adjustment,
    String reason,
  ) async {
    final res = await _api.dio.post(
      '/pharmacy-inventory/$id/adjust-stock',
      data: {'adjustment': adjustment, 'reason': reason},
    );
    return PharmacyInventoryItem.fromJson(
      Map<String, dynamic>.from(res.data['data']),
    );
  }

  Future<void> delete(int id) async =>
      _api.dio.delete('/pharmacy-inventory/$id');

  Future<List<PharmacyInventoryLog>> logs({int? studentId}) async {
    final res = await _api.dio.get(
      '/pharmacy-inventory/logs',
      queryParameters: {'student_id': ?studentId},
    );
    return (res.data['data'] as List)
        .map((j) => PharmacyInventoryLog.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }
}
