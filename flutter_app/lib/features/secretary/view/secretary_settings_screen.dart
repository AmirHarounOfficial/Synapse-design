import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `SecretarySettings.tsx`. Profile card, notification toggles (with
/// one locked/required toggle that opens an explanatory sheet), working hours,
/// import history, data & privacy, about, and a bilingual sign-out button with a
/// confirmation dialog. Inline mock data.
class SecretarySettingsScreen extends StatefulWidget {
  const SecretarySettingsScreen({super.key});

  @override
  State<SecretarySettingsScreen> createState() => _SecretarySettingsScreenState();
}

class _SecretarySettingsScreenState extends State<SecretarySettingsScreen> {
  bool _parentMessages = true;
  bool _importErrors = true;
  bool _clinicCopies = true;
  bool _documentExpiry = true;

  static const String _initials = 'SL';
  static const String _name = 'Sarah Lopez';
  static const String _role = 'School Secretary';
  static const String _school = 'Lakewood Elementary School';
  static const String _officeHours = '08:00 AM — 4:30 PM';

  void _showLockSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: SchooKeepColors.border, borderRadius: BorderRadius.circular(999)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(LucideIcons.lock, size: 24, color: SchooKeepColors.warning),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Required Notification',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      SizedBox(height: 8),
                      Text(
                        'Chatbot escalations must be received by the secretary to ensure no parent query goes unanswered.',
                        style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Got it', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('تسجيل الخروج · Sign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                "هل أنت متأكد من رغبتك في تسجيل الخروج؟\nYou'll need to sign in again to access your account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('إلغاء · Cancel',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SchooKeepColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.go('/login');
                        },
                        child: const Text('تسجيل الخروج · Sign out',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Generic bilingual info sheet used by the settings rows that have no
  /// dedicated destination screen.
  void _showInfoSheet({
    required IconData icon,
    Color iconColor = SchooKeepColors.primary,
    required String title,
    required List<Widget> body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: SchooKeepColors.border, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 24, color: iconColor)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: body),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إغلاق · Close',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _para(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5)),
      );

  void _showEditProfileInfo() => _showInfoSheet(
        icon: LucideIcons.userCog,
        title: 'تعديل الملف الشخصي · Edit profile',
        body: [
          _para('Name, role, and school assignment are managed by your school administrator and cannot be changed here.'),
          _para('To update your profile details, contact the school administration office.'),
        ],
      );

  void _showWorkingHoursInfo() => _showInfoSheet(
        icon: LucideIcons.clock,
        title: 'ساعات العمل · Working hours',
        body: [
          _para('Office hours: $_officeHours'),
          _para('Non-emergency notifications are batched and delivered during these hours. Emergency clinic escalations are always delivered immediately, day or night.'),
        ],
      );

  void _showImportHistoryInfo() => _showInfoSheet(
        icon: LucideIcons.table,
        title: 'سجل الاستيراد · Import history',
        body: [
          _para('Recent student imports:'),
          _para('• students_uae_2026.xlsx — 45 students — May 28, 2026 — Completed'),
          _para('• transfers_q1.csv — 8 students — Apr 12, 2026 — Completed'),
          _para('Every Excel/CSV import is logged with its row count and validation result for audit purposes.'),
        ],
      );

  void _showConfidentialityInfo() => _showInfoSheet(
        icon: LucideIcons.file,
        title: 'اتفاقية السرية · Confidentiality agreement',
        body: [
          _para('Signed: May 1, 2026'),
          _para('As school secretary, you agree to keep all student information strictly confidential under UAE Federal Decree-Law No. 45 of 2021 (PDPL), to access only the data needed for your duties, and to report any suspected breach to the Data Protection Officer immediately.'),
          _para('Your digital signature is on file and this agreement remains active for the duration of your employment.'),
        ],
      );

  void _showDataAccessInfo() => _showInfoSheet(
        icon: LucideIcons.shield,
        title: 'مستوى الوصول · My data access level',
        body: [
          _para('Your role can access: student basic info, enrollment records, parent contact details, and import history.'),
          _para('Your role cannot access: clinical records, medication data, clinic visit history, or counselor notes.'),
          _para('This scope is enforced server-side per UAE PDPL data-minimization requirements.'),
        ],
      );

  void _showTwoFactorInfo() => _showInfoSheet(
        icon: LucideIcons.eyeOff,
        title: 'المصادقة الثنائية · Two-factor authentication',
        body: [
          _para('Status: Enabled'),
          _para('A one-time verification code is required each time you sign in, protecting student data even if your password is compromised.'),
          _para('Two-factor authentication is mandatory for staff with student-data access and cannot be disabled from this device.'),
        ],
      );

  void _showContactSupportInfo() => _showInfoSheet(
        icon: LucideIcons.headphones,
        title: 'الاتصال بالدعم · Contact support',
        body: [
          _para('SchooKeep support is available Sunday–Thursday, 8:00 AM – 5:00 PM (GST).'),
          _para('Email: support@schookeep.ae'),
          _para('Phone: 800-SCHOOL (800-724665)'),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SchooKeepButton(
              label: 'Copy support email',
              fullWidth: false,
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: 'support@schookeep.ae'));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support email copied to clipboard')),
                );
              },
            ),
          ),
        ],
      );

  void _showPdplInfo() => _showInfoSheet(
        icon: LucideIcons.book,
        title: 'إعلان خصوصية PDPL · UAE PDPL Privacy Declaration',
        body: [
          _para('Governed by Federal Decree-Law No. 45 of 2021 on the Protection of Personal Data.'),
          _para('SchooKeep processes student health and personal data solely to support school health and safety operations. Data is stored within the UAE, access is role-scoped, and all access is logged.'),
          _para('Data subjects (parents/guardians) retain the right to access, rectify, and request erasure of personal data, subject to legal retention requirements.'),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: const SchooKeepAppBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile
            SchooKeepCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFFECFEFF), shape: BoxShape.circle),
                        child: const Text(_initials,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xFF0E7490))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(_name,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFEFF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(_role,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0E7490))),
                            ),
                            const SizedBox(height: 4),
                            const Text(_school, style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GestureDetector(
                      onTap: _showEditProfileInfo,
                      child: const Text('Edit profile',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notifications
            _sectionTitle('Notifications'),
            const SizedBox(height: 8),
            _group([
              _toggleRow(LucideIcons.bell, 'Parent messages received', 'New messages from parents in your inbox',
                  _parentMessages, (v) => setState(() => _parentMessages = v)),
              _lockedToggleRow(LucideIcons.bot, 'Chatbot escalations',
                  'When the AI assistant transfers a conversation to you'),
              _toggleRow(LucideIcons.fileText, 'Student import errors',
                  'Alerts when an Excel/CSV import has validation failures', _importErrors,
                  (v) => setState(() => _importErrors = v)),
              _toggleRow(LucideIcons.alertTriangle, 'Clinic copies',
                  'Receive copies of emergency clinic notifications sent to parents', _clinicCopies,
                  (v) => setState(() => _clinicCopies = v)),
              _toggleRow(LucideIcons.calendar, 'Document expiry reminders',
                  'Students with documents expiring within 30 days', _documentExpiry,
                  (v) => setState(() => _documentExpiry = v)),
            ]),
            const SizedBox(height: 16),

            // Working Hours
            _sectionTitle('Working Hours'),
            const SizedBox(height: 8),
            SchooKeepCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: _showWorkingHoursInfo,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(LucideIcons.clock, size: 20, color: SchooKeepColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Office hours',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                                Text(_officeHours, style: TextStyle(fontSize: 14, color: SchooKeepColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Notifications are batched outside these hours (except emergency escalations).',
                              style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Import History
            _sectionTitle('Import History'),
            const SizedBox(height: 8),
            SchooKeepCard(
              padding: EdgeInsets.zero,
              child: _navRow(LucideIcons.table, 'View past imports',
                  'See all Excel/CSV student imports and their results', onTap: _showImportHistoryInfo),
            ),
            const SizedBox(height: 16),

            // Data & Privacy
            _sectionTitle('Data & Privacy'),
            const SizedBox(height: 8),
            _group([
              _navRow(LucideIcons.file, 'Confidentiality agreement', null,
                  trailing: 'Signed May 1, 2026', onTap: _showConfidentialityInfo),
              _navRow(LucideIcons.shield, 'My data access level', null,
                  trailing: 'Student basic info — no clinical records', onTap: _showDataAccessInfo),
              _navRow(LucideIcons.eyeOff, 'Two-factor authentication', null,
                  trailing: 'Enabled', trailingColor: SchooKeepColors.accent, onTap: _showTwoFactorInfo),
            ]),
            const SizedBox(height: 16),

            // About
            _sectionTitle('About'),
            const SizedBox(height: 8),
            _group([
              _infoRow(LucideIcons.info, 'App version', 'Synapse v1.0.0'),
              _navRow(LucideIcons.headphones, 'Contact support', null, onTap: _showContactSupportInfo),
              _navRow(LucideIcons.book, 'UAE PDPL Privacy Declaration',
                  'Governed by Federal Decree-Law No. 45 of 2021', onTap: _showPdplInfo),
            ]),
            const SizedBox(height: 16),

            // Sign out
            SchooKeepCard(
              padding: EdgeInsets.zero,
              onTap: _showSignOutDialog,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('تسجيل الخروج · Sign out',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.error)),
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
      child: Text(title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: SchooKeepColors.textSecondary,
            letterSpacing: 0.8,
          )),
    );
  }

  Widget _group(List<Widget> children) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const Divider(height: 1, color: Color(0xFFF1F5F9)));
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
                const SizedBox(height: 2),
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

  /// A toggle that is locked on (chatbot escalations). Tapping shows the
  /// "Required Notification" sheet instead of toggling.
  Widget _lockedToggleRow(IconData icon, String title, String subtitle) {
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
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          InkWell(
            onTap: _showLockSheet,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 4),
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(color: SchooKeepColors.primary, borderRadius: BorderRadius.circular(999)),
                  child: const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 4),
                      child: CircleAvatar(radius: 10, backgroundColor: Colors.white),
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

  Widget _navRow(IconData icon, String title, String? subtitle,
      {String? trailing, Color? trailingColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(trailing,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 12, color: trailingColor ?? SchooKeepColors.textSecondary)),
              ),
              const SizedBox(width: 8),
            ],
            const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
          Text(trailing, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }
}
