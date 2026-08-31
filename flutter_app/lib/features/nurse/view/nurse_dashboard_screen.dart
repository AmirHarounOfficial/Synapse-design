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
import '../../../data/repositories/document_repository.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../cubit/nurse_dashboard_cubit.dart';

/// Ported from `NurseDashboard.tsx`, now wired to the API. Summary stats,
/// physician-approval card, upcoming doses and recent visits come from the
/// medications/dose/clinic/document list endpoints (see [NurseDashboardCubit]).
/// The greeting and weather banner have no API source and stay static.
class NurseDashboardScreen extends StatelessWidget {
  const NurseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NurseDashboardCubit(
        sl<MedicationRepository>(),
        sl<ClinicRepository>(),
        sl<DocumentRepository>(),
        sl<StudentRepository>(),
      ),
      child: const _NurseDashboardView(),
    );
  }
}

class _NurseDashboardView extends StatefulWidget {
  const _NurseDashboardView();

  @override
  State<_NurseDashboardView> createState() => _NurseDashboardViewState();
}

class _NurseDashboardViewState extends State<_NurseDashboardView> {
  bool _showWeatherAlert = true;
  static const int _notificationCount = 3; // no API source

  void _reload() => context.read<NurseDashboardCubit>().load();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final hour = DateTime.now().hour;
    // no API source — greeting derived from device clock, nurse name static
    final greeting = isRTL
        ? (hour < 12 ? 'صباح الخير' : 'مساء الخير')
        : (hour < 12
            ? 'Good morning'
            : hour < 18
                ? 'Good afternoon'
                : 'Good evening');

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: '$greeting, Sarah 👋',
        actions: [
          _IconAction(
            icon: LucideIcons.bell,
            badgeCount: _notificationCount,
            onTap: () => context.go('/nurse/notifications'),
          ),
          _IconAction(icon: LucideIcons.settings, onTap: () => context.go('/nurse/settings')),
        ],
      ),
      body: BlocBuilder<NurseDashboardCubit, DataState<NurseDashboardData>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const SizedBox(
                height: 320,
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _errorView(message),
            DataLoaded(:final data) => _content(isRTL, data),
          };
        },
      ),
    );
  }

  Widget _errorView(String message) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: SchooKeepColors.textSecondary)),
              const SizedBox(height: 16),
              SchooKeepButton(label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'), fullWidth: false, onPressed: _reload),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(bool isRTL, NurseDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showWeatherAlert) _weatherBanner(isRTL),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statsRow(isRTL, data),
              const SizedBox(height: 24),
              if (data.pendingPhysicianApprovals > 0) ...[
                _physicianCard(isRTL, data.pendingPhysicianApprovals),
                const SizedBox(height: 24),
              ],
              _sectionHeader(
                isRTL ? 'إجراءات سريعة' : 'Quick Actions',
                trailing: isRTL ? 'عرض الكل' : 'See all',
              ),
              const SizedBox(height: 12),
              _quickActions(isRTL),
              const SizedBox(height: 24),
              _sectionHeader(
                isRTL ? 'الجرعات القادمة' : 'Upcoming Doses',
                trailing: isRTL ? 'عرض جميع الجرعات' : 'View all doses',
                onTrailing: () => context.go('/nurse/daily-doses'),
              ),
              const SizedBox(height: 12),
              ..._upcomingDoses(isRTL, data),
              const SizedBox(height: 24),
              Text(isRTL ? 'الزيارات الأخيرة' : 'Recent Visits',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 12),
              ..._recentVisits(isRTL, data),
            ],
          ),
        ),
      ],
    );
  }

  // no API source — weather/AQI advisory is not backed by an endpoint
  Widget _weatherBanner(bool isRTL) {
    return AccentCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      background: SchooKeepColors.amberBg,
      accentColor: SchooKeepColors.warning,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isRTL
                  ? 'تحذير جوي (المركز الوطني للأرصاد): عاصفة رملية (هبوب) متوقعة الساعة 2 ظهراً. يرجى الاطلاع على القيود.'
                  : 'AQI Advisory (UAE NCM): Haboob (dust storm) expected at 2:00 PM. See activity restrictions.',
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.amberText),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showWeatherAlert = false),
            child: const Icon(LucideIcons.x, size: 16, color: SchooKeepColors.amberText),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(bool isRTL, NurseDashboardData data) {
    final pendingSub = isRTL
        ? '${data.pendingMedicationCount} معلق'
        : '${data.pendingMedicationCount} pending';
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: LucideIcons.pill,
            value: '${data.medicationCount}',
            sub: pendingSub,
            subColor: SchooKeepColors.warning,
            onTap: () => context.go('/nurse/medications/inventory'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: LucideIcons.stethoscope,
            value: '${data.visitsTodayCount}',
            sub: isRTL ? 'اليوم' : 'today',
            subColor: SchooKeepColors.textSecondary,
            onTap: () => context.go('/nurse/clinic'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: LucideIcons.fileText,
            value: '${data.pendingDocumentCount}',
            sub: isRTL ? 'من الأهالي' : 'from parents',
            subColor: SchooKeepColors.textSecondary,
            onTap: () => context.go('/nurse/documents'),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String sub,
    required Color subColor,
    VoidCallback? onTap,
  }) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: SchooKeepColors.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: subColor)),
        ],
      ),
    );
  }

  Widget _physicianCard(bool isRTL, int pendingPhysicianApprovals) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(LucideIcons.clock, size: 20, color: Color(0xFFD97706)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isRTL
                    ? '⏳ بانتظار موافقة الطبيب: عدد $pendingPhysicianApprovals بروتوكول'
                    : '⏳ Awaiting physician approval: $pendingPhysicianApprovals protocol(s)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            isRTL
                ? 'لا يمكن إعطاء الأدوية بانتظار الموافقة حتى يعتمدها الطبيب المناوب.'
                : 'Medications awaiting approval cannot be administered until reviewed and signed by the physician.',
            style: const TextStyle(fontSize: 12, color: Color(0xFFB45309)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SchooKeepColors.warning),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go('/nurse/medications'),
              child: Text(isRTL ? 'مراجعة مع الطبيب' : 'Review with Physician',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {String? trailing, VoidCallback? onTrailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailing,
            child: Text(trailing, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
          ),
      ],
    );
  }

  Widget _quickActions(bool isRTL) {
    final actions = [
      (
        label: isRTL ? 'مخزون الأدوية' : 'Medicine Inventory',
        icon: LucideIcons.boxes,
        color: const Color(0xFF2563EB),
        route: '/nurse/medications/inventory',
        filled: true,
      ),
      (
        label: isRTL ? 'تسجيل زيارة عيادة' : 'Log Clinic Visit',
        icon: LucideIcons.stethoscope,
        color: SchooKeepColors.primary,
        route: '/nurse/clinic/new-visit',
        filled: false,
      ),
      (
        label: isRTL ? 'إعطاء دواء' : 'Give Medication',
        icon: LucideIcons.pill,
        color: SchooKeepColors.accent,
        route: '/nurse/medications/dose-confirmation',
        filled: false,
      ),
      (
        label: isRTL ? 'طوارئ' : 'Emergency',
        icon: LucideIcons.zap,
        color: SchooKeepColors.error,
        route: null,
        filled: false,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        for (final a in actions)
          Material(
            color: a.filled ? a.color : SchooKeepColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: a.filled ? BorderSide.none : const BorderSide(color: SchooKeepColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: a.route == null ? () {} : () => context.go(a.route!),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a.icon, size: 28, color: a.filled ? Colors.white : a.color),
                  const SizedBox(height: 8),
                  Text(a.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: a.filled ? Colors.white : SchooKeepColors.textPrimary)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _upcomingDoses(bool isRTL, NurseDashboardData data) {
    if (data.upcomingDoses.isEmpty) {
      return [
        SchooKeepCard(
          padding: const EdgeInsets.all(16),
          child: Text(isRTL ? 'لا توجد جرعات قادمة اليوم' : 'No upcoming doses today',
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        ),
      ];
    }
    return [
      for (final d in data.upcomingDoses)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SchooKeepCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: SchooKeepColors.primary,
                  child: Text(d.initials, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.studentName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      Text(d.medicationLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SchooKeepBadge(
                  label: _doseTime(d),
                  icon: LucideIcons.clock,
                  background: d.isUrgent ? SchooKeepColors.amberChipBg : SchooKeepColors.greenChipBg,
                  foreground: d.isUrgent ? SchooKeepColors.amberText : SchooKeepColors.greenChipText,
                  fontSize: 11,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => context.go('/nurse/medications/${d.administration.medicationId}'),
                    child: Text(isRTL ? 'إعطاء' : 'Give',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  /// Formats the scheduled time (falls back to a dash when the API has none).
  static String _doseTime(UpcomingDose d) {
    final iso = d.administration.scheduledFor;
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '—';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  List<Widget> _recentVisits(bool isRTL, NurseDashboardData data) {
    if (data.recentVisits.isEmpty) {
      return [
        SchooKeepCard(
          padding: const EdgeInsets.all(16),
          child: Text(isRTL ? 'لا توجد زيارات اليوم' : 'No recent visits',
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        ),
      ];
    }
    return [
      for (final v in data.recentVisits)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SchooKeepCard(
            padding: const EdgeInsets.all(12),
            onTap: () => context.go('/nurse/clinic'),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.studentName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      Text('${v.visit.reason ?? (isRTL ? 'زيارة' : 'Visit')} • ${_visitTime(v.visit.visitedAt)}',
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
              ],
            ),
          ),
        ),
    ];
  }

  static String _visitTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap, this.badgeCount = 0});
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

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
            if (badgeCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(color: SchooKeepColors.error, borderRadius: BorderRadius.circular(999)),
                  child: Text('$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
