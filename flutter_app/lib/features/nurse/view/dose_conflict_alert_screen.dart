import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/medication_repository.dart';
import 'package:schookeep/core/router/safe_back.dart';

class DoseConflictAlertScreen extends StatefulWidget {
  const DoseConflictAlertScreen({super.key, this.medicationId, this.studentId});

  final int? medicationId;
  final int? studentId;

  @override
  State<DoseConflictAlertScreen> createState() => _DoseConflictAlertScreenState();
}

class _DoseConflictAlertScreenState extends State<DoseConflictAlertScreen> {
  String _selectedOption = 'accept';
  bool _submitting = false;
  final TextEditingController _justificationController = TextEditingController();
  final MedicationRepository _repo = sl<MedicationRepository>();

  @override
  void initState() {
    super.initState();
    _justificationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting &&
      (_selectedOption == 'accept' ||
          (_selectedOption == 'override' && _justificationController.text.trim().isNotEmpty));

  Future<void> _handleConfirm() async {
    final medId = widget.medicationId;
    final studentId = widget.studentId;
    final messenger = ScaffoldMessenger.of(context);

    if (medId != null && studentId != null) {
      setState(() => _submitting = true);
      try {
        await _repo.logDose(
          medicationId: medId,
          studentId: studentId,
          status: _selectedOption == 'override' ? 'conflict' : 'given',
          notes: _selectedOption == 'override' ? _justificationController.text.trim() : null,
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _submitting = false);
        messenger.showSnackBar(
          SnackBar(content: Text(MedicationRepository.messageFor(e)), backgroundColor: SchooKeepColors.error),
        );
        return;
      }
    }
    if (!mounted) return;
    context.go('/nurse/medications');
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(onBack: () => context.safeBack()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _amberHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _conflictInfo(context),
                const SizedBox(height: 24),
                _recommendedAdjustment(context),
                const SizedBox(height: 24),
                _nurseAction(context),
                const SizedBox(height: 24),
                _accessibilityNote(context),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.primary,
                      disabledBackgroundColor: SchooKeepColors.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _canSubmit ? _handleConfirm : null,
                    child: Text(
                      context.tr(en: 'Confirm and Update Schedule', ar: 'تأكيد الجدولة وتحديث الموعد'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amberHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      color: SchooKeepColors.warning,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.alertTriangle, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(en: 'Dose Conflict Detected', ar: 'تنبيه تعارض في موعد الجرعات'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _conflictInfo(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Parent Report', ar: 'بلاغ ولي الأمر'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(en: 'Parent reported home dose given at 7:02 AM (reported at 7:18 AM)', ar: 'أفاد ولي الأمر بإعطاء الجرعة المنزلية في 7:02 صباحاً (تم الإبلاغ 7:18 صباحاً)'),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: SchooKeepColors.border),
          const SizedBox(height: 12),
          Text(
            context.tr(en: 'Prescribed Interval', ar: 'الفصل الزمني الموصى به'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(en: '4 hours between doses', ar: '4 ساعات على الأقل بين الجرعات'),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: SchooKeepColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Conflict Detected', ar: 'تم رصد تعارض حرج'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.tr(
                en: 'Scheduled school dose (11:00 AM) falls within 3h 58min of home dose — BELOW minimum interval',
                ar: 'موعد الجرعة المدرسية (11:00 صباحاً) يقع خلال 3 ساعات و 58 دقيقة فقط من الجرعة المنزلية — أقل من الحد الأدنى الأمني',
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedAdjustment(BuildContext context) {
    return AccentCard(
      background: SchooKeepColors.greenChipBg,
      accentColor: SchooKeepColors.accent,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
            child: const Icon(LucideIcons.check, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Recommended Adjustment', ar: 'التعديل الموصى به آمنياً'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.greenChipText),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(en: 'Suggested school dose time: 11:15 AM', ar: 'الموعد المقترح للجرعة المدرسية: 11:15 صباحاً'),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.greenChipText),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(en: 'This maintains the 4-hour minimum interval', ar: 'هذا يحافظ على الفارق الأمني (4 ساعات) بين الجرعات'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF047857)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nurseAction(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Nurse Action Required', ar: 'الإجراء المطلوب من الممرض/ة'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _selectedOption,
            onChanged: (v) => setState(() => _selectedOption = v!),
            child: Column(
              children: [
                _radioOption(
                  value: 'accept',
                  title: context.tr(en: 'Accept adjusted time (11:15 AM)', ar: 'قبول الموعد المعدل (11:15 صباحاً)'),
                  subtitle: context.tr(en: 'Update schedule to recommended time', ar: 'تحديث الجدول الإعطائي للموعد الآمن الموصى به'),
                ),
                const SizedBox(height: 16),
                _radioOption(
                  value: 'override',
                  title: context.tr(en: 'Override with justification', ar: 'تجاوز التنبيه مع تقديم مبرر سريري'),
                  subtitle: context.tr(en: 'Proceed with original time (requires clinical justification)', ar: 'المتابعة بالموعد الأصلي (يتطلب مبرراً سريرياً إلزامياً)'),
                ),
              ],
            ),
          ),
          if (_selectedOption == 'override') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(en: 'Clinical Justification *', ar: 'المبرر والسبب السريري للتجاوز *'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _justificationController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: context.tr(en: 'Enter clinical justification for override...', ar: 'أدخل المبرر والتقييم السريري للتجاوز...'),
                      hintStyle: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                      filled: true,
                      fillColor: SchooKeepColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  const SizedBox(height: 8),
                  Text(
                    context.tr(en: 'This justification will be permanently recorded in the medication log', ar: 'سيتم توثيق هذا المبرر بشكل دائم في سجل التدقيق الطبي'),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _radioOption({required String value, required String title, required String subtitle}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Radio<String>(
              value: value,
              activeColor: SchooKeepColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accessibilityNote(BuildContext context) {
    return AccentCard(
      background: const Color(0xFFEFF6FF),
      accentColor: SchooKeepColors.primary,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
          children: [
            TextSpan(
              text: context.tr(en: 'Accessibility note: ', ar: 'إشعار إمكانية الوصول: '),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: context.tr(
                en: 'Red highlight indicates conflict below minimum interval. Green card shows safe recommended time.',
                ar: 'التظليل الأحمر يشير لتعارض الفارق الزمني. البطاقة الخضراء توضح الموعد الآمن الموصى به.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
