import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../cubit/vice_principal_analytics_cubit.dart';

class VicePrincipalAnalyticsScreen extends StatelessWidget {
  const VicePrincipalAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VicePrincipalAnalyticsCubit(sl<AnalyticsRepository>()),
      child: const _VicePrincipalAnalyticsView(),
    );
  }
}

class _VicePrincipalAnalyticsView extends StatelessWidget {
  const _VicePrincipalAnalyticsView();

  void _reload(BuildContext context) =>
      context.read<VicePrincipalAnalyticsCubit>().load();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(title: context.tr(en: 'Analytics', ar: 'التحليلات الصحية التجميعية')),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _permissionNotice(context),
          const SizedBox(height: 16),
          BlocBuilder<VicePrincipalAnalyticsCubit,
              DataState<VicePrincipalAnalyticsData>>(
            builder: (context, state) {
              return switch (state) {
                DataLoading() => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                DataError(:final message) => _errorBanner(context, message),
                DataLoaded(:final data) => _dataSection(context, data),
              };
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Limited Access', ar: 'صلاحيات محدودة'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _lockedRow(
            context.tr(en: 'Individual student data', ar: 'بيانات الطلاب التفصيلية'),
            context.tr(en: 'Principal access only', ar: 'مخصصة لمدير المدرسة فقط'),
          ),
          const SizedBox(height: 16),
          _privacyNotice(context),
        ],
      ),
    );
  }

  Widget _dataSection(BuildContext context, VicePrincipalAnalyticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(en: "This Week's Summary", ar: 'ملخص الأسبوع الحالي'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
        ),
        const SizedBox(height: 16),
        _metricsRow(context, data),
        const SizedBox(height: 16),
        _secondaryStats(context, data),
        const SizedBox(height: 16),
        _breakdownCard(
          context,
          context.tr(en: 'Clinic Visits by Reason', ar: 'زيارات العيادة حسب السبب'),
          data.breakdown('clinic_visits_by_category'),
          SchooKeepColors.primary,
        ),
        const SizedBox(height: 16),
        _breakdownCard(
          context,
          context.tr(en: 'Clinic Visits by Severity', ar: 'زيارات العيادة حسب درجة الخطورة'),
          data.breakdown('clinic_visits_by_severity'),
          const Color(0xFF14B8A6),
        ),
        const SizedBox(height: 16),
        _breakdownCard(
          context,
          context.tr(en: 'Medications by Status', ar: 'الأدوية حسب الحالة'),
          data.breakdown('medications_by_status'),
          SchooKeepColors.accent,
        ),
      ],
    );
  }

  Widget _metricsRow(BuildContext context, VicePrincipalAnalyticsData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _metricCard(LucideIcons.heart, '${data.overviewCount('clinic_visits_this_week')}',
              context.tr(en: 'Clinic visits (week)', ar: 'زيارات العيادة (الأسبوع)'), const Color(0xFF14B8A6), const Color(0xFFCCFBF1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(LucideIcons.activity, '${data.overviewCount('clinic_visits_today')}',
              context.tr(en: 'Visits today', ar: 'زيارات اليوم'), SchooKeepColors.primary, const Color(0xFFDBEAFE)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(LucideIcons.pill, '${data.overviewCount('active_medications')}',
              context.tr(en: 'Active meds', ar: 'أدوية نشطة'), SchooKeepColors.accent, const Color(0xFFD1FAE5)),
        ),
      ],
    );
  }

  Widget _metricCard(IconData icon, String value, String label, Color iconColor, Color bg) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _secondaryStats(BuildContext context, VicePrincipalAnalyticsData data) {
    return SchooKeepCard(
      child: Column(
        children: [
          _statLine(context.tr(en: 'Total students', ar: 'إجمالي الطلاب المقيدين'), data.overviewCount('total_students')),
          const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
          _statLine(context.tr(en: 'Students with allergens', ar: 'طلاب لديهم حالات حساسية'), data.healthCount('students_with_allergens')),
          const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
          _statLine(context.tr(en: 'Pending documents', ar: 'مستندات معلقة'), data.overviewCount('pending_documents')),
          const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
          _statLine(context.tr(en: 'Open emergency consents', ar: 'موافقات طوارئ مفتوحة'), data.overviewCount('open_emergency_consents')),
          const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
          _statLine(context.tr(en: 'Low-supply medications', ar: 'أدوية منخفضة المخزون'), data.overviewCount('low_supply_medications')),
        ],
      ),
    );
  }

  Widget _statLine(String label, int value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        ),
        Text('$value',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
      ],
    );
  }

  Widget _breakdownCard(BuildContext context, String title, Map<String, int> data, Color barColor) {
    final maxValue = data.values.isEmpty ? 0 : data.values.reduce((a, b) => a > b ? a : b);
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 16),
          if (data.isEmpty)
            Text(
              context.tr(en: 'No data for this period', ar: 'لا توجد بيانات لهذه الفترة'),
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
            )
          else
            for (final entry in data.entries) ...[
              _barRow(entry.key, entry.value, maxValue, barColor),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  Widget _barRow(String label, int value, int maxValue, Color barColor) {
    final fraction = maxValue == 0 ? 0.0 : value / maxValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _prettyLabel(label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text('$value',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  static String _prettyLabel(String raw) {
    if (raw.isEmpty) return 'Unspecified';
    final cleaned = raw.replaceAll('_', ' ').replaceAll('-', ' ');
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  Widget _errorBanner(BuildContext context, String error) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.error),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertCircle, size: 20, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error,
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.error, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SchooKeepButton(label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'), fullWidth: false, onPressed: () => _reload(context)),
      ],
    );
  }

  Widget _permissionNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.info, size: 20, color: SchooKeepColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr(
                en: 'You have access to aggregate health analytics. Detailed breakdowns and individual student data require Principal authorization.',
                ar: 'لديك صلاحية الوصول إلى التحليلات الصحية التجميعية. الترتيبات التفصيلية وبيانات الطلاب الفردية تتطلب صلاحية المدير.',
              ),
              style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1E40AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedRow(String label, String subtitle) {
    return Opacity(
      opacity: 0.6,
      child: SchooKeepCard(
        child: Stack(
          children: [
            const PositionedDirectional(
              top: 0,
              end: 0,
              child: Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacyNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.users, size: 16, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12, height: 1.5, color: SchooKeepColors.textSecondary),
                children: [
                  TextSpan(text: context.tr(en: 'Privacy Notice: ', ar: 'إشعار الخصوصية: '), style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: context.tr(
                      en: 'All analytics shown are aggregate data only. No individual student health information is displayed.',
                      ar: 'جميع التحليلات المعروضة هي بيانات تجميعية فقط. لا يتم عرض أي معلومات صحية فردية للطلاب.',
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
