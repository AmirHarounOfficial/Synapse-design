import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../cubit/vice_principal_dashboard_cubit.dart';

/// Ported from `VicePrincipalDashboard.tsx`. Deputy dashboard with delegation
/// notice, summary stats (incl. a locked stat), clinic-readiness alert, quick
/// actions (some locked) and an access-level link. The "Today's clinic visits"
/// stat is wired to `GET /clinic-visits?date=<today>`; the delegation notice,
/// "Staff active" tile, locked stat/actions and clinic-readiness count remain
/// static (no API source or access not granted to this role).
class VicePrincipalDashboardScreen extends StatelessWidget {
  const VicePrincipalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VicePrincipalDashboardCubit(sl<ClinicRepository>()),
      child: const _VicePrincipalDashboardView(),
    );
  }
}

class _VicePrincipalDashboardView extends StatelessWidget {
  const _VicePrincipalDashboardView();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Deputy Dashboard',
        actions: [
          InkWell(
            onTap: () => context.go('/vice-principal/settings'),
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Text('VD',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                ),
              ),
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _delegationNotice(),
          const SizedBox(height: 16),
          const Text('Summary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          BlocBuilder<VicePrincipalDashboardCubit, DataState<VicePrincipalDashboardData>>(
            builder: (context, state) {
              final data = state is DataLoaded<VicePrincipalDashboardData> ? state.data : null;
              final loading = state is DataLoading<VicePrincipalDashboardData>;
              return _summaryStats(clinicVisits: data?.clinicVisitsToday, loading: loading);
            },
          ),
          const SizedBox(height: 16),
          _clinicAlert(context),
          const SizedBox(height: 16),
          const Text('Quick Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          _quickActions(context),
          const SizedBox(height: 16),
          _accessInfo(context),
        ],
      ),
    );
  }

  Widget _delegationNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.info, size: 20, color: SchooKeepColors.primary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your permissions are delegated by Principal M. Davis. Contact the Principal to modify your access.',
              style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1E40AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStats({int? clinicVisits, bool loading = false}) {
    final visitsValue = loading && clinicVisits == null ? '—' : '${clinicVisits ?? 0}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _statCard(LucideIcons.heart, visitsValue, "Today's clinic visits",
              const Color(0xFF14B8A6), const Color(0xFFCCFBF1)),
        ),
        const SizedBox(width: 12),
        // no API source — staff-active count has no dashboard endpoint
        Expanded(
          child: _statCard(LucideIcons.users, '14', 'Staff active',
              SchooKeepColors.primary, const Color(0xFFDBEAFE)),
        ),
        const SizedBox(width: 12),
        const Expanded(child: _LockedStat()),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color iconColor, Color bg) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _clinicAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠ 3 clinic items require end-of-year attention',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => context.go('/vice-principal/clinic-readiness'),
                  child: const Text('Review →',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      (label: 'View analytics', icon: LucideIcons.barChart3, color: SchooKeepColors.primary, bg: const Color(0xFFDBEAFE), locked: false, route: '/vice-principal/analytics'),
      (label: 'View clinic readiness', icon: LucideIcons.clipboard, color: SchooKeepColors.accent, bg: const Color(0xFFD1FAE5), locked: false, route: '/vice-principal/clinic-readiness'),
      (label: 'Equipment checklist', icon: LucideIcons.clipboardCheck, color: SchooKeepColors.warning, bg: SchooKeepColors.amberChipBg, locked: false, route: '/vice-principal/equipment-checklist'),
      (label: 'Manage staff', icon: LucideIcons.users, color: SchooKeepColors.textSecondary, bg: const Color(0xFFF1F5F9), locked: true, route: null),
      (label: 'Issue advisory', icon: LucideIcons.alertTriangle, color: SchooKeepColors.textSecondary, bg: const Color(0xFFF1F5F9), locked: true, route: null),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        for (final a in actions)
          Opacity(
            opacity: a.locked ? 0.5 : 1.0,
            child: SchooKeepCard(
              padding: const EdgeInsets.all(16),
              onTap: a.locked ? null : () => context.go(a.route!),
              child: Stack(
                children: [
                  if (a.locked)
                    const PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
                    ),
                  Center(
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
                        Text(a.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                        if (a.locked) ...[
                          const SizedBox(height: 4),
                          const Text('Request access from Principal',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _accessInfo(BuildContext context) {
    return SchooKeepCard(
      onTap: () => context.go('/vice-principal/permissions'),
      child: const Row(
        children: [
          Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.textSecondary),
          SizedBox(width: 12),
          Expanded(
            child: Text('View my access level',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
          RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
        ],
      ),
    );
  }
}

class _LockedStat extends StatelessWidget {
  const _LockedStat();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: SchooKeepCard(
        padding: const EdgeInsets.all(12),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.pill, size: 20, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 8),
                const Text('Medication details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
                const SizedBox(height: 2),
                const Text('Access not granted',
                    style: TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
