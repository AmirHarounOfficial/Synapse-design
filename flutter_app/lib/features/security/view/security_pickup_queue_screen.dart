import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/pickup.dart';
import '../../../data/repositories/pickup_repository.dart';
import '../cubit/pickup_queue_cubit.dart';

/// Ported from `SecurityPickupQueue.tsx`, now wired to `GET /pickups`. Lists
/// verified (ready) and pending student pickups with a pending-count badge.
class SecurityPickupQueueScreen extends StatelessWidget {
  const SecurityPickupQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PickupQueueCubit(sl<PickupRepository>()),
      child: const _PickupQueueView(),
    );
  }
}

class _PickupQueueView extends StatelessWidget {
  const _PickupQueueView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickupQueueCubit, DataState<List<Pickup>>>(
      builder: (context, state) {
        final pendingCount = state is DataLoaded<List<Pickup>>
            ? state.data.where((p) => p.isPending).length
            : 0;
        return SchooKeepScaffold(
          reserveBottomNav: true,
          scrollable: state is DataLoaded<List<Pickup>>,
          appBar: SchooKeepAppBar(
            title: 'Student Pickups',
            actions: [
              if (pendingCount > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 28),
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: SchooKeepColors.error,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Text('$pendingCount',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          body: switch (state) {
            DataLoading() => const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              ),
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: SchooKeepColors.textSecondary)),
              const SizedBox(height: 16),
              SchooKeepButton(
                label: 'Retry',
                fullWidth: false,
                onPressed: () => context.read<PickupQueueCubit>().load(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<Pickup> pickups) {
    final approved = pickups.where((p) => p.isVerified).toList();
    final pending = pickups.where((p) => p.isPending).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pickups.isEmpty) _emptyState(),
          if (approved.isNotEmpty) ...[
            _sectionLabel('APPROVED — READY FOR PICKUP (${approved.length})'),
            const SizedBox(height: 12),
            for (final p in approved) ...[
              _approvedCard(p),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
          ],
          if (pending.isNotEmpty) ...[
            _sectionLabel('PENDING VERIFICATION (${pending.length})'),
            const SizedBox(height: 12),
            for (final p in pending) ...[
              _pendingCard(context, p),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  static String _personLabel(Pickup p) {
    final person = p.authorizedPerson;
    if (person == null) return 'Authorized pickup person';
    final rel = (person.relationship ?? '').isNotEmpty ? ' (${person.relationship})' : '';
    return '${person.name}$rel';
  }

  static String _gradeLabel(Pickup p) {
    final s = p.student;
    if (s == null) return '';
    final parts = [
      if ((s.grade ?? '').isNotEmpty) 'Grade ${s.grade}',
      if ((s.section ?? '').isNotEmpty) s.section,
    ].whereType<String>().toList();
    return parts.join(' • ');
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: SchooKeepColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );

  Widget _nameRow(Pickup p) => Row(
        children: [
          Flexible(
            child: Text(p.student?.name ?? 'Student #${p.studentId}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
        ],
      );

  Widget _pickupBy(Pickup p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expected pickup by:',
              style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 4),
          Text(_personLabel(p),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
        ],
      );

  Widget _approvedCard(Pickup p) => SchooKeepCard(
        borderColor: SchooKeepColors.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _nameRow(p),
                      const SizedBox(height: 4),
                      Text(_gradeLabel(p), style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Row(
                  children: [
                    Icon(LucideIcons.check, size: 20, color: SchooKeepColors.accent),
                    SizedBox(width: 6),
                    Text('Verified',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.accent)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            _pickupBy(p),
          ],
        ),
      );

  Widget _pendingCard(BuildContext context, Pickup p) => SchooKeepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _nameRow(p),
                const SizedBox(height: 4),
                Text(_gradeLabel(p), style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            _pickupBy(p),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => context.go('/security/scanner'),
                child: const Text('Verify Identity',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ],
        ),
      );

  Widget _emptyState() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, size: 32, color: SchooKeepColors.accent),
              ),
              const SizedBox(height: 16),
              const Text('No Pending Pickups',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              const SizedBox(
                width: 280,
                child: Text(
                  'All students have been picked up or are in their scheduled locations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
}
