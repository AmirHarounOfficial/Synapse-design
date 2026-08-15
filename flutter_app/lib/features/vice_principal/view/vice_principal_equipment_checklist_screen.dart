import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';
import '../../../data/models/equipment_item.dart';
import '../../../data/repositories/equipment_repository.dart';
import '../cubit/vice_principal_equipment_cubit.dart';

/// Ported from `VicePrincipalEquipmentChecklist.tsx`, wired to
/// `GET /equipment-items` via [VicePrincipalEquipmentCubit]. Renders the live
/// equipment list with an attention summary and category filter chips. Tapping
/// an item opens a status picker that calls `PUT /equipment-items/{id}` and
/// refreshes the list in place.
class VicePrincipalEquipmentChecklistScreen extends StatelessWidget {
  const VicePrincipalEquipmentChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VicePrincipalEquipmentCubit(sl<EquipmentRepository>()),
      child: const _EquipmentChecklistView(),
    );
  }
}

class _EquipmentChecklistView extends StatefulWidget {
  const _EquipmentChecklistView();

  @override
  State<_EquipmentChecklistView> createState() =>
      _EquipmentChecklistViewState();
}

class _EquipmentChecklistViewState extends State<_EquipmentChecklistView> {
  String _selectedCategory = 'all';

  static const _statusOptions = ['ok', 'low', 'expired', 'missing'];

  static bool _isOk(EquipmentItem i) => (i.status ?? 'ok') == 'ok';

  static (String label, Color bg, Color fg) _statusStyle(String? status) {
    switch (status) {
      case 'ok':
        return ('Up to date', const Color(0xFFD1FAE5), SchooKeepColors.accent);
      case 'low':
        return ('Low stock', SchooKeepColors.amberChipBg,
            SchooKeepColors.amberText);
      case 'expired':
        return ('Expired', const Color(0xFFFEE2E2), SchooKeepColors.error);
      case 'missing':
        return ('Missing', const Color(0xFFFEE2E2), SchooKeepColors.error);
      default:
        return ('Unknown', const Color(0xFFF1F5F9),
            SchooKeepColors.textSecondary);
    }
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _date(DateTime? dt) {
    if (dt == null) return 'Not recorded';
    final d = dt.toLocal();
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _reload() => context.read<VicePrincipalEquipmentCubit>().load();

  Future<void> _editStatus(EquipmentItem item) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set status — ${item.name}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 12),
              for (final option in _statusOptions)
                _statusOptionTile(sheetContext, item, option),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == item.status || !mounted) return;
    final error = await context
        .read<VicePrincipalEquipmentCubit>()
        .updateStatus(item.id, selected);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Status updated')),
    );
  }

  Widget _statusOptionTile(
      BuildContext sheetContext, EquipmentItem item, String option) {
    final (label, bg, fg) = _statusStyle(option);
    final current = (item.status ?? 'ok') == option;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(sheetContext).pop(option),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(999)),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: fg)),
              ),
              const Spacer(),
              if (current)
                const Icon(LucideIcons.check,
                    size: 18, color: SchooKeepColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: 'Equipment Checklist',
        onBack: () => context.safeBack(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: BlocBuilder<VicePrincipalEquipmentCubit,
          DataState<List<EquipmentItem>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _error(message),
            DataLoaded(:final data) => _content(data),
          };
        },
      ),
    );
  }

  Widget _content(List<EquipmentItem> all) {
    final categories = <String>{
      for (final i in all)
        if ((i.category ?? '').isNotEmpty) i.category!,
    }.toList()
      ..sort();
    final filtered = _selectedCategory == 'all'
        ? all
        : all.where((i) => i.category == _selectedCategory).toList();
    final actionNeeded = all.where((i) => !_isOk(i)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (actionNeeded > 0) ...[
          _attentionSummary(actionNeeded),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _categoryChip('all', 'All Items'),
              for (final c in categories) ...[
                const SizedBox(width: 8),
                _categoryChip(c, _humanize(c)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const SchooKeepCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No equipment items',
                    style: TextStyle(color: SchooKeepColors.textSecondary)),
              ),
            ),
          )
        else
          SchooKeepCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < filtered.length; i++) ...[
                  if (i > 0)
                    const Divider(
                        height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                  _equipmentRow(filtered[i]),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8)),
          child: const Text(
            'Tap an item to update its status. Changes are saved to the clinic equipment checklist.',
            style: TextStyle(
                fontSize: 12, height: 1.5, color: SchooKeepColors.textSecondary),
          ),
        ),
      ],
    );
  }

  static String _humanize(String raw) {
    if (raw.isEmpty) return raw;
    final spaced = raw.replaceAll('_', ' ').replaceAll('-', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  Widget _attentionSummary(int count) {
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
            child: Icon(LucideIcons.alertTriangle,
                size: 20, color: SchooKeepColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '$count ${count == 1 ? 'item requires' : 'items require'} attention',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.amberText)),
                const SizedBox(height: 4),
                const Text(
                    'Review items below marked low, expired or missing',
                    style: TextStyle(
                        fontSize: 12, color: SchooKeepColors.amberText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String id, String label) {
    final selected = _selectedCategory == id;
    return Material(
      color: selected ? SchooKeepColors.primary : SchooKeepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: selected
            ? BorderSide.none
            : const BorderSide(color: SchooKeepColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _selectedCategory = id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : SchooKeepColors.textSecondary)),
          ),
        ),
      ),
    );
  }

  Widget _equipmentRow(EquipmentItem item) {
    final ok = _isOk(item);
    final (statusLabel, badgeBg, badgeFg) = _statusStyle(item.status);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _editStatus(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ok
                      ? const Color(0xFFD1FAE5)
                      : SchooKeepColors.amberChipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ok ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
                  size: 20,
                  color: ok ? SchooKeepColors.accent : SchooKeepColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: SchooKeepColors.textPrimary)),
                    if ((item.category ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(_humanize(item.category!),
                          style: const TextStyle(
                              fontSize: 12,
                              color: SchooKeepColors.textSecondary)),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: badgeFg)),
                    ),
                    if ((item.location ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _metaRow(LucideIcons.mapPin, item.location!),
                    ],
                    const SizedBox(height: 8),
                    _metaRow(LucideIcons.calendar,
                        'Last checked: ${_date(item.lastCheckedAt)}'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const RtlIcon(LucideIcons.chevronRight,
                  size: 20, color: SchooKeepColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: SchooKeepColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12, color: SchooKeepColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _error(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.error),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertCircle,
                  size: 20, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 13,
                        color: SchooKeepColors.error,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SchooKeepButton(
            label: 'Retry', fullWidth: false, onPressed: _reload),
      ],
    );
  }
}
