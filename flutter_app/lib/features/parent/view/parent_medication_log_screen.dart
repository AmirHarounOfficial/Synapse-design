import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/dose_administration.dart';
import '../../../data/repositories/medication_repository.dart';
import '../cubit/parent_medication_log_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentMedicationLog.tsx`, now wired to the API. Read-only
/// medication administration records grouped by medication
/// (`GET /medications` + `GET /dose-administrations`), with a read-only notice,
/// compliance info card, loading/error(retry)/empty states, and a floating
/// "report home dose" action.
///
/// Note: results are scoped to the authenticated parent's child by the backend;
/// the medications cluster has no per-parent filter param, so all visible
/// records are shown.
class ParentMedicationLogScreen extends StatelessWidget {
  const ParentMedicationLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParentMedicationLogCubit(sl<MedicationRepository>()),
      child: const _ParentMedicationLogView(),
    );
  }
}

class _ParentMedicationLogView extends StatelessWidget {
  const _ParentMedicationLogView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'سجلات الأدوية' : 'Medication Records',
        centerTitle: true,
        onBack: () => context.safeBack(),
      ),
      bottomBar: Padding(
        padding: const EdgeInsetsDirectional.only(end: 16, bottom: 16),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Material(
            color: SchooKeepColors.primary,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go('/parent/app/report-home-dose'),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(LucideIcons.plus, size: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ParentMedicationLogCubit, DataState<List<MedicationLogGroup>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorView(context, message, isRTL),
            DataLoaded(:final data) => _content(context, data, isRTL),
          };
        },
      ),
    );
  }

  Widget _errorView(BuildContext context, String message, bool isRTL) {
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
              label: isRTL ? 'إعادة المحاولة' : 'Retry',
              fullWidth: false,
              onPressed: () => context.read<ParentMedicationLogCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<MedicationLogGroup> groups, bool isRTL) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _readOnlyNotice(isRTL),
          const SizedBox(height: 16),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(isRTL ? 'لا توجد سجلات أدوية بعد' : 'No medication records yet',
                    style: const TextStyle(color: SchooKeepColors.textSecondary)),
              ),
            )
          else
            for (int i = 0; i < groups.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _medicationSection(context, groups[i], isRTL),
            ],
          const SizedBox(height: 16),
          _infoCard(isRTL),
        ],
      ),
    );
  }

  Widget _readOnlyNotice(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isRTL
                  ? 'السجلات للقراءة فقط. تُعطى جميع الجرعات وتُسجَّل بواسطة ممرضة المدرسة.'
                  : 'Records are read-only. All doses are administered and logged by school nurse.',
              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats an ISO-8601 timestamp to a short readable time.
  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final local = dt.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour < 12 ? 'AM' : 'PM';
    final mm = local.minute.toString().padLeft(2, '0');
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$hour12:$mm $period (${months[local.month - 1]} ${local.day})';
  }

  Widget _medicationSection(BuildContext context, MedicationLogGroup group, bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.medication.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(group.medication.dosage ?? '',
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => context.go('/parent/app/suspend-school-dose'),
              style: TextButton.styleFrom(
                foregroundColor: SchooKeepColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(LucideIcons.pauseCircle, size: 16),
              label: Text(
                isRTL ? 'إيقاف جرعة اليوم' : 'Suspend school dose',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < group.administrations.length; i++) ...[
                if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                _doseRow(group.administrations[i], isRTL),
              ],
            ],
          ),
        ),
      ],
    );
  }

  ({IconData icon, Color color, Color bg, String labelEn, String labelAr}) _statusConfig(String? status) {
    switch (status) {
      case 'given':
        return (icon: LucideIcons.checkCircle, color: SchooKeepColors.accent, bg: SchooKeepColors.greenChipBg, labelEn: 'Administered', labelAr: 'تم الإعطاء');
      case 'conflict':
        return (icon: LucideIcons.clock, color: SchooKeepColors.warning, bg: SchooKeepColors.amberChipBg, labelEn: 'Delayed', labelAr: 'متأخر');
      case 'missed':
      case 'refused':
        return (icon: LucideIcons.xCircle, color: SchooKeepColors.error, bg: const Color(0xFFFEE2E2), labelEn: 'Missed', labelAr: 'فائت');
      default:
        return (icon: LucideIcons.checkCircle, color: SchooKeepColors.textSecondary, bg: const Color(0xFFF3F4F6), labelEn: status ?? '—', labelAr: status ?? '—');
    }
  }

  Widget _doseRow(DoseAdministration dose, bool isRTL) {
    final cfg = _statusConfig(dose.status);
    final timeLabel = _formatTime(dose.administeredAt ?? dose.scheduledFor);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: cfg.bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(cfg.icon, size: 20, color: cfg.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(timeLabel,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    SchooKeepBadge(
                      label: isRTL ? cfg.labelAr : cfg.labelEn,
                      background: cfg.bg,
                      foreground: cfg.color,
                      fontSize: 11,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isRTL ? 'بواسطة ممرضة المدرسة' : 'School nurse',
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.lock, size: 16, color: Color(0xFF94A3B8)),
        ],
      ),
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
            ? 'يتم إعطاء جميع الأدوية بواسطة ممرضات مدرسة مرخصات وفقاً لأوامر الطبيب. لا يمكن تعديل السجلات وتُحفظ للامتثال.'
            : 'All medication administration is performed by licensed school nurses following physician orders. Records cannot be modified and are maintained for compliance.',
        style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF1E40AF)),
      ),
    );
  }
}
