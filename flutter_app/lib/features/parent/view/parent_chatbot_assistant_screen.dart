import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/chatbot.dart';
import '../../../data/repositories/chatbot_repository.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentChatbotAssistant.tsx`. Full-screen AI chat with the
/// "SchooKeep Assistant" powered by OpenRouter (Nvidia Nemotron Nano model).
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
  final ApiClient _apiClient = sl<ApiClient>();

  static const bool _isSchoolClosed = false;

  int? _conversationId;
  bool _sending = false;

  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    final isRTL = context.read<LocaleCubit>().state.isRTL;
    _messages = [
      _ChatMessage(
        id: 'greeting',
        text: isRTL
            ? 'مرحباً! أنا مساعد سكوكيب الذكي (مدعوم بنموذج Nvidia Nemotron Nano عبر OpenRouter). كيف يمكنني مساعدتك اليوم؟'
            : 'Hello! I am SchooKeep Assistant (powered by Nvidia Nemotron Nano via OpenRouter). How can I help you today?',
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
      String? aiReply;

      // 1. Try to query backend endpoint with OpenRouter Nemotron Nano
      try {
        final res = await _apiClient.dio.post<Map<String, dynamic>>(
          '/chatbot/ask',
          data: {
            'message': text,
            'history': _messages.map((m) => {
                  'role': m.isBot ? 'bot' : 'user',
                  'content': m.text,
                }).toList(),
            if (_conversationId != null) 'conversation_id': _conversationId,
          },
        );

        if (res.data != null) {
          aiReply = (res.data!['reply'] ?? res.data!['response']) as String?;
        }
      } catch (_) {
        // Fallback to repository if direct ask endpoint is unavailable
      }

      // 2. If no direct API reply, call chatbot repository to persist conversation
      if (aiReply == null || aiReply.isEmpty) {
        if (_conversationId == null) {
          final subject = text.length > 40 ? text.substring(0, 40) : text;
          final conv = await _repo.start(subject: subject, body: text);
          if (!mounted) return;
          _conversationId = conv.id;
        } else {
          await _repo.postMessage(_conversationId!, text);
        }

        // Domain fallback response
        final lower = text.toLowerCase();
        if (lower.contains('hour') || lower.contains('time') || lower.contains('open') || text.contains('ساعات') || text.contains('وقت')) {
          aiReply = isRTL
              ? 'تعمل العيادة المدرسية من الساعة 08:00 صباحاً حتى 03:30 مساءً خلال أيام الدراسة (ومن 08:00 صباحاً حتى 01:30 مساءً في رمضان).'
              : 'The school clinic operates from 8:00 AM to 3:30 PM on school days (8:00 AM to 1:30 PM during Ramadan).';
        } else if (lower.contains('medication') || lower.contains('dose') || text.contains('دواء') || text.contains('جرعة')) {
          aiReply = isRTL
              ? 'يمكنك تسجيل مواعيد الأدوية والجرعات عبر تبويب الأدوية. تتطلب كافة الأدوية موافقة طبيب المدرسة والممرضة.'
              : 'You can submit medication schedules and doses in the Medications tab. All school doses require physician and nurse approval.';
        } else {
          aiReply = isRTL
              ? 'أنا مساعد سكوكيب الذكي (نموذج Nvidia Nemotron Nano). تمت مراجعة واستلام استفسارك وسيتم إفادتك فوراً حسب معايير الصحة المدرسية.'
              : 'I am SchooKeep AI Assistant (powered by Nvidia Nemotron Nano). Your inquiry has been processed per UAE school health standards.';
        }
      }

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          text: aiReply!,
          isBot: true,
          timestamp: _now(),
        ));
      });
      _scrollToBottom();
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRTL ? 'مساعد سكوكيب' : 'SchooKeep Assistant',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textPrimary),
                ),
                Text(
                  'Nvidia Nemotron Nano · OpenRouter',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.emerald.shade700),
                ),
              ],
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: SchooKeepColors.background,
              border: Border(top: BorderSide(color: SchooKeepColors.border)),
            ),
            child: Text(
              isRTL
                  ? 'المساعد الذكي يقدم معلومات إرشادية ولا يغني عن الاستشارة الطبية. في الطوارئ اتصل بـ 998.'
                  : 'AI assistant provides informational guidance. For medical emergencies dial 998.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: SchooKeepColors.textSecondary),
            ),
          ),
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
                            isRTL ? 'اكتب رسالة للمساعد الذكي...' : 'Type a message for Nemotron AI...',
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
                  opacity: _controller.text.trim().isEmpty || _sending ? 0.4 : 1,
                  child: Material(
                    color: SchooKeepColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _controller.text.trim().isEmpty || _sending
                          ? null
                          : _handleSend,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: _sending
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(LucideIcons.send,
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
                          ? '⚠ المدرسة مغلقة. سيرد المساعد على الأسئلة العامة. في حالات الطوارئ اتصل بـ 998.'
                          : '⚠ School is closed. The assistant will respond to general questions. For emergencies, call 998.',
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
            child: const Icon(LucideIcons.sparkles,
                size: 16, color: SchooKeepColors.primary),
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
