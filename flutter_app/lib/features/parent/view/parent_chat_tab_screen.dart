import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ParentChatTab.tsx`. Messages tab listing conversations with the
/// SchooKeep assistant bot and school staff. Tapping the bot conversation opens
/// the chatbot assistant.
class ParentChatTabScreen extends StatelessWidget {
  const ParentChatTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    final conversations = <({String type, String name, String lastMessage, String time, int unread})>[
      (
        type: 'bot',
        name: isRTL ? 'مساعد سكوكيب' : 'SchooKeep Assistant',
        lastMessage: isRTL ? 'تفتح عيادة المدرسة الساعة 8:00 صباحاً في أيام الدراسة...' : 'The school clinic opens at 8:00 AM on school days...',
        time: '2:45 PM',
        unread: 0,
      ),
      (
        type: 'staff',
        name: isRTL ? 'ممرضة المدرسة' : 'School Nurse',
        lastMessage: isRTL ? 'تعاملت مايا بشكل رائع مع دوائها اليوم.' : 'Maya did great with her medication today.',
        time: '2:30 PM',
        unread: 1,
      ),
      (
        type: 'staff',
        name: isRTL ? 'سكرتير المدرسة' : 'School Secretary',
        lastMessage: isRTL ? 'يمكنني مساعدتك في جدولة اجتماع.' : 'I can help you schedule a meeting.',
        time: isRTL ? 'أمس' : 'Yesterday',
        unread: 0,
      ),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(title: isRTL ? 'الرسائل' : 'Messages'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (int i = 0; i < conversations.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _conversationCard(context, conversations[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _conversationCard(
    BuildContext context,
    ({String type, String name, String lastMessage, String time, int unread}) conv,
  ) {
    final isBot = conv.type == 'bot';
    return SchooKeepCard(
      onTap: isBot ? () => context.go('/parent/app/chatbot-assistant') : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isBot ? const Color(0xFFEFF6FF) : const Color(0xFFF0F9FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isBot ? LucideIcons.bot : LucideIcons.user,
              size: 24,
              color: isBot ? SchooKeepColors.primary : const Color(0xFF0369A1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(conv.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    Text(conv.time, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ),
                    if (conv.unread > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('${conv.unread}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
