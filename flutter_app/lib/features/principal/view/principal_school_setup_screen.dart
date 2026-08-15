import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `PrincipalSchoolSetup.tsx`. School info, branding (logo upload +
/// primary color), academic calendar with an editable holidays list, and school
/// hours, plus a pinned Save button.
class PrincipalSchoolSetupScreen extends StatefulWidget {
  const PrincipalSchoolSetupScreen({super.key});

  @override
  State<PrincipalSchoolSetupScreen> createState() => _PrincipalSchoolSetupScreenState();
}

class _PrincipalSchoolSetupScreenState extends State<PrincipalSchoolSetupScreen> {
  final _schoolName = TextEditingController(text: 'Lakewood Elementary');
  final _address = TextEditingController(text: '123 Oak Street, Springfield, CA 94025');
  final _phone = TextEditingController(text: '(555) 123-4567');
  final _principalName = TextEditingController(text: 'Dr. Linda Rodriguez');
  final _primaryColor = TextEditingController(text: '#2563EB');
  final _schoolYearStart = TextEditingController(text: '2025-09-02');
  final _schoolYearEnd = TextEditingController(text: '2026-06-15');
  final _schoolHoursStart = TextEditingController(text: '07:30');
  final _schoolHoursEnd = TextEditingController(text: '17:00');

  final List<_Holiday> _holidays = [
    _Holiday('1', 'Thanksgiving Break', '2025-11-24', '2025-11-29'),
    _Holiday('2', 'Winter Break', '2025-12-20', '2026-01-03'),
    _Holiday('3', 'Spring Break', '2026-03-15', '2026-03-22'),
  ];

  Color get _previewColor {
    final hex = _primaryColor.text.replaceFirst('#', '');
    if (hex.length == 6) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) return Color(0xFF000000 | value);
    }
    return SchooKeepColors.primary;
  }

  @override
  void dispose() {
    for (final c in [
      _schoolName,
      _address,
      _phone,
      _principalName,
      _primaryColor,
      _schoolYearStart,
      _schoolYearEnd,
      _schoolHoursStart,
      _schoolHoursEnd,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: 'School Settings',
      onBack: () => context.safeBack(),
      bottomBar: _bottomBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _schoolInfoCard(),
            const SizedBox(height: 16),
            _brandingCard(),
            const SizedBox(height: 16),
            _academicCalendarCard(),
            const SizedBox(height: 16),
            _schoolHoursCard(),
          ],
        ),
      ),
    );
  }

  Widget _schoolInfoCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('School Information'),
          const SizedBox(height: 12),
          _labeledField('School Name', _schoolName),
          const SizedBox(height: 12),
          _labeledField('Address', _address),
          const SizedBox(height: 12),
          _labeledField('Phone', _phone, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _labeledField('Principal Name', _principalName),
        ],
      ),
    );
  }

  /// Logo upload — no in-app file picker, so present the source options as a
  /// bottom sheet with a confirmation snackbar (in-app feedback convention).
  void _showLogoUploadSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('Upload school logo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: SchooKeepColors.primary),
              title: const Text('Choose from gallery'),
              subtitle: const Text('PNG or SVG · Max 2MB'),
              onTap: () {
                Navigator.pop(sheetCtx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo upload started…')));
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: SchooKeepColors.primary),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetCtx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera opening…')));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _brandingCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Branding'),
          const SizedBox(height: 12),
          const _FieldLabel('School Logo'),
          GestureDetector(
            onTap: _showLogoUploadSheet,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid, width: 2),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.upload, size: 24, color: SchooKeepColors.textSecondary),
                  SizedBox(height: 8),
                  Text('Tap to upload logo',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
                  SizedBox(height: 4),
                  Text('PNG or SVG, max 2MB', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _FieldLabel('Primary Color'),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: _styledField(_primaryColor, '#2563EB', onChanged: (_) => setState(() {})),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _previewColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _academicCalendarCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Academic Calendar'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _labeledField('Year Start', _schoolYearStart)),
              const SizedBox(width: 8),
              Expanded(child: _labeledField('Year End', _schoolYearEnd)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Holidays',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
              GestureDetector(
                onTap: () => setState(() =>
                    _holidays.add(_Holiday((_holidays.length + 1).toString(), '', '', ''))),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, size: 16, color: SchooKeepColors.primary),
                    SizedBox(width: 4),
                    Text('Add',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final h in _holidays) _holidayRow(h),
        ],
      ),
    );
  }

  Widget _holidayRow(_Holiday h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 36, child: _styledField(h.name, 'Holiday name', fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: SizedBox(height: 36, child: _styledField(h.start, 'Start', fontSize: 11))),
                      const SizedBox(width: 8),
                      Expanded(child: SizedBox(height: 36, child: _styledField(h.end, 'End', fontSize: 11))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _holidays.removeWhere((x) => x.id == h.id)),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(LucideIcons.x, size: 16, color: SchooKeepColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _schoolHoursCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('School Hours'),
          const SizedBox(height: 4),
          const Text('Governs system lock/unlock times for staff access',
              style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _labeledField('Start Time', _schoolHoursStart)),
              const SizedBox(width: 12),
              Expanded(child: _labeledField('End Time', _schoolHoursEnd)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: SchooKeepColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () =>
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('School settings saved successfully'))),
          child: const Text('Save Changes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _labeledField(String label, TextEditingController c, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        SizedBox(height: 44, child: _styledField(c, '', keyboardType: keyboardType)),
      ],
    );
  }

  Widget _styledField(TextEditingController c, String hint,
      {TextInputType? keyboardType, double fontSize = 15, ValueChanged<String>? onChanged}) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: fontSize, color: SchooKeepColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: fontSize, color: const Color(0xFF94A3B8)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary));
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
      );
}

class _Holiday {
  _Holiday(this.id, String name, String start, String end)
      : name = TextEditingController(text: name),
        start = TextEditingController(text: start),
        end = TextEditingController(text: end);
  final String id;
  final TextEditingController name;
  final TextEditingController start;
  final TextEditingController end;
}
