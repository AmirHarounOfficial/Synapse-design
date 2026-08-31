import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/counselor_repository.dart';
import 'package:schookeep/core/router/safe_back.dart';

const Color _counselorPurple = Color(0xFF7C3AED);

/// Ported from `CounselorGenerateReport.tsx`, wired to `POST /counselor-reports`.
/// Full-screen report builder: individual/class type, date-range dropdown, an
/// includes list, and a submit-to-parent toggle. "Preview Report" creates the
/// report then navigates to the preview. The student selector stays static
/// (the design has no live search here), so reports are created without a
/// linked student id for now.
class CounselorGenerateReportScreen extends StatefulWidget {
  const CounselorGenerateReportScreen({super.key});

  @override
  State<CounselorGenerateReportScreen> createState() => _CounselorGenerateReportScreenState();
}

class _CounselorGenerateReportScreenState extends State<CounselorGenerateReportScreen> {
  final CounselorRepository _repo = sl<CounselorRepository>();
  String _reportType = 'individual'; // individual | class
  String _dateRange = 'last-30-days';
  bool _submitToParent = false;
  bool _submitting = false;

  void _showStudentSelectorNote() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(context.tr(
          en: 'Student is preset for this report',
          ar: 'تم تعيين الطالب مسبقًا لهذا التقرير',
        )),
      ));
  }

  Future<void> _handlePreview() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await _repo.createReport(
        type: _reportType,
        period: _dateRange,
        status: _submitToParent ? 'with_secretary' : 'draft',
        submittedToParent: _submitToParent,
      );
      if (!mounted) return;
      context.go('/counselor/report-preview');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(CounselorRepository.messageFor(e))));
    }
  }

  static const _dateRangeOptions = [
    (value: 'last-7-days', labelEn: 'Last 7 days', labelAr: 'آخر 7 أيام'),
    (value: 'last-30-days', labelEn: 'Last 30 days', labelAr: 'آخر 30 يوماً'),
    (value: 'last-90-days', labelEn: 'Last 90 days', labelAr: 'آخر 90 يوماً'),
    (value: 'school-year', labelEn: 'Full school year', labelAr: 'العام الدراسي كاملاً'),
    (value: 'custom', labelEn: 'Custom range...', labelAr: 'نطاق مخصص...'),
  ];

  static const _includesOptions = [
    (en: 'Tag frequency analysis', ar: 'تحليل تكرار الوسوم'),
    (en: 'Environmental correlations (AQI, weather)', ar: 'الارتباطات البيئية (الطقس وجودة الهواء)'),
    (en: 'Trend notices and pattern detection', ar: 'إشعارات الأنماط والتوجيهات'),
    (en: 'Confidential counselor notes', ar: 'ملاحظات المرشد السرية'),
    (en: 'Digital signature with counselor name, ID, and date', ar: 'التوقيع الرقمي مع الاسم والرمز والتاريخ'),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedStudentName = context.tr(en: 'Maya Thompson', ar: 'مايا ثومبسون');

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        title: context.tr(en: 'Generate Report', ar: 'إصدار تقرير إرشادي'),
      ),
      bottomBar: _bottomBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report type
            Text(
              context.tr(en: 'Report Type', ar: 'نوع التقرير'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _typeButton('individual', context.tr(en: 'Individual', ar: 'فردي (طالب)')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeButton('class', context.tr(en: 'Class Summary', ar: 'ملخص الصف')),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Student selector (individual only)
            if (_reportType == 'individual') ...[
              Text(
                context.tr(en: 'Student', ar: 'الطالب'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Material(
                color: SchooKeepColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _showStudentSelectorNote,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(selectedStudentName,
                              style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary)),
                        ),
                        const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Date range
            Text(
              context.tr(en: 'Date Range', ar: 'النطاق الزمني'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dateRange,
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown, size: 16, color: SchooKeepColors.textSecondary),
                  style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                  items: [
                    for (final o in _dateRangeOptions)
                      DropdownMenuItem(
                        value: o.value,
                        child: Text(context.tr(en: o.labelEn, ar: o.labelAr)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _dateRange = v ?? _dateRange),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Report includes
            SchooKeepCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(en: 'Report Includes', ar: 'يتضمن التقرير'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _includesOptions.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✓', style: TextStyle(fontSize: 13, color: SchooKeepColors.accent)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr(en: _includesOptions[i].en, ar: _includesOptions[i].ar),
                            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Submit to parent toggle
            SchooKeepCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(en: 'Submit to parent', ar: 'إرسال لولي الأمر'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _submitToParent
                              ? context.tr(en: 'Routed through secretary', ar: 'يمر عبر السكرتارية')
                              : context.tr(en: 'Save to records only', ar: 'حفظ بالسجلات فقط'),
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _SmallSwitch(
                    value: _submitToParent,
                    onChanged: (v) => setState(() => _submitToParent = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Preview note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.tr(
                  en: 'The report will be generated as a signed PDF. You can preview it before sending to ensure all information is accurate.',
                  ar: 'سيتم إنشاء التقرير كملف PDF موقّع. يمكنك معاينته قبل الإرسال للتأكد من دقة البيانات.',
                ),
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String value, String label) {
    final selected = _reportType == value;
    return SizedBox(
      height: 48,
      child: Material(
        color: selected ? _counselorPurple : SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: selected ? _counselorPurple : const Color(0xFFD1D5DB)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _reportType = value),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : SchooKeepColors.textPrimary,
                )),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _counselorPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _submitting ? null : _handlePreview,
          child: _submitting
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(
                  context.tr(en: 'Preview Report', ar: 'معاينة التقرير'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                ),
        ),
      ),
    );
  }
}

class _SmallSwitch extends StatelessWidget {
  const _SmallSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? _counselorPurple : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
