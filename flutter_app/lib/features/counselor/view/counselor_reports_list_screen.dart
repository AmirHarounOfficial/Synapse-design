import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/counselor_report.dart';
import '../../../data/repositories/counselor_repository.dart';
import '../cubit/counselor_reports_cubit.dart';
import 'counselor_dashboard_screen.dart';

const Color _counselorPurple = Color(0xFF7C3AED);
const Color _counselorPurpleBg = Color(0xFFF3F0FF);

/// Ported from `CounselorReportsList.tsx`, wired to `GET /counselor-reports`.
/// A "Generate New Report" CTA plus the list of recent reports with status
/// chips derived from each report's `status`/`submitted_to_parent`.
class CounselorReportsListScreen extends StatelessWidget {
  const CounselorReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounselorReportsCubit(sl<CounselorRepository>()),
      child: const _CounselorReportsListView(),
    );
  }
}

class _CounselorReportsListView extends StatelessWidget {
  const _CounselorReportsListView();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Reports', ar: 'التقارير الإرشادية'),
        actions: [
          Builder(
            builder: (context) => InkWell(
              onTap: () => showCounselorNotificationsSheet(context),
              borderRadius: BorderRadius.circular(999),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(LucideIcons.bell, size: 24, color: SchooKeepColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generate New Report
            Material(
              color: _counselorPurple,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.go('/counselor/generate-report'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.plus, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(en: 'Generate New Report', ar: 'إنشاء تقرير جديد'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              context.tr(en: 'Recent Reports', ar: 'أحدث التقارير'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<CounselorReportsCubit, DataState<List<CounselorReport>>>(
                builder: (context, state) {
                  return switch (state) {
                    DataLoading() => const Center(child: CircularProgressIndicator()),
                    DataError(:final message) => _errorView(context, message),
                    DataLoaded(:final data) => _list(context, data),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 16),
          SchooKeepButton(
            label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
            fullWidth: false,
            onPressed: () => context.read<CounselorReportsCubit>().load(),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, List<CounselorReport> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Text(
          context.tr(en: 'No reports yet', ar: 'لا توجد تقارير بعد'),
          style: const TextStyle(color: SchooKeepColors.textSecondary),
        ),
      );
    }
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < reports.length; i++) ...[
              if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
              _reportRow(context, reports[i]),
            ],
          ],
        ),
      ),
    );
  }

  String _titleFor(BuildContext context, CounselorReport r) {
    final typeEn = r.type.isEmpty ? 'Report' : '${r.type[0].toUpperCase()}${r.type.substring(1)} Report';
    final typeAr = r.type.toLowerCase() == 'individual'
        ? 'تقرير فردي'
        : (r.type.toLowerCase() == 'class' ? 'تقرير ملخص الصف' : 'تقرير إرشادي');
    final type = context.tr(en: typeEn, ar: typeAr);

    if (r.studentId != null) {
      return context.tr(
        en: 'Student #${r.studentId} — $typeEn',
        ar: 'الطالب #${r.studentId} — $typeAr',
      );
    }
    return type;
  }

  String _dateFor(CounselorReport r, bool isRTL) {
    final d = r.generatedAt ?? r.createdAt;
    if (d == null) return '';
    const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthsAr = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final m = isRTL ? monthsAr[d.month - 1] : monthsEn[d.month - 1];
    return isRTL ? '${d.day} $m ${d.year}' : '$m ${d.day}, ${d.year}';
  }

  ({String label, Color bg, Color fg}) _statusChip(BuildContext context, CounselorReport r) {
    if (r.submittedToParent) {
      return (
        label: context.tr(en: 'Sent to parent', ar: 'أُرسل لولي الأمر'),
        bg: SchooKeepColors.greenChipBg,
        fg: SchooKeepColors.accent
      );
    }
    final s = (r.status ?? 'draft').toLowerCase();
    if (s.contains('secretary')) {
      return (
        label: context.tr(en: 'With secretary', ar: 'عند السكرتارية'),
        bg: const Color(0xFFDBEAFE),
        fg: SchooKeepColors.primary
      );
    }
    if (s.contains('sent') || s.contains('parent')) {
      return (
        label: context.tr(en: 'Sent to parent', ar: 'أُرسل لولي الأمر'),
        bg: SchooKeepColors.greenChipBg,
        fg: SchooKeepColors.accent
      );
    }
    return (
      label: context.tr(en: 'Draft', ar: 'مسودة'),
      bg: const Color(0xFFF1F5F9),
      fg: SchooKeepColors.textSecondary
    );
  }

  Widget _reportRow(BuildContext context, CounselorReport r) {
    final isRTL = context.isRTL;
    final chip = _statusChip(context, r);
    final date = _dateFor(r, isRTL);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/counselor/report-preview'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _counselorPurpleBg, shape: BoxShape.circle),
                child: const Icon(LucideIcons.fileText, size: 20, color: _counselorPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_titleFor(context, r),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (date.isNotEmpty)
                          Text(date, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: chip.bg, borderRadius: BorderRadius.circular(999)),
                          child: Text(chip.label,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: chip.fg)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
