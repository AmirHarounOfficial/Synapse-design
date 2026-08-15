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
import '../cubit/vice_principal_messages_cubit.dart';

/// Ported from `VicePrincipalMessages.tsx`, wired to `GET /messages` via
/// [VicePrincipalMessagesCubit]. Renders one of three views: the compose form
/// (`?compose=principal`), a selected thread, or the live message list with
/// search.
class VicePrincipalMessagesScreen extends StatelessWidget {
  const VicePrincipalMessagesScreen(
      {super.key, this.composeMode, this.prefillSubject});

  final String? composeMode;
  final String? prefillSubject;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VicePrincipalMessagesCubit(sl<MessageRepository>()),
      child: _MessagesView(
        composeMode: composeMode,
        prefillSubject: prefillSubject,
      ),
    );
  }
}

class _MessagesView extends StatefulWidget {
  const _MessagesView({this.composeMode, this.prefillSubject});

  final String? composeMode;
  final String? prefillSubject;

  @override
  State<_MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<_MessagesView> {
  String _searchQuery = '';
  Message? _selectedThread;

  static String _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _date(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    return '${_months[d.month - 1]} ${d.day}';
  }

  static String _time(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '$h12:$m $ampm';
  }

  void _reload() => context.read<VicePrincipalMessagesCubit>().load();

  @override
  Widget build(BuildContext context) {
    if (widget.composeMode == 'principal') {
      return _buildCompose(context);
    }
    if (_selectedThread != null) {
      return _buildThread(context, _selectedThread!);
    }
    return _buildList(context);
  }

  // ---- Compose (visual, unchanged from the ported prototype) ----------------

  Widget _buildCompose(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: 'New Message',
        onBack: () => context.go('/vice-principal/messages'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Send',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.primary)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _composeRow(
            'To:',
            const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Text('MD',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: SchooKeepColors.primary)),
                ),
                SizedBox(width: 8),
                Text('Principal M. Davis',
                    style: TextStyle(
                        fontSize: 14, color: SchooKeepColors.textPrimary)),
              ],
            ),
          ),
          _composeRow(
            'Subject:',
            TextField(
              controller:
                  TextEditingController(text: widget.prefillSubject ?? ''),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Message subject',
                hintStyle: TextStyle(
                    fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              style: const TextStyle(
                  fontSize: 14, color: SchooKeepColors.textPrimary),
            ),
          ),
          Container(
            color: SchooKeepColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const TextField(
              maxLines: null,
              minLines: 8,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Type your message here...',
                hintStyle: TextStyle(
                    fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              style: TextStyle(
                  fontSize: 14, color: SchooKeepColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _composeRow(String label, Widget field) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: SchooKeepColors.textSecondary)),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }

  // ---- Thread (real message detail) -----------------------------------------

  Widget _buildThread(BuildContext context, Message message) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => setState(() => _selectedThread = null),
        titleWidget: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(_initials(message.senderName),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: SchooKeepColors.primary)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.senderName ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textPrimary)),
                Text(message.category ?? '',
                    style: const TextStyle(
                        fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      bottomBar: _messageInput(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if ((message.subject ?? '').isNotEmpty) ...[
            Text(message.subject!,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 12),
          ],
          _bubble(false, message.body ?? '', _time(message.createdAt)),
        ],
      ),
    );
  }

  Widget _bubble(bool mine, String content, String time) {
    return Align(
      alignment:
          mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: mine ? SchooKeepColors.primary : SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: mine ? null : Border.all(color: SchooKeepColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: mine ? Colors.white : SchooKeepColors.textPrimary)),
              const SizedBox(height: 4),
              Text(time,
                  style: TextStyle(
                      fontSize: 11,
                      color: mine
                          ? const Color(0xFFDBEAFE)
                          : SchooKeepColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageInput() {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999)),
              child: const TextField(
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                      fontSize: 14, color: SchooKeepColors.textSecondary),
                ),
                style: TextStyle(
                    fontSize: 14, color: SchooKeepColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: SchooKeepColors.primary, shape: BoxShape.circle),
            child: const Icon(LucideIcons.send, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ---- List (live data) -----------------------------------------------------

  Widget _buildList(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Messages',
        actions: [
          InkWell(
            onTap: () => context.go('/vice-principal/messages?compose=new'),
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(LucideIcons.plus,
                  size: 24, color: SchooKeepColors.primary),
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(LucideIcons.search,
                    size: 20, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Search conversations',
                      hintStyle: TextStyle(
                          fontSize: 14, color: SchooKeepColors.textSecondary),
                    ),
                    style: const TextStyle(
                        fontSize: 14, color: SchooKeepColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<VicePrincipalMessagesCubit, DataState<List<Message>>>(
            builder: (context, state) {
              return switch (state) {
                DataLoading() => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                DataError(:final message) => _error(message),
                DataLoaded(:final data) => _list(data),
              };
            },
          ),
        ],
      ),
    );
  }

  Widget _list(List<Message> all) {
    final q = _searchQuery.toLowerCase();
    final filtered = all.where((m) {
      if (q.isEmpty) return true;
      return (m.senderName ?? '').toLowerCase().contains(q) ||
          (m.subject ?? '').toLowerCase().contains(q) ||
          (m.body ?? '').toLowerCase().contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return const SchooKeepCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No messages',
                style: TextStyle(color: SchooKeepColors.textSecondary)),
          ),
        ),
      );
    }

    return SchooKeepCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < filtered.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            _messageRow(filtered[i]),
          ],
        ],
      ),
    );
  }

  Widget _messageRow(Message m) {
    final unread = (m.status ?? '') == 'unread';
    final preview = (m.body ?? '').isNotEmpty ? m.body! : (m.subject ?? '');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedThread = m),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(_initials(m.senderName),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(m.senderName ?? 'Unknown',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: SchooKeepColors.textPrimary)),
                        ),
                        const SizedBox(width: 8),
                        Text(_date(m.createdAt),
                            style: const TextStyle(
                                fontSize: 11,
                                color: SchooKeepColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            unread ? FontWeight.w500 : FontWeight.normal,
                        color: unread
                            ? SchooKeepColors.textPrimary
                            : SchooKeepColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(m.category ?? '',
                            style: const TextStyle(
                                fontSize: 11,
                                color: SchooKeepColors.textSecondary)),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: SchooKeepColors.primary,
                                shape: BoxShape.circle),
                          ),
                        ],
                      ],
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

  Widget _error(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.error),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertCircle,
                  size: 20, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 13,
                        color: SchooKeepColors.error,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SchooKeepButton(
            label: 'Retry', fullWidth: false, onPressed: _reload),
      ],
    );
  }
}
