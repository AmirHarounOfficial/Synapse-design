import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../cubit/clinic_visit_list_cubit.dart';

class ClinicVisitListScreen extends StatelessWidget {
  const ClinicVisitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicVisitListCubit(sl<ClinicRepository>()),
      child: const _ClinicVisitListView(),
    );
  }
}

class _ClinicVisitListView extends StatefulWidget {
  const _ClinicVisitListView();

  @override
  State<_ClinicVisitListView> createState() => _ClinicVisitListViewState();
}

class _ClinicVisitListViewState extends State<_ClinicVisitListView> {
  String _activeFilter = 'today';
  DateTime? _selectedDate;
  bool _withNotesOnly = false;

  static Color _avatarColor(int seed) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
    ];
    return colors[seed.abs() % colors.length];
  }

  static String _category(BuildContext context, ClinicVisit v) {
    if (v.isEmergency) return context.tr(en: 'Emergency', ar: 'طوارئ');
    final s = (v.severity ?? '').toLowerCase();
    if (s.contains('injur')) return context.tr(en: 'Injury', ar: 'إصابة');
    if (s.contains('illness') || s.contains('ill')) return context.tr(en: 'Illness', ar: 'مرض');
    if (s.contains('medic')) return context.tr(en: 'Medication', ar: 'دواء');
    return context.tr(en: 'Routine', ar: 'روتينية');
  }

  static (Color bg, Color fg) _categoryStyle(String category, BuildContext context) {
    if (category == context.tr(en: 'Emergency', ar: 'طوارئ')) {
      return (const Color(0xFFFEE2E2), SchooKeepColors.error);
    } else if (category == context.tr(en: 'Injury', ar: 'إصابة')) {
      return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText);
    } else if (category == context.tr(en: 'Illness', ar: 'مرض')) {
      return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF));
    } else if (category == context.tr(en: 'Medication', ar: 'دواء')) {
      return (const Color(0xFFE0E7FF), const Color(0xFF4338CA));
    } else {
      return (SchooKeepColors.greenChipBg, SchooKeepColors.greenChipText);
    }
  }

  static String _time(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final h12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${h12.toString().padLeft(2, '0')}:$m $ampm';
  }

  bool _matchesFilter(ClinicVisit v) {
    if (_withNotesOnly && (v.notes ?? '').isEmpty) return false;
    if (_selectedDate != null) {
      if (v.visitedAt == null) return false;
      final d = v.visitedAt!.toLocal();
      final sel = _selectedDate!;
      return d.year == sel.year && d.month == sel.month && d.day == sel.day;
    }
    switch (_activeFilter) {
      case 'emergency':
        return v.isEmergency;
      case 'routine':
        return !v.isEmergency;
      case 'week':
        if (v.visitedAt == null) return true;
        return v.visitedAt!.isAfter(
          DateTime.now().subtract(const Duration(days: 7)),
        );
      case 'today':
      default:
        if (v.visitedAt == null) return true;
        final now = DateTime.now();
        final d = v.visitedAt!.toLocal();
        return d.year == now.year && d.month == now.month && d.day == now.day;
    }
  }

  void _reload() => context.read<ClinicVisitListCubit>().load();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: context.tr(en: 'Filter visits by date', ar: 'تصفية الزيارات حسب التاريخ'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _dateBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEFF6FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(LucideIcons.calendar, size: 16, color: SchooKeepColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr(en: 'Showing ${_formatDate(_selectedDate!)}', ar: 'عرض زيارات بتاريخ ${_formatDate(_selectedDate!)}'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SchooKeepColors.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedDate = null),
            child: Text(
              context.tr(en: 'Clear', ar: 'مسح'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SchooKeepColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet() {
    final filters = [
      (id: 'today', label: context.tr(en: 'Today', ar: 'اليوم')),
      (id: 'week', label: context.tr(en: 'This Week', ar: 'هذا الأسبوع')),
      (id: 'emergency', label: context.tr(en: 'Emergency', ar: 'طوارئ')),
      (id: 'routine', label: context.tr(en: 'Routine', ar: 'روتينية')),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(en: 'Filter visits', ar: 'تصفية زيارات العيادة'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: SchooKeepColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(sheetContext).pop(),
                        child: Text(
                          context.tr(en: 'Close', ar: 'إغلاق'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: SchooKeepColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(en: 'Category', ar: 'التصنيف'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: SchooKeepColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in filters)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeFilter = f.id;
                              _selectedDate = null;
                            });
                            setSheetState(() {});
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _activeFilter == f.id
                                  ? SchooKeepColors.primary
                                  : SchooKeepColors.background,
                              borderRadius: BorderRadius.circular(999),
                              border: _activeFilter == f.id
                                  ? null
                                  : Border.all(color: SchooKeepColors.border),
                            ),
                            child: Text(
                              f.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _activeFilter == f.id
                                    ? Colors.white
                                    : SchooKeepColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: Colors.white,
                    activeTrackColor: SchooKeepColors.primary,
                    title: Text(
                      context.tr(en: 'With notes only', ar: 'التي تحتوي ملاحظات فقط'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textPrimary,
                      ),
                    ),
                    value: _withNotesOnly,
                    onChanged: (v) {
                      setState(() => _withNotesOnly = v);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  SchooKeepButton(
                    label: context.tr(en: 'Apply', ar: 'تطبيق التصفية'),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Clinic Visits', ar: 'سجل زيارات العيادة المدرسية'),
        actions: [
          _IconButton(icon: LucideIcons.calendar, onTap: _pickDate),
          _IconButton(icon: LucideIcons.slidersHorizontal, onTap: _openFilterSheet),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _filterBar(context),
            if (_selectedDate != null) _dateBanner(context),
            BlocBuilder<ClinicVisitListCubit, DataState<List<ClinicVisit>>>(
              builder: (context, state) {
                return switch (state) {
                  DataLoading() => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  DataError(:final message) => _errorBanner(context, message),
                  DataLoaded(:final data) => _list(context, data),
                };
              },
            ),
          ],
        ),
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 16, left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: SchooKeepColors.primary,
              foregroundColor: Colors.white,
              onPressed: () async {
                await context.push('/nurse/clinic/new-visit');
                if (context.mounted) _reload();
              },
              child: const Icon(LucideIcons.plus, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<ClinicVisit> all) {
    final visits = all.where(_matchesFilter).toList();
    if (visits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Text(
            context.tr(en: 'No clinic visits found', ar: 'لا توجد زيارات مسجلة'),
            style: const TextStyle(color: SchooKeepColors.textSecondary),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.tr(
                  en: '${visits.length} ${visits.length == 1 ? 'visit' : 'visits'}',
                  ar: '${visits.length} زيارة مسجلة',
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: SchooKeepColors.textSecondary,
                ),
              ),
            ),
          ),
          for (final v in visits) ...[
            _visitCard(context, v),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _filterBar(BuildContext context) {
    final filters = [
      (id: 'today', label: context.tr(en: 'Today', ar: 'اليوم')),
      (id: 'week', label: context.tr(en: 'This Week', ar: 'هذا الأسبوع')),
      (id: 'emergency', label: context.tr(en: 'Emergency', ar: 'طوارئ')),
      (id: 'routine', label: context.tr(en: 'Routine', ar: 'روتينية')),
    ];
    return Container(
      width: double.infinity,
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in filters) ...[
              _filterChip(f.id, f.label),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final active = _activeFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = id),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : SchooKeepColors.background,
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: SchooKeepColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : SchooKeepColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
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
                const Icon(
                  LucideIcons.alertCircle,
                  size: 20,
                  color: SchooKeepColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 13,
                      color: SchooKeepColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SchooKeepButton(label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'), fullWidth: false, onPressed: _reload),
        ],
      ),
    );
  }

  Widget _visitCard(BuildContext context, ClinicVisit visit) {
    final isEmergency = visit.isEmergency;
    final category = _category(context, visit);
    final (chipBg, chipFg) = _categoryStyle(category, context);
    final studentLabel = '${context.tr(en: 'Student', ar: 'الطالب')} #${visit.studentId}';
    final initials = '#${visit.studentId}';
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _avatarColor(visit.studentId),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.textPrimary,
                ),
              ),
              if ((visit.reason ?? '').isNotEmpty)
                Text(
                  visit.reason!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: SchooKeepColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 8),
              SchooKeepBadge(
                label: category,
                background: chipBg,
                foreground: chipFg,
                fontSize: 11,
              ),
              const SizedBox(height: 8),
              Text(
                _time(visit.visitedAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: SchooKeepColors.textSecondary,
                ),
              ),
              if ((visit.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.paperclip,
                      size: 12,
                      color: SchooKeepColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.tr(en: '1 note', ar: 'ملاحظة واحدة'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: const [
            Icon(
              LucideIcons.lock,
              size: 16,
              color: SchooKeepColors.textSecondary,
            ),
            SizedBox(height: 8),
            RtlIcon(
              LucideIcons.chevronRight,
              size: 20,
              color: SchooKeepColors.textSecondary,
            ),
          ],
        ),
      ],
    );
    return Material(
      color: SchooKeepColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/nurse/clinic/visit/${visit.id}'),
        child: isEmergency
            ? AccentCard(
                background: SchooKeepColors.surface,
                accentColor: SchooKeepColors.error,
                accentWidth: 3,
                radius: 12,
                padding: const EdgeInsets.all(12),
                borderColor: SchooKeepColors.border,
                child: content,
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SchooKeepColors.border),
                ),
                child: content,
              ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
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
