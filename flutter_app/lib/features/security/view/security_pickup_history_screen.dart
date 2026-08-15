import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/pickup.dart';
import '../../../data/repositories/pickup_repository.dart';
import '../cubit/pickup_history_cubit.dart';

/// Ported from `SecurityPickupHistory.tsx`, now wired to
/// `GET /pickups?status=released`. Summary header (total + QR-verified counts)
/// over the list of logged release records.
class SecurityPickupHistoryScreen extends StatelessWidget {
  const SecurityPickupHistoryScreen({super.key});

  static const List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String get _todaysDate {
    final now = DateTime.now();
    return '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  static String _formatTime(String? iso) {
    final dt = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '--';
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PickupHistoryCubit(sl<PickupRepository>()),
      child: BlocBuilder<PickupHistoryCubit, DataState<List<Pickup>>>(
        builder: (context, state) {
          return SchooKeepScaffold(
            reserveBottomNav: true,
            scrollable: state is DataLoaded<List<Pickup>>,
            appBar: SchooKeepAppBar(
              titleWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pickup History',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  Text(_todaysDate, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
            body: switch (state) {
              DataLoading() => const SizedBox(height: 400, child: Center(child: CircularProgressIndicator())),
              DataError(:final message) => _errorView(context, message),
              DataLoaded(:final data) => _content(data),
            },
          );
        },
      ),
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
                onPressed: () => context.read<PickupHistoryCubit>().load(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(List<Pickup> records) {
    final qrCount = records.where((r) => r.isQr).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SchooKeepCard(
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _stat('${records.length}', 'Total Pickups', SchooKeepColors.textPrimary)),
                  const VerticalDivider(width: 1, color: SchooKeepColors.border),
                  Expanded(child: _stat('$qrCount', 'QR Verified', SchooKeepColors.accent)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('PICKUP RECORDS (${records.length})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SchooKeepColors.textSecondary,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 12),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No releases logged today.',
                    style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
              ),
            )
          else
            for (final r in records) ...[
              _recordCard(r),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SchooKeepColors.background,
              border: Border.all(color: SchooKeepColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'All pickup records are permanently logged for security and compliance. Historical records available in the administration portal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color valueColor) => Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        ],
      );

  Widget _recordCard(Pickup r) {
    final studentName = r.student?.name ?? 'Student #${r.studentId}';
    final person = r.authorizedPerson;
    final releasedTo = person?.name ?? 'Authorized person';
    final relationship = person?.relationship ?? '';
    return SchooKeepCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Released to $releasedTo',
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    if (relationship.isNotEmpty)
                      Text(relationship, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatTime(r.releasedAt),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 4),
                  _methodChip(r.isQr),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                    r.securityGuardId != null ? 'Verified by guard #${r.securityGuardId}' : 'Verified by security',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: SchooKeepColors.greenChipBg,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(),
                    SizedBox(width: 4),
                    Text('Released',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.greenChipText)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _methodChip(bool qr) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: qr ? SchooKeepColors.greenChipBg : const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(qr ? LucideIcons.scanLine : LucideIcons.check,
                size: 14, color: qr ? SchooKeepColors.greenChipText : const Color(0xFF1E40AF)),
            const SizedBox(width: 6),
            Text(qr ? 'QR' : 'Manual',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: qr ? SchooKeepColors.greenChipText : const Color(0xFF1E40AF),
                )),
          ],
        ),
      );
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
      );
}
