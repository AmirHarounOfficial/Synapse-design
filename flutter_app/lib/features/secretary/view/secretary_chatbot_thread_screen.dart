import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:schookeep/core/router/safe_back.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/chatbot.dart';
import '../../../data/repositories/chatbot_repository.dart';
import '../cubit/secretary_chatbot_thread_cubit.dart';

/// Secretary chatbot-thread screen, wired to `GET /chatbot-conversations/{id}`
/// and `POST /chatbot-conversations/{id}/messages`. Reached from the
/// chatbot-escalations queue ("View conversation & reply",
/// `/secretary/chatbot-thread/:id`). Renders the parent/bot/staff transcript as
/// chat bubbles (parent right, bot/staff left) plus a reply composer that posts
/// a staff message through the cubit.
class SecretaryChatbotThreadScreen extends StatelessWidget {
  const SecretaryChatbotThreadScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final parsedId = int.tryParse(id) ?? 0;
    return BlocProvider(
      create: (_) => SecretaryChatbotThreadCubit(sl<ChatbotRepository>(), parsedId),
      child: const _SecretaryChatbotThreadView(),
    );
  }
}

class _SecretaryChatbotThreadView extends StatefulWidget {
  const _SecretaryChatbotThreadView();

  @override
  State<_SecretaryChatbotThreadView> createState() => _SecretaryChatbotThreadViewState();
}

class _SecretaryChatbotThreadViewState extends State<_SecretaryChatbotThreadView> {
  final TextEditingController _replyController = TextEditingController();
  String _reply = '';

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final body = _reply.trim();
    if (body.isEmpty) return;
    final cubit = context.read<SecretaryChatbotThreadCubit>();
    FocusScope.of(context).unfocus();
    final ok = await cubit.sendReply(body);
    if (!mounted) return;
    if (ok) {
      _replyController.clear();
      setState(() => _reply = '');
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Could not send reply. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: 'Conversation',
        centerTitle: true,
        onBack: () =>
            context.canPop() ? context.safeBack() : context.go('/secretary/chatbot'),
      ),
      body: BlocBuilder<SecretaryChatbotThreadCubit, DataState<ChatbotConversation>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorBanner(context, message),
            DataLoaded(:final data) => _body(data),
          };
        },
      ),
      bottomBar: BlocBuilder<SecretaryChatbotThreadCubit, DataState<ChatbotConversation>>(
        builder: (context, state) {
          if (state is! DataLoaded<ChatbotConversation>) return const SizedBox.shrink();
          return _composer();
        },
      ),
    );
  }

  Widget _errorBanner(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.messageCircle, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: 'Retry',
              fullWidth: false,
              onPressed: () => context.read<SecretaryChatbotThreadCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(ChatbotConversation c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _parentHeader(c),
        const SizedBox(height: 12),
        _escalationBanner(),
        const SizedBox(height: 16),
        if (c.messages.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('No messages yet',
                  style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
            ),
          )
        else
          for (final m in c.messages) ...[
            _bubble(m),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _parentHeader(ChatbotConversation c) {
    return SchooKeepCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: Text(_initials(c.parentName),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(c.parentName ?? 'Parent',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    ),
                    if (c.priority == 'high') ...[
                      const SizedBox(width: 8),
                      const SchooKeepBadge(
                        label: 'High priority',
                        background: Color(0xFFFEE2E2),
                        foreground: SchooKeepColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ],
                ),
                if (c.subject?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(c.subject!,
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _escalationBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.bot, size: 16, color: SchooKeepColors.primary),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "This conversation was escalated because the AI chatbot couldn't provide "
              "a satisfactory answer. Review the transcript and reply to help the parent.",
              style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(ChatbotMessage m) {
    // Parent messages align to the reading-start side; bot/staff to the end.
    final isParent = m.sender == 'parent';
    final isStaff = m.sender == 'staff';
    final align = isParent ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd;
    final bg = isParent ? SchooKeepColors.surface : SchooKeepColors.primary;
    final fg = isParent ? SchooKeepColors.textPrimary : Colors.white;
    final label = isParent
        ? 'Parent'
        : isStaff
            ? 'Staff'
            : 'AI Chatbot';
    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment: isParent ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary)),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: isParent ? Border.all(color: SchooKeepColors.border) : null,
            ),
            child: Text(m.body ?? '', style: TextStyle(fontSize: 14, height: 1.4, color: fg)),
          ),
        ],
      ),
    );
  }

  Widget _composer() {
    final canSend = _reply.trim().isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              onChanged: (v) => setState(() => _reply = v),
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: canSend ? SchooKeepColors.primary : const Color(0xFFE5E7EB),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: canSend ? _sendReply : null,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(LucideIcons.send, size: 20, color: canSend ? Colors.white : const Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
