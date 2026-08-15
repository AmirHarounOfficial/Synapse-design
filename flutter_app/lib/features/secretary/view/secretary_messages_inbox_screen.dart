import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/message_repository.dart';
import '../cubit/secretary_messages_inbox_cubit.dart';

/// Ported from `SecretaryMessagesInbox.tsx`, wired to `GET /messages`.
/// Filterable message inbox (All / Urgent / Health / Attendance / General) with
/// unread indicators (from `status`) and a compose FAB. Category filtering is
/// applied client-side over the loaded page; tapping a row opens
/// `/secretary/message/{id}`.
class SecretaryMessagesInboxScreen extends StatelessWidget {
  const SecretaryMessagesInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecretaryMessagesInboxCubit(sl<MessageRepository>()),
      child: const _SecretaryMessagesInboxView(),
    );
  }
}

class _SecretaryMessagesInboxView extends StatefulWidget {
  const _SecretaryMessagesInboxView();

  @override
  State<_SecretaryMessagesInboxView> createState() => _SecretaryMessagesInboxViewState();
}

class _SecretaryMessagesInboxViewState extends State<_SecretaryMessagesInboxView> {
  String _activeTab = 'all';

  static const List<({String id, String label})> _tabs = [
    (id: 'all', label: 'All'),
    (id: 'urgent', label: 'Urgent'),
    (id: 'health', label: 'Health'),
    (id: 'attendance', label: 'Attendance'),
    (id: 'general', label: 'General'),
  ];

  void _reload() => context.read<SecretaryMessagesInboxCubit>().load();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              Expanded(
                child: BlocBuilder<SecretaryMessagesInboxCubit, DataState<List<Message>>>(
                  builder: (context, state) {
                    return switch (state) {
                      DataLoading() => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      DataError(:final message) => _errorView(message),
                      DataLoaded(:final data) => _list(data),
                    };
                  },
                ),
              ),
            ],
          ),
          PositionedDirectional(
            bottom: 16,
            end: 16,
            child: Material(
              color: SchooKeepColors.primary,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.go('/secretary/compose-message'),
                child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(LucideIcons.plus, size: 24, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<Message> all) {
    final filtered =
        all.where((m) => _activeTab == 'all' || m.category == _activeTab).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<SecretaryMessagesInboxCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 64),
              child: Center(
                child: Text(
                  'No messages',
                  style: TextStyle(color: SchooKeepColors.textSecondary),
                ),
              ),
            )
          else
            SchooKeepCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _messageRow(filtered[i]),
                  ],
                ],
              ),
            ),
        ],
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
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(label: 'Retry', fullWidth: false, onPressed: _reload),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Messages',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  ),
                  InkWell(
                    onTap: () => context.go('/secretary/notifications'),
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(LucideIcons.bell, size: 24, color: SchooKeepColors.textPrimary),
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
                  ),
                ],
              ),
            ),
          ),
          // Filter tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _tabChip(_tabs[i].id, _tabs[i].label),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(String id, String label) {
    final active = _activeTab == id;
    return Material(
      color: active ? SchooKeepColors.primary : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _activeTab = id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _messageRow(Message message) {
    final unread = message.status == 'unread';
    final from = (message.senderName ?? '').isNotEmpty ? message.senderName! : 'Unknown';
    final preview = (message.subject ?? '').isNotEmpty
        ? message.subject!
        : (message.body ?? '');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/secretary/message/${message.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: Text(_initials(from),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(from,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                                color: SchooKeepColors.textPrimary,
                              )),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: unread ? SchooKeepColors.textPrimary : SchooKeepColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_time(message.createdAt),
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  static String _time(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final isToday = local.year == now.year && local.month == now.month && local.day == now.day;
    if (isToday) {
      final h12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final m = local.minute.toString().padLeft(2, '0');
      final ampm = local.hour < 12 ? 'AM' : 'PM';
      return '${h12.toString().padLeft(2, '0')}:$m $ampm';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year == yesterday.year && local.month == yesterday.month && local.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }
}
