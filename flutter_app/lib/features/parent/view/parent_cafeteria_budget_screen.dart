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

class _ChildOption {
  const _ChildOption({
    required this.id,
    required this.name,
    required this.gradeEn,
    required this.gradeAr,
    required this.initials,
  });
  final int id;
  final String name;
  final String gradeEn;
  final String gradeAr;
  final String initials;
}

/// Parent screen to manage child's monthly cafeteria budget, daily spending limit,
/// and view real-time remaining balances & purchase history logs. Localized in EN & AR.
class ParentCafeteriaBudgetScreen extends StatefulWidget {
  const ParentCafeteriaBudgetScreen({super.key});

  @override
  State<ParentCafeteriaBudgetScreen> createState() => _ParentCafeteriaBudgetScreenState();
}

class _ParentCafeteriaBudgetScreenState extends State<ParentCafeteriaBudgetScreen> {
  final CafeteriaRepository _repo = sl<CafeteriaRepository>();

  static const _children = [
    _ChildOption(id: 1, name: 'Emma Rodriguez', gradeEn: 'Grade 5 · Sec A', gradeAr: 'الصف الخامس · أ', initials: 'ER'),
    _ChildOption(id: 2, name: 'Marcus Chen', gradeEn: 'Grade 4 · Sec B', gradeAr: 'الصف الرابع · ب', initials: 'MC'),
  ];

  late _ChildOption _selectedChild;

  final TextEditingController _monthlyController = TextEditingController();
  final TextEditingController _dailyController = TextEditingController();

  CafeteriaWallet? _wallet;
  List<CafeteriaTransaction> _transactions = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _selectedChild = _children.first;
    _loadData();
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _dailyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final wallet = await _repo.getWallet(_selectedChild.id);
      final txs = await _repo.getTransactions(_selectedChild.id);

      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _transactions = txs;
        _monthlyController.text = wallet.monthlyBudget.toStringAsFixed(0);
        _dailyController.text = wallet.dailyLimit.toStringAsFixed(0);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = CafeteriaRepository.messageFor(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBudget() async {
    final monthly = double.tryParse(_monthlyController.text.trim());
    final daily = double.tryParse(_dailyController.text.trim());

    if (monthly == null || monthly < 0) {
      setState(() => _errorMessage = context.tr(en: 'Please enter a valid monthly budget', ar: 'يرجى إدخال ميزانية شهرية صحيحة'));
      return;
    }

    if (daily == null || daily < 0) {
      setState(() => _errorMessage = context.tr(en: 'Please enter a valid daily limit', ar: 'يرجى إدخال حد يومي صحيح'));
      return;
    }

    if (daily > monthly) {
      setState(() => _errorMessage = context.tr(en: 'Daily limit cannot exceed monthly budget', ar: 'لا يمكن أن يتجاوز الحد اليومي الميزانية الشهرية'));
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final updated = await _repo.updateWallet(_selectedChild.id, monthlyBudget: monthly, dailyLimit: daily);
      if (!mounted) return;
      setState(() {
        _wallet = updated;
        _isSaving = false;
        _successMessage = context.tr(en: 'Cafeteria budget & daily limit updated!', ar: 'تم تحديث ميزانية الكافتيريا والحد اليومي بنجاح!');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = CafeteriaRepository.messageFor(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/parent/app/home'),
        centerTitle: true,
        title: context.tr(en: 'Cafeteria Budget & Allowance', ar: 'ميزانية الكافتيريا والحد اليومي'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _freeFirstMonthBanner(),
            const SizedBox(height: 12),
            _childSelector(),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else ...[
              if (_errorMessage != null) ...[
                _errorBanner(_errorMessage!),
                const SizedBox(height: 16),
              ],
              if (_successMessage != null) ...[
                _successBanner(_successMessage!),
                const SizedBox(height: 16),
              ],
              _balanceSummaryCards(),
              const SizedBox(height: 24),
              _budgetForm(),
              const SizedBox(height: 24),
              _transactionsHeader(),
              const SizedBox(height: 12),
              _transactionsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _freeFirstMonthBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x338B5CF6), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, size: 20, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'FREE FOR FIRST MONTH', ar: 'مجاني للشهر الأول 🎁'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                ),
                Text(
                  context.tr(
                    en: 'Cafeteria spending wallet management is 100% free for your 1st month!',
                    ar: 'إدارة محفظة وميزانية الكافتيريا مجانية 100% خلال شهرك الأول!',
                  ),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
            child: Text(
              context.tr(en: 'FREE', ar: 'مجاناً'),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Row(
        children: [
          for (final c in _children)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_selectedChild.id != c.id) {
                    setState(() => _selectedChild = c);
                    _loadData();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _selectedChild.id == c.id ? SchooKeepColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedChild.id == c.id ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          c.initials,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _selectedChild.id == c.id ? Colors.white : SchooKeepColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _selectedChild.id == c.id ? Colors.white : SchooKeepColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _balanceSummaryCards() {
    final w = _wallet!;
    final monthlyPct = (w.monthlyBudget > 0 ? (w.monthlySpent / w.monthlyBudget) : 0.0).clamp(0.0, 1.0);
    final dailyPct = (w.dailyLimit > 0 ? (w.todaySpent / w.dailyLimit) : 0.0).clamp(0.0, 1.0);

    return Column(
      children: [
        // Monthly Budget Summary Card
        AccentCard(
          background: SchooKeepColors.surface,
          accentColor: SchooKeepColors.primary,
          accentWidth: 4,
          radius: 12,
          padding: const EdgeInsets.all(16),
          borderColor: SchooKeepColors.border,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.wallet, size: 20, color: SchooKeepColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(en: 'Remaining Monthly Budget', ar: 'المتبقي من الميزانية الشهرية'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    '${w.remainingMonthly.toStringAsFixed(2)} AED',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SchooKeepColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: monthlyPct,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFEFF6FF),
                  valueColor: AlwaysStoppedAnimation(monthlyPct > 0.85 ? SchooKeepColors.error : SchooKeepColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(
                      en: 'Spent this month: ${w.monthlySpent.toStringAsFixed(2)} AED',
                      ar: 'المصروف هذا الشهر: ${w.monthlySpent.toStringAsFixed(2)} درهم',
                    ),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                  Text(
                    context.tr(
                      en: 'Total budget: ${w.monthlyBudget.toStringAsFixed(0)} AED',
                      ar: 'إجمالي الميزانية: ${w.monthlyBudget.toStringAsFixed(0)} درهم',
                    ),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Today's Remaining Daily Limit Card
        AccentCard(
          background: SchooKeepColors.surface,
          accentColor: SchooKeepColors.accent,
          accentWidth: 4,
          radius: 12,
          padding: const EdgeInsets.all(16),
          borderColor: SchooKeepColors.border,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.calendarCheck, size: 20, color: SchooKeepColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(en: "Today's Remaining Limit", ar: 'المتبقي من الحد اليومي اليوم'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    '${w.remainingDaily.toStringAsFixed(2)} AED',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SchooKeepColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: dailyPct,
                  minHeight: 8,
                  backgroundColor: SchooKeepColors.greenChipBg,
                  valueColor: AlwaysStoppedAnimation(dailyPct >= 1.0 ? SchooKeepColors.error : SchooKeepColors.accent),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(
                      en: 'Spent today: ${w.todaySpent.toStringAsFixed(2)} AED',
                      ar: 'مصروف اليوم: ${w.todaySpent.toStringAsFixed(2)} درهم',
                    ),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                  Text(
                    context.tr(
                      en: 'Max daily limit: ${w.dailyLimit.toStringAsFixed(0)} AED',
                      ar: 'الحد اليومي الأقصى: ${w.dailyLimit.toStringAsFixed(0)} درهم',
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

  Widget _budgetForm() {
    return SchooKeepCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sliders, size: 20, color: SchooKeepColors.primary),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Set Cafeteria Allowance Limits', ar: 'تحديد ميزانية وحدود الشراء'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(
              en: 'Control how much ${_selectedChild.name} can spend monthly and daily in the school cafeteria.',
              ar: 'تحكم بالمبلغ الإجمالي واليومي الذي يمكن لـ ${_selectedChild.name} إنفاقه في كافتيريا المدرسة.',
            ),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Monthly Budget Input
          Text(
            context.tr(en: 'Monthly Cafeteria Budget (AED)', ar: 'الميزانية الشهرية للكافتيريا (درهم إماراتي)'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _monthlyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(
              hint: 'e.g. 500',
              suffixText: 'AED',
              icon: LucideIcons.creditCard,
            ),
          ),
          const SizedBox(height: 16),

          // Daily Spending Limit Input
          Text(
            context.tr(en: 'Maximum Daily Spending Limit (AED)', ar: 'الحد الأقصى للإنفاق اليومي (درهم إماراتي)'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _dailyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(
              hint: 'e.g. 25',
              suffixText: 'AED',
              icon: LucideIcons.clock,
            ),
          ),
          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isSaving ? null : _saveBudget,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      context.tr(en: 'Save Budget & Limit', ar: 'حفظ الميزانية والحد اليومي'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr(en: 'Cafeteria Purchase History', ar: 'سجل مشتريات الكافتيريا'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
        ),
        Text(
          context.tr(en: '${_transactions.length} items', ar: '${_transactions.length} عمليات'),
          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
        ),
      ],
    );
  }

  Widget _transactionsList() {
    if (_transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Text(
          context.tr(en: 'No cafeteria transactions recorded yet.', ar: 'لا توجد عمليات شراء من الكافتيريا مسجلة حتى الآن.'),
          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        for (final tx in _transactions) ...[
          _transactionTile(tx),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _transactionTile(CafeteriaTransaction tx) {
    final dateStr = tx.createdAt != null
        ? '${tx.createdAt!.day}/${tx.createdAt!.month}/${tx.createdAt!.year} ${tx.createdAt!.hour}:${tx.createdAt!.minute.toString().padLeft(2, '0')}'
        : 'Recently';

    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.utensils, size: 20, color: SchooKeepColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.itemName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    dateStr,
                    if (tx.staffName != null) tx.staffName!,
                  ].join(' · '),
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '-${tx.amount.toStringAsFixed(2)} ${context.tr(en: 'AED', ar: 'درهم')}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.error),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required String suffixText, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffixText,
      prefixIcon: Icon(icon, size: 18, color: SchooKeepColors.textSecondary),
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

  Widget _successBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: SchooKeepColors.greenChipBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: SchooKeepColors.accent)),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle2, size: 18, color: SchooKeepColors.accent),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: SchooKeepColors.greenChipText))),
        ],
      ),
    );
  }
}
