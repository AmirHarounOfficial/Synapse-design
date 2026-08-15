import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/meal.dart';
import '../../../data/repositories/cafeteria_repository.dart';
import '../cubit/meal_list_cubit.dart';

/// Ported from `CafeteriaDeliveryHistory.tsx`, now wired to the API. The backend
/// has no dedicated delivery-log endpoint, so this date-grouped log is sourced
/// from the meals served (`GET /meals`, ordered by date desc). The Export action
/// stays a local-only stub (no export endpoint exists). English-only, as in the
/// source.
class CafeteriaDeliveryHistoryScreen extends StatelessWidget {
  const CafeteriaDeliveryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MealListCubit(sl<CafeteriaRepository>()),
      child: const _CafeteriaDeliveryHistoryView(),
    );
  }
}

class _CafeteriaDeliveryHistoryView extends StatefulWidget {
  const _CafeteriaDeliveryHistoryView();

  @override
  State<_CafeteriaDeliveryHistoryView> createState() => _CafeteriaDeliveryHistoryViewState();
}

class _CafeteriaDeliveryHistoryViewState extends State<_CafeteriaDeliveryHistoryView> {
  bool _isExporting = false;

  void _handleExport() {
    setState(() => _isExporting = true);
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isExporting = false);
    });
  }

  static String _groupLabel(String? date) {
    if (date == null || date.isEmpty) return 'Undated';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    final today = DateTime.now();
    final d = DateTime(parsed.year, parsed.month, parsed.day);
    final t = DateTime(today.year, today.month, today.day);
    final diff = t.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  Map<String, List<Meal>> _group(List<Meal> meals) {
    final groups = <String, List<Meal>>{};
    for (final m in meals) {
      groups.putIfAbsent(_groupLabel(m.date), () => []).add(m);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Delivery History',
        actions: [
          InkWell(
            onTap: _isExporting ? null : _handleExport,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _isExporting
                    ? const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: SchooKeepColors.primary),
                        ),
                        SizedBox(width: 8),
                        Text('Exporting...',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                      ]
                    : const [
                        Icon(LucideIcons.download, size: 20, color: SchooKeepColors.primary),
                        SizedBox(width: 8),
                        Text('Export',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                      ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.fileText, size: 20, color: SchooKeepColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This log is maintained for Section 504 documentation and compliance purposes.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<MealListCubit, DataState<List<Meal>>>(
              builder: (context, state) {
                return switch (state) {
                  DataLoading() => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  DataError(:final message) => _errorView(message),
                  DataLoaded(:final data) => _list(data),
                };
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: 'Retry',
              fullWidth: false,
              onPressed: () => context.read<MealListCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<Meal> meals) {
    if (meals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No delivery records', style: TextStyle(color: SchooKeepColors.textSecondary)),
        ),
      );
    }
    final grouped = _group(meals);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          Text(
            entry.key.toUpperCase(),
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          for (final meal in entry.value) ...[
            _recordCard(meal),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _recordCard(Meal meal) {
    final tags = <String>[
      if (meal.isHalal) 'Halal',
      ...meal.allergens,
    ];
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
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
                    Text(meal.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(tags.join(' • '), style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  meal.halalCertified ? 'Halal-certified' : 'Served',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: SchooKeepColors.greenChipBg, borderRadius: BorderRadius.circular(999)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 6,
                      height: 6,
                      child: DecoratedBox(decoration: BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle)),
                    ),
                    SizedBox(width: 4),
                    Text('Delivered',
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
}
