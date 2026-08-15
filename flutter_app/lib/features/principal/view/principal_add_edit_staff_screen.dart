import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/uae_tokens.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/staff.dart';
import '../../../data/repositories/staff_repository.dart';
import '../cubit/staff_form_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `PrincipalAddEditStaff.tsx` (used for both `/principal/add-staff`
/// and `/principal/edit-staff/:staffId`), wired to [StaffFormCubit]. Personal
/// info, role grid, conditional UAE medical-license fields, permissions
/// preview, status toggle, and a pinned submit button. In edit mode the form
/// pre-fills from `GET /staff/{id}` and exposes a Deactivate action.
class PrincipalAddEditStaffScreen extends StatelessWidget {
  const PrincipalAddEditStaffScreen({super.key, this.staffId});

  final String? staffId;

  @override
  Widget build(BuildContext context) {
    final id = staffId == null ? null : int.tryParse(staffId!);
    return BlocProvider(
      create: (_) => StaffFormCubit(sl<StaffRepository>(), staffId: id),
      child: _PrincipalAddEditStaffView(staffId: id),
    );
  }
}

class _PrincipalAddEditStaffView extends StatefulWidget {
  const _PrincipalAddEditStaffView({this.staffId});

  final int? staffId;

  @override
  State<_PrincipalAddEditStaffView> createState() => _PrincipalAddEditStaffViewState();
}

class _PrincipalAddEditStaffViewState extends State<_PrincipalAddEditStaffView> {
  bool get _isEditing => widget.staffId != null;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  bool _emailValid = false;
  String _selectedRole = '';
  bool _isActive = true;
  bool _prefilled = false;

  String _licenseAuthority = '';
  final _licenseNumber = TextEditingController();
  final _licenseExpiry = TextEditingController();
  String _specialty = 'GP';

  static const _roles = <_Role>[
    _Role('nurse', 'School Nurse',
        'Clinic visit categories · Medical alerts/contraindications only · No medication details'),
    _Role('physician', 'School Physician', 'Manage medications · Protocol approvals · Clinical escalation triage'),
    _Role('vice-principal', 'Vice Principal', 'All student records · Staff management · System settings'),
    _Role('secretary', 'Secretary', 'Student directory (no medical) · Parent messages · Document imports'),
    _Role('class-teacher', 'Class Teacher', 'Class roster · Health considerations · Attendance only'),
    _Role('pe-teacher', 'PE Teacher', 'Activity restrictions · Weather advisories · No clinic data'),
    _Role('music-teacher', 'Music Teacher', 'Activity restrictions · Weather advisories · No clinic data'),
    _Role('counselor', 'Counselor', 'Psychosocial records only · No medical data · Confidential notes'),
    _Role('cafeteria', 'Cafeteria', 'Allergen alerts only · No clinic data · Delivery confirmations'),
    _Role('security', 'Security Guard', 'Pickup authorizations · QR verification · No health data'),
    _Role('driver', 'Bus Driver', 'Route roster · Boarding status · No health data'),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-select license authority for the configured emirate (Dubai → DHA).
    _licenseAuthority = 'DHA';
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _licenseNumber.dispose();
    _licenseExpiry.dispose();
    super.dispose();
  }

  /// Populates the form from the loaded staff member (edit mode), once.
  void _prefill(Staff s) {
    final parts = s.name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    _firstName.text = parts.isNotEmpty ? parts.first : '';
    _lastName.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    _email.text = s.email;
    _emailValid = true;
    _selectedRole = s.role;
    _isActive = s.isActive;
    _prefilled = true;
    setState(() {});
  }

  void _validateEmail() {
    final email = _email.text;
    final valid = email.contains('@') &&
        (email.endsWith('.ae') ||
            email.endsWith('@synapse.ae') ||
            email.endsWith('@school.ae') ||
            email.endsWith('@lakewood.edu'));
    setState(() => _emailValid = valid);
  }

  bool get _isLicenseRequired => _selectedRole == 'nurse' || _selectedRole == 'physician';

  bool get _isLicenseValid =>
      !_isLicenseRequired ||
      (_licenseAuthority.isNotEmpty && _licenseNumber.text.isNotEmpty && _licenseExpiry.text.isNotEmpty);

  bool get _canSubmit =>
      _firstName.text.isNotEmpty &&
      _lastName.text.isNotEmpty &&
      _email.text.isNotEmpty &&
      _emailValid &&
      _selectedRole.isNotEmpty &&
      _isLicenseValid;

  _Role? get _selectedRoleData {
    for (final r in _roles) {
      if (r.id == _selectedRole) return r;
    }
    return null;
  }

  String get _fullName => '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;
    final cubit = context.read<StaffFormCubit>();
    final ok = _isEditing
        ? await cubit.submitUpdate(
            id: widget.staffId!,
            name: _fullName,
            role: _selectedRole,
            isActive: _isActive,
          )
        : await cubit.submitCreate(
            name: _fullName,
            email: _email.text.trim(),
            role: _selectedRole,
          );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Staff account updated successfully' : 'Invitation sent to staff member'),
      ));
      context.safeBack();
    }
    // On failure the cubit emits StaffFormError; the builder renders the retry
    // banner (controllers keep their text, so no input is lost).
  }

  Future<void> _handleDeactivate() async {
    final cubit = context.read<StaffFormCubit>();
    final ok = await cubit.deactivate(widget.staffId!);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Staff member deactivated')));
      context.safeBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffFormCubit, StaffFormState>(
      listener: (context, state) {
        if (state is StaffFormReady && state.staff != null && !_prefilled) {
          _prefill(state.staff!);
        }
      },
      builder: (context, state) {
        final submitting = state is StaffFormReady && state.submitting;
        return SchooKeepScaffold(
          scrollable: true,
          title: _isEditing ? 'Edit Staff' : 'Add Staff',
          onBack: () => context.safeBack(),
          bottomBar: state is StaffFormReady ? _bottomBar(submitting) : null,
          body: switch (state) {
            StaffFormLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            StaffFormError(:final message) => _errorBanner(message),
            StaffFormReady() => _formBody(submitting),
          },
        );
      },
    );
  }

  Widget _formBody(bool submitting) {
    final roleData = _selectedRoleData;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _personalInfoCard(),
          const SizedBox(height: 16),
          _roleAssignment(),
          if (_isLicenseRequired) ...[
            const SizedBox(height: 16),
            _licenseCard(),
          ],
          if (roleData != null) ...[
            const SizedBox(height: 16),
            _permissionsPreview(roleData),
          ],
          const SizedBox(height: 16),
          _statusCard(),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            SchooKeepButton(
              label: 'Deactivate staff member',
              variant: SchooKeepButtonVariant.danger,
              enabled: !submitting,
              onPressed: _handleDeactivate,
            ),
          ],
          if (!_isEditing) ...[
            const SizedBox(height: 16),
            _confidentialityNotice(roleData),
          ],
        ],
      ),
    );
  }

  Widget _errorBanner(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                  child: Text(error,
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.error, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SchooKeepButton(
            label: 'Retry',
            fullWidth: false,
            onPressed: () => context.read<StaffFormCubit>().load(),
          ),
        ],
      ),
    );
  }

  Widget _personalInfoCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          _fieldLabel('First Name'),
          _textField(_firstName, 'Enter first name', onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          _fieldLabel('Last Name'),
          _textField(_lastName, 'Enter last name', onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          _fieldLabel('School Email'),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus && _email.text.isNotEmpty) _validateEmail();
            },
            child: _textField(_email, 'name@synapse.ae',
                keyboardType: TextInputType.emailAddress, onChanged: (_) => setState(() {})),
          ),
          if (_email.text.isNotEmpty && _emailValid) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(LucideIcons.checkCircle, size: 16, color: SchooKeepColors.accent),
                SizedBox(width: 4),
                Text('✓ Valid school email', style: TextStyle(fontSize: 12, color: SchooKeepColors.accent)),
              ],
            ),
          ],
          if (_email.text.isNotEmpty && !_emailValid) ...[
            const SizedBox(height: 8),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.error),
                SizedBox(width: 4),
                Expanded(
                  child: Text('Must use a valid school email address (.ae or @synapse.ae)',
                      style: TextStyle(fontSize: 12, color: SchooKeepColors.error)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _roleAssignment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Role Assignment',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.0,
          children: [
            for (final r in _roles)
              GestureDetector(
                onTap: () => setState(() => _selectedRole = r.id),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedRole == r.id ? const Color(0xFFEFF6FF) : SchooKeepColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedRole == r.id ? SchooKeepColors.primary : SchooKeepColors.border,
                      width: 2,
                    ),
                  ),
                  child: Text(r.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _selectedRole == r.id ? SchooKeepColors.primary : SchooKeepColors.textPrimary)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _licenseCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medical License Details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          _licenseAuthoritySelector(),
          const SizedBox(height: 12),
          _fieldLabel('License Number'),
          _textField(_licenseNumber, '${_licenseAuthority.isEmpty ? 'DHA' : _licenseAuthority}-XXXX-XX',
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          _fieldLabel('License Expiry Date'),
          _textField(_licenseExpiry, 'dd/mm/yyyy', onChanged: (_) => setState(() {})),
          if (_selectedRole == 'physician') ...[
            const SizedBox(height: 12),
            _fieldLabel('Specialty'),
            _dropdown(
              value: _specialty,
              items: const {
                'GP': 'General Practitioner',
                'Pediatrician': 'Pediatrician',
                'Other': 'Other Specialist',
              },
              onChanged: (v) => setState(() => _specialty = v),
            ),
          ],
        ],
      ),
    );
  }

  /// Inlined `LicenseAuthoritySelector.tsx` — emirate-aware authority dropdown
  /// with a bilingual compliance note below.
  Widget _licenseAuthoritySelector() {
    final isRTL = context.isRTL;
    final note = isRTL
        ? 'يجب أن يحمل هذا الموظف ترخيصًا ساريًا من [$_licenseAuthority] لإجراء الفحوصات والإجراءات الطبية في المدارس.'
        : 'This staff member must hold a valid [$_licenseAuthority] license to perform clinical actions in schools.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(en: 'Medical License Authority', ar: 'هيئة الترخيص الطبي'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
        const SizedBox(height: 6),
        _dropdown(
          value: _licenseAuthority,
          items: {for (final a in UaeTokens.licenseAuthorities) a: a},
          height: 52,
          onChanged: (v) => setState(() => _licenseAuthority = v),
        ),
        if (_licenseAuthority.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(note,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFB45309))),
          ),
        ],
      ],
    );
  }

  Widget _permissionsPreview(_Role role) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 16, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permissions for this role',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Text('This role will see: ${role.permissions}',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return SchooKeepCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account Status',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 2),
                Text(_isActive ? 'User can access the system' : 'User cannot log in',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          _toggle(_isActive, () => setState(() => _isActive = !_isActive),
              activeColor: SchooKeepColors.accent),
        ],
      ),
    );
  }

  Widget _confidentialityNotice(_Role? role) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Confidentiality Agreement Required',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF92400E))),
                const SizedBox(height: 4),
                Text(
                    'User will be required to sign ${role?.label ?? 'Role'} confidentiality agreement on first login',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(bool submitting) {
    final enabled = _canSubmit && !submitting;
    return Container(
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: enabled ? SchooKeepColors.primary : const Color(0xFFE2E8F0),
            disabledBackgroundColor: const Color(0xFFE2E8F0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: enabled ? _handleSubmit : null,
          child: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_isEditing ? 'Save changes' : 'Send invitation',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: enabled ? Colors.white : const Color(0xFF94A3B8))),
        ),
      ),
    );
  }

  // ---- shared field helpers ----

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
      );

  Widget _textField(TextEditingController c, String hint,
      {TextInputType? keyboardType, ValueChanged<String>? onChanged}) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          filled: true,
          fillColor: SchooKeepColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
    double height = 44,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 20, color: SchooKeepColors.textSecondary),
          style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
          items: [
            for (final e in items.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _toggle(bool value, VoidCallback onTap, {required Color activeColor}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(4),
        alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: value ? activeColor : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

class _Role {
  const _Role(this.id, this.label, this.permissions);
  final String id;
  final String label;
  final String permissions;
}
