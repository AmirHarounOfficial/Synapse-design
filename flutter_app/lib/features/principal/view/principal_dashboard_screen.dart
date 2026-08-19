import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/system_repository.dart';
import '../cubit/principal_dashboard_cubit.dart';

class PrincipalDashboardScreen extends StatelessWidget {
  const PrincipalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrincipalDashboardCubit(
        sl<SystemRepository>(),
        sl<ClinicRepository>(),
      ),
      child: const _PrincipalDashboardView(),
    );
  }
}

class _PrincipalDashboardView extends StatefulWidget {
  const _PrincipalDashboardView();

  @override
  State<_PrincipalDashboardView> createState() => _PrincipalDashboardViewState();
}

class _PrincipalDashboardViewState extends State<_PrincipalDashboardView> {
  bool _advisoryDismissed = false;

  void _dismissAdvisory() => setState(() => _advisoryDismissed = true);

  void _reload() => context.read<PrincipalDashboardCubit>().load();

  List<_HealthStat> _healthStats(BuildContext context, PrincipalDashboardData? data) => <_HealthStat>[
        _HealthStat(
          context.tr(en: 'Clinic visits today', ar: 'زيارات العيادة اليوم'),
          '${data?.clinicVisitsToday ?? 12}',
          LucideIcons.heart,
          const Color(0xFF14B8A6),
          const Color(0xFFCCFBF1),
        ),
        _HealthStat(
          context.tr(en: 'Medications due', ar: 'الأدوية المستحقة'),
          '8',
          LucideIcons.pill,
          SchooKeepColors.primary,
          const Color(0xFFDBEAFE),
        ),
        _HealthStat(
          context.tr(en: 'Pending docs', ar: 'مستندات معلقة'),
          '3',
          LucideIcons.fileText,
          SchooKeepColors.warning,
          const Color(0xFFFEF3C7),
          hasBadge: true,
        ),
        _HealthStat(
          context.tr(en: 'Active alerts', ar: 'تنبيهات نشطة'),
          '${data?.activeAlerts ?? 1}',
          LucideIcons.alertTriangle,
          SchooKeepColors.error,
          const Color(0xFFFEE2E2),
          hasBadge: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final quickActions = <_QuickAction>[
      _QuickAction(
        context.tr(en: 'Send Message', ar: 'إرسال رسالة'),
        LucideIcons.mail,
        const Color(0xFF06B6D4),
        const Color(0xFFCFFAFE),
        () => context.push('/secretary/compose-message'),
      ),
      _QuickAction(
        context.tr(en: 'Issue Advisory', ar: 'إصدار تنبيه'),
        LucideIcons.cloudOff,
        SchooKeepColors.warning,
        const Color(0xFFFEF3C7),
        () => context.push('/principal/weather-advisory'),
      ),
      _QuickAction(
        context.tr(en: 'After-Hours Access', ar: 'دخول خارج الدوام'),
        LucideIcons.moon,
        SchooKeepColors.textSecondary,
        const Color(0xFFF1F5F9),
        () => context.push('/principal/after-hours-access'),
      ),
      _QuickAction(
        context.tr(en: 'Generate Report', ar: 'إنشاء تقرير'),
        LucideIcons.barChart3,
        SchooKeepColors.primary,
        const Color(0xFFDBEAFE),
        () => context.push('/principal/annual-report'),
      ),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Al Noor International School', ar: 'مدرسة النور الدولية'),
        actions: [
          InkWell(
            onTap: () => context.go('/principal/settings'),
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Text('KR',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PrincipalDashboardCubit, DataState<PrincipalDashboardData>>(
        builder: (context, state) {
          if (state is DataError<PrincipalDashboardData>) {
            return _errorView(state.message);
          }
          final data = state is DataLoaded<PrincipalDashboardData> ? state.data : null;
          final loading = state is DataLoading<PrincipalDashboardData>;
          final showActive = data?.activeAdvisory != null && !_advisoryDismissed;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _healthOverviewCard(context, data, loading),
                const SizedBox(height: 16),
                showActive ? _advisoryActiveCard(context, data) : _advisoryPromptCard(context),
                const SizedBox(height: 16),
                _staffActivityCard(context),
                const SizedBox(height: 16),
                _legalStatusCard(context),
                const SizedBox(height: 16),
                Text(
                  context.tr(en: 'Quick Actions', ar: 'إجراءات سريعة'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _quickActionsGrid(quickActions),
                const SizedBox(height: 16),
                Text(
                  context.tr(en: 'School Management', ar: 'إدارة المدرسة'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _managementSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'), fullWidth: false, onPressed: _reload),
          ],
        ),
      ),
    );
  }

  Widget _healthOverviewCard(BuildContext context, PrincipalDashboardData? data, bool loading) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr(en: "Today's Health Overview", ar: 'نظرة عامة على صحة اليوم'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(width: 8),
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.4,
            children: [for (final s in _healthStats(context, data)) _statRow(s)],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.go('/principal/analytics'),
            child: Text(
              context.tr(en: 'View full analytics →', ar: 'عرض التحليلات الكاملة ←'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(_HealthStat s) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: s.bg, shape: BoxShape.circle),
              child: Icon(s.icon, size: 16, color: s.color),
            ),
            if (s.hasBadge)
              const Positioned(
                top: -2,
                right: -2,
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(decoration: BoxDecoration(color: SchooKeepColors.error, shape: BoxShape.circle)),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                s.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.1),
              ),
              Text(
                s.value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _advisoryPromptCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.cloudOff, size: 20, color: SchooKeepColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr(
                    en: '⚠ AQI Advisory — Moderate dust risk at 2PM today',
                    ar: '⚠ تنبيه الجو — مخاطر غبار متوسطة الساعة 2 ظهراً',
                  ),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => context.go('/principal/weather-advisory'),
                    child: Text(
                      context.tr(en: 'Issue advisory now', ar: 'إصدار التنبيه الآن'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _dismissAdvisory,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    context.tr(en: 'Dismiss', ar: 'تجاهل'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF92400E)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _advisoryActiveCard(BuildContext context, PrincipalDashboardData? data) {
    final advisory = data?.activeAdvisory;
    final headline = advisory != null && advisory.message.isNotEmpty
        ? '${context.tr(en: 'Advisory active', ar: 'التنبيه نشط')} — ${advisory.message}'
        : context.tr(en: 'Advisory active', ar: 'التنبيه نشط');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.accent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    en: 'All staff and parents have been notified',
                    ar: 'تم إشعار جميع الموظفين وأولياء الأمور بنجاح',
                  ),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF065F46)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffActivityCard(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.users, size: 20, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Active staff now: 14 of 18', ar: 'الموظفون النشطون الآن: 14 من 18'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.778,
              minHeight: 8,
              backgroundColor: Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(SchooKeepColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.go('/principal/staff'),
            child: Text(
              context.tr(en: 'View all →', ar: 'عرض جميع الموظفين ←'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legalStatusCard(BuildContext context) {
    return SchooKeepCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Platform agreement: Active ✓', ar: 'اتفاقية المنصة: نشطة ✓'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => context.go('/principal/legal-documents'),
                  child: Text(
                    context.tr(en: 'Parent consents pending: 3', ar: 'موافقات أولياء الأمور المعلقة: 3'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _managementSection(BuildContext context) {
    final rows = <Widget>[
      _managementRow(
        LucideIcons.lock,
        context.tr(en: 'Permission matrix', ar: 'مصفوفة الصلاحيات'),
        context.tr(en: 'Role access governance', ar: 'حوكمة صلاحيات الأدوار'),
        () => context.go('/principal/permission-matrix'),
      ),
      _managementRow(
        LucideIcons.wallet,
        context.tr(en: 'SMS wallet', ar: 'محفظة الرسائل النصية'),
        context.tr(en: 'Balance & top-up history', ar: 'الرصيد وسجل الشحن'),
        () => context.go('/principal/sms-wallet'),
      ),
      _managementRow(
        LucideIcons.graduationCap,
        context.tr(en: 'Student promotion', ar: 'ترقية سجلات الطلاب'),
        context.tr(en: 'Advance students to next grade', ar: 'ترقية الطلاب للصف التالي'),
        () => context.go('/principal/student-promotion'),
      ),
    ];
    final items = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) items.add(const Divider(height: 1, color: SchooKeepColors.border));
      items.add(rows[i]);
    }
    return SchooKeepCard(padding: EdgeInsets.zero, child: Column(children: items));
  }

  Widget _managementRow(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
            const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _quickActionsGrid(List<_QuickAction> actions) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        for (final a in actions)
          Material(
            color: SchooKeepColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: SchooKeepColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: a.onTap ?? () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: a.bg, shape: BoxShape.circle),
                    child: Icon(a.icon, size: 24, color: a.color),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        a.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HealthStat {
  const _HealthStat(this.label, this.value, this.icon, this.color, this.bg, {this.hasBadge = false});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool hasBadge;
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.color, this.bg, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback? onTap;
}
