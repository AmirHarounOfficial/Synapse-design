import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

class _Medication {
  const _Medication({required this.id, required this.name, required this.nextSchoolDose});
  final String id;
  final String name;
  final String nextSchoolDose;
}

/// Ported from `ParentReportHomeDose.tsx`. Parent reports the time a dose was
/// given at home so the school nurse can adjust the school schedule.
class ParentReportHomeDoseScreen extends StatefulWidget {
  const ParentReportHomeDoseScreen({super.key});

  @override
  State<ParentReportHomeDoseScreen> createState() => _ParentReportHomeDoseScreenState();
}

class _ParentReportHomeDoseScreenState extends State<ParentReportHomeDoseScreen> {
  static const List<_Medication> _medications = [
    _Medication(id: '1', name: 'Ritalin 10mg', nextSchoolDose: '10:30 AM'),
    _Medication(id: '2', name: 'Albuterol Inhaler', nextSchoolDose: 'As needed'),
  ];

  String _selectedMedication = '';
  TimeOfDay? _selectedTime;
  final TextEditingController _noteController = TextEditingController();
  bool _showConfirmation = false;

  _Medication? get _selectedMed {
    for (final m in _medications) {
      if (m.id == _selectedMedication) return m;
    }
    return null;
  }

  String get _timeLabel => _selectedTime == null ? '' : _selectedTime!.format(context);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_selectedMedication.isNotEmpty && _selectedTime != null) {
      setState(() => _showConfirmation = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    if (_showConfirmation) {
      return _buildConfirmation(context, isRTL);
    }
    return _buildForm(context, isRTL);
  }

  Widget _buildConfirmation(BuildContext context, bool isRTL) {
    final med = _selectedMed;
    final now = TimeOfDay.now().format(context);
    return SchooKeepScaffold(
      reserveBottomNav: true,
      backgroundColor: SchooKeepColors.surface,
      appBar: SchooKeepAppBar(onBack: () => context.safeBack()),
      bottomBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SchooKeepButton(
          label: isRTL ? 'تم' : 'Done',
          onPressed: () => context.go('/parent/app/medications'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: SchooKeepColors.greenChipBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.checkCircle, size: 32, color: SchooKeepColors.accent),
            ),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'تم الإبلاغ عن الجرعة المنزلية' : 'Home Dose Reported',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: SchooKeepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRTL
                  ? 'تم إخطار ممرضة المدرسة. تم تعديل جدول جرعات المدرسة لليوم تلقائياً.'
                  : "School nurse has been notified. Today's school dose schedule has been adjusted automatically.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Column(
                children: [
                  _kvRow(isRTL ? 'الدواء' : 'Medication', med?.name ?? ''),
                  const SizedBox(height: 8),
                  _kvRow(isRTL ? 'وقت الجرعة المنزلية' : 'Home dose time', _timeLabel),
                  const SizedBox(height: 8),
                  _kvRow(isRTL ? 'أُبلغ في' : 'Reported at', now),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isRTL) {
    final med = _selectedMed;
    final canSubmit = _selectedMedication.isNotEmpty && _selectedTime != null;
    final showConflict = canSubmit && med != null;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      backgroundColor: SchooKeepColors.surface,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'الإبلاغ عن توقيت الجرعة المنزلية' : 'Report home dose timing',
        onBack: () => context.safeBack(),
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SchooKeepButton(
          label: isRTL ? 'إرسال التقرير' : 'Submit Report',
          enabled: canSubmit,
          onPressed: _handleSubmit,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(isRTL ? 'الدواء' : 'Medication'),
            const SizedBox(height: 8),
            _dropdown(isRTL),
            const SizedBox(height: 16),
            _fieldLabel(isRTL ? 'في أي وقت أُعطيت الجرعة؟' : 'What time was the dose given?'),
            const SizedBox(height: 8),
            _timeField(context, isRTL),
            const SizedBox(height: 16),
            _fieldLabel(isRTL ? 'ملاحظة (اختياري)' : 'Note (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isRTL ? 'أضف أي سياق إضافي...' : 'Add any additional context...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: _inputBorder(SchooKeepColors.border),
                enabledBorder: _inputBorder(SchooKeepColors.border),
                focusedBorder: _inputBorder(SchooKeepColors.primary),
              ),
            ),
            if (showConflict) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SchooKeepColors.amberChipBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SchooKeepColors.warning),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRTL ? 'تأثير على الجدول' : 'Schedule Impact',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: SchooKeepColors.amberText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isRTL
                                ? 'الجرعة المنزلية في $_timeLabel ستعدّل جرعة المدرسة لليوم من ${med.nextSchoolDose} للحفاظ على التباعد الصحيح بين الجرعات.'
                                : "Home dose at $_timeLabel will adjust today's school dose from ${med.nextSchoolDose} to maintain proper medication spacing.",
                            style: const TextStyle(fontSize: 12, color: SchooKeepColors.amberText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Text(
                isRTL
                    ? 'يساعد هذا التقرير ممرضة المدرسة على الحفاظ على توقيت دقيق للدواء ومنع الجرعات المزدوجة.'
                    : 'This report helps the school nurse maintain accurate medication timing and prevent double-dosing.',
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(bool isRTL) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SchooKeepColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedMedication.isEmpty ? null : _selectedMedication,
          hint: Text(isRTL ? 'اختر الدواء' : 'Select medication',
              style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary)),
          items: _medications
              .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
              .toList(),
          onChanged: (v) => setState(() => _selectedMedication = v ?? ''),
        ),
      ),
    );
  }

  Widget _timeField(BuildContext context, bool isRTL) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null) setState(() => _selectedTime = picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SchooKeepColors.border),
        ),
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          _selectedTime == null ? (isRTL ? 'اختر الوقت' : 'Select time') : _timeLabel,
          style: TextStyle(
            fontSize: 15,
            color: _selectedTime == null
                ? SchooKeepColors.textSecondary
                : SchooKeepColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: SchooKeepColors.textPrimary,
        ),
      );

  OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );

  Widget _kvRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.textPrimary)),
        ),
      ],
    );
  }
}
