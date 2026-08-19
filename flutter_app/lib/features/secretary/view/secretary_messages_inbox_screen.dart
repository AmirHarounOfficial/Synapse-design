import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/message_repository.dart';
import '../cubit/secretary_messages_inbox_cubit.dart';

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

  static final List<Message> _mockMessages = [
    Message(
      id: 1,
      schoolId: 1,
      senderName: 'James Thompson',
      subject: "Re: Maya's medication schedule",
      body: "Re: Maya's medication schedule - Thank you for the clarification on the dosage times.",
      status: 'unread',
      category: 'parents',
    ),
    Message(
      id: 2,
      schoolId: 1,
      senderName: 'Sarah Williams',
      subject: 'Document expiry reminder',
      body: 'Document expiry reminder - Could you help me understand which form needs to be updated?',
      status: 'unread',
      category: 'parents',
    ),
    Message(
      id: 3,
      schoolId: 1,
      senderName: 'Nurse Chen',
      subject: '[Copy] Emergency consent sent',
      body: '[Copy] Emergency consent sent to Maya Thompson\'s parent.',
      status: 'read',
      category: 'clinic',
    ),
    Message(
      id: 4,
      schoolId: 1,
      senderName: 'Carlos Martinez',
      subject: 'Pickup authorization',
      body: 'Pickup authorization - I need to add my mother to the approved pickup list.',
      status: 'read',
      category: 'parents',
    ),
    Message(
      id: 5,
      schoolId: 1,
      senderName: 'Nurse Chen',
      subject: '[Copy] Medication administered',
      body: '[Copy] Medication administered - Ethan Williams.',
      status: 'read',
      category: 'clinic',
    ),
  ];

  static Message _getLocalizedMessage(BuildContext context, Message m) {
    if (!context.isRTL) return m;
    switch (m.id) {
      case 1:
        return Message(
          id: 1,
          schoolId: m.schoolId,
          senderName: 'جيمس طومسون (ولي أمر)',
          subject: 'رد: جدول أدوية مايا طومسون',
          body: 'رد: جدول أدوية مايا - شكراً جزيلاً على التوضيح الخاص بمواعيد وأوقات الجرعات الدوائية.',
          status: m.status,
          category: m.category,
          createdAt: m.createdAt,
        );
      case 2:
        return Message(
          id: 2,
          schoolId: m.schoolId,
          senderName: 'سارة ويليامز (ولي أمر)',
          subject: 'تذكير بانتهاء صلاحية المستندات',
          body: 'تذكير بانتهاء صلاحية المستندات - هل يمكن مساعدتي لمعرفة النموذج المطلوب تحديثه ورفعه؟',
          status: m.status,
          category: m.category,
          createdAt: m.createdAt,
        );
      case 3:
        return Message(
          id: 3,
          schoolId: m.schoolId,
          senderName: 'الممرضة تشين (العيادة)',
          subject: '[نسخة] تم إرسال نموذج موافقة الطوارئ',
          body: '[نسخة إدارية] تم إرسال نموذج الموافقة الطبية في حالات الطوارئ إلى ولي أمر الطالبة مايا طومسون.',
          status: m.status,
          category: m.category,
          createdAt: m.createdAt,
        );
      case 4:
        return Message(
          id: 4,
          schoolId: m.schoolId,
          senderName: 'كارلوس مارتينيز (ولي أمر)',
          subject: 'طلب تفويض استلام الطالب',
          body: 'تفويض استلام الطالب - أرغب في إضافة والدتي إلى قائمة الأشخاص المخولين بالاستلام من المدرسة.',
          status: m.status,
          category: m.category,
          createdAt: m.createdAt,
        );
      case 5:
        return Message(
          id: 5,
          schoolId: m.schoolId,
          senderName: 'الممرضة تشين (العيادة)',
          subject: '[نسخة] إعطاء الدواء في العيادة',
          body: '[نسخة إدارية] تم إعطاء الدواء المعتمد (ميثيلفينيديت 10 ملغ) للطالب إيثان ويليامز.',
          status: m.status,
          category: m.category,
          createdAt: m.createdAt,
        );
      default:
        return m;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              Expanded(
                child: BlocBuilder<SecretaryMessagesInboxCubit, DataState<List<Message>>>(
                  builder: (context, state) {
                    final data = switch (state) {
                      DataLoaded(:final data) when data.isNotEmpty => data,
                      _ => _mockMessages,
                    };
                    final localized = data.map((m) => _getLocalizedMessage(context, m)).toList();
                    return _list(context, localized);
                  },
                ),
              ),
            ],
          ),
          PositionedDirectional(
            bottom: 100,
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

  Widget _list(BuildContext context, List<Message> all) {
    final filtered = all.where((m) {
      if (_activeTab == 'all') return true;
      if (_activeTab == 'parents') return m.category == 'parents' || (m.senderName ?? '').contains('Thompson') || (m.senderName ?? '').contains('Williams') || (m.senderName ?? '').contains('Martinez') || (m.senderName ?? '').contains('ولي أمر');
      if (_activeTab == 'clinic') return m.category == 'clinic' || (m.senderName ?? '').contains('Nurse') || (m.senderName ?? '').contains('العيادة');
      return m.category == _activeTab;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<SecretaryMessagesInboxCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Center(
                child: Text(
                  context.tr(en: 'No messages in this category', ar: 'لا توجد رسائل في هذا القسم'),
                  style: const TextStyle(color: SchooKeepColors.textSecondary),
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
                    _messageRow(context, filtered[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final tabs = [
      (id: 'all', label: context.tr(en: 'All', ar: 'الكل')),
      (id: 'parents', label: context.tr(en: 'From Parents', ar: 'من أولياء الأمور')),
      (id: 'clinic', label: context.tr(en: 'Clinic Copies', ar: 'نسخ العيادة الطبية')),
      (id: 'sent', label: context.tr(en: 'Sent', ar: 'المرسلة')),
      (id: 'urgent', label: context.tr(en: 'Urgent', ar: 'عاجل')),
    ];

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
                  Expanded(
                    child: Text(
                      context.tr(en: 'Messages', ar: 'صندوق الرسائل والاتصالات'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _tabChip(tabs[i].id, tabs[i].label),
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

  Widget _messageRow(BuildContext context, Message message) {
    final unread = message.status == 'unread';
    final from = (message.senderName ?? '').isNotEmpty ? message.senderName! : context.tr(en: 'Unknown', ar: 'غير معروف');
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
                    Text(_time(context, message.createdAt),
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

  static String _time(BuildContext context, DateTime? dt) {
    if (dt == null) return context.tr(en: 'Today', ar: 'اليوم');
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
      return context.tr(en: 'Yesterday', ar: 'الأمس');
    }
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }
}
