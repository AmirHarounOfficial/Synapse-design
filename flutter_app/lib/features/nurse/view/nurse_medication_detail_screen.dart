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

/// Ported from `NurseMedicationDetail.tsx` and matching Figma Node `2:215`.
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
          DataLoaded(:final data) => (data.name.isNotEmpty ? data.name : 'Maya Chen'),
          _ => context.tr(en: 'Maya Chen', ar: 'مايا تشين'),
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
              label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
              fullWidth: false,
              onPressed: () => context.read<MedicationDetailCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

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
    final studentName = med.name.isNotEmpty ? med.name : context.tr(en: 'Maya Chen', ar: 'مايا تشين');
    final gradeRoom = context.tr(en: 'Grade 5 · Room 204', ar: 'الصف الخامس · غرفة 204');
    final medDisplayName = (med.dosage ?? '').isNotEmpty ? med.dosage! : 'Methylphenidate 20mg';
    final isPending = med.isPending;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Student Profile Header Card (Matching Figma Node 2:215)
          SchooKeepCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: SchooKeepColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'MC',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: SchooKeepColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            gradeRoom,
                            style: const TextStyle(
                              fontSize: 13,
                              color: SchooKeepColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SchooKeepBadge(
                      label: context.tr(en: 'Physician order', ar: 'أمر طبيب معتمد'),
                      icon: LucideIcons.checkCircle2,
                      background: const Color(0xFFD1FAE5),
                      foreground: const Color(0xFF065F46),
                      fontSize: 11,
                    ),
                    SchooKeepBadge(
                      label: context.tr(en: 'Parent consent', ar: 'موافقة ولي الأمر'),
                      icon: LucideIcons.checkCircle2,
                      background: const Color(0xFFD1FAE5),
                      foreground: const Color(0xFF065F46),
                      fontSize: 11,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Medication Header Card (Matching Figma Node 2:215)
          SchooKeepCard(
            padding: const EdgeInsets.all(16),
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
                            medDisplayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: SchooKeepColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SchooKeepBadge(
                            label: med.endDate == null
                                ? context.tr(en: 'Permanent', ar: 'دائم')
                                : context.tr(en: 'Temporary', ar: 'مؤقت'),
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
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.lock,
                      size: 14,
                      color: SchooKeepColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.tr(
                          en: 'Record created by Nurse Jane Smith · License #RN-4521 · May 15 2026 09:32:47',
                          ar: 'تم إنشاء السجل بواسطة الممرضة جين سميث · ترخيص #RN-4521 · 15 مايو 2026 09:32:47',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: SchooKeepColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Low Supply Warning Card (Matching Figma Node 2:215)
          _amberAccentCard(
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
                            context.tr(en: 'Low Supply', ar: 'تنبيه نقص المخزون'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr(
                              en: '12 doses remaining · Expires Jun 15, 2026',
                              ar: 'متبقي 12 جرعة · تنتهي الصلاحية في 15 يونيو 2026',
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF92400E),
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
                    value: 0.4,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFFEF3C7),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Home Dose Reported Alert Card (Matching Figma Node 2:215)
          _amberAccentCard(
            child: Row(
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
                        context.tr(
                          en: 'Home dose reported at 7:00 AM — school dose adjusted to 11:30 AM',
                          ar: 'تم الإبلاغ عن جرعة منزلية الساعة 7:00 صباحاً — تم تعديل موعد جرعة المدرسة إلى 11:30 صباحاً',
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          context.tr(en: 'View details', ar: 'عرض التفاصيل'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: SchooKeepColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 5. Next Dose Card (Matching Figma Node 2:215)
          SchooKeepCard(
            padding: const EdgeInsets.all(16),
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
                      context.tr(en: 'Next Dose', ar: 'الجرعة القادمة'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '11:00 AM',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SchooKeepBadge(
                  label: context.tr(en: 'Scheduled', ar: 'مجدولة'),
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
                      backgroundColor: isPending ? const Color(0xFFE5E7EB) : const Color(0xFF10B981),
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _onMarkAsGiven(context, med),
                    child: Text(
                      context.tr(en: 'Mark as Given', ar: 'تسجيل كمعطى'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isPending ? const Color(0xFF9CA3AF) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 6. Dose Log Card (Matching Figma Node 2:215)
          SchooKeepCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Dose Log', ar: 'سجل الجرعات المعطاة'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _doseLogRow(
                  context,
                  time: '08:30:47',
                  date: context.tr(en: 'May 24, 2026', ar: '24 مايو 2026'),
                  administeredBy: context.tr(en: 'Administered by Nurse Jane Smith', ar: 'بواسطة الممرضة جين سميث'),
                ),
                const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
                _doseLogRow(
                  context,
                  time: '08:31:12',
                  date: context.tr(en: 'May 23, 2026', ar: '23 مايو 2026'),
                  administeredBy: context.tr(en: 'Administered by Nurse Jane Smith', ar: 'بواسطة الممرضة جين سميث'),
                ),
                const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
                _doseLogRow(
                  context,
                  time: '08:29:55',
                  date: context.tr(en: 'May 22, 2026', ar: '22 مايو 2026'),
                  administeredBy: context.tr(en: 'Administered by Nurse Sarah Johnson', ar: 'بواسطة الممرضة سارة جونسون'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      context.tr(en: 'View all', ar: 'عرض الكل'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doseLogRow(
    BuildContext context, {
    required String time,
    required String date,
    required String administeredBy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.lock,
                    size: 14,
                    color: SchooKeepColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: SchooKeepColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                administeredBy,
                style: const TextStyle(
                  fontSize: 12,
                  color: SchooKeepColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SchooKeepBadge(
          label: context.tr(en: 'Given', ar: 'تم إعطاؤه'),
          icon: LucideIcons.checkCircle2,
          background: const Color(0xFFD1FAE5),
          foreground: const Color(0xFF065F46),
          fontSize: 11,
        ),
      ],
    );
  }

  Widget _amberAccentCard({required Widget child}) {
    return AccentCard(
      background: const Color(0xFFFFFBEB),
      accentColor: const Color(0xFFF59E0B),
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
