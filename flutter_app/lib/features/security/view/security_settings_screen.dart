import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `SecuritySettings.tsx`. Officer profile, compliance & privacy
/// items, a logged-action notice, and a log-out flow with a confirmation
/// dialog. Data is mock.
class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  static const _name = 'Marcus Johnson';
  static const _badge = '#042';
  static const _role = 'Security Officer';
  static const _shift = 'Morning Shift (7:00 AM - 3:00 PM)';
  static const _email = 'm.johnson@school.edu';
  static const _lastLogin = 'May 25, 2026 at 7:02 AM';

  /// Generic info sheet for the compliance & privacy rows, which have no
  /// dedicated destination screen.
  static void _showInfoSheet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> paragraphs,
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
                Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 24, color: SchooKeepColors.primary)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(p,
                            style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.logOut, size: 32, color: SchooKeepColors.error),
                ),
                const SizedBox(height: 16),
                const Text('Log Out of SchooKeep?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 8),
                const Text(
                  'You will need to re-authenticate with 2FA to access the security portal again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: SchooKeepColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: SchooKeepColors.error,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.go('/login');
                          },
                          child: const Text('Log Out',
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
      ),
    );
  }

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
            _profileCard(),
            const SizedBox(height: 16),
            const Text('COMPLIANCE & PRIVACY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.textSecondary,
                  letterSpacing: 0.5,
                )),
            const SizedBox(height: 12),
            _complianceItem(
              icon: LucideIcons.shield,
              title: 'Confidentiality Agreement',
              subtitle: 'Signed on May 15, 2026',
              trailing: _activeBadge(),
              onTap: () => _showInfoSheet(
                context,
                icon: LucideIcons.shield,
                title: 'Confidentiality Agreement',
                paragraphs: const [
                  'Signed on May 15, 2026 — Active.',
                  'As a security officer, you agree to keep all pickup-verification and student-identity information strictly confidential under UAE Federal Decree-Law No. 45 of 2021 (PDPL).',
                  'Your digital signature is on file and this agreement remains active for the duration of your assignment.',
                ],
              ),
            ),
            const SizedBox(height: 8),
            _complianceItem(
              icon: LucideIcons.fileText,
              title: 'FERPA Training Certificate',
              subtitle: 'Completed May 15, 2026 • Valid until May 2027',
              onTap: () => _showInfoSheet(
                context,
                icon: LucideIcons.fileText,
                title: 'FERPA Training Certificate',
                paragraphs: const [
                  'Completed: May 15, 2026.',
                  'Valid until: May 2027.',
                  'This certificate confirms you have completed training on the lawful handling of student records and pickup data. Renewal is required annually before the expiry date.',
                ],
              ),
            ),
            const SizedBox(height: 8),
            _complianceItem(
              icon: LucideIcons.shield,
              title: 'Student Safety Protocols',
              subtitle: 'Last reviewed May 20, 2026',
              onTap: () => _showInfoSheet(
                context,
                icon: LucideIcons.shield,
                title: 'Student Safety Protocols',
                paragraphs: const [
                  'Last reviewed: May 20, 2026.',
                  'Always verify the authorized-pickup match before releasing a student. Never release a student to an unverified person.',
                  'Escalate any mismatch or suspicious attempt to the front office immediately. All verification actions are permanently logged.',
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Info notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                border: Border.all(color: SchooKeepColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'All pickup verification actions are permanently logged for security compliance. Records cannot be modified or deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: SchooKeepColors.surface,
                  side: const BorderSide(color: SchooKeepColors.error, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _confirmLogout(context),
                icon: const Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
                label: const Text('Log Out',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.error)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('SchooKeep v2.1.0 • Security Portal',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() => SchooKeepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.user, size: 32, color: SchooKeepColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(_name,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      SizedBox(height: 4),
                      Text('$_role $_badge', style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                      SizedBox(height: 4),
                      Text(_shift, style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            _kvRow('Email', _email),
            const SizedBox(height: 8),
            _kvRow('Last Login', _lastLogin),
          ],
        ),
      );

  Widget _kvRow(String key, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
        ],
      );

  Widget _activeBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: SchooKeepColors.greenChipBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.lock, size: 12, color: SchooKeepColors.greenChipText),
            SizedBox(width: 4),
            Text('Active',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SchooKeepColors.greenChipText)),
          ],
        ),
      );

  Widget _complianceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) =>
      SchooKeepCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: SchooKeepColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ],
          ],
        ),
      );
}
