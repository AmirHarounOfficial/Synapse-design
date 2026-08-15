import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ReportPreview.tsx`. Optional co-signature pending banner (driven
/// by the `?cosign=true` query param), report header card, a simulated PDF
/// sheet with page navigation, a send-to-parent toggle and fixed bottom
/// actions. Sharing/exporting are faked with snackbars. Bilingual.
class ReportPreviewScreen extends StatefulWidget {
  const ReportPreviewScreen({super.key});

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  int _currentPage = 1;
  bool _sendToParent = false;

  static const int _totalPages = 5;
  static const String _schoolName = 'Lincoln Elementary School';
  static const String _dateRange = '15/06/2026';
  static const String _preparedBy = 'Emily Smith';
  static const String _license = 'RN-4521';

  void _toast(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? SchooKeepColors.error : SchooKeepColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final cosignPending =
        GoRouterState.of(context).uri.queryParameters['cosign'] == 'true';
    final reportType = isRTL ? 'الملخص اليومي للعيادة' : 'Daily Summary';

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        centerTitle: true,
        onBack: () => context.safeBack(),
        title: isRTL ? 'معاينة التقرير الطبي' : 'Report Preview',
        actions: [
          _iconButton(
            LucideIcons.share2,
            () => _toast(
              isRTL ? 'تم فتح خيارات المشاركة' : 'Share dialog opened.',
            ),
          ),
          _iconButton(
            LucideIcons.download,
            () => _toast(
              isRTL ? 'بدء تحميل ملف التقرير...' : 'Downloading report file...',
            ),
          ),
        ],
      ),
      bottomBar: _actionRow(isRTL, cosignPending),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cosign pending banner
            if (cosignPending) ...[
              AccentCard(
                background: SchooKeepColors.amberBg,
                accentColor: SchooKeepColors.warning,
                accentWidth: 4,
                radius: 12,
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.clock,
                      size: 20,
                      color: SchooKeepColors.warning,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRTL
                                ? '⏳ بانتظار التوقيع المشترك للطبيب'
                                : 'Awaiting Physician Co-Signature',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF78350F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRTL
                                ? 'تم إرسال هذا التقرير إلى الطبيب المناوب للمراجعة والتوقيع الثنائي. تم تعطيل خيار الإرسال للمدير حالياً.'
                                : 'Report submitted and routed to the on-duty school physician. Sharing is disabled until co-signed.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Report header card
            SchooKeepCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('📋', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reportType,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SchooKeepColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              _dateRange,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: SchooKeepColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              _schoolName,
                              style: TextStyle(
                                fontSize: 13,
                                color: SchooKeepColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: SchooKeepColors.border),
                  const SizedBox(height: 12),
                  Text(
                    isRTL
                        ? 'إعداد الممرضة: $_preparedBy ($_license)'
                        : 'Prepared by: $_preparedBy ($_license)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: SchooKeepColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SchooKeepBadge(
                    label: isRTL
                        ? 'تم التحقق من التوقيع الرقمي للممرضة ✓'
                        : 'Nurse digital signature verified ✓',
                    icon: LucideIcons.check,
                    background: SchooKeepColors.greenChipBg,
                    foreground: SchooKeepColors.greenChipText,
                    fontSize: 11,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PDF preview sheet
            Container(
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 8.5 / 11,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: SchooKeepColors.border),
                        ),
                        child: SingleChildScrollView(child: _sheetContent()),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: SchooKeepColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _currentPage == 1
                              ? null
                              : () => setState(() => _currentPage--),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const RtlIcon(
                                LucideIcons.chevronLeft,
                                size: 16,
                                color: SchooKeepColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isRTL ? 'السابق' : 'Previous',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: SchooKeepColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          isRTL
                              ? 'صفحة $_currentPage من $_totalPages'
                              : 'Page $_currentPage of $_totalPages',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: SchooKeepColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: _currentPage == _totalPages
                              ? null
                              : () => setState(() => _currentPage++),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isRTL ? 'التالي' : 'Next',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: SchooKeepColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const RtlIcon(
                                LucideIcons.chevronRight,
                                size: 16,
                                color: SchooKeepColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Send to parent toggle
            SchooKeepCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isRTL ? 'إرسال نسخة لأولياء الأمور' : 'Send to Parent',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SchooKeepColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: _sendToParent,
                    activeThumbColor: Colors.white,
                    activeTrackColor: SchooKeepColors.physicianTeal,
                    onChanged: (v) => setState(() => _sendToParent = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: const [
              Text(
                _schoolName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: SchooKeepColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'SCHOOL HEALTH CENTER - CLINICAL SUMMARY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B5563),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'DHA Compliance: DHA/HRS/HPSD/ST-22',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: SchooKeepColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: SchooKeepColors.border),
        const SizedBox(height: 12),
        const Text(
          'This report summarizes medical center operations at $_schoolName for $_dateRange.',
          style: TextStyle(fontSize: 11, color: Color(0xFF1F2937), height: 1.5),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: SchooKeepColors.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Clinical Metric',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 4),
              _metricRow('Clinic Student Visits', '12'),
              _metricRow('Medication Administrations', '8'),
              _metricRow(
                'Awaiting Physician Review',
                '2',
                color: const Color(0xFFB45309),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'All procedures performed complied with the UAE PDPL (المرسوم بقانون رقم 45/2021) for patient confidentiality.',
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _metricRow(String label, String count, {Color? color}) {
    final style = TextStyle(
      fontSize: 11,
      color: color ?? const Color(0xFF1F2937),
      fontWeight: color == null ? FontWeight.normal : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(count, style: style),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
      ),
    );
  }

  Widget _actionRow(bool isRTL, bool cosignPending) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: cosignPending
                    ? const Color(0xFFF9FAFB)
                    : SchooKeepColors.surface,
                side: BorderSide(
                  color: cosignPending
                      ? SchooKeepColors.border
                      : SchooKeepColors.physicianTeal,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (cosignPending) {
                  _toast(
                    isRTL
                        ? 'عذراً، يجب توقيع التقرير من الطبيب أولاً'
                        : 'Report must be co-signed by physician first.',
                    error: true,
                  );
                } else {
                  _toast(
                    isRTL
                        ? 'تم إرسال التقرير لمدير المدرسة بنجاح'
                        : 'Report sent to Principal successfully!',
                  );
                }
              },
              child: Text(
                isRTL ? 'إرسال لمدير المدرسة' : 'Share to Principal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: cosignPending
                      ? const Color(0xFF9CA3AF)
                      : SchooKeepColors.physicianTeal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.physicianTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () =>
                  _toast(isRTL ? 'تصدير بصيغة PDF...' : 'Exporting PDF...'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.download,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRTL ? 'تصدير بصيغة PDF' : 'Export PDF',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
