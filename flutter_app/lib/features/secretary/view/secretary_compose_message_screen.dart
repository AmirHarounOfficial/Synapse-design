import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/message_repository.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `SecretaryComposeMessage.tsx`, wired to `POST /messages`.
/// Full-screen compose form with a recipient typeahead, subject, body, and an
/// "urgent" toggle. The Send action lives in the app bar and enables only when
/// all fields are filled. The urgent toggle maps to the message `category`
/// (`urgent`/`general`); recipients are picked from the inline list for display.
class SecretaryComposeMessageScreen extends StatefulWidget {
  const SecretaryComposeMessageScreen({super.key});

  @override
  State<SecretaryComposeMessageScreen> createState() => _SecretaryComposeMessageScreenState();
}

class _Recipient {
  const _Recipient({required this.id, required this.name, required this.type, required this.email});
  final String id;
  final String name;
  final String type;
  final String email;
}

class _SecretaryComposeMessageScreenState extends State<SecretaryComposeMessageScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  String _recipient = '';
  String _subject = '';
  String _body = '';
  bool _isUrgent = false;
  bool _showRecipientSearch = false;
  bool _sending = false;

  static const List<_Recipient> _recipients = [
    _Recipient(id: '1', name: 'James Thompson', type: 'Parent', email: 'james.thompson@email.com'),
    _Recipient(id: '2', name: 'Sarah Williams', type: 'Parent', email: 'sarah.williams@email.com'),
    _Recipient(id: '3', name: 'Nurse Chen', type: 'Clinic', email: 'nurse.chen@school.edu'),
    _Recipient(id: '4', name: 'Principal Rodriguez', type: 'Admin', email: 'principal@school.edu'),
  ];

  bool get _canSend =>
      !_sending && _recipient.isNotEmpty && _subject.isNotEmpty && _body.isNotEmpty;

  @override
  void dispose() {
    _recipientController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_canSend) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _sending = true);
    try {
      await sl<MessageRepository>().send(
        subject: _subject.trim(),
        body: _body.trim(),
        category: _isUrgent ? 'urgent' : 'general',
      );
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text('Message sent to $_recipient${_isUrgent ? ' (marked as urgent)' : ''}')));
      router.go('/secretary/messages');
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(MessageRepository.messageFor(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final matches = _recipients
        .where((r) => r.name.toLowerCase().contains(_recipient.toLowerCase()))
        .toList();

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: 'Compose Message',
        onBack: () => context.safeBack(),
        actions: [
          GestureDetector(
            onTap: _handleSend,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text('Send',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _canSend ? SchooKeepColors.primary : const Color(0xFF9CA3AF),
                  )),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipient
            _label('Recipient'),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextField(
                controller: _recipientController,
                onChanged: (v) => setState(() {
                  _recipient = v;
                  _showRecipientSearch = true;
                }),
                onTap: () => setState(() => _showRecipientSearch = true),
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                decoration: _inputDecoration('Search parent, clinic, or admin...',
                    prefix: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary)),
              ),
            ),
            if (_showRecipientSearch && _recipient.isNotEmpty && matches.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: SchooKeepColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SchooKeepColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: matches.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (ctx, i) {
                    final r = matches[i];
                    return InkWell(
                      onTap: () => setState(() {
                        _recipient = r.name;
                        _recipientController.text = r.name;
                        _showRecipientSearch = false;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('${r.type} • ${r.email}',
                                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Subject
            _label('Subject'),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextField(
                controller: _subjectController,
                onChanged: (v) => setState(() => _subject = v),
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                decoration: _inputDecoration('Message subject'),
              ),
            ),
            const SizedBox(height: 16),

            // Body
            _label('Message'),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: TextField(
                controller: _bodyController,
                onChanged: (v) => setState(() => _body = v),
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                decoration: _inputDecoration('Type your message...', contentPadding: const EdgeInsets.all(16)),
              ),
            ),
            const SizedBox(height: 16),

            // Mark as urgent
            SchooKeepCard(
              child: Row(
                children: [
                  Icon(LucideIcons.alertTriangle,
                      size: 20, color: _isUrgent ? SchooKeepColors.warning : SchooKeepColors.textSecondary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mark as urgent',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                        SizedBox(height: 2),
                        Text('Shows amber indicator to recipient',
                            style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isUrgent,
                    activeThumbColor: Colors.white,
                    activeTrackColor: SchooKeepColors.warning,
                    onChanged: (v) => setState(() => _isUrgent = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.4),
                  children: [
                    TextSpan(text: 'Tip: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            'Messages are automatically logged in the school communication system. Parents will receive a notification via their preferred channel (email, SMS, or app).'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary));
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefix, EdgeInsetsGeometry? contentPadding}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      prefixIcon: prefix,
      filled: true,
      fillColor: SchooKeepColors.surface,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
      ),
    );
  }
}
