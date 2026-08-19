import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../cubit/secretary_dashboard_cubit.dart';

class SecretaryDashboardScreen extends StatelessWidget {
  const SecretaryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecretaryDashboardCubit(
        sl<NotificationRepository>(),
        sl<StudentRepository>(),
      ),
      child: const _SecretaryDashboardView(),
    );
  }
}

class _SecretaryDashboardView extends StatelessWidget {
  const _SecretaryDashboardView();

  void _reload(BuildContext context) => context.read<SecretaryDashboardCubit>().load();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: true,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Administration', ar: 'الشؤون الإدارية والسكرتارية'),
        actions: [
          BlocBuilder<SecretaryDashboardCubit, DataState<SecretaryDashboardData>>(
            builder: (context, state) {
              final hasUnread =
                  state is DataLoaded<SecretaryDashboardData> && state.data.unreadCount > 0;
              return _BellAction(showDot: hasUnread);
            },
          ),
        ],
      ),
      body: BlocBuilder<SecretaryDashboardCubit, DataState<SecretaryDashboardData>>(
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
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'), fullWidth: false, onPressed: () => _reload(context)),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, SecretaryDashboardData data) {
    final pending = data.notifications.where((n) => n.isUnread).take(5).toList();

    final quickActions = <_QuickAction>[
      _QuickAction(
        label: context.tr(en: 'Import students', ar: 'استيراد بيانات الطلاب'),
        icon: LucideIcons.upload,
        color: SchooKeepColors.accent,
        bg: const Color(0xFFD1FAE5),
        route: '/secretary/import-students',
      ),
      _QuickAction(
        label: context.tr(en: 'Compose message', ar: 'كتابة رسالة جديدة'),
        icon: LucideIcons.messageCircle,
        color: SchooKeepColors.primary,
        bg: const Color(0xFFEFF6FF),
        route: '/secretary/compose-message',
      ),
      _QuickAction(
        label: context.tr(en: 'View chatbot queue', ar: 'محادثات المساعد الآلي'),
        icon: LucideIcons.bot,
        color: const Color(0xFF8B5CF6),
        bg: const Color(0xFFEDE9FE),
        route: '/secretary/chatbot',
      ),
      _QuickAction(
        label: '${context.tr(en: 'Student directory', ar: 'دليل الطلاب')} (${data.studentCount})',
        icon: LucideIcons.users,
        color: SchooKeepColors.textSecondary,
        bg: const Color(0xFFF1F5F9),
        route: '/secretary/students',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr(en: 'Pending Tasks', ar: 'المهام المعلقة'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          if (pending.isEmpty)
            SchooKeepCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(context.tr(en: 'No pending tasks', ar: 'لا توجد مهام معلقة الآن'),
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                ),
              ),
            )
          else
            SchooKeepCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < pending.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _pendingTaskRow(context, pending[i]),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),

          const _HasanaSyncWidget(),
          const SizedBox(height: 16),

          Text(context.tr(en: 'Quick Actions', ar: 'إجراءات سريعة'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [for (final a in quickActions) _quickActionCard(context, a)],
          ),
          const SizedBox(height: 16),

          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(en: "Today's Activity", ar: 'نشاط اليوم الإداري'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Stat(value: '12', label: context.tr(en: 'Messages sent', ar: 'رسائل تم إرسالها'), color: SchooKeepColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(value: '5', label: context.tr(en: 'Escalations resolved', ar: 'تصعيدات تم معالجتها'), color: SchooKeepColors.accent)),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(value: '3', label: context.tr(en: 'Pending replies', ar: 'ردود قيد الانتظار'), color: SchooKeepColors.warning)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingTaskRow(BuildContext context, AppNotification n) {
    final title = (n.title?.isNotEmpty ?? false)
        ? n.title!
        : (n.body?.isNotEmpty ?? false)
            ? n.body!
            : context.tr(en: 'Notification', ar: 'إشعار إداري');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/secretary/notifications'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: const Icon(LucideIcons.bell, size: 20, color: SchooKeepColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
              ),
              const SizedBox(width: 12),
              const Icon(LucideIcons.alertCircle, size: 20, color: SchooKeepColors.warning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActionCard(BuildContext context, _QuickAction a) {
    return Material(
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
                alignment: Alignment.center,
                decoration: BoxDecoration(color: a.bg, shape: BoxShape.circle),
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
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.route,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String route;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
      ],
    );
  }
}

class _BellAction extends StatelessWidget {
  const _BellAction({this.showDot = false});

  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/secretary/notifications'),
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(LucideIcons.bell, size: 24, color: SchooKeepColors.textPrimary),
            if (showDot)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: SchooKeepColors.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HasanaSyncWidget extends StatefulWidget {
  const _HasanaSyncWidget();

  @override
  State<_HasanaSyncWidget> createState() => _HasanaSyncWidgetState();
}

enum _SyncStatus { synced, pending, failed }

class _HasanaSyncWidgetState extends State<_HasanaSyncWidget> {
  _SyncStatus _status = _SyncStatus.synced;
  bool _loading = false;
  late String _syncTime = '${DateFormatter.formatGregorian(DateTime.now())} at 08:30:00';

  void _handleRetry() {
    setState(() {
      _loading = true;
      _status = _SyncStatus.pending;
    });
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final now = DateTime.now();
      final time = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';
      setState(() {
        _status = _SyncStatus.synced;
        _loading = false;
        _syncTime = '${DateFormatter.formatGregorian(now)} at $time';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SchooKeepColors.uaeGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('DHA',
                        style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text(context.tr(en: 'HASANA Hub Integration', ar: 'الربط المباشر مع منصة حصانة (DHA)'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                ],
              ),
              _statusBadge(context),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _status == _SyncStatus.synced
                      ? '${context.tr(en: 'Last sync', ar: 'آخر مزامنة')}: $_syncTime'
                      : context.tr(en: 'Verifying connection gateway', ar: 'جاري التحقق من بوابة الاتصال...'),
                  style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
                ),
              ),
              if (_status == _SyncStatus.synced || _status == _SyncStatus.failed)
                InkWell(
                  onTap: _loading ? null : _handleRetry,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_loading ? LucideIcons.loader : LucideIcons.refreshCw, size: 12, color: SchooKeepColors.primary),
                      const SizedBox(width: 4),
                      Text(context.tr(en: 'Sync Now', ar: 'تزامن الآن'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.primary)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context) {
    switch (_status) {
      case _SyncStatus.synced:
        return SchooKeepBadge(
          label: context.tr(en: 'Synced ✓', ar: 'متزامن ✓'),
          icon: LucideIcons.checkCircle,
          background: const Color(0xFFD1FAE5),
          foreground: const Color(0xFF065F46),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
      case _SyncStatus.pending:
        return SchooKeepBadge(
          label: context.tr(en: 'Syncing...', ar: 'جاري المزامنة...'),
          icon: LucideIcons.refreshCw,
          background: const Color(0xFFFEF3C7),
          foreground: const Color(0xFF92400E),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
      case _SyncStatus.failed:
        return SchooKeepBadge(
          label: context.tr(en: 'Sync Failed ⚠', ar: 'فشلت المزامنة ⚠'),
          icon: LucideIcons.alertCircle,
          background: const Color(0xFFFEE2E2),
          foreground: SchooKeepColors.error,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
    }
  }
}
