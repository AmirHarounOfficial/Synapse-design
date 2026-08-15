import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../cubit/annual_report_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `PrincipalAnnualReport.tsx`, wired to `GET /analytics/annual-report`.
/// Academic-year selector (reloads the rollups), a live rollup summary, a section
/// checklist, and Preview / Generate buttons.
class PrincipalAnnualReportScreen extends StatelessWidget {
  const PrincipalAnnualReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnnualReportCubit(sl<AnalyticsRepository>()),
      child: const _PrincipalAnnualReportView(),
    );
  }
}

class _PrincipalAnnualReportView extends StatefulWidget {
  const _PrincipalAnnualReportView();

  @override
  State<_PrincipalAnnualReportView> createState() => _PrincipalAnnualReportViewState();
}

class _PrincipalAnnualReportViewState extends State<_PrincipalAnnualReportView> {
  String _academicYear = '2025-2026';

  final Map<String, bool> _includes = {
    'clinicVisits': true,
    'medicationCompliance': true,
    'emergencyEvents': true,
    'documentStatus': true,
    'staffActivity': true,
    'wellnessTrends': true,
  };

  static const _reportItems = <_ReportItem>[
    _ReportItem('clinicVisits', 'Total clinic visits', 'Monthly breakdown and trends'),
    _ReportItem('medicationCompliance', 'Medication compliance', 'Adherence rates and statistics'),
    _ReportItem('emergencyEvents', 'Emergency events', 'Incidents requiring immediate response'),
    _ReportItem('documentStatus', 'Document status', 'Parent consent and form completion'),
    _ReportItem('staffActivity', 'Staff activity summary', 'System usage and engagement metrics'),
    _ReportItem('wellnessTrends', 'Student wellness trends', 'Counselor tags and patterns'),
  ];

  /// Maps an academic-year label ("2025-2026") to the starting calendar year.
  int get _selectedYear => int.tryParse(_academicYear.split('-').first) ?? DateTime.now().year;

  static int _int(Map<String, dynamic> m, String key) => (m[key] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: 'Annual Report',
      onBack: () => context.safeBack(),
      bottomBar: _bottomBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _academicYearCard(),
            const SizedBox(height: 16),
            _rollupCard(),
            const SizedBox(height: 16),
            _includesCard(),
            const SizedBox(height: 16),
            _detailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _academicYearCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Academic Year',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _academicYear,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, size: 20, color: SchooKeepColors.textSecondary),
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                items: const [
                  DropdownMenuItem(value: '2025-2026', child: Text('2025–2026 (Current)')),
                  DropdownMenuItem(value: '2024-2025', child: Text('2024–2025')),
                  DropdownMenuItem(value: '2023-2024', child: Text('2023–2024')),
                ],
                onChanged: (v) {
                  if (v == null || v == _academicYear) return;
                  setState(() => _academicYear = v);
                  context.read<AnnualReportCubit>().load(year: _selectedYear);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rollupCard() {
    return SchooKeepCard(
      child: BlocBuilder<AnnualReportCubit, DataState<Map<String, dynamic>>>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Report Summary',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 12),
              switch (state) {
                DataLoading() => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                DataError(:final message) => _inlineError(message),
                DataLoaded(:final data) => _rollupBody(data),
              },
            ],
          );
        },
      ),
    );
  }

  Widget _rollupBody(Map<String, dynamic> data) {
    final documents = (data['documents_processed'] as Map?) ?? const {};
    final documentsTotal = documents.values.fold<int>(0, (sum, v) => sum + ((v as num?)?.toInt() ?? 0));
    return Column(
      children: [
        _rollupRow(LucideIcons.heart, 'Total clinic visits', '${_int(data, 'total_clinic_visits')}'),
        _rollupRow(LucideIcons.pill, 'Doses administered', '${_int(data, 'total_doses_administered')}'),
        _rollupRow(LucideIcons.alertTriangle, 'Emergency consents', '${_int(data, 'total_emergency_consents')}'),
        _rollupRow(LucideIcons.fileText, 'Documents processed', '$documentsTotal', last: true),
      ],
    );
  }

  Widget _rollupRow(IconData icon, String label, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: SchooKeepColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary)),
          ),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _inlineError(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(LucideIcons.alertCircle, size: 18, color: SchooKeepColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: const TextStyle(fontSize: 12, color: SchooKeepColors.error)),
        ),
        TextButton(
          onPressed: () => context.read<AnnualReportCubit>().load(year: _selectedYear),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _includesCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Report Includes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          for (final item in _reportItems) _includeRow(item),
        ],
      ),
    );
  }

  Widget _includeRow(_ReportItem item) {
    final checked = _includes[item.key] ?? false;
    return InkWell(
      onTap: () => setState(() => _includes[item.key] = !checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: checked ? SchooKeepColors.primary : SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: checked ? SchooKeepColors.primary : const Color(0xFFD1D5DB)),
              ),
              child: checked ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(item.description, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('The report will be generated as a professionally formatted PDF with:',
              style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5)),
          const SizedBox(height: 8),
          _detailLine('School branding and logo'),
          _detailLine('Principal digital signature'),
          _detailLine('Charts and statistical summaries'),
          _detailLine('FERPA-compliant aggregate data only'),
        ],
      ),
    );
  }

  Widget _detailLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.check, size: 12, color: SchooKeepColors.accent),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () =>
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening preview...'))),
              icon: const Icon(LucideIcons.eye, size: 20, color: SchooKeepColors.textPrimary),
              label: const Text('Preview',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Generating annual report PDF with school branding and Principal digital signature...'))),
              icon: const Icon(LucideIcons.download, size: 20, color: Colors.white),
              label: const Text('Generate & Download',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem {
  const _ReportItem(this.key, this.label, this.description);
  final String key;
  final String label;
  final String description;
}
