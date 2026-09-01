import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../cubit/teacher_dashboard_cubit.dart';

/// Ported from `TeacherDashboard.tsx`. Teacher greeting app bar, today's
/// summary stats, dismissible dust-storm banner, health considerations card,
/// upcoming clinic visits, and quick actions. Localized in English & Arabic.
class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeacherDashboardCubit(sl<ClinicRepository>()),
      child: const _TeacherDashboardView(),
    );
  }
}

class _TeacherDashboardView extends StatelessWidget {
  const _TeacherDashboardView();

  static const _showWeatherBanner = true; // no API source

  // Attendance figures have no API endpoint — kept static.
  static const _present = 22; // no API source
  static const _total = 24; // no API source
  static const _absent = 2; // no API source

  static String _formatTime(DateTime? dt, bool isRTL) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? (isRTL ? 'ص' : 'AM') : (isRTL ? 'م' : 'PM');
    return '$h:$m $period';
  }

  void _reload(BuildContext context) => context.read<TeacherDashboardCubit>().load();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr(en: 'Ms. Sarah Johnson', ar: 'أ. سارة الجابري'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            Text(
              context.tr(en: 'Room 204 — Grade 5', ar: 'غرفة ٢٠٤ — الصف الخامس'),
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
            ),
          ],
        ),
        actions: [
          _IconAction(
            icon: LucideIcons.bell,
            showDot: true,
            onTap: () => context.go('/teacher/notifications'),
          ),
          _IconAction(icon: LucideIcons.settings, onTap: () => context.go('/teacher/settings')),
        ],
      ),
      body: BlocBuilder<TeacherDashboardCubit, DataState<List<ClinicVisit>>>(
        builder: (context, state) {
          final visits = state is DataLoaded<List<ClinicVisit>> ? state.data : const <ClinicVisit>[];
          final medicalAlerts = visits.length;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel(context.tr(en: "Today's Summary", ar: 'ملخص اليوم')),
                const SizedBox(height: 12),
                _statsRow(context, medicalAlerts),
                const SizedBox(height: 16),
                if (_showWeatherBanner) ...[
                  _weatherBanner(context),
                  const SizedBox(height: 16),
                ],
                _medicalAlertsCard(context, medicalAlerts),
                const SizedBox(height: 16),
                _sectionLabel(context.tr(en: 'Upcoming Clinic Visits', ar: 'زيارات العيادة القادمة')),
                const SizedBox(height: 12),
                _visitsSection(context, state),
                const SizedBox(height: 16),
                _sectionLabel(context.tr(en: 'Quick Actions', ar: 'الإجراءات السريعة')),
                const SizedBox(height: 12),
                SchooKeepButton(
                  label: context.tr(en: 'Take Attendance', ar: 'تسجيل الحضور والغياب'),
                  icon: LucideIcons.calendar,
                  onPressed: () => context.go('/teacher/attendance'),
                ),
                const SizedBox(height: 12),
                SchooKeepButton(
                  label: context.tr(en: 'Report Bias / Racism Incident', ar: 'الإبلاغ عن حادث تمييز / عنصرية'),
                  icon: LucideIcons.shieldAlert,
                  variant: SchooKeepButtonVariant.outline,
                  onPressed: () => context.go('/teacher/report-bias'),
                ),
                const SizedBox(height: 12),
                SchooKeepButton(
                  label: context.tr(en: 'Send Clinic Referral', ar: 'إرسال إحالة للعيادة الطبية'),
                  icon: LucideIcons.stethoscope,
                  variant: SchooKeepButtonVariant.outline,
                  onPressed: () => context.go('/teacher/clinic-referral'),
                ),
                const SizedBox(height: 12),
                SchooKeepButton(
                  label: context.tr(en: 'Activity Exemptions', ar: 'إعفاءات الأنشطة'),
                  icon: LucideIcons.activity,
                  variant: SchooKeepButtonVariant.outline,
                  onPressed: () => context.go('/teacher/activity-exemptions'),
                ),
                const SizedBox(height: 12),
                SchooKeepButton(
                  label: context.tr(en: 'Student Release', ar: 'مغادرة طالب'),
                  icon: LucideIcons.userCheck,
                  variant: SchooKeepButtonVariant.outline,
                  onPressed: () => context.go('/teacher/student-release'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _visitsSection(BuildContext context, DataState<List<ClinicVisit>> state) {
    return switch (state) {
      DataLoading() => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      DataError(:final message) => _errorView(context, message),
      DataLoaded(:final data) => _releases(context, data),
    };
  }

  Widget _errorView(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            const Icon(LucideIcons.wifiOff, size: 32, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 12),
            SchooKeepButton(
              label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
              fullWidth: false,
              onPressed: () => _reload(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: SchooKeepColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );

  Widget _statsRow(BuildContext context, int medicalAlerts) {
    return Row(
      children: [
        // Present/Absent come from attendance, which has no API endpoint — static.
        Expanded(
          child: _statCard(
            LucideIcons.checkCircle,
            SchooKeepColors.accent,
            context.tr(en: 'Present', ar: 'الحاضرون'),
            '$_present/$_total',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            LucideIcons.users,
            SchooKeepColors.textSecondary,
            context.tr(en: 'Absent', ar: 'الغائبون'),
            '$_absent',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            LucideIcons.alertCircle,
            SchooKeepColors.warning,
            context.tr(en: 'Alerts', ar: 'التنبيهات'),
            '$medicalAlerts',
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, Color iconColor, String label, String value) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      radius: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // Static demo banner — there is no teacher-scoped weather endpoint.
  Widget _weatherBanner(BuildContext context) {
    return AccentCard(
      background: SchooKeepColors.amberChipBg,
      accentColor: SchooKeepColors.warning,
      accentWidth: 3,
      radius: 12,
      padding: const EdgeInsets.all(12),
      borderColor: SchooKeepColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(en: 'Dust Storm Advisory', ar: 'تنبيه عاصفة ترابية'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(en: '3 students must remain indoors today', ar: 'يجب أن يبقى ٣ طلاب بداخل المبنى اليوم'),
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.amberText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.go('/teacher/weather-restriction'),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.tr(en: 'View list', ar: 'عرض القائمة'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.warning,
                  decoration: TextDecoration.underline,
                  decorationColor: SchooKeepColors.warning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicalAlertsCard(BuildContext context, int medicalAlerts) {
    return SchooKeepCard(
      borderColor: SchooKeepColors.border,
      onTap: () => context.go('/teacher/health-considerations'),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: SchooKeepColors.warning, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CircleAvatarBox(
                    bg: SchooKeepColors.amberChipBg,
                    child: Icon(LucideIcons.alertCircle, size: 20, color: SchooKeepColors.warning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(en: 'Health Considerations', ar: 'الحالات الصحية الخاصة'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            en: '$medicalAlerts students have active health considerations',
                            ar: 'لدى $medicalAlerts طلاب حالات صحية خاصة نشطة',
                          ),
                          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(en: 'Tap to view safe-activity guidance', ar: 'اضغط لعرض إرشادات الأنشطة الآمنة'),
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.amberText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _releases(BuildContext context, List<ClinicVisit> visits) {
    if (visits.isEmpty) {
      return SchooKeepCard(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            context.tr(en: 'No clinic visits today', ar: 'لا توجد زيارات للعيادة اليوم'),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
        ),
      );
    }
    final isRTL = context.isRTL;
    return Column(
      children: [
        for (final v in visits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SchooKeepCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const _CircleAvatarBox(
                    bg: Color(0xFFEFF6FF),
                    child: Icon(LucideIcons.stethoscope, size: 18, color: SchooKeepColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(en: 'Student #${v.studentId}', ar: 'الطالب #${v.studentId}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                        ),
                        Text(
                          [_formatTime(v.visitedAt, isRTL), v.reason]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (v.isEmergency)
                    SchooKeepBadge(
                      label: context.tr(en: 'Emergency', ar: 'طوارئ'),
                      icon: LucideIcons.alertCircle,
                      background: const Color(0xFFFEE2E2),
                      foreground: SchooKeepColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    )
                  else
                    SchooKeepBadge(
                      label: context.tr(en: 'Visited', ar: 'تمت الزيارة'),
                      icon: LucideIcons.stethoscope,
                      background: const Color(0xFFDBEAFE),
                      foreground: const Color(0xFF1E40AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleAvatarBox extends StatelessWidget {
  const _CircleAvatarBox({required this.bg, required this.child});
  final Color bg;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: child,
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap, this.showDot = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 24, color: SchooKeepColors.textSecondary),
            if (showDot)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: SchooKeepColors.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
