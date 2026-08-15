import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/chatbot.dart';
import '../../../data/repositories/chatbot_repository.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentChatbotAssistant.tsx`. A full-screen chat with the
/// "SchooKeep Assistant", wired to `POST /chatbot-conversations`. The first send
/// calls [ChatbotRepository.start] (creating a persisted conversation that shows
/// up in the secretary escalation queue); subsequent sends call
/// [ChatbotRepository.postMessage]. A local bot greeting is shown for instant UX
/// before the first send.
class ParentChatbotAssistantScreen extends StatefulWidget {
  const ParentChatbotAssistantScreen({super.key});

  @override
  State<ParentChatbotAssistantScreen> createState() =>
      _ParentChatbotAssistantScreenState();
}

class _ChatMessage {
  _ChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    required this.timestamp,
  });

  final String id;
  final String text;
  final bool isBot;
  final String timestamp;
}

class _ParentChatbotAssistantScreenState
    extends State<ParentChatbotAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotRepository _repo = sl<ChatbotRepository>();

  // Simulate school hours check (in real app, based on actual time).
  static const bool _isSchoolClosed = false;

  /// Set once the first message creates a persisted conversation; drives the
  /// start-vs-postMessage branch in [_handleSend].
  int? _conversationId;
  bool _sending = false;

  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    final isRTL = context.read<LocaleCubit>().state.isRTL;
    // Local greeting only — shown instantly before the first send creates the
    // real conversation (whose own bot greeting then replaces this list).
    _messages = [
      _ChatMessage(
        id: 'greeting',
        text: isRTL
            ? 'مرحباً! أنا مساعد سكوكيب. كيف يمكنني مساعدتك اليوم؟'
            : 'Hello! I am SchooKeep Assistant. How can I help you today?',
        isBot: true,
        timestamp: _now(),
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _now() => _formatTime(DateTime.now());

  static String _formatTime(DateTime? dt) {
    final local = (dt ?? DateTime.now()).toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// Maps a persisted [ChatbotMessage] to a chat bubble. `parent` sits on the
  /// right; `bot`/`staff` on the left, matching the existing design.
  _ChatMessage _fromApi(ChatbotMessage m) => _ChatMessage(
        id: m.id.toString(),
        text: m.body ?? '',
        isBot: m.sender != 'parent',
        timestamp: _formatTime(m.createdAt),
      );

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _handleSend() async {
    final isRTL = context.read<LocaleCubit>().state.isRTL;
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    _controller.clear();
    // Optimistic parent bubble for instant UX; reconciled with server truth
    // once the awaited call returns.
    final tempId = 'local-${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _sending = true;
      _messages.add(_ChatMessage(
        id: tempId,
        text: text,
        isBot: false,
        timestamp: _now(),
      ));
    });
    _scrollToBottom();

    try {
      if (_conversationId == null) {
        // FIRST send: create a persisted conversation (subject = first ~40
        // chars). The returned conversation carries the bot greeting + this
        // parent message, so we replace the local list with server truth.
        final subject = text.length > 40 ? text.substring(0, 40) : text;
        final conv = await _repo.start(subject: subject, body: text);
        if (!mounted) return;
        _conversationId = conv.id;
        setState(() {
          _messages
            ..clear()
            ..addAll(conv.messages.map(_fromApi));
        });
      } else {
        // SUBSEQUENT sends: persist the message and swap the optimistic bubble
        // for the returned, server-assigned one.
        final msg = await _repo.postMessage(_conversationId!, text);
        if (!mounted) return;
        setState(() {
          final i = _messages.indexWhere((m) => m.id == tempId);
          if (i >= 0) {
            _messages[i] = _fromApi(msg);
          } else {
            _messages.add(_fromApi(msg));
          }
        });
      }
      _scrollToBottom();

      // Lightweight local acknowledgement (not persisted) — preserves the
      // existing "assistant replies" feel while a human/staff follows up.
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _messages.add(_ChatMessage(
            id: 'ack-${DateTime.now().millisecondsSinceEpoch}',
            text: isRTL
                ? 'فهمت. دعني أساعدك في ذلك.'
                : 'I understand. Let me help you with that.',
            isBot: true,
            timestamp: _now(),
          ));
        });
        _scrollToBottom();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ChatbotRepository.messageFor(e))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      scrollable: false,
      backgroundColor: SchooKeepColors.background,
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        titleWidget: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: SchooKeepColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('S',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Text(
              isRTL ? 'مساعد سكوكيب' : 'SchooKeep Assistant',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.textPrimary),
            ),
          ],
        ),
        actions: const [
          SizedBox(
            width: 44,
            height: 44,
            child: Icon(LucideIcons.info,
                size: 24, color: SchooKeepColors.textPrimary),
          ),
        ],
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Disclaimer banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: SchooKeepColors.background,
              border: Border(top: BorderSide(color: SchooKeepColors.border)),
            ),
            child: Text(
              isRTL
                  ? 'لا يمكن لهذا المساعد تقديم استشارات طبية.'
                  : 'This assistant cannot provide medical advice.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: SchooKeepColors.textSecondary),
            ),
          ),
          // Input bar
          Container(
            color: SchooKeepColors.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isRTL
                              ? 'إرفاق الملفات غير متاح بعد.'
                              : 'File attachments are not available yet.'),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.paperclip,
                        size: 20, color: SchooKeepColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _handleSend(),
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText:
                            isRTL ? 'اكتب رسالة...' : 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide:
                              const BorderSide(color: SchooKeepColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide:
                              const BorderSide(color: SchooKeepColors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Opacity(
                  opacity: _controller.text.trim().isEmpty ? 0.4 : 1,
                  child: Material(
                    color: SchooKeepColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _controller.text.trim().isEmpty
                          ? null
                          : _handleSend,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(LucideIcons.send,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSchoolClosed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: SchooKeepColors.amberChipBg,
                border:
                    Border(bottom: BorderSide(color: SchooKeepColors.warning)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.alertTriangle,
                      size: 16, color: SchooKeepColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isRTL
                          ? '⚠ المدرسة مغلقة. سيرد المساعد على الأسئلة العامة. في حالات الطوارئ اتصل بـ 911.'
                          : '⚠ School is closed. The assistant will respond to general questions. For emergencies, call 911.',
                      style: const TextStyle(
                          fontSize: 12, color: SchooKeepColors.amberText),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _bubble(_messages[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(_ChatMessage msg) {
    final bubble = Column(
      crossAxisAlignment:
          msg.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: msg.isBot ? SchooKeepColors.surface : SchooKeepColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(msg.isBot ? 4 : 18),
              bottomRight: Radius.circular(msg.isBot ? 18 : 4),
            ),
            border: msg.isBot
                ? Border.all(color: SchooKeepColors.border)
                : null,
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: msg.isBot ? SchooKeepColors.textPrimary : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(msg.timestamp,
              style: const TextStyle(
                  fontSize: 11, color: SchooKeepColors.textSecondary)),
        ),
      ],
    );

    return Row(
      mainAxisAlignment:
          msg.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (msg.isBot) ...[
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('S',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.primary)),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: bubble,
          ),
        ),
      ],
    );
  }
}
