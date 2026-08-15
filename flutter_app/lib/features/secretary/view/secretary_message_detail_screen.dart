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
import '../cubit/secretary_message_detail_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Secretary message-detail screen (`/secretary/message/:id`), wired to
/// `GET /messages/{id}`. Marks the message read on open when unread, and a
/// Reply action posts to `POST /messages/{id}/reply`.
class SecretaryMessageDetailScreen extends StatelessWidget {
  const SecretaryMessageDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final parsedId = int.tryParse(id) ?? 0;
    return BlocProvider(
      create: (_) => SecretaryMessageDetailCubit(sl<MessageRepository>(), parsedId),
      child: const _SecretaryMessageDetailView(),
    );
  }
}

class _SecretaryMessageDetailView extends StatelessWidget {
  const _SecretaryMessageDetailView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: isRTL ? 'الرسالة' : 'Message',
        centerTitle: true,
        onBack: () =>
            context.canPop() ? context.safeBack() : context.go('/secretary/messages'),
      ),
      body: BlocBuilder<SecretaryMessageDetailCubit, DataState<Message>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
            DataError(:final message) => _errorView(context, message, isRTL),
            DataLoaded(:final data) => _content(context, data, isRTL),
          };
        },
      ),
    );
  }

  Widget _errorView(BuildContext context, String message, bool isRTL) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.mailX, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: isRTL ? 'إعادة المحاولة' : 'Retry',
              fullWidth: false,
              onPressed: () => context.read<SecretaryMessageDetailCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, Message m, bool isRTL) {
    final (catBg, catFg, catLabel) = _categoryStyle(m.category, isRTL);
    final from = (m.senderName ?? '').isNotEmpty ? m.senderName! : (isRTL ? 'غير معروف' : 'Unknown');
    return ListView(
      padding: const EdgeInsets.all(16),
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
                        Text(_time(m.createdAt),
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
          label: isRTL ? 'الرد' : 'Reply',
          onPressed: () => _openReplySheet(context, from, isRTL),
        ),
      ],
    );
  }

  void _openReplySheet(BuildContext context, String from, bool isRTL) {
    final cubit = context.read<SecretaryMessageDetailCubit>();
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ReplySheet(
          cubit: cubit,
          controller: controller,
          from: from,
          isRTL: isRTL,
        );
      },
    ).whenComplete(controller.dispose);
  }

  (Color bg, Color fg, String label) _categoryStyle(String? category, bool isRTL) {
    switch (category) {
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

  static String _time(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final h12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} '
        '${h12.toString().padLeft(2, '0')}:$m $ampm';
  }
}

/// Bottom-sheet reply composer used by the message-detail screen.
class _ReplySheet extends StatefulWidget {
  const _ReplySheet({
    required this.cubit,
    required this.controller,
    required this.from,
    required this.isRTL,
  });

  final SecretaryMessageDetailCubit cubit;
  final TextEditingController controller;
  final String from;
  final bool isRTL;

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  bool _sending = false;

  Future<void> _send() async {
    final body = widget.controller.text.trim();
    if (body.isEmpty || _sending) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);
    final ok = await widget.cubit.reply(body);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(widget.isRTL ? 'تم إرسال الرد' : 'Reply sent to ${widget.from}')));
    } else {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(widget.isRTL ? 'تعذر إرسال الرد' : 'Could not send the reply')));
    }
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
              controller: widget.controller,
              minLines: 3,
              maxLines: 6,
              autofocus: true,
              style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: widget.isRTL ? 'اكتب ردك...' : 'Type your reply...',
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
                  : (widget.isRTL ? 'إرسال' : 'Send reply'),
              onPressed: _sending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
