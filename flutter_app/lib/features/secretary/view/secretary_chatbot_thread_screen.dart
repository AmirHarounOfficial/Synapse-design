import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:schookeep/core/router/safe_back.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/chatbot.dart';
import '../../../data/repositories/chatbot_repository.dart';
import '../cubit/secretary_chatbot_thread_cubit.dart';

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
        ..showSnackBar(SnackBar(content: Text(context.tr(en: 'Could not send reply. Please try again.', ar: 'تعذر إرسال الرد. يُرجى المحاولة مرة أخرى.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Conversation', ar: 'المحادثة والاستفسار'),
        centerTitle: true,
        onBack: () =>
            context.canPop() ? context.safeBack() : context.go('/secretary/chatbot'),
      ),
      body: BlocBuilder<SecretaryChatbotThreadCubit, DataState<ChatbotConversation>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorBanner(context, message),
            DataLoaded(:final data) => _body(context, data),
          };
        },
      ),
      bottomBar: BlocBuilder<SecretaryChatbotThreadCubit, DataState<ChatbotConversation>>(
        builder: (context, state) {
          if (state is! DataLoaded<ChatbotConversation>) return const SizedBox.shrink();
          return _composer(context);
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
              label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
              fullWidth: false,
              onPressed: () => context.read<SecretaryChatbotThreadCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ChatbotConversation c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _parentHeader(context, c),
        const SizedBox(height: 12),
        _escalationBanner(context),
        const SizedBox(height: 16),
        if (c.messages.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(context.tr(en: 'No messages yet', ar: 'لا توجد رسائل سابقة في هذه المحادثة'),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
            ),
          )
        else
          for (final m in c.messages) ...[
            _bubble(context, m),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _parentHeader(BuildContext context, ChatbotConversation c) {
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
                      child: Text(c.parentName ?? context.tr(en: 'Parent', ar: 'ولي الأمر'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    ),
                    if (c.priority == 'high') ...[
                      const SizedBox(width: 8),
                      SchooKeepBadge(
                        label: context.tr(en: 'High priority', ar: 'أولوية عالية'),
                        background: const Color(0xFFFEE2E2),
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

  Widget _escalationBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.bot, size: 16, color: SchooKeepColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr(
                en: "This conversation was escalated because the AI chatbot couldn't provide a satisfactory answer. Review the transcript and reply to help the parent.",
                ar: 'تم تحويل هذه المحادثة من المساعد الآلي للسكرتارية. يُرجى الاطلاع على السجل وإرسال الرد لتوضيح الأمر لولي الأمر.',
              ),
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(BuildContext context, ChatbotMessage m) {
    final isParent = m.sender == 'parent';
    final isStaff = m.sender == 'staff';
    final align = isParent ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd;
    final bg = isParent ? SchooKeepColors.surface : SchooKeepColors.primary;
    final fg = isParent ? SchooKeepColors.textPrimary : Colors.white;
    final label = isParent
        ? context.tr(en: 'Parent', ar: 'ولي الأمر')
        : isStaff
            ? context.tr(en: 'Staff', ar: 'السكرتارية / الكادر الإداري')
            : context.tr(en: 'AI Chatbot', ar: 'المساعد الآلي');
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

  Widget _composer(BuildContext context) {
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
                hintText: context.tr(en: 'Type your reply...', ar: 'اكتب نص الرد المباشر...'),
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
                child: RtlIcon(LucideIcons.send, size: 20, color: canSend ? Colors.white : const Color(0xFF9CA3AF)),
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
