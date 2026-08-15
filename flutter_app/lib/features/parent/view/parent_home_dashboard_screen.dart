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

/// Ported from `ParentHomeDashboard.tsx`, now wired to the API. Recent activity
/// (doses + clinic visits), the "last clinic visit" line and the document
/// expiry reminder come from the clinic/medication/document endpoints (see
/// [ParentDashboardCubit]). The greeting, child profile header, school-status
/// line, consent banner and quick actions have no API source and stay static.
class ParentHomeDashboardScreen extends StatelessWidget {
  const ParentHomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParentDashboardCubit(
        sl<ClinicRepository>(),
        sl<MedicationRepository>(),
        sl<DocumentRepository>(),
      ),
      child: const _ParentHomeDashboardView(),
    );
  }
}

class _ParentHomeDashboardView extends StatelessWidget {
  const _ParentHomeDashboardView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    // no API source — quick actions are static navigation tiles
    final quickActions = [
      (
        label: isRTL ? 'تسجيل جرعة منزلية' : 'Report home dose',
        icon: LucideIcons.clock,
        color: SchooKeepColors.primary,
        bg: const Color(0xFFEFF6FF),
        route: '/parent/app/report-home-dose',
      ),
      (
        label: isRTL ? 'عرض الأدوية' : 'View medications',
        icon: LucideIcons.pill,
        color: SchooKeepColors.accent,
        bg: SchooKeepColors.greenChipBg,
        route: '/parent/app/medications',
      ),
      (
        label: isRTL ? 'رفع مستند' : 'Upload document',
        icon: LucideIcons.upload,
        color: SchooKeepColors.warning,
        bg: SchooKeepColors.amberChipBg,
        route: '/parent/app/document-upload',
      ),
      (
        label: isRTL ? 'محادثة المدرسة' : 'Chat with school',
        icon: LucideIcons.messageCircle,
        color: const Color(0xFF8B5CF6),
        bg: const Color(0xFFEDE9FE),
        route: '/parent/app/chat',
      ),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        // no API source — parent greeting is static
        title: isRTL ? 'مرحباً، جيمس 👋' : 'Hello, James 👋',
        actions: [
          InkWell(
            onTap: () => context.go('/parent/app/profile-settings'),
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(LucideIcons.settings, size: 24, color: SchooKeepColors.textPrimary),
            ),
          ),
          InkWell(
            onTap: () => context.go('/parent/app/notifications'),
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(LucideIcons.bell, size: 24, color: SchooKeepColors.textPrimary),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: SchooKeepColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ParentDashboardCubit, DataState<ParentDashboardData>>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _overviewCard(isRTL, state),
                const SizedBox(height: 16),
                _busTrackingCard(context, isRTL),
                const SizedBox(height: 16),
                _consentBanner(context, isRTL),
                const SizedBox(height: 16),
                _sectionHeader(
                  context,
                  isRTL ? 'النشاط الأخير' : 'Recent Activity',
                  trailing: isRTL ? 'عرض الكل' : 'View all',
                  onTrailing: () => context.go('/parent/app/health'),
                ),
                const SizedBox(height: 12),
                _activityState(context, isRTL, state),
                const SizedBox(height: 16),
                Text(isRTL ? 'إجراءات سريعة' : 'Quick Actions',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                _quickActionsGrid(context, quickActions),
                const SizedBox(height: 16),
                _expiryReminder(context, isRTL, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _overviewCard(bool isRTL, DataState<ParentDashboardData> state) {
    // no API source — child profile header (name/grade/school/avatar) is static
    final lastVisitLine = switch (state) {
      DataLoaded(:final data) when data.lastVisit?.visitedAt != null =>
        (isRTL ? 'آخر زيارة للعيادة: ' : 'Last clinic visit: ') + _timeAgo(isRTL, data.lastVisit!.visitedAt!),
      DataLoaded() => isRTL ? 'لا توجد زيارات سابقة' : 'No clinic visits yet',
      _ => isRTL ? 'جارٍ التحميل…' : 'Loading…',
    };

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('MT',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'مايا طومسون' : 'Maya Thompson',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
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
              const Icon(LucideIcons.checkCircle, size: 16, color: SchooKeepColors.accent),
              const SizedBox(width: 8),
              Expanded(
                // no API source — school attendance status is static
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                    children: [
                      TextSpan(text: isRTL ? 'الحالة المدرسية: ' : 'School status: '),
                      TextSpan(
                        text: isRTL ? 'حاضر ✓' : 'Present ✓',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: SchooKeepColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lastVisitLine,
                  style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // no API source — static CTA into the live bus-tracking screen
  Widget _busTrackingCard(BuildContext context, bool isRTL) {
    return Material(
      color: SchooKeepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SchooKeepColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/parent/app/bus-tracking'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: SchooKeepColors.greenChipBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.bus, size: 20, color: SchooKeepColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRTL ? 'تتبع الحافلة المباشر' : 'Live bus tracking',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isRTL ? 'تتبّع موقع حافلة طفلك' : "Track your child's bus location",
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const RtlIcon(Icons.arrow_forward_ios, size: 16, color: SchooKeepColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // no API source — consent banner is a static CTA into the consent flow
  Widget _consentBanner(BuildContext context, bool isRTL) {
    return Material(
      color: SchooKeepColors.amberChipBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/parent/app/emergency-consent'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.warning),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRTL ? 'طلب موافقة طارئة معلق' : 'Emergency consent request pending',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRTL ? 'اضغط للرد • تنتهي خلال 08:23' : 'Tap to respond • Expires in 08:23',
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.amberText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, {String? trailing, VoidCallback? onTrailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailing,
            child: Text(trailing, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
          ),
      ],
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
                child: Text(message, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
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
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
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

  Widget _quickActionsGrid(BuildContext context, List<({String label, IconData icon, Color color, Color bg, String route})> actions) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        for (final a in actions)
          Material(
            color: SchooKeepColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: SchooKeepColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go(a.route),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: a.bg, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(a.icon, size: 24, color: a.color),
                    ),
                    const SizedBox(height: 12),
                    Text(a.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _expiryReminder(BuildContext context, bool isRTL, DataState<ParentDashboardData> state) {
    final doc = state is DataLoaded<ParentDashboardData> ? state.data.expiringDocument : null;
    if (doc == null) return const SizedBox.shrink();

    final days = _daysUntil(doc.expiryDate);
    final title = doc.title ?? (isRTL ? 'مستند' : 'Document');
    final expiryText = days == null
        ? title
        : days >= 0
            ? (isRTL ? '$title ينتهي خلال $days يوماً' : '$title expires in $days days')
            : (isRTL ? '$title منتهي الصلاحية' : '$title has expired');

    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expiryText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => context.go('/parent/app/document-upload'),
                  child: Text(
                    isRTL ? 'رفع مستند جديد' : 'Upload new document',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int? _daysUntil(String? date) {
    if (date == null || date.isEmpty) return null;
    final exp = DateTime.tryParse(date);
    if (exp == null) return null;
    final now = DateTime.now();
    return DateTime(exp.year, exp.month, exp.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Relative "x days/hours ago" label from a timestamp.
  static String _timeAgo(bool isRTL, DateTime? dt) {
    if (dt == null) return isRTL ? '—' : '—';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return isRTL ? 'الآن' : 'just now';
    if (diff.inMinutes < 60) return isRTL ? 'قبل ${diff.inMinutes} د' : '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return isRTL ? 'قبل ${diff.inHours} س' : '${diff.inHours} hr ago';
    if (diff.inDays == 1) return isRTL ? 'منذ يوم' : '1 day ago';
    return isRTL ? 'قبل ${diff.inDays} أيام' : '${diff.inDays} days ago';
  }
}
