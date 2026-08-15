import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/bus_repository.dart';
import '../cubit/boarding_event_cubit.dart';

/// Ported from `BusStudentDeboarding.tsx`, now wired to
/// `POST /bus-routes/{routeId}/events` (type=deboarding). Confirming opens a
/// two-state dialog (confirm → sending) that records the event, then returns to
/// the route overview.
class BusStudentDeboardingScreen extends StatelessWidget {
  const BusStudentDeboardingScreen({
    super.key,
    required this.id,
    this.routeId,
    this.studentName,
    this.stopName,
  });

  final String id;
  final int? routeId;
  final String? studentName;
  final String? stopName;

  int get _studentId => int.tryParse(id) ?? 0;
  String get _name => (studentName ?? '').isNotEmpty ? studentName! : 'Student #$id';

  String get _currentTime {
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BoardingEventCubit(sl<BusRepository>()),
      child: Builder(builder: (context) {
        final firstName = _name.split(' ').first;
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            onBack: () => context.go('/bus/route'),
            title: 'Confirm Drop-off',
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                _studentCard(),
                const SizedBox(height: 24),
                _safetyNotice(),
                const SizedBox(height: 24),
                _parentNotice(firstName),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _openConfirmation(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.check, size: 24, color: Colors.white),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text('Confirm Safe Drop-off at Home',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => context.go('/bus/route'),
                    child: const Text('Cancel',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _openConfirmation(BuildContext context) {
    final cubit = context.read<BoardingEventCubit>();
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _DeboardingDialog(
          name: _name,
          currentTime: _currentTime,
          onConfirm: () => cubit.record(
            routeId: routeId ?? 0,
            studentId: _studentId,
            boarding: false,
            stopName: stopName,
          ),
        ),
      ),
    );
  }

  Widget _studentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(_initials(_name),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
          ),
          const SizedBox(height: 16),
          Text(_name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          if ((stopName ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.home, size: 16, color: SchooKeepColors.greenChipText),
                  const SizedBox(width: 8),
                  Text(stopName!,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.greenChipText)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _safetyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.check, size: 20, color: SchooKeepColors.warning),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safe Drop-off Confirmation',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText)),
                SizedBox(height: 4),
                Text(
                  'Only confirm when the student has safely exited the bus and is clear of the vehicle.',
                  style: TextStyle(fontSize: 12, color: SchooKeepColors.amberText, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _parentNotice(String firstName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.send, size: 20, color: SchooKeepColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Parent Notification',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF))),
                const SizedBox(height: 4),
                Text(
                  'The parent will receive: "$firstName has arrived home safely at $_currentTime"',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeboardingDialog extends StatelessWidget {
  const _DeboardingDialog({required this.name, required this.currentTime, required this.onConfirm});
  final String name;
  final String currentTime;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BoardingEventCubit, BoardingEventState>(
      listener: (context, state) {
        if (state is BoardingEventDone) {
          Navigator.of(context).pop();
          context.go('/bus/route');
        } else if (state is BoardingEventFailed) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final sending = state is BoardingEventSending;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 384),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: SchooKeepColors.surface, borderRadius: BorderRadius.circular(16)),
            child: sending ? _sendingState() : _confirmState(context),
          ),
        );
      },
    );
  }

  Widget _confirmState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: SchooKeepColors.greenChipBg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.home, size: 32, color: SchooKeepColors.accent),
        ),
        const SizedBox(height: 16),
        const Text('Confirm Safe Drop-off',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            children: [
              const TextSpan(text: 'Confirm '),
              TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' has safely arrived home at $currentTime?'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: SchooKeepColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SchooKeepColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onConfirm,
                  child: const Text('Confirm',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sendingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: SchooKeepColors.greenChipBg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.send, size: 32, color: SchooKeepColors.accent),
        ),
        const SizedBox(height: 16),
        const Text('Sending Notification...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 8),
        Text('Marking $name as dropped off',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
      ],
    );
  }
}
