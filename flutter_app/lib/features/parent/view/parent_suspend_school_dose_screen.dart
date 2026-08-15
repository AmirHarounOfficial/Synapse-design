import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentSuspendSchoolDose.tsx`. Parent suspends today's school
/// dose with a required reason; a confirm dialog then a permanent success log.
class ParentSuspendSchoolDoseScreen extends StatefulWidget {
  const ParentSuspendSchoolDoseScreen({super.key});

  @override
  State<ParentSuspendSchoolDoseScreen> createState() =>
      _ParentSuspendSchoolDoseScreenState();
}

class _ParentSuspendSchoolDoseScreenState extends State<ParentSuspendSchoolDoseScreen> {
  // Stable keys so selection survives language switches; labels localized.
  static const String _afterHours = 'afterHours';
  static const String _appointment = 'appointment';
  static const String _other = 'other';

  String _reason = '';
  final TextEditingController _noteController = TextEditingController();
  bool _showSuccess = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> _reasons(bool isRTL) => [
        MapEntry(_afterHours,
            isRTL ? 'أُخذت الجرعة بعد ساعات الدوام' : 'Dose taken after school hours'),
        MapEntry(_appointment,
            isRTL ? 'الدواء في موعد الطبيب' : 'Medication at doctor appointment'),
        MapEntry(_other, isRTL ? 'أخرى (ملاحظة مطلوبة)' : 'Other (required note)'),
      ];

  String _reasonLabel(bool isRTL) {
    for (final r in _reasons(isRTL)) {
      if (r.key == _reason) return r.value;
    }
    return '';
  }

  bool get _canSubmit =>
      _reason.isNotEmpty && (_reason != _other || _noteController.text.isNotEmpty);

  void _handleSuspend(bool isRTL) {
    if (!_canSubmit) return;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.alertTriangle, size: 32, color: SchooKeepColors.error),
              ),
              const SizedBox(height: 16),
              Text(
                isRTL ? 'تعليق جرعة اليوم؟' : "Suspend Today's Dose?",
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
                    ? 'سيتم إخطار ممرضة المدرسة وتعليق جرعة اليوم المدرسية. يُسجّل هذا بشكل دائم ولا يمكن التراجع عنه.'
                    : "School nurse will be notified and today's school dose will be suspended. This is logged permanently and cannot be undone.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _OutlineButton(
                      label: isRTL ? 'إلغاء' : 'Cancel',
                      borderColor: SchooKeepColors.border,
                      foreground: SchooKeepColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OutlineButton(
                      label: isRTL ? 'تأكيد' : 'Confirm',
                      borderColor: SchooKeepColors.error,
                      foreground: SchooKeepColors.error,
                      borderWidth: 2,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        setState(() => _showSuccess = true);
                      },
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
    if (_showSuccess) {
      return _buildSuccess(context, isRTL);
    }
    return _buildForm(context, isRTL);
  }

  Widget _buildSuccess(BuildContext context, bool isRTL) {
    final now = TimeOfDay.now().format(context);
    final note = _noteController.text;
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
              isRTL ? 'تم تعليق جرعة المدرسة' : 'School Dose Suspended',
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
                  ? 'تم إخطار ممرضة المدرسة. لن تُعطى جرعة اليوم المدرسية.'
                  : "School nurse has been notified. Today's school dose will not be administered.",
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kvRow(isRTL ? 'السبب' : 'Reason', _reasonLabel(isRTL)),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 8),
                    Text(isRTL ? 'ملاحظة' : 'Note',
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(note,
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary)),
                  ],
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  _kvRow(isRTL ? 'سُجّل في' : 'Logged at', now),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isRTL) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      backgroundColor: SchooKeepColors.surface,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'تعليق جرعة المدرسة لليوم' : "Suspend today's school dose",
        onBack: () => context.safeBack(),
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _OutlineButton(
          label: isRTL ? 'تأكيد التعليق' : 'Confirm Suspension',
          borderColor: SchooKeepColors.error,
          foreground: SchooKeepColors.error,
          borderWidth: 2,
          fullWidth: true,
          height: 52,
          enabled: _canSubmit,
          onPressed: () => _handleSuspend(isRTL),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(isRTL ? 'السبب' : 'Reason',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(width: 4),
                const Text('*', style: TextStyle(fontSize: 13, color: SchooKeepColors.error)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SchooKeepColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _reason.isEmpty ? null : _reason,
                  hint: Text(isRTL ? 'اختر السبب' : 'Select reason',
                      style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary)),
                  items: _reasons(isRTL)
                      .map((r) => DropdownMenuItem(value: r.key, child: Text(r.value)))
                      .toList(),
                  onChanged: (v) => setState(() => _reason = v ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(isRTL ? 'ملاحظة' : 'Note',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                if (_reason == _other) ...[
                  const SizedBox(width: 4),
                  const Text('*', style: TextStyle(fontSize: 13, color: SchooKeepColors.error)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _reason == _other
                    ? (isRTL
                        ? 'يرجى توضيح سبب الحاجة لتعليق الجرعة'
                        : 'Please explain why the dose needs to be suspended')
                    : (isRTL ? 'أضف أي سياق إضافي...' : 'Add any additional context...'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: _inputBorder(SchooKeepColors.border),
                enabledBorder: _inputBorder(SchooKeepColors.border),
                focusedBorder: _inputBorder(SchooKeepColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.error),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isRTL ? 'هام' : 'Important',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
                        const SizedBox(height: 4),
                        Text(
                          isRTL
                              ? 'هذا تعليق دائم لليوم فقط. لن تعطي ممرضة المدرسة الجرعة المجدولة. سيستأنف جدول الغد بشكل طبيعي.'
                              : "This is a permanent suspension for today only. The school nurse will not administer the scheduled dose. Tomorrow's schedule will resume normally.",
                          style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                    ? 'استخدم هذه الميزة فقط عندما يتلقى طفلك دواءه خارج المدرسة اليوم. كل عمليات التعليق مُسجّلة ولا يمكن عكسها.'
                    : 'Use this feature only when your child has received or will receive their medication outside of school today. All suspensions are logged and cannot be reversed.',
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.onPressed,
    required this.borderColor,
    required this.foreground,
    this.borderWidth = 1,
    this.fontWeight = FontWeight.w600,
    this.fullWidth = true,
    this.height = 52,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color foreground;
  final double borderWidth;
  final FontWeight fontWeight;
  final bool fullWidth;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: Material(
          color: SchooKeepColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor, width: borderWidth),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: Text(
                label,
                style: TextStyle(color: foreground, fontWeight: fontWeight, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
