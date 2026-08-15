import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../cubit/secretary_dashboard_cubit.dart';

/// Ported from `SecretaryDashboard.tsx`. "Administration" app bar with a bell,
/// pending-tasks list, the Dubai-only HASANA sync widget, quick actions grid,
/// and today's activity stats. The pending-tasks list is driven by the user's
/// notifications (`GET /notifications`) and the student-directory tile by the
/// roster total (`GET /students`); the HASANA widget and the "Today's Activity"
/// pure-stat tiles remain static (no API source).
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
      appBar: SchooKeepAppBar(
        title: 'Administration',
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
            SchooKeepButton(label: 'Retry', fullWidth: false, onPressed: () => _reload(context)),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, SecretaryDashboardData data) {
    final pending = data.notifications.where((n) => n.isUnread).take(5).toList();

    final quickActions = <_QuickAction>[
      _QuickAction(
        label: 'Import students',
        icon: LucideIcons.upload,
        color: SchooKeepColors.accent,
        bg: const Color(0xFFD1FAE5),
        route: '/secretary/import-students',
      ),
      _QuickAction(
        label: 'Compose message',
        icon: LucideIcons.messageCircle,
        color: SchooKeepColors.primary,
        bg: const Color(0xFFEFF6FF),
        route: '/secretary/compose-message',
      ),
      _QuickAction(
        label: 'View chatbot queue',
        icon: LucideIcons.bot,
        color: const Color(0xFF8B5CF6),
        bg: const Color(0xFFEDE9FE),
        route: '/secretary/chatbot',
      ),
      _QuickAction(
        label: 'Student directory (${data.studentCount})',
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
          // Pending Tasks (driven by unread notifications)
          const Text('Pending Tasks',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          if (pending.isEmpty)
            const SchooKeepCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No pending tasks',
                      style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
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

          // HASANA Sync Widget (Dubai-only) — no API source, demo state.
          const _HasanaSyncWidget(),
          const SizedBox(height: 16),

          // Quick Actions
          const Text('Quick Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
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

          // Today's Activity — no API source, static demo figures.
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Activity",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: _Stat(value: '12', label: 'Messages sent', color: SchooKeepColors.primary)),
                    SizedBox(width: 12),
                    Expanded(child: _Stat(value: '5', label: 'Escalations resolved', color: SchooKeepColors.accent)),
                    SizedBox(width: 12),
                    Expanded(child: _Stat(value: '3', label: 'Pending replies', color: SchooKeepColors.warning)),
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
            : 'Notification';
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

/// Ported from `HasanaSyncWidget.tsx`. DHA HASANA Hub integration status card —
/// only relevant for Dubai schools. Defaults to a synced state with a retry
/// ("Sync Now") action that briefly shows a syncing state.
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
                    width: 20,
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
                  const Text('HASANA Hub Integration',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                ],
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _status == _SyncStatus.synced ? 'Last sync: $_syncTime' : 'Verifying connection gateway',
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
                      const Text('Sync Now',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.primary)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    switch (_status) {
      case _SyncStatus.synced:
        return const SchooKeepBadge(
          label: 'Synced ✓',
          icon: LucideIcons.checkCircle,
          background: Color(0xFFD1FAE5),
          foreground: Color(0xFF065F46),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
      case _SyncStatus.pending:
        return const SchooKeepBadge(
          label: 'Syncing...',
          icon: LucideIcons.refreshCw,
          background: Color(0xFFFEF3C7),
          foreground: Color(0xFF92400E),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
      case _SyncStatus.failed:
        return const SchooKeepBadge(
          label: 'Sync Failed ⚠',
          icon: LucideIcons.alertCircle,
          background: Color(0xFFFEE2E2),
          foreground: SchooKeepColors.error,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        );
    }
  }
}
