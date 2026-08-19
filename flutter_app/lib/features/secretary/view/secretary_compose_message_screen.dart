import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/message_repository.dart';
import 'package:schookeep/core/router/safe_back.dart';

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

  String _recipientMode = 'sector'; // 'sector', 'multi', 'individual'
  String _targetSector = 'all_parents';
  final List<_Recipient> _selectedRecipients = [];
  String _recipient = '';
  String _subject = '';
  String _body = '';
  bool _isUrgent = false;
  bool _showRecipientSearch = false;
  bool _sending = false;

  bool get _canSend {
    if (_sending || _subject.trim().isEmpty || _body.trim().isEmpty) return false;
    if (_recipientMode == 'sector') return _targetSector.isNotEmpty;
    if (_recipientMode == 'multi') return _selectedRecipients.isNotEmpty;
    return _recipient.trim().isNotEmpty;
  }

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
      final recipientName = _recipientMode == 'sector'
          ? _sectorLabel(context, _targetSector)
          : _recipientMode == 'multi'
              ? '${_selectedRecipients.length} ${context.tr(en: 'selected recipients', ar: 'مستلمين محددين')}'
              : _recipient;

      await sl<MessageRepository>().send(
        subject: _subject.trim(),
        body: _body.trim(),
        category: _isUrgent ? 'urgent' : 'general',
        recipientType: _recipientMode,
        targetSector: _recipientMode == 'sector' ? _targetSector : null,
        recipientIds: _recipientMode == 'multi'
            ? _selectedRecipients.map((r) => int.tryParse(r.id) ?? 1).toList()
            : null,
        recipientId: _recipientMode == 'individual' ? 1 : null,
      );

      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(
          context.tr(
            en: 'Message sent to $recipientName${_isUrgent ? ' (marked as urgent)' : ''}',
            ar: 'تم إرسال الرسالة إلى $recipientName${_isUrgent ? ' (تم تمييزها كعاجلة)' : ''}',
          ),
        )));
      if (context.canPop()) {
        context.pop();
      } else {
        router.go('/secretary/messages');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(MessageRepository.messageFor(e))));
    }
  }

  static String _sectorLabel(BuildContext context, String sector) {
    switch (sector) {
      case 'all_parents':
        return context.tr(en: 'All Parents', ar: 'جميع أولياء الأمور');
      case 'all_teachers':
        return context.tr(en: 'All Teachers & Staff', ar: 'كافة المعلمين والكادر التدريسي');
      case 'all_nurses':
        return context.tr(en: 'Clinic & Health Team', ar: 'فريق العيادة والتمريض');
      case 'grade_4':
        return context.tr(en: 'Grade 4 Parents', ar: 'أولياء أمور الصف الرابع');
      case 'grade_5':
        return context.tr(en: 'Grade 5 Parents', ar: 'أولياء أمور الصف الخامس');
      case 'all_school':
      default:
        return context.tr(en: 'Entire School Community', ar: 'مجتمع المدرسة بالكامل');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRecipients = [
      _Recipient(id: '1', name: 'James Thompson', type: context.tr(en: 'Parent', ar: 'ولي أمر'), email: 'james.thompson@email.com'),
      _Recipient(id: '2', name: 'Sarah Williams', type: context.tr(en: 'Parent', ar: 'ولي أمر'), email: 'sarah.williams@email.com'),
      _Recipient(id: '3', name: context.tr(en: 'Nurse Chen', ar: 'الممرضة تشين'), type: context.tr(en: 'Clinic', ar: 'العيادة الطبية'), email: 'nurse.chen@school.edu'),
      _Recipient(id: '4', name: context.tr(en: 'Principal Rodriguez', ar: 'مدير المدرسة'), type: context.tr(en: 'Admin', ar: 'الإدارة العليا'), email: 'principal@school.edu'),
      _Recipient(id: '5', name: 'Carlos Martinez', type: context.tr(en: 'Parent', ar: 'ولي أمر'), email: 'carlos.martinez@email.com'),
    ];

    final matches = allRecipients
        .where((r) => r.name.toLowerCase().contains(_recipient.toLowerCase()) && !_selectedRecipients.contains(r))
        .toList();

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Compose Message', ar: 'كتابة رسالة جديدة'),
        onBack: () => context.safeBack(),
        actions: [
          GestureDetector(
            onTap: _handleSend,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(context.tr(en: 'Send', ar: 'إرسال'),
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
            // Mode Selector
            _label(context.tr(en: 'Recipient Target', ar: 'نطاق أو فئة المستلمين')),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _modeChip('sector', context.tr(en: 'Full Sector / Group', ar: 'قطاع / فئة كاملة'), LucideIcons.users),
                  const SizedBox(width: 8),
                  _modeChip('multi', context.tr(en: 'Multiple Persons', ar: 'عدة أشخاص مختارين'), LucideIcons.userPlus),
                  const SizedBox(width: 8),
                  _modeChip('individual', context.tr(en: 'Individual Person', ar: 'شخص واحد'), LucideIcons.user),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mode 1: Sector Dropdown Selector
            if (_recipientMode == 'sector') ...[
              _label(context.tr(en: 'Select Target Sector', ar: 'اختر الفئة المستهدفة')),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: SchooKeepColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _targetSector,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 20, color: SchooKeepColors.textSecondary),
                    items: [
                      DropdownMenuItem(
                        value: 'all_parents',
                        child: Text(context.tr(en: 'All Parents', ar: 'جميع أولياء الأمور')),
                      ),
                      DropdownMenuItem(
                        value: 'all_teachers',
                        child: Text(context.tr(en: 'All Teachers & Staff', ar: 'كافة المعلمين والكادر التدريسي')),
                      ),
                      DropdownMenuItem(
                        value: 'all_nurses',
                        child: Text(context.tr(en: 'Clinic & Health Team', ar: 'فريق العيادة والتمريض')),
                      ),
                      DropdownMenuItem(
                        value: 'grade_4',
                        child: Text(context.tr(en: 'Grade 4 Parents', ar: 'أولياء أمور الصف الرابع')),
                      ),
                      DropdownMenuItem(
                        value: 'grade_5',
                        child: Text(context.tr(en: 'Grade 5 Parents', ar: 'أولياء أمور الصف الخامس')),
                      ),
                      DropdownMenuItem(
                        value: 'all_school',
                        child: Text(context.tr(en: 'Entire School Community', ar: 'مجتمع المدرسة بالكامل')),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _targetSector = v);
                    },
                  ),
                ),
              ),
            ],

            // Mode 2: Multi Person Selector
            if (_recipientMode == 'multi') ...[
              _label(context.tr(en: 'Selected Recipients', ar: 'المستلمون المختارون')),
              const SizedBox(height: 8),
              if (_selectedRecipients.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in _selectedRecipients)
                      Chip(
                        avatar: CircleAvatar(
                          backgroundColor: SchooKeepColors.primary,
                          child: Text(r.name[0], style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                        label: Text(r.name, style: const TextStyle(fontSize: 13)),
                        deleteIcon: const Icon(LucideIcons.x, size: 16),
                        onDeleted: () => setState(() => _selectedRecipients.remove(r)),
                        backgroundColor: const Color(0xFFEFF6FF),
                        side: const BorderSide(color: SchooKeepColors.border),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
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
                  decoration: _inputDecoration(
                    context.tr(en: 'Search and add recipient...', ar: 'ابحث عن شخص لإضافته للمستلمين...'),
                    prefix: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
                  ),
                ),
              ),
            ],

            // Mode 3: Individual Person Selector
            if (_recipientMode == 'individual') ...[
              _label(context.tr(en: 'Recipient', ar: 'المستلم')),
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
                  decoration: _inputDecoration(
                    context.tr(en: 'Search parent, clinic, or admin...', ar: 'ابحث عن ولي أمر، العيادة، أو الإدارة...'),
                    prefix: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
                  ),
                ),
              ),
            ],

            // Recipient Search Results Dropdown (for Multi & Individual modes)
            if ((_recipientMode == 'multi' || _recipientMode == 'individual') &&
                _showRecipientSearch &&
                _recipient.isNotEmpty &&
                matches.isNotEmpty) ...[
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
                        if (_recipientMode == 'multi') {
                          _selectedRecipients.add(r);
                          _recipientController.clear();
                          _recipient = '';
                        } else {
                          _recipient = r.name;
                          _recipientController.text = r.name;
                          _showRecipientSearch = false;
                        }
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

            _label(context.tr(en: 'Subject', ar: 'موضوع الرسالة')),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextField(
                controller: _subjectController,
                onChanged: (v) => setState(() => _subject = v),
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                decoration: _inputDecoration(context.tr(en: 'Message subject', ar: 'عنوان أو موضوع الرسالة')),
              ),
            ),
            const SizedBox(height: 16),

            _label(context.tr(en: 'Message', ar: 'نص الرسالة')),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              onChanged: (v) => setState(() => _body = v),
              minLines: 6,
              maxLines: 10,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
              decoration: _inputDecoration(
                context.tr(en: 'Type your message...', ar: 'اكتب نص الرسالة هنا...'),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            SchooKeepCard(
              child: Row(
                children: [
                  Icon(LucideIcons.alertTriangle,
                      size: 20, color: _isUrgent ? SchooKeepColors.warning : SchooKeepColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr(en: 'Mark as urgent', ar: 'تمييز كرسالة عاجلة ومهمة'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(context.tr(en: 'Shows amber indicator to recipient', ar: 'يظهر تنبيهاً باللون البرتقالي لدى المستلم'),
                            style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
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

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.4),
                  children: [
                    TextSpan(text: context.tr(en: 'Tip: ', ar: 'ملاحظة: '), style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: context.tr(
                      en: 'Messages are automatically logged in the school communication system. Parents will receive a notification via their preferred channel (email, SMS, or app).',
                      ar: 'تتم أرشفة كافة المراسلات تلقائياً في سجلات المدرسة. وسيتلقى أولياء الأمور إشعاراً عبر وسيلة التواصل المعتمدة.',
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(String mode, String label, IconData icon) {
    final active = _recipientMode == mode;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: active ? Colors.white : SchooKeepColors.textSecondary),
      label: Text(label),
      selected: active,
      selectedColor: SchooKeepColors.primary,
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: active ? Colors.white : SchooKeepColors.textSecondary,
      ),
      onSelected: (_) => setState(() {
        _recipientMode = mode;
        _showRecipientSearch = false;
      }),
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
