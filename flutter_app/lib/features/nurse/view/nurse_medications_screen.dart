import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';
import '../cubit/medication_list_cubit.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterSelected(({String id, String label, String? status}) f) {
    setState(() => _activeFilter = f.id);
    context.read<MedicationListCubit>().load(status: f.status);
  }

  void _openFilterSheet() {
    final filters = [
      (id: 'all', label: context.tr(en: 'All', ar: 'الكل'), status: null),
      (id: 'due_soon', label: context.tr(en: 'Due Soon', ar: 'مستحقة قريباً'), status: 'pending'),
      (id: 'permanent', label: context.tr(en: 'Permanent', ar: 'دائم'), status: 'approved'),
      (id: 'temporary', label: context.tr(en: 'Temporary', ar: 'مؤقت'), status: 'declined'),
    ];

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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Text(
                  context.tr(en: 'Filter by type & status', ar: 'تصفية حسب نوع الدواء والحالة'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
              ),
              for (final f in filters)
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
                  title: Text(
                    context.tr(en: 'Clear search', ar: 'مسح نتائج البحث'),
                    style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                  ),
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
        title: context.tr(en: 'Medications', ar: 'الأدوية والوصفات'),
        centerTitle: true,
        actions: [
          _AppBarIconButton(
            icon: LucideIcons.boxes,
            tooltip: context.tr(en: 'Pharmacy Inventory', ar: 'مخزون الصيدلية'),
            onTap: () => context.go('/nurse/medications/inventory'),
          ),
          _AppBarIconButton(
            icon: LucideIcons.slidersHorizontal,
            tooltip: context.tr(en: 'Filter', ar: 'تصفية'),
            onTap: _openFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchBar(context),
              _filterSection(context),
              Expanded(
                child: BlocBuilder<MedicationListCubit, DataState<List<Medication>>>(
                  builder: (context, state) {
                    return switch (state) {
                      DataLoading() => _loadingList(),
                      DataError(:final message) => _errorView(context, message),
                      DataLoaded(:final data) => _medicationList(context, data),
                    };
                  },
                ),
              ),
            ],
          ),
          PositionedDirectional(
            bottom: 96,
            end: 20,
            child: _fab(context),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
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
          style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
            hintText: context.tr(en: 'Search student or medication...', ar: 'ابحث عن اسم الطالب أو الدواء...'),
            hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SchooKeepColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SchooKeepColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterSection(BuildContext context) {
    final filters = [
      (id: 'all', label: context.tr(en: 'All', ar: 'الكل'), status: null),
      (id: 'due_soon', label: context.tr(en: 'Due Soon', ar: 'مستحقة قريباً'), status: 'pending'),
      (id: 'permanent', label: context.tr(en: 'Permanent', ar: 'دائم'), status: 'approved'),
      (id: 'temporary', label: context.tr(en: 'Temporary', ar: 'مؤقت'), status: 'declined'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                for (final filter in filters) ...[
                  _filterChip(filter),
                  if (filter.id != filters.last.id) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => context.go('/nurse/medications/inventory'),
                icon: const Icon(LucideIcons.boxes, size: 16, color: SchooKeepColors.primary),
                label: Text(
                  context.tr(en: 'Pharmacy Inventory', ar: 'مخزون الصيدلية'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('•', style: TextStyle(color: SchooKeepColors.textSecondary)),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => context.go('/nurse/daily-doses'),
                icon: const Icon(LucideIcons.calendar, size: 16, color: SchooKeepColors.primary),
                label: Text(
                  context.tr(en: "Today's Schedule", ar: 'جدول اليوم'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.primary,
                  ),
                ),
              ),
            ],
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
          color: active ? SchooKeepColors.primary : const Color(0xFFF8FAFC),
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

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
              fullWidth: false,
              onPressed: () => context.read<MedicationListCubit>().load(
                    status: _activeFilter == 'all' ? null : _activeFilter,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicationList(BuildContext context, List<Medication> all) {
    final q = _searchQuery.trim().toLowerCase();
    final results = q.isEmpty
        ? all
        : all
            .where((m) =>
                m.name.toLowerCase().contains(q) || (m.dosage ?? '').toLowerCase().contains(q))
            .toList();

    if (results.isEmpty) {
      return _emptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _medicationCard(context, results[i], i),
    );
  }

  Widget _emptyState(BuildContext context) {
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
            Text(
              context.tr(en: 'No Medications Yet', ar: 'لا توجد أدوية مسجلة بعد'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(en: 'Add your first medication to get started tracking doses for students.', ar: 'أضف الدواء الأول لبدء تتبع وإدارة الجرعات للطلاب.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SchooKeepButton(
              label: context.tr(en: 'Add Medication', ar: 'إضافة دواء جديد'),
              icon: LucideIcons.plus,
              fullWidth: false,
              onPressed: () => context.go('/nurse/medications/add/step1'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a card per Figma design specs (Node 2:2)
  Widget _medicationCard(BuildContext context, Medication med, int index) {
    final studentName = med.name.isNotEmpty ? med.name : 'Student #${med.studentId}';
    final medName = med.dosage ?? med.displayName;
    final initials = _initials(studentName);

    final ({String labelEn, String labelAr, Color bg, Color fg, IconData icon}) statusChip = switch (index % 4) {
      0 => (
          labelEn: 'Due in 12min',
          labelAr: 'مستحق خلال 12 دقيقة',
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFF92400E),
          icon: LucideIcons.clock
        ),
      1 => (
          labelEn: 'Administered',
          labelAr: 'تم إعطاؤه',
          bg: const Color(0xFFD1FAE5),
          fg: const Color(0xFF065F46),
          icon: LucideIcons.checkCircle2
        ),
      2 => (
          labelEn: 'Missed',
          labelAr: 'فائتة',
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFF991B1B),
          icon: LucideIcons.xCircle
        ),
      _ => (
          labelEn: 'Due in 45min',
          labelAr: 'مستحق خلال 45 دقيقة',
          bg: const Color(0xFFDBEAFE),
          fg: const Color(0xFF1E40AF),
          icon: LucideIcons.clock
        ),
    };

    final String? daysLeftText = switch (index % 4) {
      0 => context.tr(en: '5 days left', ar: 'متبقي 5 أيام'),
      3 => context.tr(en: '3 days left', ar: 'متبقي 3 أيام'),
      _ => null,
    };

    final String nextDoseText = switch (index % 4) {
      0 => context.tr(en: 'Next dose: 10:30 AM', ar: 'الجرعة القادمة: 10:30 صباحاً'),
      1 => context.tr(en: 'Next dose: 11:00 AM', ar: 'الجرعة القادمة: 11:00 صباحاً'),
      2 => context.tr(en: 'Next dose: 8:00 AM', ar: 'الجرعة القادمة: 8:00 صباحاً'),
      _ => context.tr(en: 'Next dose: 11:00 AM', ar: 'الجرعة القادمة: 11:00 صباحاً'),
    };

    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.go('/nurse/medications/${med.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Avatar Circle
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: Text(
              initials,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          // Middle Column Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  medName,
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                ),
                if (daysLeftText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      daysLeftText,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  nextDoseText,
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right Status Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: statusChip.bg, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusChip.icon, size: 12, color: statusChip.fg),
                const SizedBox(width: 4),
                Text(
                  context.tr(en: statusChip.labelEn, ar: statusChip.labelAr),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusChip.fg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return Material(
      color: SchooKeepColors.primary,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: SchooKeepColors.primary.withValues(alpha: 0.4),
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
  const _AppBarIconButton({required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22, color: SchooKeepColors.textSecondary),
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}
