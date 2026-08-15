import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
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
        title: 'Reports',
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
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.plus, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Generate New Report',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Recent Reports',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
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
            label: 'Retry',
            fullWidth: false,
            onPressed: () => context.read<CounselorReportsCubit>().load(),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, List<CounselorReport> reports) {
    if (reports.isEmpty) {
      return const Center(
        child: Text('No reports yet', style: TextStyle(color: SchooKeepColors.textSecondary)),
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

  String _titleFor(CounselorReport r) {
    final type = r.type.isEmpty ? 'Report' : '${r.type[0].toUpperCase()}${r.type.substring(1)} Report';
    if (r.studentId != null) return 'Student #${r.studentId} — $type';
    return type;
  }

  String _dateFor(CounselorReport r) {
    final d = r.generatedAt ?? r.createdAt;
    if (d == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  ({String label, Color bg, Color fg}) _statusChip(CounselorReport r) {
    if (r.submittedToParent) {
      return (label: 'Sent to parent', bg: SchooKeepColors.greenChipBg, fg: SchooKeepColors.accent);
    }
    final s = (r.status ?? 'draft').toLowerCase();
    if (s.contains('secretary')) {
      return (label: 'With secretary', bg: const Color(0xFFDBEAFE), fg: SchooKeepColors.primary);
    }
    if (s.contains('sent') || s.contains('parent')) {
      return (label: 'Sent to parent', bg: SchooKeepColors.greenChipBg, fg: SchooKeepColors.accent);
    }
    return (label: 'Draft', bg: const Color(0xFFF1F5F9), fg: SchooKeepColors.textSecondary);
  }

  Widget _reportRow(BuildContext context, CounselorReport r) {
    final chip = _statusChip(r);
    final date = _dateFor(r);
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
                    Text(_titleFor(r),
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
