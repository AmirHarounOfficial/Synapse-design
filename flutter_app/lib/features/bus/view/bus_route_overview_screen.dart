import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/bus_boarding_event.dart';
import '../../../data/models/bus_route.dart';
import '../../../data/repositories/bus_repository.dart';
import '../cubit/bus_route_cubit.dart';

/// Ported from `BusRouteOverview.tsx`, now wired to `GET /bus-routes/{id}`.
/// Route header + status progress bar over the student manifest derived from
/// the route's boarding events. Tapping a not-yet-boarded student opens the
/// boarding screen for that student.
class BusRouteOverviewScreen extends StatelessWidget {
  const BusRouteOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BusRouteCubit(sl<BusRepository>()),
      child: const _RouteOverviewView(),
    );
  }
}

/// One row in the manifest, collapsed from the route's events per student.
class _ManifestEntry {
  const _ManifestEntry({required this.studentId, required this.name, required this.boarded, this.stopName});
  final int studentId;
  final String name;
  final bool boarded;
  final String? stopName;
}

class _RouteOverviewView extends StatelessWidget {
  const _RouteOverviewView();

  static String get _currentTime {
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  /// Collapse events into one manifest row per student (latest event wins).
  List<_ManifestEntry> _manifest(BusRoute route) {
    final byStudent = <int, BusBoardingEvent>{};
    for (final e in route.events) {
      final existing = byStudent[e.studentId];
      if (existing == null) {
        byStudent[e.studentId] = e;
      } else {
        final a = e.occurredAtDate, b = existing.occurredAtDate;
        if (a != null && b != null && a.isAfter(b)) byStudent[e.studentId] = e;
      }
    }
    final entries = byStudent.values
        .map((e) => _ManifestEntry(
              studentId: e.studentId,
              name: e.student?.name ?? 'Student #${e.studentId}',
              boarded: e.isBoarded,
              stopName: e.stopName,
            ))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusRouteCubit, DataState<BusRoute>>(
      builder: (context, state) {
        return SchooKeepScaffold(
          reserveBottomNav: true,
          scrollable: state is DataLoaded<BusRoute>,
          appBar: SchooKeepAppBar(
            titleWidget: Row(
              children: [
                Expanded(
                  child: Text(
                    state is DataLoaded<BusRoute> ? state.data.name : 'Bus Route',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                  ),
                ),
                const Icon(LucideIcons.clock, size: 16, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 8),
                Text(_currentTime,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          body: switch (state) {
            DataLoading() => const SizedBox(height: 400, child: Center(child: CircularProgressIndicator())),
            DataError(:final message) => _errorView(context, message),
            DataLoaded(:final data) => _content(context, data),
          },
        );
      },
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
              const SizedBox(height: 16),
              SchooKeepButton(
                label: 'Retry',
                fullWidth: false,
                onPressed: () => context.read<BusRouteCubit>().load(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, BusRoute route) {
    final manifest = _manifest(route);
    final total = manifest.length;
    final boarded = manifest.where((s) => s.boarded).length;
    final progress = total == 0 ? 0.0 : (boarded / total) * 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _routeStatus(boarded, total, progress),
          const SizedBox(height: 12),
          _biasReportLink(context),
          const SizedBox(height: 12),
          _earlyDismissalLink(context),
          const SizedBox(height: 16),
          Text('STUDENT MANIFEST ($total)',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          if (manifest.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No students on this route yet.',
                    style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
              ),
            )
          else
            for (final s in manifest) ...[
              _studentCard(context, route, s),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 8),
          _infoNotice(),
        ],
      ),
    );
  }

  Widget _biasReportLink(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/bus/report-bias'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.shieldAlert, size: 20, color: SchooKeepColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(en: 'Report Bus Transit Bias Incident', ar: 'الإبلاغ عن حادث تمييز في الحافلة'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr(en: 'Confidential report sent directly to Guidance Counselor', ar: 'تقرير سري يُرسل مباشرة للمرشد الطلابي'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                    ),
                  ],
                ),
              ),
              const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _earlyDismissalLink(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/bus/early-dismissal'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SchooKeepColors.amberChipBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.warning),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Early Dismissal Alerts',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText)),
                    SizedBox(height: 2),
                    Text('Students leaving before the afternoon route',
                        style: TextStyle(fontSize: 12, color: SchooKeepColors.amberText)),
                  ],
                ),
              ),
              const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.warning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeStatus(int boarded, int total, double progress) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ROUTE STATUS',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
              Text('$boarded of $total',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(SchooKeepColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('${progress.toStringAsFixed(0)}% Complete',
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _studentCard(BuildContext context, BusRoute route, _ManifestEntry s) {
    final isBoarded = s.boarded;
    final Color borderColor = isBoarded ? SchooKeepColors.accent : SchooKeepColors.border;
    final Color bgColor = isBoarded ? const Color(0xFFF0FDF4) : SchooKeepColors.surface;

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Text(s.stopName ?? 'Stop —',
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _statusBadge(isBoarded),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(
              isBoarded ? '/bus/deboarding/${s.studentId}' : '/bus/boarding/${s.studentId}',
              extra: {
                'routeId': route.id,
                'name': s.name,
                'stopName': s.stopName,
              },
            ),
        child: card,
      ),
    );
  }

  Widget _statusBadge(bool boarded) {
    if (boarded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: SchooKeepColors.greenChipBg, borderRadius: BorderRadius.circular(8)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.check, size: 16, color: SchooKeepColors.greenChipText),
            SizedBox(width: 6),
            Text('Boarded',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.greenChipText)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
      child: const Text('Pending',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary)),
    );
  }

  Widget _infoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Text(
        'Tap a pending student to confirm boarding, or a boarded student to confirm drop-off. Parents will receive automatic notifications.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.5),
      ),
    );
  }
}
