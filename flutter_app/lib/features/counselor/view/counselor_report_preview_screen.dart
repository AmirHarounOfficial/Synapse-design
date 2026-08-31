import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

const Color _counselorPurple = Color(0xFF7C3AED);
const Color _counselorPurpleBg = Color(0xFFF3F0FF);

/// Ported from `CounselorReportPreview.tsx`. Full-screen confidential PDF
/// preview (student wellbeing report) with share/download actions and
/// send-to-secretary / send-to-parent CTAs.
///
/// Not wired to the API: the route carries no report id and the rendered PDF
/// body (tag-frequency bars, signature block, etc.) has no matching fields on
/// `CounselorReportResource`. It stays a static design preview; the report
/// record itself is created on the preceding Generate Report screen.
class CounselorReportPreviewScreen extends StatelessWidget {
  const CounselorReportPreviewScreen({super.key});

  /// The report ID shown in the rendered PDF header — reused in share/export
  /// feedback so the actions reference the document the counselor is viewing.
  static const String _reportId = 'WB-2026-0531-001';

  void _send(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    context.go('/counselor/home');
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Share action — no external share sheet (no added packages), so offer
  /// in-app options: copy the report reference to the clipboard, or queue it
  /// for secure export.
  void _handleShare(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SchooKeepColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Text(
                  sheetContext.tr(en: 'Share report', ar: 'مشاركة التقرير'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
              ),
              ListTile(
                leading: const Icon(LucideIcons.copy, size: 20, color: _counselorPurple),
                title: Text(
                  sheetContext.tr(en: 'Copy report reference', ar: 'نسخ مرجع التقرير'),
                  style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                ),
                onTap: () async {
                  await Clipboard.setData(const ClipboardData(text: 'SchooKeep Report $_reportId'));
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                  _snack(
                    context,
                    context.tr(
                      en: 'Report reference $_reportId copied',
                      ar: 'تم نسخ مرجع التقرير $_reportId',
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.send, size: 20, color: _counselorPurple),
                title: Text(
                  sheetContext.tr(en: 'Queue secure export', ar: 'جدولة تصدير آمن'),
                  style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _snack(
                    context,
                    context.tr(en: 'Report queued for export', ar: 'تم جدولة التقرير للتصدير'),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Download action — no file-system access (no added packages), so confirm
  /// the signed PDF has been queued for export.
  void _handleDownload(BuildContext context) {
    _snack(
      context,
      context.tr(
        en: 'Signed PDF queued for export',
        ar: 'تم جدولة ملف PDF الموقّع للتصدير',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        title: context.tr(en: 'Report Preview', ar: 'معاينة التقرير'),
        actions: [
          _IconAction(icon: LucideIcons.share2, onTap: () => _handleShare(context)),
          _IconAction(icon: LucideIcons.download, onTap: () => _handleDownload(context)),
        ],
      ),
      bottomBar: _bottomBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _pdfPage(context),
      ),
    );
  }

  Widget _pdfPage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: SchooKeepColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('SchooKeep',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.tr(en: 'Report Date: 05/31/2026', ar: 'تاريخ التقرير: 31/05/2026'),
                          style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary),
                        ),
                        Text(
                          context.tr(en: 'Report ID: $_reportId', ar: 'رمز التقرير: $_reportId'),
                          style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(en: 'Student Wellbeing Report', ar: 'تقرير الرفاه الطلابي والنفسي'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
                Text(
                  context.tr(
                    en: 'Lincoln Elementary School • Confidential',
                    ar: 'مدرسة الشروق النموذجية • سري للغاية',
                  ),
                  style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: SchooKeepColors.border),
          const SizedBox(height: 16),

          // Student info
          _sectionTitle(context.tr(en: 'Student Information', ar: 'معلومات الطالب')),
          const SizedBox(height: 8),
          _infoRow(
            context.tr(en: 'Name:', ar: 'الاسم:'),
            context.tr(en: 'Maya Thompson', ar: 'مايا ثومبسون'),
          ),
          _infoRow(
            context.tr(en: 'Grade:', ar: 'الصف:'),
            context.tr(en: '4th Grade', ar: 'الصف الرابع'),
          ),
          _infoRow(
            context.tr(en: 'Report Period:', ar: 'فترة التقرير:'),
            context.tr(en: 'May 1-31, 2026 (30 days)', ar: '1-31 مايو 2026 (30 يوماً)'),
          ),
          const SizedBox(height: 16),

          // Tag frequency
          _sectionTitle(context.tr(en: 'Tag Frequency Analysis', ar: 'تحليل تكرار الوسوم')),
          const SizedBox(height: 8),
          _freqBar(0.60, context.tr(en: 'Headache (3)', ar: 'صداع (3)')),
          const SizedBox(height: 8),
          _freqBar(0.40, context.tr(en: 'Difficulty focusing (2)', ar: 'صعوبة تركيز (2)')),
          const SizedBox(height: 8),
          _freqBar(0.20, context.tr(en: 'Low mood (1)', ar: 'مزاج منخفض (1)')),
          const SizedBox(height: 16),

          // Environmental correlations
          _sectionTitle(context.tr(en: 'Environmental Correlations', ar: 'الارتباطات البيئية')),
          const SizedBox(height: 8),
          _calloutBox(
            bg: SchooKeepColors.amberChipBg,
            border: const Color(0xFFFDE68A),
            textColor: SchooKeepColors.amberText,
            boldLead: context.tr(en: 'Pattern Detected:', ar: 'تم اكتشاف نمط:'),
            body: context.tr(
              en: ' 67% of headache tags occurred during AQI advisory days (2 of 3 instances). Consider air quality as contributing factor.',
              ar: ' 67% من وسوم الصداع حدثت خلال أيام تنبيهات جودة الهواء. يرجى مراعاة جودة الهواء كعامل مؤثر.',
            ),
          ),
          const SizedBox(height: 16),

          // Trend notices
          _sectionTitle(context.tr(en: 'Trend Notices', ar: 'ملاحظات الأنماط والتوجيهات')),
          const SizedBox(height: 8),
          _calloutBox(
            bg: const Color(0xFFFEF2F2),
            border: const Color(0xFFFCA5A5),
            textColor: const Color(0xFF991B1B),
            boldLead: context.tr(en: 'Recommendation:', ar: 'التوصية:'),
            body: context.tr(
              en: ' Repeated "Headache" pattern warrants environmental assessment and possible pediatric consultation.',
              ar: ' تكرار نمط الصداع يتطلب تقييماً بيئياً واستشارة طبيب أطفال.',
            ),
          ),
          const SizedBox(height: 24),

          // Digital signature
          const Divider(height: 1, thickness: 1, color: SchooKeepColors.border),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: context.tr(en: 'Digitally signed by: ', ar: 'موقّع رقمياً بواسطة: '),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: context.tr(en: 'Dr. Sarah Chen', ar: 'د. سارة تشن')),
            ]),
            style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: context.tr(en: 'Counselor ID: ', ar: 'رمز المرشد: '),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: 'SC-2026-0142'),
            ]),
            style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: context.tr(en: 'Signature Date: ', ar: 'تاريخ التوقيع: '),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: context.tr(
                  en: 'May 31, 2026 at 2:34 PM PST',
                  ar: '31 مايو 2026 الساعة 2:34 مساءً',
                ),
              ),
            ]),
            style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary));
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(label, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _freqBar(double fraction, String label) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 24,
              color: _counselorPurpleBg,
              child: FractionallySizedBox(
                widthFactor: fraction,
                alignment: Alignment.centerLeft,
                child: Container(color: _counselorPurple),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 128,
          child: Text(label, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textPrimary)),
        ),
      ],
    );
  }

  Widget _calloutBox({
    required Color bg,
    required Color border,
    required Color textColor,
    required String boldLead,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: boldLead, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: body),
        ]),
        style: TextStyle(fontSize: 11, color: textColor, height: 1.5),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _send(
                context,
                context.tr(
                  en: 'Report sent to secretary for parent distribution',
                  ar: 'تم إرسال التقرير للسكرتارية لتوزيعه على ولي الأمر',
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.send, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    context.tr(en: 'Send to Secretary', ar: 'إرسال للسكرتارية'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: SchooKeepColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _send(
                  context,
                  context.tr(
                    en: 'Report sent directly to parent',
                    ar: 'تم إرسال التقرير إلى ولي الأمر مباشرة',
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.send, size: 20, color: SchooKeepColors.textPrimary),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(en: 'Send to Parent Directly', ar: 'إرسال لولي الأمر مباشرة'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
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
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 20, color: SchooKeepColors.textPrimary),
      ),
    );
  }
}
