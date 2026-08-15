import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/medication_repository.dart';
import '../cubit/parent_medications_cubit.dart';

/// Legacy `/parent` portal "Medications" tab. Wired to `GET /medications`
/// (+ `GET /dose-administrations`): lists the child's medications with status,
/// dosage, low-supply flag and last-administered time. Read-only for parents —
/// the React original was a placeholder, so the layout follows the app's
/// medication design system.
class ParentMedicationsScreen extends StatelessWidget {
  const ParentMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParentMedicationsCubit(sl<MedicationRepository>()),
      child: const _ParentMedicationsView(),
    );
  }
}

class _ParentMedicationsView extends StatelessWidget {
  const _ParentMedicationsView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'الأدوية' : 'Medications',
      ),
      body: BlocBuilder<ParentMedicationsCubit, DataState<List<ParentMedicationItem>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
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
                textAlign: TextAlign.center,
                style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: isRTL ? 'إعادة المحاولة' : 'Retry',
              fullWidth: false,
              onPressed: () => context.read<ParentMedicationsCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<ParentMedicationItem> items, bool isRTL) {
    return RefreshIndicator(
      onRefresh: () => context.read<ParentMedicationsCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _readOnlyNotice(isRTL),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(isRTL ? 'لا توجد أدوية مسجلة' : 'No medications on file',
                    style: const TextStyle(color: SchooKeepColors.textSecondary)),
              ),
            )
          else
            for (final item in items) ...[
              _medicationCard(item, isRTL),
              const SizedBox(height: 12),
            ],
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
                  ? 'تُدار جميع الأدوية وتُسجَّل بواسطة ممرضة المدرسة.'
                  : 'All medications are managed and logged by the school nurse.',
              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicationCard(ParentMedicationItem item, bool isRTL) {
    final med = item.medication;
    final name = isRTL ? (med.nameAr ?? med.name) : med.name;
    final last = item.administrations.isEmpty
        ? null
        : (item.administrations
            .map((a) => a.administeredAt ?? a.scheduledFor)
            .where((s) => s != null && s.isNotEmpty)
            .toList()
          ..sort((a, b) => (b ?? '').compareTo(a ?? ''))).firstOrNull;
    final status = _statusConfig(med.status, isRTL);

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.pill, size: 20, color: SchooKeepColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: SchooKeepColors.textPrimary)),
                    if ((med.dosage ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(med.dosage!,
                          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SchooKeepBadge(
                label: status.label,
                background: status.bg,
                foreground: status.fg,
                fontSize: 11,
              ),
            ],
          ),
          if ((med.instructions ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(med.instructions!,
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 14, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  last == null
                      ? (isRTL ? 'لم تُعطَ بعد' : 'Not yet administered')
                      : (isRTL ? 'آخر جرعة: ${_formatTime(last)}' : 'Last dose: ${_formatTime(last)}'),
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                ),
              ),
            ],
          ),
          if (med.isLowSupply) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.alertTriangle, size: 14, color: SchooKeepColors.warning),
                const SizedBox(width: 6),
                Text(
                  isRTL ? 'المخزون منخفض' : 'Low supply',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.warning),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  ({String label, Color bg, Color fg}) _statusConfig(String? status, bool isRTL) {
    switch (status) {
      case 'active':
      case 'approved':
        return (label: isRTL ? 'نشط' : 'Active', bg: SchooKeepColors.greenChipBg, fg: SchooKeepColors.greenChipText);
      case 'pending':
        return (label: isRTL ? 'قيد الموافقة' : 'Pending', bg: SchooKeepColors.amberChipBg, fg: SchooKeepColors.amberText);
      case 'declined':
        return (label: isRTL ? 'مرفوض' : 'Declined', bg: const Color(0xFFFEE2E2), fg: SchooKeepColors.error);
      default:
        return (label: status ?? (isRTL ? 'غير معروف' : 'Unknown'), bg: const Color(0xFFF3F4F6), fg: SchooKeepColors.textSecondary);
    }
  }

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
}
