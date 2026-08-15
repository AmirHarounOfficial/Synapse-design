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
import '../cubit/clinic_visit_detail_cubit.dart';

/// Clinic visit detail, reached from `ClinicVisitListScreen`
/// (`/nurse/clinic/visit/:id`) and wired to `GET /clinic-visits/{id}`. Shows the
/// student, reason, severity/category, emergency flag, notes, visit time and any
/// outcome/photo on record. Layout intent follows `ClinicVisitList.tsx` styling.
class ClinicVisitDetailScreen extends StatelessWidget {
  const ClinicVisitDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final visitId = int.tryParse(id) ?? 0;
    return BlocProvider(
      create: (_) => ClinicVisitDetailCubit(sl<ClinicRepository>(), visitId),
      child: const _ClinicVisitDetailView(),
    );
  }
}

class _ClinicVisitDetailView extends StatelessWidget {
  const _ClinicVisitDetailView();

  static String _category(ClinicVisit v) {
    if (v.isEmergency) return 'Emergency';
    final s = (v.severity ?? '').toLowerCase();
    if (s.contains('injur')) return 'Injury';
    if (s.contains('illness') || s.contains('ill')) return 'Illness';
    if (s.contains('medic')) return 'Medication';
    return 'Routine';
  }

  static (Color bg, Color fg) _categoryStyle(String category) {
    switch (category) {
      case 'Emergency':
        return (const Color(0xFFFEE2E2), SchooKeepColors.error);
      case 'Injury':
        return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText);
      case 'Illness':
        return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF));
      case 'Medication':
        return (const Color(0xFFE0E7FF), const Color(0xFF4338CA));
      case 'Routine':
        return (SchooKeepColors.greenChipBg, SchooKeepColors.greenChipText);
      default:
        return (SchooKeepColors.border, SchooKeepColors.textSecondary);
    }
  }

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

  static String _dateTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${months[local.month - 1]} ${local.day}, ${local.year} · '
        '${h12.toString().padLeft(2, '0')}:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Visit Details', ar: 'تفاصيل الزيارة'),
        centerTitle: true,
        onBack: () => context.go('/nurse/clinic'),
      ),
      body: BlocBuilder<ClinicVisitDetailCubit, DataState<ClinicVisit>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorView(context, message),
            DataLoaded(:final data) => _content(context, data),
          };
        },
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
              fullWidth: false,
              onPressed: () => context.read<ClinicVisitDetailCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ClinicVisit visit) {
    final isRTL = context.isRTL;
    final category = _category(visit);
    final (chipBg, chipFg) = _categoryStyle(category);
    final reason = isRTL && (visit.reasonAr ?? '').isNotEmpty ? visit.reasonAr! : (visit.reason ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card: student + category + emergency flag.
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _avatarColor(visit.studentId),
                      child: Text(
                        '#${visit.studentId}',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${context.tr(en: 'Student', ar: 'الطالب')} #${visit.studentId}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              SchooKeepBadge(label: category, background: chipBg, foreground: chipFg, fontSize: 11),
                              if (visit.isEmergency)
                                const SchooKeepBadge(
                                  label: 'Emergency',
                                  background: Color(0xFFFEE2E2),
                                  foreground: SchooKeepColors.error,
                                  fontSize: 11,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 16, color: SchooKeepColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dateTime(visit.visitedAt),
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Emergency banner.
          if (visit.isEmergency) ...[
            AccentCard(
              background: const Color(0xFFFEE2E2),
              accentColor: SchooKeepColors.error,
              accentWidth: 4,
              radius: 12,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr(
                        en: 'This visit was flagged as an emergency.',
                        ar: 'تم وضع علامة على هذه الزيارة كحالة طارئة.',
                      ),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Visit information.
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Visit Information', ar: 'معلومات الزيارة'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _row(context.tr(en: 'Reason', ar: 'السبب'), reason.isEmpty ? '—' : reason),
                _row(context.tr(en: 'Severity', ar: 'الشدة'), _titleCase(visit.severity) ?? '—'),
                _row(context.tr(en: 'Category', ar: 'الفئة'), category),
                _row(
                  context.tr(en: 'Emergency', ar: 'طارئة'),
                  visit.isEmergency
                      ? context.tr(en: 'Yes', ar: 'نعم')
                      : context.tr(en: 'No', ar: 'لا'),
                ),
                _row(
                  context.tr(en: 'Visit Time', ar: 'وقت الزيارة'),
                  _dateTime(visit.visitedAt),
                  last: (visit.outcome ?? '').isEmpty,
                ),
                if ((visit.outcome ?? '').isNotEmpty)
                  _row(context.tr(en: 'Outcome', ar: 'النتيجة'), visit.outcome!, last: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Notes.
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.fileText, size: 16, color: SchooKeepColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(en: 'Notes', ar: 'ملاحظات'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  (visit.notes ?? '').isEmpty
                      ? context.tr(en: 'No notes recorded for this visit.', ar: 'لا توجد ملاحظات مسجلة لهذه الزيارة.')
                      : visit.notes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: (visit.notes ?? '').isEmpty ? SchooKeepColors.textSecondary : SchooKeepColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Photo / consent evidence.
          if ((visit.photoUrl ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            SchooKeepCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.paperclip, size: 16, color: SchooKeepColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(en: 'Attached Photo', ar: 'صورة مرفقة'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      visit.photoUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        alignment: Alignment.center,
                        color: SchooKeepColors.background,
                        child: const Icon(LucideIcons.imageOff, size: 32, color: SchooKeepColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SchooKeepButton(
            label: context.tr(en: 'Back to Clinic Visits', ar: 'العودة إلى زيارات العيادة'),
            onPressed: () => context.go('/nurse/clinic'),
          ),
        ],
      ),
    );
  }

  static String? _titleCase(String? s) {
    if (s == null || s.isEmpty) return null;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _row(String label, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
