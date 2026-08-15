import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/cafeteria_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../cubit/send_cafeteria_alert_cubit.dart';
import '../../cafeteria/widgets/allergen_chip_grid.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `SendCafeteriaAlert.tsx`, now wired to the API. Live student
/// search (`GET /students`), dietary/allergen chip selection, custom restriction,
/// special meal toggle, effective-date radios, live preview, and a confirm dialog
/// that creates the allergen alert (`POST /cafeteria-alerts`). Bilingual.
class SendCafeteriaAlertScreen extends StatelessWidget {
  const SendCafeteriaAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SendCafeteriaAlertCubit(
        sl<CafeteriaRepository>(),
        sl<StudentRepository>(),
        sl<AuthRepository>(),
      ),
      child: const _SendCafeteriaAlertView(),
    );
  }
}

class _SendCafeteriaAlertView extends StatefulWidget {
  const _SendCafeteriaAlertView();

  @override
  State<_SendCafeteriaAlertView> createState() => _SendCafeteriaAlertViewState();
}

class _SendCafeteriaAlertViewState extends State<_SendCafeteriaAlertView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  final TextEditingController _mealController = TextEditingController();
  Timer? _debounce;

  Student? _selectedStudent;
  bool _showResults = false;
  final List<String> _selectedAllergens = [];
  bool _specialMealRequired = false;
  String _effectiveDate = 'today'; // today | ongoing | until
  DateTime? _untilDate;

  static const List<({String id, String en, String ar})> _dietaryItems = [
    (id: 'non-halal', en: 'NON-HALAL', ar: 'غير حلال'),
    (id: 'pork', en: 'PORK-FREE', ar: 'خالٍ من الخنزير'),
    (id: 'alcohol', en: 'ALCOHOL-FREE', ar: 'خالٍ من الكحول'),
    (id: 'peanuts', en: 'PEANUT-FREE', ar: 'خالٍ من الفول السوداني'),
    (id: 'tree-nuts', en: 'TREE NUT-FREE', ar: 'خالٍ من المكسرات'),
    (id: 'dairy', en: 'DAIRY-FREE', ar: 'خالٍ من الألبان'),
    (id: 'eggs', en: 'EGG-FREE', ar: 'خالٍ من البيض'),
    (id: 'wheat', en: 'WHEAT-FREE', ar: 'خالٍ من القمح'),
    (id: 'soy', en: 'SOY-FREE', ar: 'خالٍ من الصويا'),
    (id: 'sesame', en: 'SESAME-FREE', ar: 'خالٍ من السمسم'),
    (id: 'fish', en: 'FISH-FREE', ar: 'خالٍ من الأسماك'),
    (id: 'shellfish', en: 'SHELLFISH-FREE', ar: 'خالٍ من القشريات'),
  ];

  static const List<Color> _avatarColors = [
    Color(0xFF2563EB), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF06B6D4),
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _customController.dispose();
    _mealController.dispose();
    super.dispose();
  }

  Color _avatarColor(int seed) => _avatarColors[seed.abs() % _avatarColors.length];

  bool get _canSend =>
      _selectedStudent != null &&
      (_selectedAllergens.isNotEmpty || _customController.text.trim().isNotEmpty);

  bool get _isHalalIssue =>
      _selectedAllergens.contains('non-halal') ||
      _selectedAllergens.contains('pork') ||
      _selectedAllergens.contains('alcohol');

  void _onSearchChanged(String value) {
    setState(() => _showResults = true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<SendCafeteriaAlertCubit>().search(value);
    });
  }

  String _previewText(bool isRTL) {
    final student = _selectedStudent;
    if (student == null) return '';
    final parts = student.name.trim().split(RegExp(r'\s+'));
    final formatted = parts.length > 1 ? '${parts.first} ${parts.last[0]}.' : parts.first;

    final selectedEn = <String>[];
    final selectedAr = <String>[];
    for (final id in _selectedAllergens) {
      final item = _dietaryItems.where((x) => x.id == id).firstOrNull;
      if (item != null) {
        selectedEn.add(item.en);
        selectedAr.add(item.ar);
      }
    }
    final custom = _customController.text.trim();
    if (custom.isNotEmpty) {
      selectedEn.add(custom.toUpperCase());
      selectedAr.add(custom);
    }
    if (selectedEn.isEmpty) return '';

    return isRTL
        ? '$formatted — [${selectedAr.join('، ')}] / [${selectedEn.join(', ')}]'
        : '$formatted — [${selectedEn.join(', ')}] / [${selectedAr.join(', ')}]';
  }

  /// Composes the alert title + message from the current selection.
  ({String title, String message}) _composeAlert() {
    final student = _selectedStudent!;
    final restrictions = <String>[];
    for (final id in _selectedAllergens) {
      final item = _dietaryItems.where((x) => x.id == id).firstOrNull;
      if (item != null) restrictions.add(item.en);
    }
    final custom = _customController.text.trim();
    if (custom.isNotEmpty) restrictions.add(custom.toUpperCase());

    final title = 'Meal restriction — ${student.name}';
    final buffer = StringBuffer(restrictions.join(', '));
    if (_specialMealRequired) {
      final meal = _mealController.text.trim();
      buffer.write(meal.isEmpty ? ' • Special meal required' : ' • Special meal: $meal');
    }
    return (title: title, message: buffer.toString());
  }

  String? _createdForDate() {
    if (_effectiveDate == 'today') {
      final now = DateTime.now();
      return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
    if (_effectiveDate == 'until' && _untilDate != null) {
      final d = _untilDate!;
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return null; // ongoing / until-without-date → no specific date
  }

  void _toggleAllergen(String id) {
    setState(() {
      if (_selectedAllergens.contains(id)) {
        _selectedAllergens.remove(id);
      } else {
        _selectedAllergens.add(id);
      }
    });
  }

  void _submit() {
    final student = _selectedStudent;
    if (student == null) return;
    final composed = _composeAlert();
    context.read<SendCafeteriaAlertCubit>().send(
          studentId: student.id,
          title: composed.title,
          message: composed.message,
          isHalalIssue: _isHalalIssue,
          createdForDate: _createdForDate(),
        );
  }

  void _showConfirmDialog(bool isRTL) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isRTL ? 'تأكيد إرسال التنبيه' : 'Confirm Cafeteria Alert',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 16),
              Text(
                isRTL
                    ? 'سيتم إخطار موظفي الكافتيريا فوراً بالقيود الغذائية للطالب. لا يمكن التراجع عن هذا الإجراء.'
                    : 'Cafeteria staff will be notified immediately. This cannot be undone. Confirm?',
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: SchooKeepColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(isRTL ? 'إلغاء' : 'Cancel',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SchooKeepColors.physicianTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _submit();
                        },
                        child: Text(isRTL ? 'إرسال' : 'Confirm',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return BlocConsumer<SendCafeteriaAlertCubit, SendAlertState>(
      listener: (context, state) {
        if (state is SendAlertFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is SendAlertSuccess) {
          return _successScreen(isRTL, state.sentAt);
        }
        final submitting = state is SendAlertSubmitting;
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            centerTitle: true,
            onBack: () => context.safeBack(),
            title: isRTL ? 'تنبيه الكافتيريا' : 'Send Cafeteria Alert',
          ),
          bottomBar: _sendBar(isRTL, submitting),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                AccentCard(
                  background: const Color(0xFFEFF6FF),
                  accentColor: SchooKeepColors.primary,
                  accentWidth: 4,
                  radius: 12,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.info, size: 20, color: SchooKeepColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isRTL
                              ? 'سيرى موظفو الكافتيريا القيود المفروضة فقط دون إظهار التشخيص الطبي للطالب حماية للخصوصية بموجب قانون حماية البيانات الإماراتي (PDPL).'
                              : 'Cafeteria staff will only see the dietary restriction — not the medical reason. This protects student privacy per UAE PDPL.',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Student selector
                Text(isRTL ? 'اختر الطالب' : 'Select Student',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 8),
                _studentSelector(isRTL, state),
                const SizedBox(height: 24),

                // Restriction type
                Text(isRTL ? 'حدد قيود الطعام والشريعة' : 'Select restriction type',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                AllergenChipGrid(selectedIds: _selectedAllergens, onToggle: _toggleAllergen),
                const SizedBox(height: 16),
                _textField(
                  controller: _customController,
                  hint: isRTL ? 'قيود إضافية أخرى (مثل: نباتي)' : 'Other restriction (e.g., vegetarian)',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                // Special meal
                InkWell(
                  onTap: () => setState(() => _specialMealRequired = !_specialMealRequired),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _specialMealRequired,
                          activeColor: SchooKeepColors.primary,
                          onChanged: (v) => setState(() => _specialMealRequired = v ?? false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(isRTL ? 'طلب تحضير وجبة خاصة' : 'Request special meal preparation',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                if (_specialMealRequired) ...[
                  const SizedBox(height: 12),
                  _textField(
                    controller: _mealController,
                    hint: isRTL ? 'تفاصيل الوجبة الخاصة المطلوبة...' : 'Meal description (optional)',
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 24),

                // Effective date
                Text(isRTL ? 'فترة سريان التنبيه' : 'Effective date',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                _radioRow('today', isRTL ? 'اليوم فقط' : 'Today only'),
                const SizedBox(height: 8),
                _radioRow('ongoing', isRTL ? 'حتى إشعار آخر' : 'Until further notice'),
                const SizedBox(height: 8),
                _radioRow('until', isRTL ? 'حتى تاريخ محدد' : 'Until date'),
                if (_effectiveDate == 'until') ...[
                  const SizedBox(height: 8),
                  _dateField(isRTL),
                ],

                // Preview
                if (_canSend) ...[
                  const SizedBox(height: 24),
                  Text(isRTL ? 'معاينة التنبيه' : 'Preview',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 12),
                  SchooKeepCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isRTL ? 'سوف تستلم الكافتيريا ما يلي:' : 'Cafeteria will receive:',
                            style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SchooKeepColors.amberBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: SchooKeepColors.warning),
                          ),
                          child: Text(_previewText(isRTL),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _successScreen(bool isRTL, String sentAt) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        centerTitle: true,
        onBack: () => context.safeBack(),
        title: isRTL ? 'إرسال تنبيه للكافتيريا' : 'Send Cafeteria Alert',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: SchooKeepColors.greenChipBg, shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, size: 32, color: SchooKeepColors.accent),
              ),
              const SizedBox(height: 16),
              Text(isRTL ? 'تم إرسال التنبيه بنجاح' : 'Alert Sent Successfully',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                isRTL ? 'تم تسليم تنبيه الكافتيريا في الساعة $sentAt' : 'Alert delivered to cafeteria at $sentAt',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentSelector(bool isRTL, SendAlertState state) {
    final student = _selectedStudent;
    if (student != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _avatarColor(student.id),
              child: Text(student.initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                  if ((student.grade ?? '').isNotEmpty)
                    Text(student.grade!, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _selectedStudent = null;
                _searchController.clear();
                context.read<SendCafeteriaAlertCubit>().clearResults();
              }),
              child: const Icon(LucideIcons.x, size: 16, color: SchooKeepColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final results = state is SendAlertIdle ? state.results : const <Student>[];
    final searching = state is SendAlertIdle && state.searching;
    final query = _searchController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onTap: () => setState(() => _showResults = true),
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
            suffixIcon: searching
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: SchooKeepColors.primary),
                    ),
                  )
                : null,
            hintText: isRTL ? 'ابحث عن اسم الطالب...' : 'Search student name...',
            hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
            filled: true,
            fillColor: SchooKeepColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SchooKeepColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
            ),
          ),
        ),
        if (_showResults && query.isNotEmpty && results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final s in results)
                  InkWell(
                    onTap: () => setState(() {
                      _selectedStudent = s;
                      _searchController.clear();
                      _showResults = false;
                      context.read<SendCafeteriaAlertCubit>().clearResults();
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _avatarColor(s.id),
                            child: Text(s.initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                                if ((s.grade ?? '').isNotEmpty)
                                  Text(s.grade!, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (_showResults && query.isNotEmpty && !searching && results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(isRTL ? 'لا توجد نتائج' : 'No students found',
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
        filled: true,
        fillColor: SchooKeepColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SchooKeepColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _radioRow(String value, String label) {
    return InkWell(
      onTap: () => setState(() => _effectiveDate = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Row(
          children: [
            _RadioDot(selected: _effectiveDate == value, color: SchooKeepColors.primary),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _dateField(bool isRTL) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _untilDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => _untilDate = picked);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Text(
          _untilDate == null
              ? (isRTL ? 'اختر التاريخ' : 'Select date')
              : '${_untilDate!.year}-${_untilDate!.month.toString().padLeft(2, '0')}-${_untilDate!.day.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 14,
            color: _untilDate == null ? SchooKeepColors.textSecondary : SchooKeepColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _sendBar(bool isRTL, bool submitting) {
    final enabled = _canSend && !submitting;
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: SchooKeepColors.physicianTeal,
            disabledBackgroundColor: SchooKeepColors.physicianTeal.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: enabled ? () => _showConfirmDialog(isRTL) : null,
          child: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(isRTL ? 'إرسال التنبيه للكافتيريا' : 'Send to Cafeteria',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.color});
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? color : SchooKeepColors.border, width: 2),
          ),
          child: selected
              ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
