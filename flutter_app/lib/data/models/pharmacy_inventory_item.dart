class PharmacyInventoryItem {
  final int id;
  final String name;
  final String? nameAr;
  final String category;
  final String dosageForm;
  final int stockQuantity;
  final int minThreshold;
  final String unit;
  final String location;
  final String expiryDate;
  final String supplier;
  final String status;
  final String? notes;

  const PharmacyInventoryItem({
    required this.id,
    required this.name,
    this.nameAr,
    required this.category,
    required this.dosageForm,
    required this.stockQuantity,
    required this.minThreshold,
    required this.unit,
    required this.location,
    required this.expiryDate,
    required this.supplier,
    required this.status,
    this.notes,
  });

  factory PharmacyInventoryItem.fromJson(Map<String, dynamic> json) {
    return PharmacyInventoryItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      category: json['category'] as String? ?? 'General',
      dosageForm: json['dosage_form'] as String? ?? '',
      stockQuantity: json['stock_quantity'] is int ? json['stock_quantity'] as int : int.parse(json['stock_quantity']?.toString() ?? '0'),
      minThreshold: json['min_threshold'] is int ? json['min_threshold'] as int : int.parse(json['min_threshold']?.toString() ?? '10'),
      unit: json['unit'] as String? ?? 'tablets',
      location: json['location'] as String? ?? '',
      expiryDate: json['expiry_date'] as String? ?? '',
      supplier: json['supplier'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'category': category,
      'dosage_form': dosageForm,
      'stock_quantity': stockQuantity,
      'min_threshold': minThreshold,
      'unit': unit,
      'location': location,
      'expiry_date': expiryDate,
      'supplier': supplier,
      'status': status,
      'notes': notes,
    };
  }

  PharmacyInventoryItem copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? category,
    String? dosageForm,
    int? stockQuantity,
    int? minThreshold,
    String? unit,
    String? location,
    String? expiryDate,
    String? supplier,
    String? status,
    String? notes,
  }) {
    return PharmacyInventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      category: category ?? this.category,
      dosageForm: dosageForm ?? this.dosageForm,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minThreshold: minThreshold ?? this.minThreshold,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      expiryDate: expiryDate ?? this.expiryDate,
      supplier: supplier ?? this.supplier,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class PharmacyInventoryLog {
  final int id;
  final String itemName;
  final String performedByName;
  final String performedByRole;
  final String action;
  final int? quantityChange;
  final int? newQuantity;
  final String? reason;
  final String createdAt;

  const PharmacyInventoryLog({
    required this.id,
    required this.itemName,
    required this.performedByName,
    required this.performedByRole,
    required this.action,
    this.quantityChange,
    this.newQuantity,
    this.reason,
    required this.createdAt,
  });

  factory PharmacyInventoryLog.fromJson(Map<String, dynamic> json) {
    return PharmacyInventoryLog(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      itemName: json['item_name'] as String? ?? 'Pharmacy Item',
      performedByName: json['performed_by_name'] as String? ?? 'Nurse',
      performedByRole: json['performed_by_role'] as String? ?? 'nurse',
      action: json['action'] as String? ?? 'updated',
      quantityChange: json['quantity_change'] != null ? (json['quantity_change'] is int ? json['quantity_change'] as int : int.tryParse(json['quantity_change'].toString())) : null,
      newQuantity: json['new_quantity'] != null ? (json['new_quantity'] is int ? json['new_quantity'] as int : int.tryParse(json['new_quantity'].toString())) : null,
      reason: json['reason'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
