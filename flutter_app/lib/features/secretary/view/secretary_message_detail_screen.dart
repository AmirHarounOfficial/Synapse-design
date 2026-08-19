import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/message.dart';
import '../../../data/repositories/message_repository.dart';
import '../cubit/secretary_message_detail_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

class SecretaryMessageDetailScreen extends StatelessWidget {
  const SecretaryMessageDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final parsedId = int.tryParse(id) ?? 0;
    return BlocProvider(
      create: (_) => SecretaryMessageDetailCubit(sl<MessageRepository>(), parsedId),
      child: _SecretaryMessageDetailView(id: parsedId),
    );
  }
}

class _SecretaryMessageDetailView extends StatelessWidget {
  const _SecretaryMessageDetailView({required this.id});

  final int id;

  static final Map<int, Message> _fallbackMessages = {
    1: Message(
      id: 1,
      schoolId: 1,
      senderName: 'James Thompson',
      subject: "Re: Maya's medication schedule",
      body: "Hello,\n\nThank you for clarifying the medication schedule for Maya. Could you confirm if the afternoon dose should be taken with lunch or strictly at 1:30 PM?\n\nBest regards,\nJames Thompson",
      status: 'read',
      category: 'parents',
    ),
    2: Message(
      id: 2,
      schoolId: 1,
      senderName: 'Sarah Williams',
      subject: 'Document expiry reminder',
      body: "Hi Secretary,\n\nI received an automated reminder about an expiring document. Could you help me understand which form needs to be updated and where to upload it?\n\nThank you,\nSarah Williams",
      status: 'read',
      category: 'parents',
    ),
    3: Message(
      id: 3,
      schoolId: 1,
      senderName: 'Nurse Chen',
      subject: '[Copy] Emergency consent sent',
      body: "Automatic Copy for School Administration:\n\nEmergency medical consent form has been dispatched to Maya Thompson's parent for digital signature.\n\nSender: Clinic Office",
      status: 'read',
      category: 'clinic',
    ),
    4: Message(
      id: 4,
      schoolId: 1,
      senderName: 'Carlos Martinez',
      subject: 'Pickup authorization',
      body: "Dear Administration,\n\nI need to add my mother (Elena Martinez) to the approved pickup list for my son starting tomorrow. Please let me know what documents are required.\n\nThank you,\nCarlos",
      status: 'read',
      category: 'parents',
    ),
    5: Message(
      id: 5,
      schoolId: 1,
      senderName: 'Nurse Chen',
      subject: '[Copy] Medication administered',
      body: "Automatic Copy for School Records:\n\nMedication (Methylphenidate 10mg) administered to Ethan Williams at 08:05 AM.\n\nAdministered by: Nurse Chen",
      status: 'read',
      category: 'clinic',
    ),
  };

  static Message _getLocalizedMessage(BuildContext context, Message m) {
    if (!context.isRTL) return m;
    switch (m.id) {
      case 1:
        return Message(
          id: 1,
          schoolId: m.schoolId,
          senderName: 'جيمس طومسون (ولي أمر)',
          subject: 'رد: جدول أدوية مايا طومسون',
          body: 'مرحباً،\n\nشكراً جزيلاً لك على توضيح جدول الأدوية الخاص بالطالبة مايا. هل يمكنك التأكيد لي ما إذا كانت جرعة ما بعد الظهر تُؤخذ مع وجبة الغداء أم في الساعة 1:30 ظهراً بالظبط؟\n\nمع خالص التقدير،\nجيمس طومسون',
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
          body: 'عزيزي السكرتير/ة،\n\nتلقيت تذكيراً آلياً بشأن انتهاء صلاحية إحدى الوثائق. هل يمكنك مساعدتي لمعرفة النموذج المحدد الذي يحتاج إلى تحديث وأين يجب تحميلة؟\n\nشكراً لك،\nسارة ويليامز',
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
          body: 'نسخة تلقائية مخصصة لإدارة المدرسة:\n\nتم إرسال نموذج الموافقة الطبية في حالات الطوارئ إلى ولي أمر الطالبة مايا طومسون للتوقيع الرقمي.\n\nالمرسل: مكتب العيادة المدرسية',
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
          body: 'عزيزتي إدارة المدرسة،\n\nأود إضافة والدتي (إيلينا مارتينيز) إلى قائمة الأشخاص المصرح لهم باستلام ابني اعتباراً من الغد. يرجى إعلامي بالوثائق المطلوبة.\n\nشكراً لكم،\nكارلوس',
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
          body: 'نسخة تلقائية لسجلات المدرسة:\n\nتم إعطاء الدواء (ميثيلفينيديت 10 ملغ) للطالب إيثان ويليامز في تمام الساعة 08:05 صباحاً.\n\nبواسطة: الممرضة تشين',
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
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'الرسالة' : 'Message',
        centerTitle: true,
        onBack: () =>
            context.canPop() ? context.safeBack() : context.go('/secretary/messages'),
      ),
      body: BlocBuilder<SecretaryMessageDetailCubit, DataState<Message>>(
        builder: (context, state) {
          final rawMessage = switch (state) {
            DataLoaded(:final data) => data,
            _ => _fallbackMessages[id] ??
                Message(
                  id: id,
                  schoolId: 1,
                  senderName: 'Parent / Staff',
                  subject: 'School Communication',
                  body: 'Communication body details for message #$id',
                  status: 'read',
                  category: 'general',
                ),
          };
          final messageData = _getLocalizedMessage(context, rawMessage);

          return _content(context, messageData, isRTL);
        },
      ),
    );
  }

  Widget _content(BuildContext context, Message m, bool isRTL) {
    final (catBg, catFg, catLabel) = _categoryStyle(m.category, isRTL);
    final from = (m.senderName ?? '').isNotEmpty ? m.senderName! : (isRTL ? 'غير معروف' : 'Unknown');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SchooKeepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                      child: Text(_initials(from),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(from,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(_time(context, m.createdAt),
                              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                        ],
                      ),
                    ),
                    SchooKeepBadge(label: catLabel, background: catBg, foreground: catFg, fontSize: 11),
                  ],
                ),
                const SizedBox(height: 16),
                Text((m.subject ?? '').isNotEmpty ? m.subject! : (isRTL ? '(بدون موضوع)' : '(No subject)'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Text(m.body ?? '',
                      style: const TextStyle(fontSize: 14, height: 1.6, color: SchooKeepColors.textPrimary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SchooKeepButton(
            label: isRTL ? 'الرد على الرسالة' : 'Reply to message',
            onPressed: () => _openReplySheet(context, from, isRTL),
          ),
        ],
      ),
    );
  }

  void _openReplySheet(BuildContext context, String from, bool isRTL) {
    final cubit = context.read<SecretaryMessageDetailCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ReplySheet(
          cubit: cubit,
          from: from,
          isRTL: isRTL,
        );
      },
    );
  }

  (Color bg, Color fg, String label) _categoryStyle(String? category, bool isRTL) {
    switch (category) {
      case 'parents':
        return (const Color(0xFFEFF6FF), const Color(0xFF2563EB), isRTL ? 'أولياء الأمور' : 'Parents');
      case 'clinic':
        return (const Color(0xFFF0F9FF), const Color(0xFF0369A1), isRTL ? 'العيادة الطبية' : 'Clinic');
      case 'sent':
        return (const Color(0xFFD1FAE5), const Color(0xFF065F46), isRTL ? 'مرسلة' : 'Sent');
      case 'urgent':
        return (const Color(0xFFFEE2E2), SchooKeepColors.error, isRTL ? 'عاجل' : 'Urgent');
      case 'health':
        return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF), isRTL ? 'صحة' : 'Health');
      case 'attendance':
        return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText, isRTL ? 'الحضور' : 'Attendance');
      case 'general':
      default:
        return (const Color(0xFFEDE9FE), const Color(0xFF6D28D9), isRTL ? 'عام' : 'General');
    }
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  static String _time(BuildContext context, DateTime? dt) {
    if (dt == null) return context.tr(en: 'Today at 10:45 AM', ar: 'اليوم 10:45 صباحاً');
    final local = dt.toLocal();
    final h12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} '
        '${h12.toString().padLeft(2, '0')}:$m $ampm';
  }
}

class _ReplySheet extends StatefulWidget {
  const _ReplySheet({
    required this.cubit,
    required this.from,
    required this.isRTL,
  });

  final SecretaryMessageDetailCubit cubit;
  final String from;
  final bool isRTL;

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  late final TextEditingController _controller;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    final messenger = ScaffoldMessenger.of(context);
    final isRTL = widget.isRTL;
    final from = widget.from;
    setState(() => _sending = true);
    await widget.cubit.reply(body);
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(isRTL
              ? 'تم إرسال الرد بنجاح إلى $from'
              : 'Reply sent to $from')));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isRTL ? 'الرد على ${widget.from}' : 'Reply to ${widget.from}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    widget.isRTL ? 'إغلاق' : 'Close',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              autofocus: true,
              style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: widget.isRTL ? 'اكتب ردك هنا...' : 'Type your reply...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.all(12),
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
            const SizedBox(height: 12),
            SchooKeepButton(
              label: _sending
                  ? (widget.isRTL ? 'جارٍ الإرسال...' : 'Sending...')
                  : (widget.isRTL ? 'إرسال الرد' : 'Send reply'),
              onPressed: _sending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
