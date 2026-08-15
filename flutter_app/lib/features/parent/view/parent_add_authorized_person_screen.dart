import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Add Authorized Person form, ported from the add-person form in
/// `ParentAuthorizedPickups.tsx` / `ParentAuthorizedPersonsManager.tsx`.
///
/// The backend exposes authorized persons only nested under pickups (there is no
/// create endpoint — see [PickupRepository]), so Save records the person locally
/// and shows success feedback, mirroring the React prototype which adds to local
/// state. A unique QR code is generated server-side once the school links the
/// person to a pickup.
class ParentAddAuthorizedPersonScreen extends StatefulWidget {
  const ParentAddAuthorizedPersonScreen({super.key});

  @override
  State<ParentAddAuthorizedPersonScreen> createState() =>
      _ParentAddAuthorizedPersonScreenState();
}

class _ParentAddAuthorizedPersonScreenState
    extends State<ParentAddAuthorizedPersonScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _relationship = '';
  bool _showSuccess = false;

  // (value, English label, Arabic label) — mirrors the React relationship select.
  static const List<(String, String, String)> _relationships = [
    ('Father', 'Father', 'الأب'),
    ('Mother', 'Mother', 'الأم'),
    ('Grandparent', 'Grandparent', 'جد / جدة'),
    ('Aunt/Uncle', 'Aunt/Uncle', 'خال / عم'),
    ('Sibling', 'Sibling', 'أخ / أخت'),
    ('Guardian', 'Legal Guardian', 'وصي قانوني'),
    ('Other', 'Other', 'آخر'),
  ];

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _relationship.isNotEmpty &&
      _phoneController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_canSubmit) setState(() => _showSuccess = true);
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    if (_showSuccess) return _buildSuccess(context, isRTL);
    return _buildForm(context, isRTL);
  }

  Widget _buildForm(BuildContext context, bool isRTL) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      backgroundColor: SchooKeepColors.surface,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'إضافة شخص مخوّل' : 'Add Authorized Person',
        centerTitle: true,
        onBack: () => context.safeBack(),
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SchooKeepButton(
          label: isRTL ? 'إضافة شخص' : 'Add Person',
          icon: LucideIcons.plus,
          enabled: _canSubmit,
          onPressed: _handleSave,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(isRTL ? 'الاسم الكامل' : 'Full Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                isRTL ? 'مثال: أحمد محمد' : 'e.g. John Smith',
              ),
            ),
            const SizedBox(height: 16),
            _fieldLabel(isRTL ? 'صلة القرابة' : 'Relationship'),
            const SizedBox(height: 8),
            _relationshipDropdown(isRTL),
            const SizedBox(height: 16),
            _fieldLabel(isRTL ? 'رقم الهاتف' : 'Phone Number'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                isRTL ? '(555) 123-4567' : '(555) 123-4567',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Text(
                isRTL
                    ? 'سيتم إنشاء رمز QR فريد لهذا الشخص. سيحتاج إلى إظهار هذا الرمز لأمن المدرسة عند الاصطحاب.'
                    : 'A unique QR code will be generated for this person. They will need to show this code to school security during pickup.',
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, bool isRTL) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      backgroundColor: SchooKeepColors.surface,
      appBar: SchooKeepAppBar(onBack: () => context.safeBack()),
      bottomBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SchooKeepButton(
          label: isRTL ? 'تم' : 'Done',
          onPressed: () => context.go('/parent/app/authorized-persons'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: SchooKeepColors.greenChipBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.checkCircle, size: 32, color: SchooKeepColors.accent),
            ),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'تمت إضافة الشخص المخوّل' : 'Authorized Person Added',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: SchooKeepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRTL
                  ? 'سيتم إنشاء رمز QR فريد لهذا الشخص لاستخدامه عند اصطحاب طفلك.'
                  : 'A unique QR code will be generated for this person to use when picking up your child.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Column(
                children: [
                  _kvRow(isRTL ? 'الاسم' : 'Name', _nameController.text.trim()),
                  const SizedBox(height: 8),
                  _kvRow(isRTL ? 'صلة القرابة' : 'Relationship', _relationshipLabel(isRTL)),
                  const SizedBox(height: 8),
                  _kvRow(isRTL ? 'الهاتف' : 'Phone', _phoneController.text.trim()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _relationshipDropdown(bool isRTL) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SchooKeepColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _relationship.isEmpty ? null : _relationship,
          hint: Text(isRTL ? 'اختر صلة القرابة' : 'Select relationship',
              style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary)),
          items: [
            for (final (value, en, ar) in _relationships)
              DropdownMenuItem(value: value, child: Text(isRTL ? ar : en)),
          ],
          onChanged: (v) => setState(() => _relationship = v ?? ''),
        ),
      ),
    );
  }

  String _relationshipLabel(bool isRTL) {
    for (final (value, en, ar) in _relationships) {
      if (value == _relationship) return isRTL ? ar : en;
    }
    return _relationship;
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: SchooKeepColors.textPrimary,
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: _inputBorder(SchooKeepColors.border),
        enabledBorder: _inputBorder(SchooKeepColors.border),
        focusedBorder: _inputBorder(SchooKeepColors.primary),
      );

  OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );

  Widget _kvRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.textPrimary)),
        ),
      ],
    );
  }
}
