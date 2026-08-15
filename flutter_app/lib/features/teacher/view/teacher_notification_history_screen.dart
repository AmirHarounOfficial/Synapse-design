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
import '../../nurse/cubit/notifications_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `TeacherNotificationHistory.tsx`, wired to `GET /notifications`.
/// Filter chips, the notification list with per-type icon/color, and an empty
/// state. "Clear all" marks every notification read (the API has no bulk-delete
/// endpoint), and tapping a card marks it read via `POST /notifications/{id}/read`.
class TeacherNotificationHistoryScreen extends StatelessWidget {
  const TeacherNotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(sl<NotificationRepository>()),
      child: const _TeacherNotificationHistoryView(),
    );
  }
}

class _TeacherNotificationHistoryView extends StatefulWidget {
  const _TeacherNotificationHistoryView();

  @override
  State<_TeacherNotificationHistoryView> createState() => _TeacherNotificationHistoryViewState();
}

class _TeacherNotificationHistoryViewState extends State<_TeacherNotificationHistoryView> {
  String _activeFilter = 'all';

  static const _filters = [
    (id: 'all', label: 'All'),
    (id: 'medical', label: 'Medical Alerts'),
    (id: 'weather', label: 'Weather'),
    (id: 'clinic', label: 'Clinic'),
    (id: 'students', label: 'Students'),
    (id: 'system', label: 'System'),
  ];

  (IconData, Color, Color) _typeStyle(String? type) => switch (type) {
        'medical' => (LucideIcons.alertCircle, SchooKeepColors.primary, const Color(0xFFEFF6FF)),
        'weather' => (LucideIcons.cloud, SchooKeepColors.warning, SchooKeepColors.amberChipBg),
        'clinic' => (LucideIcons.stethoscope, const Color(0xFF14B8A6), const Color(0xFFCCFBF1)),
        'students' => (LucideIcons.users, const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)),
        _ => (LucideIcons.bell, SchooKeepColors.textSecondary, SchooKeepColors.background),
      };

  void _showClearDialog() {
    final cubit = context.read<NotificationsCubit>();
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Clear All Notifications?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'This marks every notification in your history as read.',
                style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: SchooKeepColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SchooKeepColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          cubit.markAllRead();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Clear All',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, DataState<List<AppNotification>>>(
      builder: (context, state) {
        final all = state is DataLoaded<List<AppNotification>> ? state.data : const <AppNotification>[];
        return SchooKeepScaffold(
          reserveBottomNav: true,
          scrollable: false,
          appBar: SchooKeepAppBar(
            onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
            centerTitle: true,
            title: 'Alerts & Notifications',
            actions: [
              if (all.isNotEmpty)
                TextButton(
                  onPressed: _showClearDialog,
                  child: const Text('Clear all',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.error)),
                ),
            ],
          ),
          body: Column(
            children: [
              _filterChips(),
              const Divider(height: 1, color: SchooKeepColors.border),
              Expanded(
                child: switch (state) {
                  DataLoading() => const Center(child: CircularProgressIndicator()),
                  DataError(:final message) => _errorView(message),
                  DataLoaded(:final data) => _list(data),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _list(List<AppNotification> all) {
    final filtered = all.where((n) => _activeFilter == 'all' || n.type == _activeFilter).toList();
    return filtered.isNotEmpty
        ? ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _notificationCard(filtered[i]),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _emptyState(),
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

  Widget _filterChips() {
    return Container(
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in _filters) ...[
              _chip(f.id, f.label),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String id, String label) {
    final active = _activeFilter == id;
    return SizedBox(
      height: 44,
      child: Material(
        color: active ? SchooKeepColors.primary : SchooKeepColors.background,
        shape: active
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999), side: BorderSide.none)
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999), side: const BorderSide(color: SchooKeepColors.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => setState(() => _activeFilter = id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : SchooKeepColors.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }

  static String _relativeTime(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  Widget _notificationCard(AppNotification n) {
    final (icon, iconColor, bg) = _typeStyle(n.type);
    final navigateTo = n.data['navigate_to'] as String?;
    return Material(
      color: SchooKeepColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (n.isUnread) context.read<NotificationsCubit>().markRead(n.id);
          if (navigateTo != null && navigateTo.isNotEmpty) context.go(navigateTo);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(n.title ?? '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                        ),
                        if (n.isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                    if ((n.body ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(n.body!, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ],
                    const SizedBox(height: 4),
                    Text(_relativeTime(n.createdAt),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Column(
          children: const [
            _EmptyIcon(),
            SizedBox(height: 16),
            Text('No Alerts in This Category',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            SizedBox(height: 8),
            Text("You're all caught up",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _EmptyIcon extends StatelessWidget {
  const _EmptyIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: SchooKeepColors.background, shape: BoxShape.circle),
      child: const Icon(LucideIcons.bellOff, size: 32, color: Color(0xFF94A3B8)),
    );
  }
}
