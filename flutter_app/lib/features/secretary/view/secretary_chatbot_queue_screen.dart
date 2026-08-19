import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/chatbot.dart';
import '../../../data/repositories/chatbot_repository.dart';
import '../cubit/secretary_chatbot_queue_cubit.dart';

class SecretaryChatbotQueueScreen extends StatelessWidget {
  const SecretaryChatbotQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecretaryChatbotQueueCubit(sl<ChatbotRepository>())..load(),
      child: const _SecretaryChatbotQueueView(),
    );
  }
}

class _SecretaryChatbotQueueView extends StatelessWidget {
  const _SecretaryChatbotQueueView();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Chatbot Escalations', ar: 'تصعيدات المساعد الآلي'),
        actions: const [_BellAction()],
      ),
      body: BlocBuilder<SecretaryChatbotQueueCubit, DataState<List<ChatbotConversation>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _errorBanner(context, message),
            DataLoaded(:final data) => _content(context, data),
          };
        },
      ),
    );
  }

  Widget _errorBanner(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
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
                const Icon(LucideIcons.alertCircle, size: 20, color: SchooKeepColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 13,
                      color: SchooKeepColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SchooKeepButton(
            label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
            fullWidth: false,
            onPressed: () => context.read<SecretaryChatbotQueueCubit>().load(),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, List<ChatbotConversation> conversations) {
    final resolved = conversations.where((c) => c.status == 'resolved').length;
    final pending = conversations.where((c) => c.status == 'pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr(en: 'AI Chatbot Escalations', ar: 'محادثات محولة من البوت الذكي'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E40AF))),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(
                          en: "These conversations were escalated because the AI couldn't provide a satisfactory answer. Review and respond to help the parent.",
                          ar: 'تم تصعيد هذه الاستفسارات للسكرتارية لعدم وجود إجابة آلية مباشرة لدى البوت. يُرجى المراجعة والرد على ولي الأمر.',
                        ),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('${context.tr(en: 'Pending Escalations', ar: 'التصعيدات قيد الانتظار')} (${conversations.length})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          if (conversations.isEmpty)
            SchooKeepCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(context.tr(en: 'No escalations right now', ar: 'لا توجد تصعيدات معلقة في الوقت الحالي'),
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                ),
              ),
            )
          else
            SchooKeepCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < conversations.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _escalationCard(context, conversations[i]),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),

          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(en: "Today's Stats", ar: 'إحصائيات اليوم'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Stat(value: '$resolved', label: context.tr(en: 'Resolved', ar: 'تم حله'), color: SchooKeepColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(value: '$pending', label: context.tr(en: 'Pending', ar: 'قيد الانتظار'), color: SchooKeepColors.warning)),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(value: '2.4', label: context.tr(en: 'Avg response (hrs)', ar: 'معدل الاستجابة (ساعة)'), color: SchooKeepColors.accent)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _escalationCard(BuildContext context, ChatbotConversation c) {
    final question = c.subject?.isNotEmpty == true
        ? c.subject!
        : (c.firstMessage ?? c.latestMessage ?? '');
    final (statusBg, statusFg, statusLabel) = _statusStyle(context, c.status);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
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
                    Text(c.parentName ?? context.tr(en: 'Parent', ar: 'ولي الأمر'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        SchooKeepBadge(
                          label: statusLabel,
                          background: statusBg,
                          foreground: statusFg,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        if (c.priority == 'high')
                          SchooKeepBadge(
                            label: context.tr(en: 'High priority', ar: 'أولوية عالية'),
                            background: const Color(0xFFFEE2E2),
                            foreground: SchooKeepColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                      ],
                    ),
                    if (question.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        question,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      context.tr(
                        en: '${c.messageCount} ${c.messageCount == 1 ? 'message' : 'messages'}',
                        ar: '${c.messageCount} رسائل في المحادثة',
                      ),
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go('/secretary/chatbot-thread/${c.id}'),
              child: Text(
                context.tr(en: 'View conversation & reply', ar: 'عرض المحادثة والرد'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static (Color bg, Color fg, String label) _statusStyle(BuildContext context, String? status) {
    switch (status) {
      case 'resolved':
        return (SchooKeepColors.greenChipBg, SchooKeepColors.greenChipText, context.tr(en: 'Resolved', ar: 'تم الرد والحسم'));
      case 'assigned':
        return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF), context.tr(en: 'Assigned', ar: 'معين للمتابعة'));
      case 'pending':
      default:
        return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText, context.tr(en: 'Pending', ar: 'قيد الانتظار'));
    }
  }

  static String _initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
      ],
    );
  }
}

class _BellAction extends StatelessWidget {
  const _BellAction();

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
    );
  }
}
