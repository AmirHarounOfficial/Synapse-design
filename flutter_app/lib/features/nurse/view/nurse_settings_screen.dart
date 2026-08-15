import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `NurseSettings.tsx`. Profile card, notification toggles,
/// session/security controls, reports shortcut, about/help and a sign-out
/// button. English-only in the source (sign-out label is bilingual).
class NurseSettingsScreen extends StatefulWidget {
  const NurseSettingsScreen({super.key});

  @override
  State<NurseSettingsScreen> createState() => _NurseSettingsScreenState();
}

class _NurseSettingsScreenState extends State<NurseSettingsScreen> {
  bool _medicationDue = true;
  bool _clinicReferrals = true;
  bool _emergency = true;
  bool _documents = true;
  bool _system = false;

  int _autoLockMinutes = 5;
  bool _requireBiometric = true;

  static const String _name = 'Jane Smith';
  static const String _initials = 'JS';
  static const String _license = 'RN-4521';
  static const String _role = 'School Nurse';

  void _handleSignOut() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج · Sign out?'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟\nAre you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/login');
            },
            child: const Text('Sign out', style: TextStyle(color: SchooKeepColors.error)),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfoSheet({required String title, required List<Widget> children}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Close',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet() {
    _showInfoSheet(
      title: 'Edit profile',
      children: const [
        Text('Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
        SizedBox(height: 2),
        Text(_name, style: TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
        SizedBox(height: 12),
        Text('License', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
        SizedBox(height: 2),
        Text('#$_license', style: TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
        SizedBox(height: 12),
        Text('Role', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
        SizedBox(height: 2),
        Text(_role, style: TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
        SizedBox(height: 16),
        Text('Profile details are managed by your school administrator. Contact support to request a change.',
            style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5)),
      ],
    );
  }

  void _showSessionInfoSheet() {
    _showInfoSheet(
      title: 'Active session info',
      children: const [
        _SessionRow(label: 'Device', value: 'iPhone 14 · iOS 17.4'),
        _SessionRow(label: 'Location', value: 'Dubai, United Arab Emirates'),
        _SessionRow(label: 'IP address', value: '94.200.18.42'),
        _SessionRow(label: 'Signed in', value: 'Today · 07:42 AM'),
        _SessionRow(label: 'Auto-lock', value: 'Enabled'),
        SizedBox(height: 8),
        Text('This is the only active session for your account.',
            style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5)),
      ],
    );
  }

  void _showSupportSheet() {
    _showInfoSheet(
      title: 'Contact support',
      children: [
        const Text('SchooKeep Health Support is available Sunday–Thursday, 8:00 AM – 6:00 PM (GST).',
            style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5)),
        const SizedBox(height: 16),
        _contactRow(LucideIcons.mail, 'support@schookeep.ae'),
        const SizedBox(height: 8),
        _contactRow(LucideIcons.phone, '+971 4 123 4567'),
      ],
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!mounted) return;
        _toast('Copied $value');
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SchooKeepColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: SchooKeepColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            ),
            const Icon(LucideIcons.copy, size: 16, color: SchooKeepColors.primary),
          ],
        ),
      ),
    );
  }

  void _showPdplSheet() {
    _showInfoSheet(
      title: 'UAE PDPL Privacy Declaration',
      children: const [
        Text('Governed by Federal Decree-Law No. 45 of 2021 on the Protection of Personal Data (PDPL).',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary, height: 1.6)),
        SizedBox(height: 14),
        Text(
            'SchooKeep processes student health records as protected personal data. Access is restricted to authorized school health staff and is logged for audit purposes.',
            style: TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.6)),
        SizedBox(height: 14),
        Text(
            'Data is stored within the UAE and is not shared with third parties without explicit consent, except where required by law. Unauthorized disclosure or modification of these records violates Federal law and may result in legal action.',
            style: TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.6)),
        SizedBox(height: 14),
        Text(
            'Parents and guardians may request access to, correction of, or deletion of their child’s records by contacting the school administrator.',
            style: TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.6)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(title: 'Settings', onBack: () => context.safeBack()),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile
            SchooKeepCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                        child: const Text(_initials,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(_name,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                            const SizedBox(height: 4),
                            const Text('License #$_license',
                                style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(_role,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1E40AF))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: SchooKeepColors.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showEditProfileSheet,
                      child: const Text('Edit profile',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notifications
            _sectionTitle('Notifications'),
            const SizedBox(height: 12),
            _group([
              _toggleRow(LucideIcons.bell, 'Medication due', 'Push, SMS, Email', _medicationDue, (v) => setState(() => _medicationDue = v)),
              _toggleRow(LucideIcons.bell, 'Clinic referrals', 'Push, SMS', _clinicReferrals, (v) => setState(() => _clinicReferrals = v)),
              _toggleRow(LucideIcons.bell, 'Emergency', 'Push, SMS, Email', _emergency, (v) => setState(() => _emergency = v)),
              _toggleRow(LucideIcons.bell, 'Documents', 'Push', _documents, (v) => setState(() => _documents = v)),
              _toggleRow(LucideIcons.bell, 'System', 'App updates & maintenance', _system, (v) => setState(() => _system = v)),
            ]),
            const SizedBox(height: 24),

            // Session & Security
            _sectionTitle('Session & Security'),
            const SizedBox(height: 12),
            _group([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Auto-lock after',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                          Text('Currently: $_autoLockMinutes minutes',
                              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                        ],
                      ),
                    ),
                    _stepperButton('-', () => setState(() => _autoLockMinutes = (_autoLockMinutes - 1).clamp(3, 10))),
                    SizedBox(
                      width: 24,
                      child: Text('$_autoLockMinutes',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    ),
                    _stepperButton('+', () => setState(() => _autoLockMinutes = (_autoLockMinutes + 1).clamp(3, 10))),
                  ],
                ),
              ),
              _toggleRow(LucideIcons.shield, 'Require biometric on return', 'Face ID or Touch ID', _requireBiometric,
                  (v) => setState(() => _requireBiometric = v)),
              _navRow(LucideIcons.lock, 'Active session info', 'Device & location details', onTap: _showSessionInfoSheet),
            ]),
            const SizedBox(height: 24),

            // My Reports
            _sectionTitle('My Reports'),
            const SizedBox(height: 12),
            SchooKeepCard(
              padding: EdgeInsets.zero,
              onTap: () => context.go('/nurse/reports/generate'),
              child: _navRowContent(LucideIcons.fileText, 'View my generated reports', 'Access report history'),
            ),
            const SizedBox(height: 24),

            // About & Help
            _sectionTitle('About & Help'),
            const SizedBox(height: 12),
            _group([
              _navRow(LucideIcons.helpCircle, 'Contact support', null, onTap: _showSupportSheet),
              _navRow(LucideIcons.shield, 'UAE PDPL Privacy Declaration', 'Governed by Federal Decree-Law No. 45 of 2021', onTap: _showPdplSheet),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Version 1.0.0 (Build 2026.05.25)',
                      style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // Sign out
            SchooKeepCard(
              padding: EdgeInsets.zero,
              borderColor: SchooKeepColors.error,
              onTap: _handleSignOut,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
                    SizedBox(width: 8),
                    Text('تسجيل الخروج · Sign out',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.error)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
    );
  }

  Widget _group(List<Widget> children) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const Divider(height: 1, color: SchooKeepColors.border));
      items.add(children[i]);
    }
    return SchooKeepCard(padding: EdgeInsets.zero, child: Column(children: items));
  }

  Widget _toggleRow(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: SchooKeepColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _navRow(IconData icon, String title, String? subtitle, {required VoidCallback onTap}) {
    return InkWell(onTap: onTap, child: _navRowContent(icon, title, subtitle));
  }

  Widget _navRowContent(IconData icon, String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
        ],
      ),
    );
  }

  Widget _stepperButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: const TextStyle(fontSize: 18, color: SchooKeepColors.textSecondary)),
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
        ],
      ),
    );
  }
}
