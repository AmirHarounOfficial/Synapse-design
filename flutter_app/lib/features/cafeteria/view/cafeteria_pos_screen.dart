import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/cafeteria_wallet.dart';
import '../../../data/repositories/cafeteria_repository.dart';

class _MealPreset {
  const _MealPreset({
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.category,
    required this.icon,
  });
  final String nameEn;
  final String nameAr;
  final double price;
  final String category;
  final IconData icon;
}

/// Cafeteria Specialist Point-of-Sale (POS) screen to look up student cafeteria
/// allowances, check allergen warnings, and charge meal purchases against the
/// student's daily limit and monthly budget. Localized in EN & AR.
class CafeteriaPosScreen extends StatefulWidget {
  const CafeteriaPosScreen({super.key});

  @override
  State<CafeteriaPosScreen> createState() => _CafeteriaPosScreenState();
}

class _CafeteriaPosScreenState extends State<CafeteriaPosScreen> {
  final CafeteriaRepository _repo = sl<CafeteriaRepository>();

  static const List<({int id, String name, String grade, String allergyEn, String allergyAr})> _demoStudents = [
    (id: 1, name: 'Emma Rodriguez', grade: 'Grade 5 · Sec A', allergyEn: 'Peanut Allergy', allergyAr: 'حساسية الفول السوداني'),
    (id: 2, name: 'Marcus Chen', grade: 'Grade 4 · Sec B', allergyEn: 'Gluten Intolerance', allergyAr: 'حساسية الجلوتين'),
    (id: 3, name: 'Sophia Williams', grade: 'Grade 6 · Sec A', allergyEn: 'Lactose Intolerant', allergyAr: 'حساسية اللاكتوز'),
  ];

  static const _presets = [
    _MealPreset(nameEn: 'Hot Meal Deal + Drink', nameAr: 'وجبة ساخنة + عصير', price: 20.0, category: 'meal', icon: LucideIcons.utensils),
    _MealPreset(nameEn: 'Chicken Sandwich & Juice', nameAr: 'سندويش دجاج + عصير', price: 15.0, category: 'meal', icon: LucideIcons.sandwich),
    _MealPreset(nameEn: 'Fresh Fruit Salad & Yogurt', nameAr: 'سلطة فواكه طازجة + زبادي', price: 8.5, category: 'snack', icon: LucideIcons.apple),
    _MealPreset(nameEn: 'Apple / Orange Juice Box', nameAr: 'علبة عصير طازج', price: 5.0, category: 'beverage', icon: LucideIcons.cupSoda),
  ];

  late ({int id, String name, String grade, String allergyEn, String allergyAr}) _selectedStudent;

  final TextEditingController _customItemController = TextEditingController();
  final TextEditingController _customPriceController = TextEditingController();

  CafeteriaWallet? _wallet;
  bool _isLoadingWallet = true;
  bool _isCharging = false;
  _MealPreset? _selectedPreset;

  String? _errorMessage;
  CafeteriaWallet? _lastReceiptWallet;
  String? _lastChargedItem;
  double? _lastChargedAmount;

  @override
  void initState() {
    super.initState();
    _selectedStudent = _demoStudents.first;
    _selectedPreset = _presets.first;
    _customItemController.text = _presets.first.nameEn;
    _customPriceController.text = _presets.first.price.toStringAsFixed(2);
    _loadWallet();
  }

  @override
  void dispose() {
    _customItemController.dispose();
    _customPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _isLoadingWallet = true;
      _errorMessage = null;
      _lastReceiptWallet = null;
    });

    try {
      final wallet = await _repo.getWallet(_selectedStudent.id);
      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _isLoadingWallet = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = CafeteriaRepository.messageFor(e);
        _isLoadingWallet = false;
      });
    }
  }

  void _selectPreset(_MealPreset preset, bool isAr) {
    setState(() {
      _selectedPreset = preset;
      _customItemController.text = isAr ? preset.nameAr : preset.nameEn;
      _customPriceController.text = preset.price.toStringAsFixed(2);
    });
  }

  Future<void> _chargePurchase() async {
    final itemName = _customItemController.text.trim();
    final amount = double.tryParse(_customPriceController.text.trim());

    if (itemName.isEmpty) {
      setState(() => _errorMessage = context.tr(en: 'Please enter item name', ar: 'يرجى إدخال اسم الوجبة/الصنف'));
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = context.tr(en: 'Please enter a valid price amount', ar: 'يرجى إدخال سعر صحيح'));
      return;
    }

    if (_wallet != null && amount > _wallet!.remainingDaily) {
      setState(() => _errorMessage = context.tr(
            en: 'Amount exceeds daily remaining limit of ${_wallet!.remainingDaily.toStringAsFixed(2)} AED',
            ar: 'المبلغ يتجاوز الحد اليومي المتبقي للطالب وهو ${_wallet!.remainingDaily.toStringAsFixed(2)} درهم',
          ));
      return;
    }

    if (_wallet != null && amount > _wallet!.remainingMonthly) {
      setState(() => _errorMessage = context.tr(
            en: 'Amount exceeds monthly remaining budget of ${_wallet!.remainingMonthly.toStringAsFixed(2)} AED',
            ar: 'المبلغ يتجاوز الميزانية الشهرية المتبقية للطالب وهي ${_wallet!.remainingMonthly.toStringAsFixed(2)} درهم',
          ));
      return;
    }

    setState(() {
      _isCharging = true;
      _errorMessage = null;
    });

    try {
      final updatedWallet = await _repo.chargePurchase(
        _selectedStudent.id,
        amount: amount,
        itemName: itemName,
        category: _selectedPreset?.category ?? 'meal',
        staffName: 'Cafeteria Specialist (Main Counter)',
      );

      if (!mounted) return;
      setState(() {
        _isCharging = false;
        _wallet = updatedWallet;
        _lastReceiptWallet = updatedWallet;
        _lastChargedItem = itemName;
        _lastChargedAmount = amount;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCharging = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRTL;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/cafeteria/home'),
        centerTitle: true,
        title: context.tr(en: 'Cafeteria POS & Student Allowance', ar: 'نقطة بيع الكافتيريا ورصيد الطلاب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _studentSelector(isAr),
            const SizedBox(height: 16),
            if (_isLoadingWallet)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else ...[
              if (_errorMessage != null) ...[
                _errorBanner(_errorMessage!),
                const SizedBox(height: 16),
              ],
              if (_lastReceiptWallet != null) ...[
                _receiptBanner(isAr),
                const SizedBox(height: 16),
              ],
              _studentBalanceCard(isAr),
              const SizedBox(height: 20),
              _presetsGrid(isAr),
              const SizedBox(height: 20),
              _customChargeForm(isAr),
            ],
          ],
        ),
      ),
    );
  }

  Widget _studentSelector(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(en: 'Select Student', ar: 'اختر الطالب / ابحث بالهوية'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SchooKeepColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedStudent.id,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 20, color: SchooKeepColors.textSecondary),
              items: _demoStudents.map((s) {
                return DropdownMenuItem<int>(
                  value: s.id,
                  child: Row(
                    children: [
                      const Icon(LucideIcons.user, size: 18, color: SchooKeepColors.primary),
                      const SizedBox(width: 10),
                      Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      const SizedBox(width: 8),
                      Text('(${s.grade})', style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final found = _demoStudents.firstWhere((s) => s.id == val);
                  setState(() => _selectedStudent = found);
                  _loadWallet();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _studentBalanceCard(bool isAr) {
    final w = _wallet!;
    final isDailyExhausted = w.remainingDaily <= 0;

    return Column(
      children: [
        // Allergy Alert Notice Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SchooKeepColors.error),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${context.tr(en: 'Dietary Warning: ', ar: 'تنبيه حساسية غذائية: ')}${isAr ? _selectedStudent.allergyAr : _selectedStudent.allergyEn}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.error),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Wallet Balance Card
        AccentCard(
          background: SchooKeepColors.surface,
          accentColor: isDailyExhausted ? SchooKeepColors.error : SchooKeepColors.accent,
          accentWidth: 4,
          radius: 12,
          padding: const EdgeInsets.all(16),
          borderColor: SchooKeepColors.border,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(en: "Today's Allowed Remaining", ar: 'المسموح به اليوم للكافتيريا'),
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${w.remainingDaily.toStringAsFixed(2)} AED',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDailyExhausted ? SchooKeepColors.error : SchooKeepColors.accent,
                        ),
                      ),
                    ],
                  ),
                  Container(height: 36, width: 1, color: SchooKeepColors.border),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        context.tr(en: 'Monthly Remaining', ar: 'المتبقي من الميزانية الشهرية'),
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${w.remainingMonthly.toStringAsFixed(2)} AED',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SchooKeepColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, color: SchooKeepColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(
                      en: 'Daily Limit: ${w.dailyLimit.toStringAsFixed(0)} AED (Spent: ${w.todaySpent.toStringAsFixed(2)} AED)',
                      ar: 'الحد اليومي: ${w.dailyLimit.toStringAsFixed(0)} درهم (أنفق: ${w.todaySpent.toStringAsFixed(2)} درهم)',
                    ),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                  Text(
                    context.tr(
                      en: 'Monthly Budget: ${w.monthlyBudget.toStringAsFixed(0)} AED',
                      ar: 'الميزانية: ${w.monthlyBudget.toStringAsFixed(0)} درهم',
                    ),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _presetsGrid(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(en: 'Quick Meal & Snack Presets', ar: 'الوجبات الجاهزة والسريعة'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: [
            for (final p in _presets)
              GestureDetector(
                onTap: () => _selectPreset(p, isAr),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedPreset == p ? const Color(0xFFEFF6FF) : SchooKeepColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedPreset == p ? SchooKeepColors.primary : SchooKeepColors.border,
                      width: _selectedPreset == p ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(p.icon, size: 18, color: _selectedPreset == p ? SchooKeepColors.primary : SchooKeepColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isAr ? p.nameAr : p.nameEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selectedPreset == p ? SchooKeepColors.primary : SchooKeepColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${p.price.toStringAsFixed(2)} ${context.tr(en: 'AED', ar: 'درهم')}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _customChargeForm(bool isAr) {
    final w = _wallet!;
    final price = double.tryParse(_customPriceController.text.trim()) ?? 0.0;
    final isOverLimit = price > w.remainingDaily || price > w.remainingMonthly;

    return SchooKeepCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Confirm & Charge Purchase', ar: 'تأكيد وإتمام الشراء'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(en: 'Item Description', ar: 'اسم الوجبة / صنف الشراء'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _customItemController,
            decoration: _inputDecoration(hint: 'Item name...'),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(en: 'Purchase Amount (AED)', ar: 'مبلغ الشراء (درهم إماراتي)'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _customPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(hint: '0.00'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isOverLimit ? SchooKeepColors.border : SchooKeepColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: (_isCharging || isOverLimit) ? null : _chargePurchase,
              child: _isCharging
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      isOverLimit
                          ? context.tr(en: 'Exceeds Allowance Limit', ar: 'يتجاوز الحد المسموح اليوم')
                          : context.tr(en: 'Charge Student Allowance', ar: 'خصم المبلغ من رصيد الطالب'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isOverLimit ? const Color(0xFF94A3B8) : Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: SchooKeepColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2)),
    );
  }

  Widget _errorBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8), border: Border.all(color: SchooKeepColors.error)),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, size: 18, color: SchooKeepColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: SchooKeepColors.error))),
        ],
      ),
    );
  }

  Widget _receiptBanner(bool isAr) {
    final w = _lastReceiptWallet!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.greenChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.accent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.checkCircle2, size: 22, color: SchooKeepColors.accent),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Transaction Charged Successfully!', ar: 'تم خصم المبلغ وتوثيق العملية بنجاح!'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.greenChipText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_lastChargedItem!} — ${_lastChargedAmount!.toStringAsFixed(2)} AED',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(
              en: "Remaining today: ${w.remainingDaily.toStringAsFixed(2)} AED · Remaining monthly: ${w.remainingMonthly.toStringAsFixed(2)} AED",
              ar: "المتبقي اليوم: ${w.remainingDaily.toStringAsFixed(2)} درهم · المتبقي شهرياً: ${w.remainingMonthly.toStringAsFixed(2)} درهم",
            ),
            style: const TextStyle(fontSize: 12, color: SchooKeepColors.greenChipText),
          ),
        ],
      ),
    );
  }
}
