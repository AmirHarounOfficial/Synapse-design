import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/bus_boarding_event.dart';
import '../../../data/repositories/bus_repository.dart';
import '../cubit/bus_history_cubit.dart';

/// Ported from `BusRouteHistory.tsx`, now wired to the bus-routes API (each
/// route's `events`). Date header, a two-column summary (boardings / drop-offs),
/// and grouped event lists.
class BusRouteHistoryScreen extends StatelessWidget {
  const BusRouteHistoryScreen({super.key});

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static String get _todaysDate {
    final now = DateTime.now();
    return '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  static String _formatTime(BusBoardingEvent e) {
    final dt = e.occurredAtDate?.toLocal();
    if (dt == null) return '--';
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BusHistoryCubit(sl<BusRepository>()),
      child: BlocBuilder<BusHistoryCubit, DataState<List<BusBoardingEvent>>>(
        builder: (context, state) {
          return SchooKeepScaffold(
            reserveBottomNav: true,
            scrollable: state is DataLoaded<List<BusBoardingEvent>>,
            appBar: SchooKeepAppBar(
              titleWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Route History',
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
                onPressed: () => context.read<BusHistoryCubit>().load(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(List<BusBoardingEvent> events) {
    final boardings = events.where((e) => e.isBoarding).toList();
    final dropoffs = events.where((e) => !e.isBoarding).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summary(boardings.length, dropoffs.length),
          const SizedBox(height: 16),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No route events logged yet.',
                    style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
              ),
            ),
          if (dropoffs.isNotEmpty) ...[
            _sectionHeader('DROP-OFFS (${dropoffs.length})'),
            const SizedBox(height: 12),
            for (final e in dropoffs) ...[
              _eventCard(e),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
          ],
          if (boardings.isNotEmpty) ...[
            _sectionHeader('BOARDINGS (${boardings.length})'),
            const SizedBox(height: 12),
            for (final e in boardings) ...[
              _eventCard(e),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
          ],
          _infoNotice(),
        ],
      ),
    );
  }

  Widget _summary(int boardings, int dropoffs) {
    return SchooKeepCard(
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _summaryCell('$boardings', 'Boardings')),
            const VerticalDivider(width: 1, color: SchooKeepColors.border),
            Expanded(child: _summaryCell('$dropoffs', 'Drop-offs')),
          ],
        ),
      ),
    );
  }

  Widget _summaryCell(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
      ],
    );
  }

  Widget _sectionHeader(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.5));
  }

  Widget _eventCard(BusBoardingEvent e) {
    final isBoarding = e.isBoarding;
    final studentName = e.student?.name ?? 'Student #${e.studentId}';
    return SchooKeepCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isBoarding ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(isBoarding ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                size: 20, color: isBoarding ? SchooKeepColors.primary : SchooKeepColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Text('${e.stopName ?? 'Stop —'} — ${isBoarding ? 'Boarding' : 'Drop-off'}',
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                if (e.parentNotified) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isBoarding ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Parent notified',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isBoarding ? const Color(0xFF1E40AF) : SchooKeepColors.greenChipText)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_formatTime(e),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _infoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: const Text(
        'All boarding and drop-off events are logged with automatic parent notifications. Historical records available in the driver portal.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
      ),
    );
  }
}
