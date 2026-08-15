import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/document_repository.dart';
import '../../../data/repositories/medication_repository.dart';
import '../cubit/parent_dashboard_cubit.dart';

/// Legacy `/parent` portal "Home" tab. The React original was a placeholder, so
/// this builds a wired dashboard using [ParentDashboardCubit] (clinic visits +
/// dose administrations + documents): an overview line for the last clinic
/// visit, a recent-activity list, a document-expiry reminder, and static quick
/// links into the medications/alerts tabs.
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParentDashboardCubit(
        sl<ClinicRepository>(),
        sl<MedicationRepository>(),
        sl<DocumentRepository>(),
      ),
      child: const _ParentDashboardView(),
    );
  }
}

class _ParentDashboardView extends StatelessWidget {
  const _ParentDashboardView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'لوحة ولي الأمر' : 'Parent Dashboard',
      ),
      body: BlocBuilder<ParentDashboardCubit, DataState<ParentDashboardData>>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<ParentDashboardCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _overviewCard(context, isRTL, state),
                const SizedBox(height: 16),
                Text(isRTL ? 'النشاط الأخير' : 'Recent Activity',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                _activityState(context, isRTL, state),
                _expiryReminder(isRTL, state),
                const SizedBox(height: 16),
                Text(isRTL ? 'روابط سريعة' : 'Quick Links',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                _quickLinks(context, isRTL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _overviewCard(BuildContext context, bool isRTL, DataState<ParentDashboardData> state) {
    final lastVisitLine = switch (state) {
      DataLoaded(:final data) when data.lastVisit?.visitedAt != null =>
        (isRTL ? 'آخر زيارة للعيادة: ' : 'Last clinic visit: ') +
            _timeAgo(isRTL, data.lastVisit!.visitedAt!),
      DataLoaded() => isRTL ? 'لا توجد زيارات سابقة' : 'No clinic visits yet',
      DataError() => isRTL ? 'تعذّر تحميل بيانات العيادة' : 'Could not load clinic data',
      _ => isRTL ? 'جارٍ التحميل…' : 'Loading…',
    };

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('MT',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'مايا طومسون' : 'Maya Thompson',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      isRTL ? 'الصف الرابع • مدرسة ليكسايد الابتدائية' : '4th Grade • Lakeside Elementary',
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(lastVisitLine,
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityState(BuildContext context, bool isRTL, DataState<ParentDashboardData> state) {
    return switch (state) {
      DataLoading() => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      DataError(:final message) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.border),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.wifiOff, size: 20, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message,
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => context.read<ParentDashboardCubit>().load(),
                child: Text(isRTL ? 'إعادة' : 'Retry'),
              ),
            ],
          ),
        ),
      DataLoaded(:final data) => _activityList(isRTL, data),
    };
  }

  Widget _activityList(bool isRTL, ParentDashboardData data) {
    final items = data.recentActivity;
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Text(isRTL ? 'لا يوجد نشاط حديث' : 'No recent activity',
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: _activityBg(items[i].kind), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Icon(_activityIcon(items[i].kind), size: 20, color: _activityColor(items[i].kind)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].label,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: SchooKeepColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(_timeAgo(isRTL, items[i].at),
                            style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _activityIcon(ParentActivityKind k) =>
      k == ParentActivityKind.dose ? LucideIcons.pill : LucideIcons.fileText;

  static Color _activityColor(ParentActivityKind k) =>
      k == ParentActivityKind.dose ? SchooKeepColors.primary : SchooKeepColors.textSecondary;

  static Color _activityBg(ParentActivityKind k) =>
      k == ParentActivityKind.dose ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6);

  Widget _expiryReminder(bool isRTL, DataState<ParentDashboardData> state) {
    final doc = state is DataLoaded<ParentDashboardData> ? state.data.expiringDocument : null;
    if (doc == null) return const SizedBox.shrink();

    final days = _daysUntil(doc.expiryDate);
    final title = doc.title ?? (isRTL ? 'مستند' : 'Document');
    final text = days == null
        ? title
        : days >= 0
            ? (isRTL ? '$title ينتهي خلال $days يوماً' : '$title expires in $days days')
            : (isRTL ? '$title منتهي الصلاحية' : '$title has expired');

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SchooKeepColors.amberChipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.warning),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(LucideIcons.fileText, size: 20, color: SchooKeepColors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickLinks(BuildContext context, bool isRTL) {
    final links = [
      (
        label: isRTL ? 'الأدوية' : 'Medications',
        icon: LucideIcons.pill,
        route: '/parent/medications',
      ),
      (
        label: isRTL ? 'الإشعارات' : 'Notifications',
        icon: LucideIcons.bell,
        route: '/parent/notifications',
      ),
    ];
    return Column(
      children: [
        for (final l in links) ...[
          Material(
            color: SchooKeepColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: SchooKeepColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go(l.route),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(l.icon, size: 20, color: SchooKeepColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l.label,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.textPrimary)),
                    ),
                    const RtlIcon(LucideIcons.chevronRight,
                        size: 20, color: SchooKeepColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  static int? _daysUntil(String? date) {
    if (date == null || date.isEmpty) return null;
    final exp = DateTime.tryParse(date);
    if (exp == null) return null;
    final now = DateTime.now();
    return DateTime(exp.year, exp.month, exp.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  static String _timeAgo(bool isRTL, DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return isRTL ? 'الآن' : 'just now';
    if (diff.inMinutes < 60) return isRTL ? 'قبل ${diff.inMinutes} د' : '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return isRTL ? 'قبل ${diff.inHours} س' : '${diff.inHours} hr ago';
    if (diff.inDays == 1) return isRTL ? 'منذ يوم' : '1 day ago';
    return isRTL ? 'قبل ${diff.inDays} أيام' : '${diff.inDays} days ago';
  }
}
