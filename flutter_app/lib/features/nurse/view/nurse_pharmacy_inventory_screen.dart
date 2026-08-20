import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/pharmacy_inventory_item.dart';
import '../../../data/repositories/pharmacy_inventory_repository.dart';

class NursePharmacyInventoryScreen extends StatefulWidget {
  const NursePharmacyInventoryScreen({super.key});

  @override
  State<NursePharmacyInventoryScreen> createState() => _NursePharmacyInventoryScreenState();
}

class _NursePharmacyInventoryScreenState extends State<NursePharmacyInventoryScreen> {
  final PharmacyInventoryRepository _repo = sl<PharmacyInventoryRepository>();

  List<PharmacyInventoryItem> _items = [];
  List<PharmacyInventoryLog> _logs = [];
  bool _isLoading = true;

  String _activeTab = 'all'; // 'all', 'low_stock', 'out_of_stock', 'audit_log'
  String _searchQuery = '';
  final String _categoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final items = await _repo.list();
      final logs = await _repo.logs();
      if (mounted) {
        setState(() {
          _items = items;
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Handlers ---
  void _openAddModal() {
    _showAddEditDialog();
  }

  void _openEditModal(PharmacyInventoryItem item) {
    _showAddEditDialog(existing: item);
  }

  void _openAdjustModal(PharmacyInventoryItem item) {
    final qtyController = TextEditingController(text: '0');
    final reasonController = TextEditingController(
      text: context.tr(en: 'Routine stock intake', ar: 'إدخال مخزون روتيني'),
    );

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(LucideIcons.slidersHorizontal, color: SchooKeepColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr(en: 'Adjust Stock Count', ar: 'تعديل كمية المخزون'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.isRTL && item.nameAr != null && item.nameAr!.isNotEmpty
                            ? item.nameAr!
                            : item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.tr(en: 'Current Stock', ar: 'المخزون الحالي')}: ${item.stockQuantity} ${item.unit}',
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr(en: 'Adjustment (+ for intake, - for dispense)', ar: 'التعديل (+ للإضافة، - للصرف)'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: context.tr(en: 'e.g. 20 or -5', ar: 'مثال: 20 أو -5'),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  context.tr(en: 'Reason for Audit Log *', ar: 'السبب لسجل التدقيق *'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: context.tr(en: 'Reason for inventory change...', ar: 'سبب تغيير المخزون...'),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(context.tr(en: 'Cancel', ar: 'إلغاء')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final adj = int.tryParse(qtyController.text) ?? 0;
                final reason = reasonController.text.trim();
                if (adj == 0) return;

                Navigator.pop(dialogCtx);
                await _repo.adjustStock(item.id, adj, reason.isEmpty ? 'Stock adjustment' : reason);

                final nowStr = DateTime.now().toString().substring(0, 16);
                final updatedItem = item.copyWith(
                  stockQuantity: (item.stockQuantity + adj).clamp(0, 999999),
                  status: (item.stockQuantity + adj) <= 0
                      ? 'out_of_stock'
                      : ((item.stockQuantity + adj) <= item.minThreshold ? 'low_stock' : 'active'),
                );

                setState(() {
                  _items = _items.map((i) => i.id == item.id ? updatedItem : i).toList();
                  _logs.insert(
                    0,
                    PharmacyInventoryLog(
                      id: DateTime.now().millisecondsSinceEpoch,
                      itemName: item.name,
                      performedByName: context.tr(en: 'Aisha Rahman (Nurse)', ar: 'عائشة الرحمن (ممرضة)'),
                      performedByRole: 'nurse',
                      action: 'stock_adjusted',
                      quantityChange: adj,
                      newQuantity: updatedItem.stockQuantity,
                      reason: reason,
                      createdAt: nowStr,
                    ),
                  );
                });
              },
              child: Text(context.tr(en: 'Confirm', ar: 'تأكيد'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _openDeleteModal(PharmacyInventoryItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Remove Item?', ar: 'حذف العنصر؟'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            context.tr(
              en: 'Are you sure you want to remove "${item.name}" from the pharmacy inventory? This action will be logged in the audit trail.',
              ar: 'هل أنت تأكد من رغبتك في إزالة "${item.nameAr ?? item.name}" من مخزون الصيدلية؟ سيتم تسجيل هذا الإجراء في سجل التدقيق.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(context.tr(en: 'Cancel', ar: 'إلغاء')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await _repo.delete(item.id);

                final nowStr = DateTime.now().toString().substring(0, 16);
                setState(() {
                  _items.removeWhere((i) => i.id == item.id);
                  _logs.insert(
                    0,
                    PharmacyInventoryLog(
                      id: DateTime.now().millisecondsSinceEpoch,
                      itemName: item.name,
                      performedByName: context.tr(en: 'Aisha Rahman (Nurse)', ar: 'عائشة الرحمن (ممرضة)'),
                      performedByRole: 'nurse',
                      action: 'deleted',
                      quantityChange: -item.stockQuantity,
                      newQuantity: 0,
                      reason: context.tr(en: 'Item deleted from pharmacy catalog', ar: 'تم حذف الدواء من دليل الصيدلية'),
                      createdAt: nowStr,
                    ),
                  );
                });
              },
              child: Text(context.tr(en: 'Delete', ar: 'حذف'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditDialog({PharmacyInventoryItem? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final nameArCtrl = TextEditingController(text: existing?.nameAr ?? '');
    final categoryCtrl = TextEditingController(text: existing?.category ?? 'Analgesic');
    final dosageCtrl = TextEditingController(text: existing?.dosageForm ?? '500mg Tablet');
    final stockCtrl = TextEditingController(text: (existing?.stockQuantity ?? 20).toString());
    final minCtrl = TextEditingController(text: (existing?.minThreshold ?? 10).toString());
    final unitCtrl = TextEditingController(text: existing?.unit ?? 'tablets');
    final locCtrl = TextEditingController(text: existing?.location ?? 'Cabinet A-1');
    final expCtrl = TextEditingController(text: existing?.expiryDate ?? '2027-12-31');
    final suppCtrl = TextEditingController(text: existing?.supplier ?? 'Julphar Pharmaceuticals');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(LucideIcons.package, color: SchooKeepColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  existing != null
                      ? context.tr(en: 'Edit Pharmacy Item', ar: 'تعديل عنصر الصيدلية')
                      : context.tr(en: 'Add Pharmacy Item', ar: 'إضافة دواء جديد للصيدلية'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr(en: 'Item Name (EN) *', ar: 'اسم الدواء (الإنجليزية) *'),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameArCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr(en: 'Item Name (AR)', ar: 'اسم الدواء (العربية)'),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: categoryCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr(en: 'Category *', ar: 'الفئة *'),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dosageCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr(en: 'Dosage Form / Strength', ar: 'الشكل الصيدلاني / الجرعة'),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.tr(en: 'Stock Qty *', ar: 'الكمية *'),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.tr(en: 'Min Alert *', ar: 'حد التنبيه *'),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: unitCtrl,
                          decoration: InputDecoration(
                            labelText: context.tr(en: 'Unit', ar: 'الوحدة'),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: locCtrl,
                          decoration: InputDecoration(
                            labelText: context.tr(en: 'Location', ar: 'الموقع/المكان'),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: expCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr(en: 'Expiry Date (YYYY-MM-DD)', ar: 'تاريخ الانتهاء (سسسس-شه-يو)'),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: suppCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr(en: 'Supplier', ar: 'المورد/المصنع'),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: context.tr(en: 'Notes', ar: 'ملاحظات وتدابير الاستخدام'),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(context.tr(en: 'Cancel', ar: 'إلغاء')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final stock = int.tryParse(stockCtrl.text) ?? 0;
                final minT = int.tryParse(minCtrl.text) ?? 10;
                final status = stock <= 0 ? 'out_of_stock' : (stock <= minT ? 'low_stock' : 'active');

                final payload = {
                  'name': name,
                  'name_ar': nameArCtrl.text.trim().isEmpty ? null : nameArCtrl.text.trim(),
                  'category': categoryCtrl.text.trim().isEmpty ? 'Analgesic' : categoryCtrl.text.trim(),
                  'dosage_form': dosageCtrl.text.trim(),
                  'stock_quantity': stock,
                  'min_threshold': minT,
                  'unit': unitCtrl.text.trim().isEmpty ? 'tablets' : unitCtrl.text.trim(),
                  'location': locCtrl.text.trim().isEmpty ? 'Cabinet A-1' : locCtrl.text.trim(),
                  'expiry_date': expCtrl.text.trim(),
                  'supplier': suppCtrl.text.trim(),
                  'notes': notesCtrl.text.trim(),
                  'status': status,
                };

                Navigator.pop(dialogCtx);
                final nowStr = DateTime.now().toString().substring(0, 16);

                if (existing != null) {
                  await _repo.update(existing.id, payload);
                  final updated = existing.copyWith(
                    name: name,
                    nameAr: payload['name_ar'] as String?,
                    category: payload['category'] as String,
                    dosageForm: payload['dosage_form'] as String,
                    stockQuantity: stock,
                    minThreshold: minT,
                    unit: payload['unit'] as String,
                    location: payload['location'] as String,
                    expiryDate: payload['expiry_date'] as String,
                    supplier: payload['supplier'] as String,
                    notes: payload['notes'] as String?,
                    status: status,
                  );
                  setState(() {
                    _items = _items.map((i) => i.id == existing.id ? updated : i).toList();
                    _logs.insert(
                      0,
                      PharmacyInventoryLog(
                        id: DateTime.now().millisecondsSinceEpoch,
                        itemName: name,
                        performedByName: context.tr(en: 'Aisha Rahman (Nurse)', ar: 'عائشة الرحمن (ممرضة)'),
                        performedByRole: 'nurse',
                        action: 'updated',
                        quantityChange: stock - existing.stockQuantity,
                        newQuantity: stock,
                        reason: context.tr(en: 'Updated item specifications', ar: 'تم تحديث مواصفات الدواء'),
                        createdAt: nowStr,
                      ),
                    );
                  });
                } else {
                  final created = await _repo.create(payload);
                  setState(() {
                    _items.insert(0, created);
                    _logs.insert(
                      0,
                      PharmacyInventoryLog(
                        id: DateTime.now().millisecondsSinceEpoch,
                        itemName: name,
                        performedByName: context.tr(en: 'Aisha Rahman (Nurse)', ar: 'عائشة الرحمن (ممرضة)'),
                        performedByRole: 'nurse',
                        action: 'created',
                        quantityChange: stock,
                        newQuantity: stock,
                        reason: context.tr(en: 'Added new item to catalog', ar: 'تمت إضافة دواء جديد للدليل'),
                        createdAt: nowStr,
                      ),
                    );
                  });
                }
              },
              child: Text(context.tr(en: 'Save Item', ar: 'حفظ الدواء'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- Filtering ---
  List<PharmacyInventoryItem> get _filteredItems {
    return _items.where((item) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          (item.nameAr ?? '').toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.location.toLowerCase().contains(q);

      final matchesCat = _categoryFilter == 'all' || item.category == _categoryFilter;

      if (!matchesSearch || !matchesCat) return false;

      if (_activeTab == 'low_stock') {
        return item.stockQuantity <= item.minThreshold && item.stockQuantity > 0;
      }
      if (_activeTab == 'out_of_stock') {
        return item.stockQuantity == 0;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = _items.where((i) => i.stockQuantity <= i.minThreshold && i.stockQuantity > 0).length;
    final outOfStockCount = _items.where((i) => i.stockQuantity == 0).length;
    final totalUnits = _items.fold(0, (acc, item) => acc + item.stockQuantity);

    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Pharmacy Inventory', ar: 'مخزون الصيدلية'),
        centerTitle: true,
        onBack: () => context.go('/nurse/medications'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: SchooKeepColors.primary),
            onPressed: _openAddModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Nurse Session Banner (Prevents RenderFlex overflow with Flexible)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFFEFF6FF),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(LucideIcons.userCheck, size: 16, color: SchooKeepColors.primary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                context.tr(en: 'Aisha Rahman (Nurse)', ar: 'عائشة الرحمن (ممرضة المدرسية)'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          context.tr(en: 'All Actions Logged', ar: 'موثق بالسجل'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPI Cards (Clickable statistics cards to filter lists)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _kpiCard(
                                    context.tr(en: 'Items', ar: 'الأدوية'),
                                    _items.length.toString(),
                                    '$totalUnits ${context.tr(en: 'units', ar: 'وحدة')}',
                                    LucideIcons.package,
                                    SchooKeepColors.primary,
                                    isActive: _activeTab == 'all',
                                    onTap: () => setState(() => _activeTab = 'all'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _kpiCard(
                                    context.tr(en: 'Low Stock', ar: 'منخفض'),
                                    lowStockCount.toString(),
                                    context.tr(en: 'Reorder', ar: 'طلب إعادة'),
                                    LucideIcons.alertTriangle,
                                    const Color(0xFFD97706),
                                    isActive: _activeTab == 'low_stock',
                                    onTap: () => setState(() => _activeTab = 'low_stock'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _kpiCard(
                                    context.tr(en: 'Out Stock', ar: 'منتهي'),
                                    outOfStockCount.toString(),
                                    context.tr(en: 'Depleted', ar: 'نفد'),
                                    LucideIcons.shieldAlert,
                                    Colors.red,
                                    isActive: _activeTab == 'out_of_stock',
                                    onTap: () => setState(() => _activeTab = 'out_of_stock'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _kpiCard(
                                    context.tr(en: 'Logs', ar: 'السجل'),
                                    _logs.length.toString(),
                                    context.tr(en: 'History', ar: 'التدقيق'),
                                    LucideIcons.history,
                                    const Color(0xFF7C3AED),
                                    isActive: _activeTab == 'audit_log',
                                    onTap: () => setState(() => _activeTab = 'audit_log'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tab Bar
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _tabChip('all', '${context.tr(en: 'All', ar: 'الكل')} (${_items.length})'),
                              const SizedBox(width: 8),
                              _tabChip('low_stock', '${context.tr(en: 'Low Stock', ar: 'مخزون منخفض')} ($lowStockCount)'),
                              const SizedBox(width: 8),
                              _tabChip('out_of_stock', '${context.tr(en: 'Out of Stock', ar: 'نفد المخزون')} ($outOfStockCount)'),
                              const SizedBox(width: 8),
                              _tabChip('audit_log', '${context.tr(en: 'Audit History', ar: 'سجل التدقيق')} (${_logs.length})'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Search Field
                        if (_activeTab != 'audit_log') ...[
                          SizedBox(
                            height: 42,
                            child: TextField(
                              onChanged: (v) => setState(() => _searchQuery = v),
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: context.tr(en: 'Search pharmacy stock...', ar: 'بحث في مخزون الصيدلية...'),
                                prefixIcon: const Icon(LucideIcons.search, size: 18),
                                isDense: true,
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Main List or Audit Log
                        if (_activeTab == 'audit_log') _buildAuditLogList() else _buildItemList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _kpiCard(
    String label,
    String value,
    String sub,
    IconData icon,
    Color color, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : SchooKeepColors.border,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? color : SchooKeepColors.textSecondary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 12, color: color),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(sub, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.8))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabChip(String id, String label) {
    final active = _activeTab == id;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: active ? null : Border.all(color: SchooKeepColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : SchooKeepColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildItemList() {
    final list = _filteredItems;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(LucideIcons.package, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                context.tr(en: 'No Pharmacy Items Found', ar: 'لم يتم العثور على أدوية في الصيدلية'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _openAddModal,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: Text(context.tr(en: 'Add Item', ar: 'إضافة دواء')),
              )
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = list[i];
        final isOut = item.stockQuantity == 0;
        final isLow = item.stockQuantity <= item.minThreshold && !isOut;

        final displayName = context.isRTL && item.nameAr != null && item.nameAr!.isNotEmpty
            ? item.nameAr!
            : item.name;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isOut ? const Color(0xFFFEF2F2) : (isLow ? const Color(0xFFFFFBEB) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOut ? const Color(0xFFFCA5A5) : (isLow ? const Color(0xFFFDE68A) : SchooKeepColors.border),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOut ? const Color(0xFFFEE2E2) : (isLow ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOut
                          ? context.tr(en: 'Out of Stock', ar: 'نفد المخزون')
                          : (isLow
                              ? context.tr(en: 'Low Stock', ar: 'مخزون منخفض')
                              : context.tr(en: 'Active', ar: 'نشط')),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOut ? Colors.red[900] : (isLow ? Colors.amber[900] : Colors.green[900]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${item.category} • ${item.dosageForm}',
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${context.tr(en: 'Stock', ar: 'المخزون')}: ${item.stockQuantity} ${item.unit}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${context.tr(en: 'Loc', ar: 'الموقع')}: ${item.location}',
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${context.tr(en: 'Exp', ar: 'الانتهاء')}: ${item.expiryDate}',
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action Buttons Row (Fitted/Expanded to prevent RenderFlex overflow)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _openAdjustModal(item),
                      icon: const Icon(LucideIcons.slidersHorizontal, size: 14),
                      label: FittedBox(
                        child: Text(
                          context.tr(en: 'Adjust Stock', ar: 'تعديل الكمية'),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit2, size: 18, color: SchooKeepColors.primary),
                        onPressed: () => _openEditModal(item),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                        onPressed: () => _openDeleteModal(item),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuditLogList() {
    if (_logs.isEmpty) {
      return Center(child: Text(context.tr(en: 'No audit logs recorded yet.', ar: 'لا توجد سجلات تدقيق حتى الآن.')));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final log = _logs[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    log.action.toUpperCase().replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.primary),
                  ),
                  Text(log.createdAt, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              Text(log.itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '${context.tr(en: 'Nurse', ar: 'الممرضة')}: ${log.performedByName}',
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
              ),
              if (log.reason != null && log.reason!.isNotEmpty)
                Text('"${log.reason}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
              if (log.quantityChange != null)
                Text(
                  '${context.tr(en: 'Change', ar: 'التغيير')}: ${log.quantityChange! > 0 ? "+${log.quantityChange}" : log.quantityChange} (${context.tr(en: 'New', ar: 'الإجمالي الجديد')}: ${log.newQuantity})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
                ),
            ],
          ),
        );
      },
    );
  }
}
