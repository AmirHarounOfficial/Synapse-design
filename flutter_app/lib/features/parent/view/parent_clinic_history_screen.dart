import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../cubit/parent_clinic_history_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentClinicHistory.tsx`, wired to `GET /clinic-visits`.
/// Read-only clinic visit history with expandable, privacy-compliant cards and
/// a FERPA info card.
class ParentClinicHistoryScreen extends StatelessWidget {
  const ParentClinicHistoryScreen({super.key, this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParentClinicHistoryCubit(sl<ClinicRepository>(), studentId: studentId),
      child: const _ParentClinicHistoryView(),
    );
  }
}

class _ParentClinicHistoryView extends StatefulWidget {
  const _ParentClinicHistoryView();

  @override
  State<_ParentClinicHistoryView> createState() => _ParentClinicHistoryViewState();
}

class _ParentClinicHistoryViewState extends State<_ParentClinicHistoryView> {
  int? _expandedId;

  // Client-side filters applied over the loaded visit list.
  String _dateFilter = 'all'; // all | 7d | 30d
  String _reasonFilter = 'all'; // all | Emergency | Moderate | Minor

  void _reload() => context.read<ParentClinicHistoryCubit>().load();

  List<ClinicVisit> _applyFilters(List<ClinicVisit> visits) {
    return visits.where((v) {
      if (_reasonFilter != 'all' && _category(v) != _reasonFilter) return false;
      if (_dateFilter != 'all') {
        final at = v.visitedAt;
        if (at == null) return false;
        final days = _dateFilter == '7d' ? 7 : 30;
        if (at.isBefore(DateTime.now().subtract(Duration(days: days)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _pickFilter({
    required String title,
    required String current,
    required List<({String value, String label})> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SchooKeepColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textPrimary)),
            ),
            for (final o in options)
              ListTile(
                title: Text(o.label,
                    style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary)),
                trailing: o.value == current
                    ? const Icon(LucideIcons.check, size: 18, color: SchooKeepColors.primary)
                    : null,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onSelected(o.value);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static String _category(ClinicVisit v) {
    if (v.isEmergency) return 'Emergency';
    final s = (v.severity ?? '').toLowerCase();
    if (s.contains('severe') || s.contains('moderate')) return 'Moderate';
    return 'Minor';
  }

  static String _dateLabel(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = dt.toLocal();
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h12:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'سجل العيادة' : 'Clinic History',
        centerTitle: true,
        onBack: () => context.safeBack(),
      ),
      body: BlocBuilder<ParentClinicHistoryCubit, DataState<List<ClinicVisit>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator())),
            DataError(:final message) => _errorView(message),
            DataLoaded(:final data) => _content(data, isRTL),
          };
        },
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
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(label: 'Retry', fullWidth: false, onPressed: _reload),
          ],
        ),
      ),
    );
  }

  String _dateFilterLabel(bool isRTL) => switch (_dateFilter) {
        '7d' => isRTL ? 'آخر 7 أيام' : 'Last 7 days',
        '30d' => isRTL ? 'آخر 30 يوماً' : 'Last 30 days',
        _ => isRTL ? 'كل التواريخ' : 'All dates',
      };

  String _reasonFilterLabel(bool isRTL) => switch (_reasonFilter) {
        'Emergency' => isRTL ? 'طارئة' : 'Emergency',
        'Moderate' => isRTL ? 'متوسطة' : 'Moderate',
        'Minor' => isRTL ? 'بسيطة' : 'Minor',
        _ => isRTL ? 'كل الأسباب' : 'All reasons',
      };

  Widget _content(List<ClinicVisit> allVisits, bool isRTL) {
    final visits = _applyFilters(allVisits);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _filterButton(
                  _dateFilterLabel(isRTL),
                  active: _dateFilter != 'all',
                  onTap: () => _pickFilter(
                    title: isRTL ? 'تصفية حسب التاريخ' : 'Filter by date',
                    current: _dateFilter,
                    options: [
                      (value: 'all', label: isRTL ? 'كل التواريخ' : 'All dates'),
                      (value: '7d', label: isRTL ? 'آخر 7 أيام' : 'Last 7 days'),
                      (value: '30d', label: isRTL ? 'آخر 30 يوماً' : 'Last 30 days'),
                    ],
                    onSelected: (v) => setState(() => _dateFilter = v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _filterButton(
                  _reasonFilterLabel(isRTL),
                  active: _reasonFilter != 'all',
                  onTap: () => _pickFilter(
                    title: isRTL ? 'تصفية حسب السبب' : 'Filter by reason',
                    current: _reasonFilter,
                    options: [
                      (value: 'all', label: isRTL ? 'كل الأسباب' : 'All reasons'),
                      (value: 'Emergency', label: isRTL ? 'طارئة' : 'Emergency'),
                      (value: 'Moderate', label: isRTL ? 'متوسطة' : 'Moderate'),
                      (value: 'Minor', label: isRTL ? 'بسيطة' : 'Minor'),
                    ],
                    onSelected: (v) => setState(() => _reasonFilter = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (visits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(isRTL ? 'لا توجد زيارات' : 'No clinic visits yet',
                    style: const TextStyle(color: SchooKeepColors.textSecondary)),
              ),
            )
          else
            for (final v in visits) ...[
              _visitCard(v, isRTL),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 4),
          _infoCard(isRTL),
        ],
      ),
    );
  }

  Widget _filterButton(String label, {required bool active, required VoidCallback onTap}) {
    return Material(
      color: SchooKeepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: active ? SchooKeepColors.primary : SchooKeepColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        color: active ? SchooKeepColors.primary : SchooKeepColors.textPrimary)),
              ),
              Icon(LucideIcons.chevronDown,
                  size: 16,
                  color: active ? SchooKeepColors.primary : SchooKeepColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  ({Color bg, Color fg}) _categoryColor(String category) {
    switch (category) {
      case 'Emergency':
        return (bg: const Color(0xFFFEE2E2), fg: SchooKeepColors.error);
      case 'Moderate':
        return (bg: SchooKeepColors.amberChipBg, fg: SchooKeepColors.warning);
      default:
        return (bg: const Color(0xFFF0F9FF), fg: const Color(0xFF0369A1));
    }
  }

  String _categoryLabel(String category, bool isRTL) {
    if (!isRTL) return category.toUpperCase();
    switch (category) {
      case 'Emergency':
        return 'طارئة';
      case 'Moderate':
        return 'متوسطة';
      default:
        return 'بسيطة';
    }
  }

  Widget _visitCard(ClinicVisit visit, bool isRTL) {
    final expanded = _expandedId == visit.id;
    final category = _category(visit);
    final cat = _categoryColor(category);
    final reason = isRTL ? (visit.reasonAr ?? visit.reason ?? '') : (visit.reason ?? '');
    final date = _dateLabel(visit.visitedAt);
    final time = _timeLabel(visit.visitedAt);

    return SchooKeepCard(
      onTap: () => setState(() => _expandedId = expanded ? null : visit.id),
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
                    Text(reason.isNotEmpty ? reason : (isRTL ? 'زيارة عيادة' : 'Clinic visit'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      isRTL ? '$date الساعة $time' : '$date at $time',
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SchooKeepBadge(
                label: _categoryLabel(category, isRTL),
                background: cat.bg,
                foreground: cat.fg,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.checkCircle, size: 16, color: SchooKeepColors.accent),
              const SizedBox(width: 8),
              Text(isRTL ? 'السجل آمن ✓' : 'Record is secure ✓',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.accent)),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),
            _detailRow(isRTL ? 'بواسطة' : 'Attended by',
                visit.nurseId != null ? 'Nurse #${visit.nurseId}' : (isRTL ? 'ممرضة المدرسة' : 'School nurse')),
            const SizedBox(height: 8),
            _detailRow(isRTL ? 'الطابع الزمني' : 'Timestamp', '$date $time'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Text(
                isRTL
                    ? 'المعلومات السريرية التفصيلية محمية بموجب FERPA و HIPAA. يتم عرض الفئة وإقرار الممرضة فقط للحفاظ على الامتثال للخصوصية.'
                    : 'Detailed clinical information is protected under FERPA and HIPAA. Only category and nurse attestation are shown to maintain privacy compliance.',
                style: const TextStyle(fontSize: 12, height: 1.5, color: SchooKeepColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
        ),
      ],
    );
  }

  Widget _infoCard(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.primary),
      ),
      child: Text(
        isRTL
            ? 'تُحفظ سجلات العيادة الكاملة بما في ذلك الملاحظات السريرية والتشخيصات لدى ممرضة المدرسة وتتوفر عند الطلب الكتابي وفقاً لإرشادات FERPA.'
            : 'Complete clinic records including clinical notes and diagnoses are maintained by the school nurse and are available upon written request per FERPA guidelines.',
        style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF1E40AF)),
      ),
    );
  }
}
