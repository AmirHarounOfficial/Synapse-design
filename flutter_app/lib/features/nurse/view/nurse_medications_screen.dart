import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';
import '../cubit/medication_list_cubit.dart';

/// Ported from `NurseMedications.tsx`, now wired to the API (`GET /medications`).
/// Tab-root medications list with a search field, status filter chips, a "view
/// today's schedule" link, loading/error(retry)/empty states and a floating add
/// button. The search field filters the loaded page client-side; the status
/// chips reload from the backend with a `status=` query.
class NurseMedicationsScreen extends StatelessWidget {
  const NurseMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicationListCubit(sl<MedicationRepository>()),
      child: const _NurseMedicationsView(),
    );
  }
}

class _NurseMedicationsView extends StatefulWidget {
  const _NurseMedicationsView();

  @override
  State<_NurseMedicationsView> createState() => _NurseMedicationsViewState();
}

class _NurseMedicationsViewState extends State<_NurseMedicationsView> {
  String _activeFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Maps the UI filter chips to a backend `status` value (or null for client
  // side / no filter). The API status field is freeform; these map to it.
  static const List<({String id, String label, String? status})> _filters = [
    (id: 'all', label: 'All', status: null),
    (id: 'pending', label: 'Pending', status: 'pending'),
    (id: 'approved', label: 'Approved', status: 'approved'),
    (id: 'declined', label: 'Declined', status: 'declined'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterSelected(({String id, String label, String? status}) f) {
    setState(() => _activeFilter = f.id);
    context.read<MedicationListCubit>().load(status: f.status);
  }

  /// Filter icon in the app bar — opens a bottom sheet mirroring the status
  /// chips, plus a quick clear-search action, for a more discoverable filter UI.
  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SchooKeepColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Text('Filter by status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              ),
              for (final f in _filters)
                ListTile(
                  leading: Icon(
                    _activeFilter == f.id ? LucideIcons.checkCircle : LucideIcons.circle,
                    size: 20,
                    color: _activeFilter == f.id ? SchooKeepColors.primary : SchooKeepColors.textSecondary,
                  ),
                  title: Text(f.label,
                      style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _onFilterSelected(f);
                  },
                ),
              if (_searchQuery.isNotEmpty)
                ListTile(
                  leading: const Icon(LucideIcons.x, size: 20, color: SchooKeepColors.textSecondary),
                  title: const Text('Clear search',
                      style: TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  (Color, Color) _statusStyle(String? status) {
    switch (status) {
      case 'approved':
      case 'active':
        return (SchooKeepColors.greenChipBg, SchooKeepColors.greenChipText);
      case 'declined':
        return (const Color(0xFFFEE2E2), const Color(0xFF991B1B));
      case 'pending':
        return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText);
      default:
        return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF));
    }
  }

  IconData? _statusIcon(String? status) {
    switch (status) {
      case 'approved':
      case 'active':
        return LucideIcons.checkCircle;
      case 'declined':
        return LucideIcons.x;
      case 'pending':
        return LucideIcons.clock;
      default:
        return null;
    }
  }

  String _statusLabel(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: 'Medications',
        centerTitle: true,
        actions: [
          _AppBarIconButton(
            icon: LucideIcons.slidersHorizontal,
            onTap: _openFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchBar(),
              _filterSection(),
              Expanded(
                child: BlocBuilder<MedicationListCubit, DataState<List<Medication>>>(
                  builder: (context, state) {
                    return switch (state) {
                      DataLoading() => _loadingList(),
                      DataError(:final message) => _errorView(message),
                      DataLoaded(:final data) => _medicationList(data),
                    };
                  },
                ),
              ),
            ],
          ),
          PositionedDirectional(
            bottom: 100,
            end: 24,
            child: _fab(),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
            hintText: 'Search student or medication…',
            hintStyle: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            filled: true,
            fillColor: SchooKeepColors.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SchooKeepColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in _filters) ...[
                  _filterChip(filter),
                  if (filter.id != _filters.last.id) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => context.go('/nurse/daily-doses'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.calendar, size: 16, color: SchooKeepColors.primary),
                  SizedBox(width: 8),
                  Text(
                    "View Today's Dose Schedule",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(({String id, String label, String? status}) f) {
    final active = _activeFilter == f.id;
    return GestureDetector(
      onTap: () => _onFilterSelected(f),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : SchooKeepColors.background,
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: SchooKeepColors.border),
        ),
        child: Text(
          f.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : SchooKeepColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _loadingList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            const _LoadingSkeleton(),
            if (i < 3) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _errorView(String message) {
    return Center(
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
              onPressed: () => context.read<MedicationListCubit>().load(
                    status: _filters.firstWhere((f) => f.id == _activeFilter).status,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicationList(List<Medication> all) {
    final q = _searchQuery.trim().toLowerCase();
    final results = q.isEmpty
        ? all
        : all
            .where((m) =>
                m.name.toLowerCase().contains(q) || (m.dosage ?? '').toLowerCase().contains(q))
            .toList();

    if (results.isEmpty) {
      return _emptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _medicationCard(results[i]),
    );
  }

  Widget _emptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
              child: const Icon(LucideIcons.pill, size: 32, color: SchooKeepColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Medications Yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first medication to get started tracking doses for students.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SchooKeepButton(
              label: 'Add Medication',
              icon: LucideIcons.plus,
              fullWidth: false,
              onPressed: () => context.go('/nurse/medications/add/step1'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicationCard(Medication med) {
    final (bg, fg) = _statusStyle(med.status);
    final icon = _statusIcon(med.status);
    // The API exposes a student_id but not the student name on this list; show
    // the medication name as the primary line and dosage as secondary.
    final title = med.name;
    final subtitle = med.dosage ?? '';
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.go('/nurse/medications/${med.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: Text(
              _initials(med.name),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                  ),
                ],
                if (med.isLowSupply) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: SchooKeepColors.amberChipBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${med.supplyCount} doses left',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText),
                    ),
                  ),
                ],
                if (med.doses.isNotEmpty && med.doses.first.scheduledTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Next dose: ${med.doses.first.scheduledTime}',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 4)],
                Text(
                  _statusLabel(med.status),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fab() {
    return Material(
      color: SchooKeepColors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.go('/nurse/medications/add/step1'),
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(LucideIcons.plus, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: SchooKeepColors.border, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 128, height: 16, color: SchooKeepColors.border),
                const SizedBox(height: 8),
                Container(width: 192, height: 12, color: SchooKeepColors.border),
                const SizedBox(height: 8),
                Container(width: 96, height: 12, color: SchooKeepColors.border),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 24,
            decoration: BoxDecoration(color: SchooKeepColors.border, borderRadius: BorderRadius.circular(999)),
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 24, color: SchooKeepColors.textSecondary),
      ),
    );
  }
}
