import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../cubit/notifications_cubit.dart';

/// Ported from `NurseNotifications.tsx`, wired to `GET /notifications`. Filter
/// chips, notifications grouped by Today / Yesterday / Older, mark-all-read
/// (`POST /notifications/{id}/read`), and an empty state.
class NurseNotificationsScreen extends StatelessWidget {
  const NurseNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(sl<NotificationRepository>()),
      child: const _NurseNotificationsView(),
    );
  }
}

class _NurseNotificationsView extends StatefulWidget {
  const _NurseNotificationsView();

  @override
  State<_NurseNotificationsView> createState() => _NurseNotificationsViewState();
}

class _NurseNotificationsViewState extends State<_NurseNotificationsView> {
  String _activeFilter = 'all';

  static const List<({String id, String label})> _filters = [
    (id: 'all', label: 'All'),
    (id: 'medication', label: 'Medications'),
    (id: 'emergency', label: 'Emergency'),
    (id: 'document', label: 'Documents'),
    (id: 'system', label: 'System'),
  ];

  ({IconData icon, Color bg}) _iconConfig(String? type) {
    switch (type) {
      case 'medication':
        return (icon: LucideIcons.pill, bg: SchooKeepColors.warning);
      case 'emergency':
        return (icon: LucideIcons.zap, bg: SchooKeepColors.error);
      case 'document':
        return (icon: LucideIcons.fileText, bg: SchooKeepColors.primary);
      default:
        return (icon: LucideIcons.info, bg: SchooKeepColors.textSecondary);
    }
  }

  bool _isToday(DateTime d) {
    final t = DateTime.now();
    return d.year == t.year && d.month == t.month && d.day == t.day;
  }

  bool _isYesterday(DateTime d) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  static String _timeLabel(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal();
    final h = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, DataState<List<AppNotification>>>(
      builder: (context, state) {
        final all = state is DataLoaded<List<AppNotification>> ? state.data : const <AppNotification>[];
        final unreadCount = all.where((n) => n.isUnread).length;

        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            centerTitle: true,
            titleWidget: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/nurse/dashboard'),
                  borderRadius: BorderRadius.circular(999),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(LucideIcons.bell, size: 24, color: SchooKeepColors.textSecondary),
                  ),
                ),
                const Expanded(
                  child: Text('Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                ),
                SizedBox(
                  width: 100,
                  child: unreadCount > 0
                      ? Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: () => context.read<NotificationsCubit>().markAllRead(),
                            child: const Text('Mark all read',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          scrollable: false,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _filterRow(),
              Expanded(
                child: switch (state) {
                  DataLoading() => const Center(child: CircularProgressIndicator()),
                  DataError(:final message) => _errorView(message),
                  DataLoaded(:final data) => _content(data),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterRow() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in _filters) ...[
              _filterChip(f.id, f.label),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorView(String message) {
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
            SchooKeepButton(
              label: 'Retry',
              fullWidth: false,
              onPressed: () => context.read<NotificationsCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(List<AppNotification> all) {
    final filtered =
        _activeFilter == 'all' ? all : all.where((n) => n.type == _activeFilter).toList();

    if (filtered.isEmpty) {
      return _emptyState();
    }

    final todayItems = filtered.where((n) => n.createdAt != null && _isToday(n.createdAt!.toLocal())).toList();
    final yesterdayItems =
        filtered.where((n) => n.createdAt != null && _isYesterday(n.createdAt!.toLocal())).toList();
    final olderItems = filtered
        .where((n) =>
            n.createdAt == null ||
            (!_isToday(n.createdAt!.toLocal()) && !_isYesterday(n.createdAt!.toLocal())))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _group(todayItems, 'Today'),
          _group(yesterdayItems, 'Yesterday'),
          _group(olderItems, 'Older'),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
              child: const Icon(LucideIcons.bellOff, size: 32, color: SchooKeepColors.primary),
            ),
            const SizedBox(height: 16),
            const Text("You're all caught up",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('New alerts and notifications will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final active = _activeFilter == id;
    return Material(
      color: active ? SchooKeepColors.primary : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _activeFilter = id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : SchooKeepColors.textSecondary,
              )),
        ),
      ),
    );
  }

  Widget _group(List<AppNotification> items, String label) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.55)),
          ),
          for (final n in items)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _notificationTile(n),
            ),
        ],
      ),
    );
  }

  Widget _notificationTile(AppNotification n) {
    final config = _iconConfig(n.type);
    final navigateTo = n.data['navigate_to'] as String?;
    final tileBody = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (n.isUnread) context.read<NotificationsCubit>().markRead(n.id);
          if (navigateTo != null && navigateTo.isNotEmpty) context.go(navigateTo);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: config.bg, shape: BoxShape.circle),
                child: Icon(config.icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title ?? '',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    if ((n.body ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(n.body!,
                          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.3)),
                    ],
                    const SizedBox(height: 4),
                    Text(_timeLabel(n.createdAt),
                        style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
              if (n.isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );

    if (n.isUnread) {
      return AccentCard(
        background: const Color(0xFFF5F9FF),
        accentColor: SchooKeepColors.primary,
        accentWidth: 2,
        radius: 12,
        padding: EdgeInsets.zero,
        borderColor: SchooKeepColors.border,
        child: tileBody,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: tileBody,
    );
  }
}
