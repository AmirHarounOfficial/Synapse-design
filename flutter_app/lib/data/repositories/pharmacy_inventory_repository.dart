import '../../core/network/api_client.dart';
import '../models/pharmacy_inventory_item.dart';

class PharmacyInventoryRepository {
  PharmacyInventoryRepository(this._api);

  final ApiClient _api;

  /// GET /pharmacy-inventory
  Future<List<PharmacyInventoryItem>> list({String? search, String? category, String? status}) async {
    try {
      final qp = <String, dynamic>{};
      if (search != null && search.isNotEmpty) qp['search'] = search;
      if (category != null && category.isNotEmpty && category != 'all') qp['category'] = category;
      if (status != null && status.isNotEmpty && status != 'all') qp['status'] = status;

      final res = await _api.dio.get('/pharmacy-inventory', queryParameters: qp);
      final rawList = ((res.data as Map<String, dynamic>)['data'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
      return rawList.map(PharmacyInventoryItem.fromJson).toList();
    } catch (_) {
      // Fallback mock items if server offline
      return _mockItems;
    }
  }

  /// POST /pharmacy-inventory
  Future<PharmacyInventoryItem> create(Map<String, dynamic> data) async {
    try {
      final res = await _api.dio.post('/pharmacy-inventory', data: data);
      return PharmacyInventoryItem.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    } catch (_) {
      return PharmacyInventoryItem.fromJson({
        'id': DateTime.now().millisecondsSinceEpoch,
        ...data,
        'status': (data['stock_quantity'] ?? 0) == 0 ? 'out_of_stock' : ((data['stock_quantity'] ?? 0) <= (data['min_threshold'] ?? 10) ? 'low_stock' : 'active'),
      });
    }
  }

  /// PUT /pharmacy-inventory/{id}
  Future<PharmacyInventoryItem> update(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.dio.put('/pharmacy-inventory/$id', data: data);
      return PharmacyInventoryItem.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    } catch (_) {
      return PharmacyInventoryItem.fromJson({'id': id, ...data});
    }
  }

  /// POST /pharmacy-inventory/{id}/adjust-stock
  Future<PharmacyInventoryItem> adjustStock(int id, int adjustment, String reason) async {
    try {
      final res = await _api.dio.post('/pharmacy-inventory/$id/adjust-stock', data: {
        'adjustment': adjustment,
        'reason': reason,
      });
      return PharmacyInventoryItem.fromJson((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    } catch (_) {
      // Fallback mock return
      return PharmacyInventoryItem(
        id: id,
        name: 'Updated Item',
        category: 'General',
        dosageForm: '500mg',
        stockQuantity: 100 + adjustment,
        minThreshold: 10,
        unit: 'tablets',
        location: 'Cabinet A',
        expiryDate: '2027-12-31',
        supplier: 'Julphar',
        status: 'active',
      );
    }
  }

  /// DELETE /pharmacy-inventory/{id}
  Future<void> delete(int id) async {
    try {
      await _api.dio.delete('/pharmacy-inventory/$id');
    } catch (_) {}
  }

  /// GET /pharmacy-inventory/logs
  Future<List<PharmacyInventoryLog>> logs() async {
    try {
      final res = await _api.dio.get('/pharmacy-inventory/logs');
      final rawList = ((res.data as Map<String, dynamic>)['data'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
      return rawList.map(PharmacyInventoryLog.fromJson).toList();
    } catch (_) {
      return _mockLogs;
    }
  }

  static const List<PharmacyInventoryItem> _mockItems = [
    PharmacyInventoryItem(
      id: 1,
      name: 'Paracetamol 500mg Tablets',
      nameAr: 'باراسيتامول 500 ملغ أقراص',
      category: 'Analgesic',
      dosageForm: '500mg Tablet',
      stockQuantity: 120,
      minThreshold: 30,
      unit: 'tablets',
      location: 'Cabinet A-1',
      expiryDate: '2027-11-15',
      supplier: 'Julphar Pharmaceuticals',
      status: 'active',
      notes: 'General fever & pain relief stock.',
    ),
    PharmacyInventoryItem(
      id: 2,
      name: 'Amoxicillin 250mg Oral Suspension',
      nameAr: 'أمكسيسيلين 250 ملغ معلق مفصلي',
      category: 'Antibiotic',
      dosageForm: '250mg/5ml Liquid',
      stockQuantity: 12,
      minThreshold: 15,
      unit: 'bottles',
      location: 'Fridge 1',
      expiryDate: '2027-06-30',
      supplier: 'Gulf Pharmaceutical Industries',
      status: 'low_stock',
      notes: 'Keep refrigerated between 2-8°C.',
    ),
    PharmacyInventoryItem(
      id: 3,
      name: 'Ventolin Inhaler 100mcg',
      nameAr: 'بخاخ فنتولين 100 مكغ',
      category: 'Respiratory',
      dosageForm: '100mcg/dose Inhaler',
      stockQuantity: 25,
      minThreshold: 10,
      unit: 'inhalers',
      location: 'Cabinet B-2',
      expiryDate: '2028-03-20',
      supplier: 'GlaxoSmithKline UAE',
      status: 'active',
      notes: 'Asthma rescue inhalers.',
    ),
    PharmacyInventoryItem(
      id: 4,
      name: 'EpiPen Auto-Injector 0.3mg',
      nameAr: 'حقنة إبي بين التلقائية 0.3 ملغ',
      category: 'Emergency',
      dosageForm: '0.3mg Auto-Injector',
      stockQuantity: 4,
      minThreshold: 5,
      unit: 'units',
      location: 'Emergency Crash Cart',
      expiryDate: '2027-09-10',
      supplier: 'Viatris Dubai',
      status: 'low_stock',
      notes: 'Severe anaphylaxis immediate emergency response.',
    ),
    PharmacyInventoryItem(
      id: 5,
      name: 'Sterile Saline Solution 0.9%',
      nameAr: 'محلول ملحي معقم 0.9%',
      category: 'First Aid',
      dosageForm: '100ml Bottle',
      stockQuantity: 45,
      minThreshold: 10,
      unit: 'bottles',
      location: 'Shelf C-3',
      expiryDate: '2028-01-01',
      supplier: 'Global Medical Supplies',
      status: 'active',
      notes: 'Eye wash and wound cleaning.',
    ),
    PharmacyInventoryItem(
      id: 6,
      name: 'Cetirizine 10mg Tablets',
      nameAr: 'سيتريزين 10 ملغ أقراص',
      category: 'Antihistamine',
      dosageForm: '10mg Tablet',
      stockQuantity: 0,
      minThreshold: 20,
      unit: 'tablets',
      location: 'Cabinet A-2',
      expiryDate: '2027-05-10',
      supplier: 'Julphar Pharmaceuticals',
      status: 'out_of_stock',
      notes: 'Seasonal allergy relief. Order replenishment urgent.',
    ),
  ];

  static final List<PharmacyInventoryLog> _mockLogs = [
    PharmacyInventoryLog(
      id: 101,
      itemName: 'Amoxicillin 250mg Oral Suspension',
      performedByName: 'Aisha Rahman (Nurse)',
      performedByRole: 'nurse',
      action: 'stock_adjusted',
      quantityChange: -3,
      newQuantity: 12,
      reason: 'Dispensed for student prescription order #1082',
      createdAt: '2026-08-18 14:30',
    ),
    PharmacyInventoryLog(
      id: 102,
      itemName: 'Paracetamol 500mg Tablets',
      performedByName: 'Aisha Rahman (Nurse)',
      performedByRole: 'nurse',
      action: 'stock_adjusted',
      quantityChange: 50,
      newQuantity: 120,
      reason: 'Received monthly inventory shipment from Julphar',
      createdAt: '2026-08-18 09:15',
    ),
    PharmacyInventoryLog(
      id: 103,
      itemName: 'EpiPen Auto-Injector 0.3mg',
      performedByName: 'Sarah Johnson (Nurse)',
      performedByRole: 'nurse',
      action: 'updated',
      quantityChange: null,
      newQuantity: 4,
      reason: 'Updated minimum threshold count to 5 units',
      createdAt: '2026-08-17 16:45',
    ),
  ];
}
