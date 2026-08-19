import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../cubit/secretary_notifications_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Secretary notifications list. Reached from the "Administration" dashboard
/// (pending-task rows) and the bell icons across the secretary tabs. Wired to
/// `GET /notifications`; tapping an unread notification marks it read
/// (`POST /notifications/{id}/read`).
class SecretaryNotificationsScreen extends StatelessWidget {
  const SecretaryNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecretaryNotificationsCubit(sl<NotificationRepository>()),
      child: const _SecretaryNotificationsView(),
    );
  }
}

class _SecretaryNotificationsView extends StatelessWidget {
  const _SecretaryNotificationsView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'الإشعارات' : 'Notifications',
        onBack: () =>
            context.canPop() ? context.safeBack() : context.go('/secretary/home'),
      ),
      body: BlocBuilder<SecretaryNotificationsCubit, DataState<List<AppNotification>>>(
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
              onPressed: () => context.read<SecretaryNotificationsCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<AppNotification> items, bool isRTL) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.bellOff, size: 36, color: SchooKeepColors.textSecondary),
              const SizedBox(height: 12),
              Text(isRTL ? 'لا توجد إشعارات' : 'No notifications yet',
                  style: const TextStyle(color: SchooKeepColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    final unreadCount = items.where((n) => n.isUnread).length;
    return RefreshIndicator(
      onRefresh: () => context.read<SecretaryNotificationsCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (unreadCount > 0) ...[
            Text(
              isRTL ? '$unreadCount غير مقروء' : '$unreadCount unread',
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 12),
          ],
          for (final n in items) ...[
            _notificationCard(context, n, isRTL),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _notificationCard(BuildContext context, AppNotification n, bool isRTL) {
    final cfg = _typeConfig(n.type);
    final card = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                children: [
                  Expanded(
                    child: Text(
                      n.title ?? (isRTL ? 'إشعار' : 'Notification'),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: SchooKeepColors.textPrimary),
                    ),
                  ),
                  if (n.isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: SchooKeepColors.primary, shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
              if ((n.body ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(n.body!,
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
              const SizedBox(height: 6),
              Text(_timeAgo(isRTL, n.createdAt),
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ),
      ],
    );

    return SchooKeepCard(
      color: n.isUnread ? const Color(0xFFEFF6FF) : SchooKeepColors.surface,
      borderColor: n.isUnread ? SchooKeepColors.primary : SchooKeepColors.border,
      onTap: n.isUnread
          ? () => context.read<SecretaryNotificationsCubit>().markRead(n.id)
          : null,
      child: card,
    );
  }

  ({IconData icon, Color color, Color bg}) _typeConfig(String? type) {
    switch (type) {
      case 'emergency':
        return (icon: LucideIcons.alertTriangle, color: SchooKeepColors.error, bg: const Color(0xFFFEE2E2));
      case 'medication':
        return (icon: LucideIcons.pill, color: SchooKeepColors.primary, bg: const Color(0xFFEFF6FF));
      case 'clinic':
        return (icon: LucideIcons.stethoscope, color: const Color(0xFF0369A1), bg: const Color(0xFFF0F9FF));
      case 'document':
        return (icon: LucideIcons.fileText, color: SchooKeepColors.warning, bg: SchooKeepColors.amberChipBg);
      case 'weather':
        return (icon: LucideIcons.cloudRain, color: const Color(0xFF0369A1), bg: const Color(0xFFF0F9FF));
      default:
        return (icon: LucideIcons.bell, color: SchooKeepColors.textSecondary, bg: const Color(0xFFF3F4F6));
    }
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
