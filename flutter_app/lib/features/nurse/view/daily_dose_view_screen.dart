import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/medication_repository.dart';
import '../cubit/daily_dose_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `DailyDoseView.tsx`, now wired to the API
/// (`GET /dose-administrations?date=today`, joined to medications for labels).
/// A timeline of today's dose administrations with summary stats and a progress
/// bar, plus loading/error(retry)/empty states.
class DailyDoseViewScreen extends StatelessWidget {
  const DailyDoseViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DailyDoseCubit(sl<MedicationRepository>()),
      child: const _DailyDoseView(),
    );
  }
}

class _DailyDoseView extends StatelessWidget {
  const _DailyDoseView();

  String get _today {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  /// Formats an ISO-8601 timestamp to a short 12-hour time, or returns it as-is.
  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final local = dt.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour < 12 ? 'AM' : 'PM';
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hour12:$mm $period';
  }

  Widget _statusIcon(String? status) {
    switch (status) {
      case 'given':
        return _circleIcon(
          SchooKeepColors.accent,
          LucideIcons.check,
          Colors.white,
          16,
        );
      case 'pending':
        return _circleIcon(
          SchooKeepColors.warning,
          LucideIcons.clock,
          Colors.white,
          14,
        );
      case 'missed':
      case 'refused':
        return _circleIcon(
          SchooKeepColors.error,
          LucideIcons.x,
          Colors.white,
          16,
        );
      case 'conflict':
        return _circleIcon(
          SchooKeepColors.warning,
          LucideIcons.alertTriangle,
          Colors.white,
          14,
        );
      default:
        return _circleIcon(
          SchooKeepColors.border,
          LucideIcons.clock,
          SchooKeepColors.textSecondary,
          14,
        );
    }
  }

  Widget _circleIcon(Color bg, IconData icon, Color fg, double iconSize) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: iconSize, color: fg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: "Today's Doses",
        centerTitle: true,
        onBack: () => context.safeBack(),
        actions: [
          Center(
            child: Text(
              _today,
              style: const TextStyle(
                fontSize: 13,
                color: SchooKeepColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DailyDoseCubit, DataState<List<DailyDoseEntry>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorView(context, message),
            DataLoaded(:final data) => _content(context, data),
          };
        },
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.wifiOff,
              size: 36,
              color: SchooKeepColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: 'Retry',
              fullWidth: false,
              onPressed: () => context.read<DailyDoseCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<DailyDoseEntry> doses) {
    if (doses.isEmpty) {
      return const Center(
        child: Text(
          'No doses scheduled today',
          style: TextStyle(color: SchooKeepColors.textSecondary),
        ),
      );
    }
    final total = doses.length;
    final given = doses.where((d) => d.administration.status == 'given').length;
    final pending = doses
        .where((d) => d.administration.status == 'pending')
        .length;
    final missed = doses
        .where(
          (d) =>
              d.administration.status == 'missed' ||
              d.administration.status == 'refused',
        )
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _statColumn(
                  '$total',
                  'Total',
                  SchooKeepColors.textPrimary,
                ),
              ),
              Expanded(
                child: _statColumn(
                  '$given',
                  'Given',
                  SchooKeepColors.accent,
                  icon: LucideIcons.check,
                ),
              ),
              Expanded(
                child: _statColumn(
                  '$pending',
                  'Pending',
                  SchooKeepColors.warning,
                ),
              ),
              Expanded(
                child: _statColumn('$missed', 'Missed', SchooKeepColors.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : given / total,
              minHeight: 6,
              backgroundColor: SchooKeepColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                SchooKeepColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < doses.length; i++)
            _timelineRow(context, doses, i),
        ],
      ),
    );
  }

  Widget _statColumn(
    String value,
    String label,
    Color valueColor, {
    IconData? icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: valueColor),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: SchooKeepColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _timelineRow(
    BuildContext context,
    List<DailyDoseEntry> doses,
    int index,
  ) {
    final entry = doses[index];
    final dose = entry.administration;
    final status = dose.status;
    final isMissed = status == 'missed' || status == 'refused';
    final isConflict = status == 'conflict';
    final timeLabel = _formatTime(dose.scheduledFor ?? dose.administeredAt);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                timeLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: SchooKeepColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _statusIcon(status),
              ),
              if (index < doses.length - 1)
                const Expanded(
                  child: SizedBox(
                    width: 1,
                    child: ColoredBox(color: SchooKeepColors.border),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: _timelineCardBody(
                isMissed: isMissed,
                isConflict: isConflict,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMissed) ...[
                      const SchooKeepBadge(
                        label: 'Missed',
                        background: Color(0xFFFEE2E2),
                        foreground: SchooKeepColors.error,
                        fontSize: 11,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (isConflict) ...[
                      const SchooKeepBadge(
                        label: 'Dose Conflict',
                        background: SchooKeepColors.amberChipBg,
                        foreground: SchooKeepColors.amberText,
                        fontSize: 11,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Student #${dose.studentId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textPrimary,
                      ),
                    ),
                    Text(
                      entry.medicationName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: SchooKeepColors.textSecondary,
                      ),
                    ),
                    if (status == 'given') ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.lock,
                            size: 12,
                            color: SchooKeepColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Administered at ${_formatTime(dose.administeredAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: SchooKeepColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (status == 'pending') ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: SchooKeepColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => context.go(
                            '/nurse/medications/dose-confirmation',
                          ),
                          child: const Text(
                            'Give now',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (isMissed) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: SchooKeepColors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => context.go(
                            '/nurse/medications/dose-confirmation',
                          ),
                          child: const Text(
                            'Overdue — log reason',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (isConflict) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: SchooKeepColors.warning,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => context.go(
                            '/nurse/medications/dose-conflict'
                            '?medication_id=${dose.medicationId}'
                            '&student_id=${dose.studentId}',
                          ),
                          child: const Text(
                            'Review conflict',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineCardBody({
    required bool isMissed,
    bool isConflict = false,
    required Widget child,
  }) {
    if (isMissed || isConflict) {
      return AccentCard(
        background: Colors.transparent,
        accentColor: isConflict ? SchooKeepColors.warning : SchooKeepColors.error,
        accentWidth: 3,
        radius: 12,
        padding: const EdgeInsets.all(12),
        borderColor: SchooKeepColors.border,
        child: child,
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: child,
    );
  }
}
