import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/cafeteria_alert.dart';
import '../../../data/repositories/cafeteria_repository.dart';
import '../cubit/cafeteria_alert_list_cubit.dart';

/// Ported from `CafeteriaRealtimeAlert.tsx`, now wired to the API. A blocking
/// full-screen modal announcing the most recent unacknowledged allergy alert
/// (`GET /cafeteria-alerts?acknowledged=false`). It cannot be dismissed without
/// refreshing — tapping the button navigates to the alerts list.
class CafeteriaRealtimeAlertScreen extends StatelessWidget {
  const CafeteriaRealtimeAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return BlocProvider(
      create: (_) => CafeteriaAlertListCubit(sl<CafeteriaRepository>())..load(acknowledged: false),
      child: Stack(
        children: [
          // Faded background content
          const Opacity(
            opacity: 0.3,
            child: IgnorePointer(
              child: SchooKeepScaffold(
                reserveBottomNav: true,
                scrollable: false,
                appBar: SchooKeepAppBar(title: "Today's Meal Restrictions"),
                body: SizedBox.shrink(),
              ),
            ),
          ),
          // Modal overlay
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SchooKeepColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SchooKeepColors.error, width: 4),
                    ),
                    child: BlocBuilder<CafeteriaAlertListCubit, DataState<List<CafeteriaAlert>>>(
                      builder: (context, state) {
                        final latest = switch (state) {
                          DataLoaded(:final data) => data.isNotEmpty ? data.first : null,
                          _ => null,
                        };
                        return _modalBody(context, isRTL, latest);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modalBody(BuildContext context, bool isRTL, CafeteriaAlert? alert) {
    final title = alert?.title ?? (isRTL ? 'تنبيه حساسية جديد' : 'New Allergy Alert');
    final detail = alert?.message ??
        (isRTL
            ? 'تم تحديث قيود الحساسية لأحد الطلاب في منطقة خدمتك.'
            : 'An allergen restriction has been updated for a student in your service area.');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
          child: const Icon(LucideIcons.alertTriangle, size: 40, color: SchooKeepColors.error),
        ),
        const SizedBox(height: 16),
        Text(
          isRTL ? 'تنبيه حساسية جديد' : 'New Allergy Alert',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SchooKeepColors.error),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary, height: 1.4),
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary, height: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          isRTL
              ? 'يجب تحديث القائمة لعرض المعلومات المحدثة قبل متابعة تقديم الوجبات.'
              : 'You must refresh the list to see the updated information before continuing meal service.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: SchooKeepColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => context.go('/cafeteria/alerts'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.refreshCw, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(isRTL ? 'تحديث القائمة الآن' : 'Refresh List Now',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SchooKeepColors.amberChipBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isRTL
                ? 'لحماية سلامة الطلاب، لا يمكن إغلاق هذا التنبيه دون تحديث القائمة.'
                : 'For student safety, this alert cannot be dismissed without refreshing.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText),
          ),
        ),
      ],
    );
  }
}
