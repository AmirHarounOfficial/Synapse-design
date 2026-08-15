import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `AddMedicationStep2.tsx`. Medication info form: student dropdown,
/// name field, type toggle, required-document toggles, daily-dose stepper with
/// per-dose time fields, and a submit-for-review confirmation modal.
class AddMedicationStep2Screen extends StatefulWidget {
  const AddMedicationStep2Screen({super.key});

  @override
  State<AddMedicationStep2Screen> createState() => _AddMedicationStep2ScreenState();
}

class _AddMedicationStep2ScreenState extends State<AddMedicationStep2Screen> {
  /// 'permanent' | 'temporary'
  String _medicationType = 'permanent';
  int _dailyDoses = 1;
  bool _hasPhysicianOrder = false;
  bool _hasParentAuth = false;
  List<String> _doseTimes = ['08:00'];
  String _student = 'Maya Chen - Grade 5';

  static const List<String> _students = [
    'Maya Chen - Grade 5',
    'Emma Rodriguez - Grade 4',
    'Marcus Chen - Grade 7',
  ];

  bool get _isFormValid =>
      _hasPhysicianOrder && _hasParentAuth && _doseTimes.every((t) => t.isNotEmpty);

  void _handleAddDose() {
    if (_dailyDoses < 4) {
      setState(() {
        _dailyDoses += 1;
        _doseTimes = [..._doseTimes, ''];
      });
    }
  }

  void _handleRemoveDose() {
    if (_dailyDoses > 1) {
      setState(() {
        _dailyDoses -= 1;
        _doseTimes = _doseTimes.sublist(0, _doseTimes.length - 1);
      });
    }
  }

  void _updateDoseTime(int index, String value) {
    setState(() {
      final newTimes = [..._doseTimes];
      newTimes[index] = value;
      _doseTimes = newTimes;
    });
  }

  void _showSubmitModal() {
    final isRTL = context.isRTL;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SchooKeepColors.physicianTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.checkCircle, size: 24, color: SchooKeepColors.physicianTeal),
                ),
                const SizedBox(height: 8),
                Text(
                  isRTL ? 'إرسال لمراجعة الطبيب' : 'Submit for Physician Review',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  isRTL
                      ? 'سيتم إرسال هذا البروتوكول الدوائي إلى د. أمينة الهاشمي للمراجعة والاعتماد بموجب ترخيصها. لا يمكن إعطاؤه حتى يتم التوقيع عليه.'
                      : 'This medication protocol will be sent to Dr. Amina Al-Hashimi for approval. It cannot be administered until approved.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(isRTL ? 'إلغاء' : 'Cancel',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            // Advance to step 3 (final review) — the wizard is a
                            // 3-step flow: step1 → step2 → step3 → submit.
                            context.go('/nurse/medications/add/step3');
                          },
                          child: Text(isRTL ? 'تأكيد وإرسال' : 'Submit',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'إضافة دواء جديد' : 'Add Medication',
        centerTitle: true,
        onBack: () => context.go('/nurse/medications/add/step1'),
        actions: [
          Center(
            child: Text(isRTL ? 'الخطوة 2 من 3' : 'Step 2 of 3',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepProgress(activeStep: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo thumbnail
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SchooKeepColors.primary, width: 2),
                    ),
                    child: const Icon(LucideIcons.camera, size: 32, color: SchooKeepColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),
                // Medication info section
                SchooKeepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isRTL ? 'معلومات الدواء' : 'Medication Information',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      const SizedBox(height: 16),
                      // Student
                      _fieldLabel(isRTL ? 'الطالب' : 'Student'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _student,
                        isExpanded: true,
                        decoration: _inputDecoration(),
                        icon: const Icon(LucideIcons.chevronDown, size: 20, color: SchooKeepColors.textSecondary),
                        items: [
                          for (final s in _students) DropdownMenuItem(value: s, child: Text(s)),
                        ],
                        onChanged: (v) => setState(() => _student = v ?? _student),
                      ),
                      const SizedBox(height: 10),
                      // Physician context chip
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SchooKeepColors.physicianTeal.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SchooKeepColors.physicianTeal.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isRTL ? 'الطبيب المناوب حالياً' : 'PHYSICIAN ON DUTY',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal, letterSpacing: 1),
                                  ),
                                  Text(
                                    isRTL ? 'د. أمينة الهاشمي' : 'Dr. Amina Al-Hashimi',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
                                  ),
                                  Text(
                                    isRTL ? 'متواجد بالمدرسة حتى 3:00 م' : 'On-site until 3:00 PM',
                                    style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: SchooKeepColors.physicianTeal.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(isRTL ? 'متواجد' : 'On-Site',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Medication name
                      _fieldLabel(isRTL ? 'اسم الدواء' : 'Medication Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: 'Methylphenidate 10mg',
                        decoration: _inputDecoration().copyWith(
                          suffixIcon: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFEFF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(isRTL ? 'مستخرج تلقائياً' : 'Auto-extracted',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0E7490))),
                            ),
                          ),
                          suffixIconConstraints: const BoxConstraints(maxHeight: 52),
                        ),
                        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      // Type toggle
                      _fieldLabel(isRTL ? 'النوع' : 'Type'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _typeButton('permanent', isRTL ? 'دائم' : 'Permanent')),
                          const SizedBox(width: 8),
                          Expanded(child: _typeButton('temporary', isRTL ? 'مؤقت' : 'Temporary')),
                        ],
                      ),
                    ],
                  ),
                ),
                // Required documents warning banner
                if (!_hasPhysicianOrder || !_hasParentAuth) ...[
                  const SizedBox(height: 24),
                  AccentCard(
                    background: const Color(0xFFFEE2E2),
                    accentColor: SchooKeepColors.error,
                    accentWidth: 4,
                    radius: 12,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.alertCircle, size: 20, color: SchooKeepColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isRTL
                                ? 'لا يمكن جدولة الدواء حتى يتم تقديم ملف أمر الطبيب وموافقة ولي الأمر أولاً.'
                                : 'Medication cannot be scheduled until physician order AND parent consent are on file.',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF991B1B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Document uploads
                _docToggle(
                  label: isRTL ? 'أمر الطبيب المعالج' : 'Physician Order',
                  checked: _hasPhysicianOrder,
                  onTap: () => setState(() => _hasPhysicianOrder = !_hasPhysicianOrder),
                ),
                const SizedBox(height: 12),
                _docToggle(
                  label: isRTL ? 'موافقة ولي الأمر' : 'Parent Authorization',
                  checked: _hasParentAuth,
                  onTap: () => setState(() => _hasParentAuth = !_hasParentAuth),
                ),
                const SizedBox(height: 24),
                // Dose schedule
                SchooKeepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isRTL ? 'جدول الجرعات' : 'Dose Schedule',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      const SizedBox(height: 16),
                      _fieldLabel(isRTL ? 'عدد الجرعات اليومية' : 'Daily Doses'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _stepperButton('-', _dailyDoses > 1 ? _handleRemoveDose : null),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 40,
                            child: Text('$_dailyDoses',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                          ),
                          const SizedBox(width: 12),
                          _stepperButton('+', _dailyDoses < 4 ? _handleAddDose : null),
                        ],
                      ),
                      for (var i = 0; i < _doseTimes.length; i++) ...[
                        const SizedBox(height: 16),
                        _fieldLabel(isRTL ? 'وقت الجرعة ${i + 1}' : 'Dose ${i + 1} Time'),
                        const SizedBox(height: 8),
                        _TimeField(
                          value: _doseTimes[i],
                          onChanged: (v) => _updateDoseTime(i, v),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _fieldLabel(isRTL ? 'التنبيه قبل (بالدقائق)' : 'Notify Before (minutes)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: '15',
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(),
                        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                      ),
                      if (_medicationType == 'temporary') ...[
                        const SizedBox(height: 16),
                        _fieldLabel(isRTL ? 'تاريخ الانتهاء' : 'End Date'),
                        const SizedBox(height: 8),
                        TextFormField(
                          readOnly: true,
                          decoration: _inputDecoration().copyWith(
                            hintText: 'dd/mm/yyyy',
                            hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
                          ),
                          style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.physicianTeal,
                      disabledBackgroundColor: SchooKeepColors.physicianTeal.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isFormValid ? _showSubmitModal : null,
                    child: Text(isRTL ? 'إرسال لمراجعة الطبيب' : 'Submit for Physician Review',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary));
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
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
    );
  }

  Widget _typeButton(String value, String label) {
    final active = _medicationType == value;
    return SizedBox(
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: active ? SchooKeepColors.primary : SchooKeepColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: active ? BorderSide.none : const BorderSide(color: SchooKeepColors.border),
          ),
          elevation: 0,
        ),
        onPressed: () => setState(() => _medicationType = value),
        child: Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? Colors.white : SchooKeepColors.textSecondary)),
      ),
    );
  }

  Widget _stepperButton(String label, VoidCallback? onTap) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: SchooKeepColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
      ),
    );
  }

  Widget _docToggle({required String label, required bool checked, required VoidCallback onTap}) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: checked ? SchooKeepColors.greenChipBg : SchooKeepColors.surface,
          side: BorderSide(color: checked ? SchooKeepColors.accent : SchooKeepColors.error, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: checked ? SchooKeepColors.greenChipText : SchooKeepColors.textPrimary,
                  )),
            ),
            Icon(checked ? LucideIcons.checkCircle : LucideIcons.upload,
                size: 20, color: checked ? SchooKeepColors.accent : SchooKeepColors.error),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatefulWidget {
  const _TimeField({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<_TimeField> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final parts = widget.value.split(':');
        final initial = parts.length == 2
            ? TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0)
            : const TimeOfDay(hour: 8, minute: 0);
        final picked = await showTimePicker(context: context, initialTime: initial);
        if (picked != null) {
          widget.onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        height: 52,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Text(
          widget.value.isEmpty ? '--:--' : widget.value,
          style: TextStyle(
            fontSize: 14,
            color: widget.value.isEmpty ? SchooKeepColors.textSecondary : SchooKeepColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.activeStep});
  final int activeStep;

  @override
  Widget build(BuildContext context) {
    Color barColor(int step) {
      if (step < activeStep) return SchooKeepColors.accent;
      if (step == activeStep) return SchooKeepColors.primary;
      return SchooKeepColors.border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Row(
        children: [
          for (var step = 1; step <= 3; step++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: barColor(step), borderRadius: BorderRadius.circular(999)),
              ),
            ),
            if (step < 3) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}
