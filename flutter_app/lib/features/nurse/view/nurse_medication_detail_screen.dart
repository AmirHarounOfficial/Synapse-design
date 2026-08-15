import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../cubit/medication_detail_cubit.dart';
import '../widgets/physician_approval_card.dart';

/// Ported from `NurseMedicationDetail.tsx`, now wired to the API
/// (`GET /medications/{id}`). The "Mark as Given" action logs a dose
/// (`POST /dose-administrations`) and is blocked while the record is pending
/// physician approval. Static record-provenance text (license #, signatory) is
/// kept as the source had it where the API has no matching field.
class NurseMedicationDetailScreen extends StatelessWidget {
  const NurseMedicationDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final medId = int.tryParse(id) ?? 0;
    return BlocProvider(
      create: (_) => MedicationDetailCubit(sl<MedicationRepository>(), medId),
      child: const _MedicationDetailView(),
    );
  }
}

class _MedicationDetailView extends StatelessWidget {
  const _MedicationDetailView();

  static const bool _isWithinDoseWindow = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationDetailCubit, DataState<Medication>>(
      builder: (context, state) {
        final title = switch (state) {
          DataLoaded(:final data) => data.name,
          _ => 'Medication',
        };
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            title: title,
            centerTitle: true,
            onBack: () => context.go('/nurse/medications'),
            actions: [
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  onPressed: () => _openOverflowMenu(
                    context,
                    state is DataLoaded<Medication> ? state.data : null,
                  ),
                  icon: const Icon(
                    LucideIcons.moreVertical,
                    size: 24,
                    color: SchooKeepColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          body: switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorView(context, message),
            DataLoaded(:final data) => _content(context, data),
          },
        );
      },
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.wifiOff,
              size: 36,
              color: SchooKeepColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: 'Retry',
              fullWidth: false,
              onPressed: () => context.read<MedicationDetailCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  /// Overflow menu in the app bar. Offers context-relevant actions:
  /// view the low-supply alert (when supply is low) and copy the medication
  /// summary to the clipboard.
  void _openOverflowMenu(BuildContext context, Medication? med) {
    final isRTL = context.isRTL;
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
            children: [
              const SizedBox(height: 8),
              if (med != null && med.isLowSupply)
                ListTile(
                  leading: const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
                  title: Text(
                    isRTL ? 'عرض تنبيه المخزون' : 'View supply alert',
                    style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/nurse/medications/low-supply?medication_id=${med.id}');
                  },
                ),
              ListTile(
                leading: const Icon(LucideIcons.copy, size: 20, color: SchooKeepColors.primary),
                title: Text(
                  isRTL ? 'نسخ معلومات الدواء' : 'Copy medication info',
                  style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (med == null) return;
                  final summary = [
                    med.displayName,
                    if ((med.dosage ?? '').isNotEmpty) med.dosage,
                    if ((med.prescribedBy ?? '').isNotEmpty)
                      (isRTL ? 'وصفها: ${med.prescribedBy}' : 'Prescribed by ${med.prescribedBy}'),
                  ].join(' · ');
                  Clipboard.setData(ClipboardData(text: summary));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isRTL ? 'تم نسخ معلومات الدواء' : 'Medication info copied'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMarkAsGiven(BuildContext context, Medication med) async {
    final isRTL = context.isRTL;
    final messenger = ScaffoldMessenger.of(context);
    if (med.isPending) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isRTL
                ? 'عذراً، لا يمكن إعطاء الدواء قبل الحصول على موافقة الطبيب'
                : 'Action Blocked: Medication cannot be given without physician approval.',
          ),
        ),
      );
      return;
    }
    if (!_isWithinDoseWindow) return;
    final error = await context.read<MedicationDetailCubit>().markAsGiven();
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (isRTL
                  ? 'تم تسجيل إعطاء الجرعة بنجاح'
                  : 'Dose marked as given successfully!'),
        ),
        backgroundColor: error != null ? SchooKeepColors.error : null,
      ),
    );
  }

  Widget _content(BuildContext context, Medication med) {
    final isRTL = context.isRTL;
    final isPending = med.isPending;
    final approvalStatus = med.status ?? 'pending';
    final medicationName = med.displayName;
    final dosesRemaining = med.supplyCount;
    final isLowSupply = med.isLowSupply;
    final nextDose = med.doses.isNotEmpty
        ? med.doses.first.scheduledTime
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student banner (the list resource exposes student_id only; show that).
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: SchooKeepColors.primary,
                      child: const Icon(
                        LucideIcons.user,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRTL
                                ? 'الطالب رقم ${med.studentId}'
                                : 'Student #${med.studentId}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: SchooKeepColors.textPrimary,
                            ),
                          ),
                          if ((med.prescribedBy ?? '').isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              isRTL
                                  ? 'وصفها: ${med.prescribedBy}'
                                  : 'Prescribed by ${med.prescribedBy}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: SchooKeepColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SchooKeepBadge(
                      label: isRTL ? 'أمر طبيب معتمد' : 'Physician order',
                      icon: LucideIcons.checkCircle,
                      background: SchooKeepColors.greenChipBg,
                      foreground: SchooKeepColors.greenChipText,
                      fontSize: 11,
                    ),
                    const SizedBox(width: 8),
                    SchooKeepBadge(
                      label: isRTL ? 'موافقة ولي الأمر' : 'Parent consent',
                      icon: LucideIcons.checkCircle,
                      background: SchooKeepColors.greenChipBg,
                      foreground: SchooKeepColors.greenChipText,
                      fontSize: 11,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Medication header card
          SchooKeepCard(
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
                          Text(
                            medicationName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SchooKeepBadge(
                            label: med.endDate == null
                                ? (isRTL ? 'دائم' : 'Permanent')
                                : (isRTL ? 'مؤقت' : 'Temporary'),
                            background: const Color(0xFFEFF6FF),
                            foreground: SchooKeepColors.primary,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: SchooKeepColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SchooKeepColors.border),
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 24,
                        color: SchooKeepColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if ((med.instructions ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.info,
                        size: 14,
                        color: SchooKeepColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          med.instructions!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SchooKeepColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Physician approval status card (driven by API status).
          PhysicianApprovalCard(
            status: approvalStatus,
            approvedBy: 'Dr. Amina Al-Hashimi',
            licenseNumber: 'DHA MD-4029',
            approvedAt: med.approvedAt ?? '—',
          ),
          // Supply counter
          if (isLowSupply && dosesRemaining != null) ...[
            const SizedBox(height: 16),
            _amberPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.alertTriangle,
                        size: 20,
                        color: SchooKeepColors.warning,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRTL ? 'المخزون منخفض' : 'Low Supply',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: SchooKeepColors.amberText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isRTL
                                  ? 'متبقي $dosesRemaining جرعات'
                                  : '$dosesRemaining doses remaining',
                              style: const TextStyle(
                                fontSize: 13,
                                color: SchooKeepColors.amberText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (dosesRemaining / 30).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: SchooKeepColors.amberChipBg,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        SchooKeepColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Next dose card
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.clock,
                      size: 20,
                      color: SchooKeepColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRTL ? 'الجرعة التالية' : 'Next Dose',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  nextDose ?? '—',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SchooKeepBadge(
                  label: isRTL ? 'مجدولة' : 'Scheduled',
                  icon: LucideIcons.clock,
                  background: const Color(0xFFDBEAFE),
                  foreground: const Color(0xFF1E40AF),
                  fontSize: 12,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isPending
                          ? const Color(0xFFE5E7EB)
                          : SchooKeepColors.accent,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _onMarkAsGiven(context, med),
                    child: Text(
                      isRTL ? 'تسجيل كمعطى' : 'Mark as Given',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isPending
                            ? const Color(0xFF9CA3AF)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Dose log (from administrations)
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'سجل الجرعات' : 'Dose Log',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (med.administrations.isEmpty)
                  Text(
                    isRTL ? 'لا توجد جرعات مسجلة بعد' : 'No doses logged yet',
                    style: const TextStyle(
                      fontSize: 13,
                      color: SchooKeepColors.textSecondary,
                    ),
                  )
                else
                  for (final a in med.administrations.take(5)) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    a.administeredAt ?? a.scheduledFor ?? '—',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: SchooKeepColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    LucideIcons.lock,
                                    size: 14,
                                    color: SchooKeepColors.textSecondary,
                                  ),
                                ],
                              ),
                              if ((a.notes ?? '').isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  a.notes!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: SchooKeepColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SchooKeepBadge(
                          label: a.status ?? '—',
                          icon: a.status == 'given'
                              ? LucideIcons.checkCircle
                              : null,
                          background: a.status == 'given'
                              ? SchooKeepColors.greenChipBg
                              : SchooKeepColors.amberChipBg,
                          foreground: a.status == 'given'
                              ? SchooKeepColors.greenChipText
                              : SchooKeepColors.amberText,
                          fontSize: 11,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amberPanel({required Widget child}) {
    return AccentCard(
      background: SchooKeepColors.amberBg,
      accentColor: SchooKeepColors.warning,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
