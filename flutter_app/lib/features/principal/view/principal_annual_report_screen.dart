import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../cubit/annual_report_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

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

  int get _selectedYear => int.tryParse(_academicYear.split('-').first) ?? DateTime.now().year;

  static int _int(Map<String, dynamic> m, String key) => (m[key] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: context.tr(en: 'Annual Report', ar: 'التقرير السنوي للصحة والسلامة'),
      onBack: () => context.safeBack(),
      bottomBar: _bottomBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _academicYearCard(context),
            const SizedBox(height: 16),
            _rollupCard(context),
            const SizedBox(height: 16),
            _includesCard(context),
            const SizedBox(height: 16),
            _detailsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _academicYearCard(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Academic Year', ar: 'العام الدراسي'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
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
                items: [
                  DropdownMenuItem(value: '2025-2026', child: Text(context.tr(en: '2025–2026 (Current)', ar: '2025–2026 (الحالي)'))),
                  DropdownMenuItem(value: '2024-2025', child: Text(context.tr(en: '2024–2025', ar: '2024–2025'))),
                  DropdownMenuItem(value: '2023-2024', child: Text(context.tr(en: '2023–2024', ar: '2023–2024'))),
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

  Widget _rollupCard(BuildContext context) {
    return SchooKeepCard(
      child: BlocBuilder<AnnualReportCubit, DataState<Map<String, dynamic>>>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(en: 'Report Summary', ar: 'ملخص التقرير'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(height: 12),
              switch (state) {
                DataLoading() => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                DataError(:final message) => _inlineError(context, message),
                DataLoaded(:final data) => _rollupBody(context, data),
              },
            ],
          );
        },
      ),
    );
  }

  Widget _rollupBody(BuildContext context, Map<String, dynamic> data) {
    final documents = (data['documents_processed'] as Map?) ?? const {};
    final documentsTotal = documents.values.fold<int>(0, (sum, v) => sum + ((v as num?)?.toInt() ?? 0));
    return Column(
      children: [
        _rollupRow(LucideIcons.heart, context.tr(en: 'Total clinic visits', ar: 'إجمالي زيارات العيادة'), '${_int(data, 'total_clinic_visits')}'),
        _rollupRow(LucideIcons.pill, context.tr(en: 'Doses administered', ar: 'إجمالي الجرعات المقدمة'), '${_int(data, 'total_doses_administered')}'),
        _rollupRow(LucideIcons.alertTriangle, context.tr(en: 'Emergency consents', ar: 'موافقات الطوارئ'), '${_int(data, 'total_emergency_consents')}'),
        _rollupRow(LucideIcons.fileText, context.tr(en: 'Documents processed', ar: 'المستندات والمعاملات المكتملة'), '$documentsTotal', last: true),
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

  Widget _inlineError(BuildContext context, String message) {
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
          child: Text(context.tr(en: 'Retry', ar: 'إعادة المحاولة')),
        ),
      ],
    );
  }

  Widget _includesCard(BuildContext context) {
    final reportItems = <_ReportItem>[
      _ReportItem('clinicVisits', context.tr(en: 'Total clinic visits', ar: 'زيارات العيادة المدرسية'), context.tr(en: 'Monthly breakdown and trends', ar: 'التحليل الشهري والمؤشرات البيانية')),
      _ReportItem('medicationCompliance', context.tr(en: 'Medication compliance', ar: 'نسب الالتزام بالأدوية'), context.tr(en: 'Adherence rates and statistics', ar: 'إحصائيات إعطاء الجرعات')),
      _ReportItem('emergencyEvents', context.tr(en: 'Emergency events', ar: 'حالات الطوارئ والتصعيد'), context.tr(en: 'Incidents requiring immediate response', ar: 'الحوادث والتحويلات الطارئة')),
      _ReportItem('documentStatus', context.tr(en: 'Document status', ar: 'حالة موافقة أولياء الأمور والمستندات'), context.tr(en: 'Parent consent and form completion', ar: 'نسب اكتمال النماذج والموافقات')),
      _ReportItem('staffActivity', context.tr(en: 'Staff activity summary', ar: 'نشاط وحضور الكادر الطبي'), context.tr(en: 'System usage and engagement metrics', ar: 'مؤشرات استخدام النظام والتدقيق')),
      _ReportItem('wellnessTrends', context.tr(en: 'Student wellness trends', ar: 'مؤشرات صحة ورفاه الطلاب'), context.tr(en: 'Counselor tags and patterns', ar: 'سجلات وأنشطة الأخصائي الاجتماعي')),
    ];

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Report Includes', ar: 'محتويات التقرير'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          for (final item in reportItems) _includeRow(item),
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

  Widget _detailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              en: 'The report will be generated as a professionally formatted PDF with:',
              ar: 'سيتم إنشاء التقرير كملف PDF موثوق ومنسق احترافياً يتضمن:',
            ),
            style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 8),
          _detailLine(context.tr(en: 'School branding and logo', ar: 'شعار وهواية المدرسة الرسمية')),
          _detailLine(context.tr(en: 'Principal digital signature', ar: 'التوقيع الرقمي لمدير المدرسة')),
          _detailLine(context.tr(en: 'Charts and statistical summaries', ar: 'الرسوم البيانية والمؤشرات الإحصائية')),
          _detailLine(context.tr(en: 'FERPA-compliant aggregate data only', ar: 'بيانات تجميعية متوافقة مع معايير خصوصية الطلاب')),
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

  Widget _bottomBar(BuildContext context) {
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr(en: 'Opening preview...', ar: 'جاري فتح المعاينة...')))),
              icon: const Icon(LucideIcons.eye, size: 20, color: SchooKeepColors.textPrimary),
              label: Text(
                context.tr(en: 'Preview', ar: 'معاينة التقرير'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
              ),
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
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(context.tr(
                en: 'Generating annual report PDF with school branding and Principal digital signature...',
                ar: 'جاري إنشاء تقرير PDF السنوي مع التوقيع الرقمي لشعار وتوقيع المدير...',
              )))),
              icon: const Icon(LucideIcons.download, size: 20, color: Colors.white),
              label: Text(
                context.tr(en: 'Generate & Download', ar: 'إنشاء وتنزيل التقرير'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
              ),
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
