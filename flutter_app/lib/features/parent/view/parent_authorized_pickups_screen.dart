import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentAuthorizedPickups.tsx`. Lists people authorized to pick
/// up the child, with an add-person form (name / relationship / phone) and a
/// pinned "Complete Setup" CTA. Progress bar at 87.5%.
class ParentAuthorizedPickupsScreen extends StatefulWidget {
  const ParentAuthorizedPickupsScreen({super.key});

  @override
  State<ParentAuthorizedPickupsScreen> createState() =>
      _ParentAuthorizedPickupsScreenState();
}

class _AuthorizedPerson {
  const _AuthorizedPerson({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.isSelf = false,
  });
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final bool isSelf;
}

class _ParentAuthorizedPickupsScreenState
    extends State<ParentAuthorizedPickupsScreen> {
  bool _showAddForm = false;
  final List<_AuthorizedPerson> _people = [
    const _AuthorizedPerson(
      id: 'self',
      name: 'Jennifer Thompson',
      relationship: 'Mother',
      phone: '(555) 123-4567',
      isSelf: true,
    ),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _relationship = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhone(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length <= 3) return cleaned;
    if (cleaned.length <= 6) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3)}';
    }
    final end = cleaned.length < 10 ? cleaned.length : 10;
    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6, end)}';
  }

  void _onPhoneChanged(String value) {
    final formatted = _formatPhone(value);
    if (formatted != value) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() {});
  }

  bool get _canAdd =>
      _nameController.text.isNotEmpty &&
      _relationship.isNotEmpty &&
      _phoneController.text.isNotEmpty;

  void _handleAddPerson() {
    if (!_canAdd) return;
    setState(() {
      _people.add(_AuthorizedPerson(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        relationship: _relationship,
        phone: _phoneController.text,
      ));
      _nameController.clear();
      _phoneController.clear();
      _relationship = '';
      _showAddForm = false;
    });
  }

  /// Shows the person's pickup QR code in a bottom sheet. The QR payload is a
  /// stable token derived from the person id (the onboarding flow has no API
  /// yet, so the code is generated locally for preview).
  void _showQrSheet(BuildContext context, _AuthorizedPerson person) {
    final isRTL = context.isRTL;
    final token = 'SK-PICKUP-${person.id}';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SchooKeepColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: SchooKeepColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              person.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: SchooKeepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              person.relationship,
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.qrCode, size: 120, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              token,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SchooKeepColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isRTL
                  ? 'يُظهر هذا الرمز لأمن المدرسة أثناء الاستلام.'
                  : 'Show this code to school security during pickup.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SchooKeepButton(
              label: isRTL ? 'تم' : 'Done',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: false,
      backgroundColor: SchooKeepColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProgressBar(fraction: 0.875),
          SchooKeepAppBar(
            title: context.tr(
              en: 'Step 4 of 4 — Authorized Pickups',
              ar: 'الخطوة 4 من 4 — أشخاص الاستلام المعتمدون',
            ),
            centerTitle: true,
            onBack: () => context.safeBack(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr(en: 'Who can pick up Maya?', ar: 'من يمكنه استلام مايا؟'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                      en: 'Add people authorized to pick up your child from school',
                      ar: 'أضف الأشخاص المخولين باستلام طفلك من المدرسة',
                    ),
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  for (final person in _people) ...[
                    _personCard(context, person),
                    const SizedBox(height: 12),
                  ],
                  if (!_showAddForm)
                    _AddPersonButton(onTap: () => setState(() => _showAddForm = true)),
                  if (_showAddForm) _buildAddForm(context),
                  const SizedBox(height: 16),
                  // Security note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SchooKeepColors.primary),
                    ),
                    child: Text(
                      context.tr(
                        en: 'For security, all authorized persons must present a valid government-issued ID and their unique QR code during pickup. Photos are required for visual verification.',
                        ar: 'لأغراض الأمان، يجب على جميع الأشخاص المعتمدين تقديم هوية حكومية سارية ورمز QR الخاص بهم أثناء الاستلام. الصور مطلوبة للتحقق البصري.',
                      ),
                      style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF1E40AF)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          border: Border(top: BorderSide(color: SchooKeepColors.border)),
        ),
        child: SchooKeepButton(
          label: context.tr(en: 'Complete Setup', ar: 'إكمال الإعداد'),
          variant: SchooKeepButtonVariant.secondary,
          onPressed: () => context.go('/parent/onboarding/complete'),
        ),
      ),
    );
  }

  Widget _personCard(BuildContext context, _AuthorizedPerson person) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.user, size: 24, color: SchooKeepColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  person.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: SchooKeepColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (person.isSelf)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 8),
                                  child: Text(
                                    context.tr(en: '(You)', ar: '(أنت)'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: SchooKeepColors.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            person.relationship,
                            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!person.isSelf)
                      GestureDetector(
                        onTap: () => setState(() => _people.removeWhere((p) => p.id == person.id)),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(LucideIcons.x, size: 20, color: SchooKeepColors.error),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  person.phone,
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Material(
                    color: SchooKeepColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: SchooKeepColors.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _showQrSheet(context, person),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.qrCode, size: 16, color: SchooKeepColors.textPrimary),
                          const SizedBox(width: 8),
                          Text(
                            person.isSelf
                                ? context.tr(en: 'View QR Code', ar: 'عرض رمز QR')
                                : context.tr(en: 'QR Code Generated', ar: 'تم إنشاء رمز QR'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(en: 'Add Authorized Person', ar: 'إضافة شخص معتمد'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SchooKeepColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showAddForm = false),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(LucideIcons.x, size: 20, color: SchooKeepColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _fieldLabel(context.tr(en: 'Full Name', ar: 'الاسم الكامل')),
          const SizedBox(height: 6),
          _textField(
            controller: _nameController,
            hint: 'John Smith',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _fieldLabel(context.tr(en: 'Relationship', ar: 'صلة القرابة')),
          const SizedBox(height: 6),
          _relationshipDropdown(context),
          const SizedBox(height: 12),
          _fieldLabel(context.tr(en: 'Phone Number', ar: 'رقم الهاتف')),
          const SizedBox(height: 6),
          _textField(
            controller: _phoneController,
            hint: '(555) 123-4567',
            keyboardType: TextInputType.phone,
            maxLength: 14,
            onChanged: _onPhoneChanged,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SchooKeepColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Text(
              context.tr(
                en: 'A unique QR code will be generated for this person. They will need to show this code to school security during pickup.',
                ar: 'سيتم إنشاء رمز QR فريد لهذا الشخص. سيحتاج إلى إظهار هذا الرمز لأمن المدرسة أثناء الاستلام.',
              ),
              style: const TextStyle(fontSize: 11, height: 1.5, color: SchooKeepColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          SchooKeepButton(
            label: context.tr(en: 'Add Person', ar: 'إضافة شخص'),
            height: 48,
            enabled: _canAdd,
            onPressed: _handleAddPerson,
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: SchooKeepColors.textPrimary,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: SchooKeepColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: SchooKeepColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _relationshipDropdown(BuildContext context) {
    final options = <({String value, String label})>[
      (value: 'Father', label: context.tr(en: 'Father', ar: 'الأب')),
      (value: 'Mother', label: context.tr(en: 'Mother', ar: 'الأم')),
      (value: 'Grandparent', label: context.tr(en: 'Grandparent', ar: 'الجد/الجدة')),
      (value: 'Aunt/Uncle', label: context.tr(en: 'Aunt/Uncle', ar: 'العم/الخال')),
      (value: 'Sibling', label: context.tr(en: 'Sibling', ar: 'أخ/أخت')),
      (value: 'Guardian', label: context.tr(en: 'Legal Guardian', ar: 'الوصي القانوني')),
      (value: 'Other', label: context.tr(en: 'Other', ar: 'أخرى')),
    ];
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _relationship.isEmpty ? null : _relationship,
          hint: Text(
            context.tr(en: 'Select relationship', ar: 'اختر صلة القرابة'),
            style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
          ),
          style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
          items: [
            for (final o in options)
              DropdownMenuItem<String>(value: o.value, child: Text(o.label)),
          ],
          onChanged: (value) => setState(() => _relationship = value ?? ''),
        ),
      ),
    );
  }
}

class _AddPersonButton extends StatelessWidget {
  const _AddPersonButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: SchooKeepColors.primary, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.plus, size: 20, color: SchooKeepColors.primary),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Add Person', ar: 'إضافة شخص'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SchooKeepColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: Row(
        children: [
          Expanded(
            flex: (fraction * 1000).round(),
            child: const ColoredBox(color: SchooKeepColors.primary),
          ),
          Expanded(
            flex: 1000 - (fraction * 1000).round(),
            child: const ColoredBox(color: Color(0xFFF3F4F6)),
          ),
        ],
      ),
    );
  }
}
