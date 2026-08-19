import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../cubit/health_analytics_cubit.dart';

class PrincipalHealthAnalyticsScreen extends StatelessWidget {
  const PrincipalHealthAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HealthAnalyticsCubit(sl<AnalyticsRepository>()),
      child: const _PrincipalHealthAnalyticsView(),
    );
  }
}

class _PrincipalHealthAnalyticsView extends StatefulWidget {
  const _PrincipalHealthAnalyticsView();

  @override
  State<_PrincipalHealthAnalyticsView> createState() => _PrincipalHealthAnalyticsViewState();
}

class _PrincipalHealthAnalyticsViewState extends State<_PrincipalHealthAnalyticsView> {
  String _dateRange = 'month';

  static const _ramadanBar = Color(0xFFD97706);
  static const _categoryColors = <Color>[
    SchooKeepColors.primary,
    Color(0xFF14B8A6),
    SchooKeepColors.accent,
    SchooKeepColors.warning,
    Color(0xFF8B5CF6),
    SchooKeepColors.textSecondary,
  ];

  static int _int(Map<String, dynamic> m, String key) => (m[key] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr(en: 'Health Analytics', ar: 'التحليلات الصحية'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 16, color: SchooKeepColors.textPrimary),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _dateRange,
                      isDense: true,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                      items: [
                        DropdownMenuItem(value: 'month', child: Text(context.tr(en: 'This month', ar: 'هذا الشهر'))),
                        DropdownMenuItem(value: 'semester', child: Text(context.tr(en: 'This semester', ar: 'هذا الفصل الدراسي'))),
                        DropdownMenuItem(value: 'year', child: Text(context.tr(en: 'This year', ar: 'هذه السنة'))),
                      ],
                      onChanged: (v) => setState(() => _dateRange = v ?? _dateRange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<HealthAnalyticsCubit, DataState<HealthAnalyticsData>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _errorBanner(context, message),
            DataLoaded(:final data) => _content(context, data),
          };
        },
      ),
    );
  }

  Widget _content(BuildContext context, HealthAnalyticsData data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _privacyNotice(context),
          const SizedBox(height: 16),
          _statGrid(context, data.overview),
          const SizedBox(height: 16),
          _visitChart(context),
          const SizedBox(height: 16),
          _weatherCorrelation(context),
          const SizedBox(height: 16),
          _conditionBreakdown(context, data.health),
          const SizedBox(height: 16),
          _medicationCompliance(context, data.health),
          const SizedBox(height: 16),
          _healthBreakdowns(context, data.health),
        ],
      ),
    );
  }

  Widget _errorBanner(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          SchooKeepButton(
            label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
            fullWidth: false,
            onPressed: () => context.read<HealthAnalyticsCubit>().load(),
          ),
        ],
      ),
    );
  }

  Widget _privacyNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 16, color: SchooKeepColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr(
                en: 'This dashboard shows aggregate statistics. No individual student data is displayed.',
                ar: 'تعرض هذه لوحة التحكم إحصائيات تجميعية فقط. لا يتم عرض بيانات أي طالب فردي.',
              ),
              style: const TextStyle(fontSize: 11, color: Color(0xFF1E40AF), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statGrid(BuildContext context, Map<String, dynamic> overview) {
    final stats = <_Stat>[
      _Stat(
        context.tr(en: 'Total students', ar: 'إجمالي الطلاب'),
        '${_int(overview, 'total_students')}',
        LucideIcons.users,
        SchooKeepColors.primary,
        const Color(0xFFDBEAFE),
      ),
      _Stat(
        context.tr(en: 'Clinic visits this week', ar: 'زيارات العيادة هذا الأسبوع'),
        '${_int(overview, 'clinic_visits_this_week')}',
        LucideIcons.heart,
        const Color(0xFF14B8A6),
        const Color(0xFFCCFBF1),
      ),
      _Stat(
        context.tr(en: 'Active medications', ar: 'الأدوية النشطة'),
        '${_int(overview, 'active_medications')}',
        LucideIcons.pill,
        SchooKeepColors.accent,
        const Color(0xFFD1FAE5),
      ),
      _Stat(
        context.tr(en: 'Pending documents', ar: 'المستندات المعلقة'),
        '${_int(overview, 'pending_documents')}',
        LucideIcons.fileText,
        SchooKeepColors.warning,
        const Color(0xFFFEF3C7),
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        for (final s in stats)
          SchooKeepCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: s.bg, shape: BoxShape.circle),
                  child: Icon(s.icon, size: 20, color: s.color),
                ),
                const SizedBox(height: 8),
                Text(s.value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 2),
                Text(s.label, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _visitChart(BuildContext context) {
    final weeklyVisits = <_WeekVisit>[
      _WeekVisit(context.tr(en: 'W1', ar: 'الأسبوع 1'), 18, false, false),
      _WeekVisit(context.tr(en: 'W2', ar: 'الأسبوع 2'), 22, false, false),
      _WeekVisit(context.tr(en: 'W3', ar: 'الأسبوع 3'), 15, false, false),
      _WeekVisit(context.tr(en: 'W4', ar: 'الأسبوع 4'), 19, false, false),
      _WeekVisit(context.tr(en: 'W5', ar: 'الأسبوع 5'), 42, true, true),
      _WeekVisit(context.tr(en: 'W6', ar: 'الأسبوع 6'), 38, true, true),
      _WeekVisit(context.tr(en: 'W7', ar: 'الأسبوع 7'), 45, true, false),
      _WeekVisit(context.tr(en: 'W8', ar: 'الأسبوع 8'), 21, false, false),
    ];
    final maxVisits = weeklyVisits.map((w) => w.visits).reduce((a, b) => a > b ? a : b);

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(en: 'Weekly Clinic Visits', ar: 'زيارات العيادة الأسبوعية'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              Flexible(
                child: Text(
                  context.tr(en: 'Source: UAE NCM', ar: 'المصدر: المركز الوطني للأرصاد'),
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final w in weeklyVisits) _barRow(w, maxVisits),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _legend(SchooKeepColors.primary, context.tr(en: 'Normal week', ar: 'أسبوع طبيعي')),
              _legend(SchooKeepColors.warning, context.tr(en: 'Advisory week', ar: 'أسبوع تنبيهات الأرصاد')),
              _legend(_ramadanBar, context.tr(en: 'Ramadan', ar: 'رمضان المبارك')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barRow(_WeekVisit w, int maxVisits) {
    final color = w.isRamadan ? _ramadanBar : (w.hasAdvisory ? SchooKeepColors.warning : SchooKeepColors.primary);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(w.week, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                ),
                FractionallySizedBox(
                  widthFactor: w.visits / maxVisits,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                    alignment: AlignmentDirectional.centerEnd,
                    child: w.hasAdvisory && !w.isRamadan
                        ? const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(LucideIcons.cloudOff, size: 12, color: Colors.white),
                          )
                        : null,
                  ),
                ),
                if (w.isRamadan) Container(width: 2, height: 24, color: const Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text('${w.visits}',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
      ],
    );
  }

  Widget _weatherCorrelation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.cloudOff, size: 20, color: SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Weather Correlation (UAE NCM)', ar: 'ربط الأحوال الجوية (المركز الوطني للأرصاد)'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    en: 'During the 3 Haboob (Sandstorm) days this month, respiratory clinic visits increased 340% vs. average.',
                    ar: 'خلال أيام العواصف الرملية الثلاثة هذا الشهر، ارتفعت زيارات الجهاز التنفسي للعيادة بنسبة 340% عن المعدل.',
                  ),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conditionBreakdown(BuildContext context, Map<String, dynamic> health) {
    final raw = (health['clinic_visits_by_category'] as Map?) ?? const {};
    final entries = raw.entries
        .map((e) => (category: (e.key ?? 'Unknown').toString(), count: (e.value as num?)?.toInt() ?? 0))
        .where((e) => e.count > 0)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final total = entries.fold<int>(0, (sum, e) => sum + e.count);

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Visit Categories', ar: 'تصنيفات زيارات العيادة'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(
              context.tr(en: 'No clinic visits recorded yet.', ar: 'لا توجد زيارات عيادة مسجلة بعد.'),
              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
            )
          else
            for (int i = 0; i < entries.length; i++) ...[
              Builder(builder: (ctx) {
                final e = entries[i];
                final pct = total > 0 ? (e.count / total * 100) : 0.0;
                final color = _categoryColors[i % _categoryColors.length];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.category,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                          ),
                        ),
                        Text(
                          context.tr(en: '${e.count} visits · ${pct.round()}%', ar: '${e.count} زيارة · ${pct.round()}%'),
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),
            ],
        ],
      ),
    );
  }

  Widget _medicationCompliance(BuildContext context, Map<String, dynamic> health) {
    final doses = (health['doses_by_status'] as Map?) ?? const {};
    var total = 0;
    var given = 0;
    doses.forEach((k, v) {
      final n = (v as num?)?.toInt() ?? 0;
      total += n;
      if (k.toString().toLowerCase() == 'given') given += n;
    });
    final pct = total > 0 ? (given / total * 100) : 0.0;

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(en: 'Medication Compliance', ar: 'معدل الالتزام بالأدوية'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              const Icon(LucideIcons.pill, size: 20, color: SchooKeepColors.accent),
            ],
          ),
          const SizedBox(height: 8),
          Text('${pct.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: SchooKeepColors.accent)),
          const SizedBox(height: 4),
          Text(
            context.tr(
              en: '$given of $total scheduled doses administered',
              ar: 'تم إعطاء $given من أصل $total جرعة محدودة',
            ),
            style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(SchooKeepColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthBreakdowns(BuildContext context, Map<String, dynamic> health) {
    final severity = (health['clinic_visits_by_severity'] as Map?) ?? const {};
    final medStatus = (health['medications_by_status'] as Map?) ?? const {};
    final allergens = _int(health, 'students_with_allergens');

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Health Breakdowns', ar: 'تفاصيل الحالة الصحية العامة'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _breakdownGroup(context.tr(en: 'Clinic visits by severity', ar: 'زيارات العيادة حسب درجة الخطورة'), severity),
          const SizedBox(height: 8),
          _breakdownGroup(context.tr(en: 'Medications by status', ar: 'الأدوية حسب حالة المتابعة'), medStatus),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                child: const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr(en: 'Students with recorded allergens', ar: 'الطلاب المسجل لديهم مسببات حساسية'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
              ),
              Text('$allergens',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownGroup(String title, Map raw) {
    final entries = raw.entries
        .map((e) => (label: _titleCase((e.key ?? 'Unknown').toString()), count: (e.value as num?)?.toInt() ?? 0))
        .where((e) => e.count > 0)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final total = entries.fold<int>(0, (sum, e) => sum + e.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary)),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const Text('No data yet.', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary))
        else
          for (int i = 0; i < entries.length; i++) ...[
            Builder(builder: (ctx) {
              final e = entries[i];
              final pct = total > 0 ? (e.count / total * 100) : 0.0;
              final color = _categoryColors[i % _categoryColors.length];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(e.label,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      ),
                      Text('${e.count}',
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
          ],
      ],
    );
  }

  static String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon, this.color, this.bg);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
}

class _WeekVisit {
  const _WeekVisit(this.week, this.visits, this.hasAdvisory, this.isRamadan);
  final String week;
  final int visits;
  final bool hasAdvisory;
  final bool isRamadan;
}
