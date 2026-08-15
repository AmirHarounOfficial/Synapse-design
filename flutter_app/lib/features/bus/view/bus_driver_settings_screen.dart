import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `BusDriverSettings.tsx`. Driver profile card, compliance &
/// certifications list, and a logout button that opens a confirmation dialog.
/// Brand wordmark "Synapse" is rendered as "SchooKeep" per the porting guide.
class BusDriverSettingsScreen extends StatelessWidget {
  const BusDriverSettingsScreen({super.key});

  static const Map<String, String> _userInfo = {
    'name': 'Robert Anderson',
    'employeeId': 'BD-128',
    'role': 'Bus Driver',
    'route': 'Route 12',
    'email': 'r.anderson@school.edu',
    'phone': '(555) 123-4567',
    'lastLogin': 'May 25, 2026 at 6:48 AM',
  };

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 384),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: SchooKeepColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.logOut, size: 32, color: SchooKeepColors.error),
              ),
              const SizedBox(height: 16),
              const Text('Log Out of SchooKeep?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('You will need to re-authenticate with 2FA to access the bus driver portal again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: const SchooKeepAppBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(),
            const SizedBox(height: 16),
            const Text('COMPLIANCE & CERTIFICATIONS',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _certCard(
              icon: LucideIcons.fileText,
              iconColor: SchooKeepColors.accent,
              iconBg: SchooKeepColors.greenChipBg,
              title: 'CDL License (Class B)',
              subtitle: 'Valid until August 2027',
              activeBadge: true,
            ),
            const SizedBox(height: 8),
            _certCard(
              icon: LucideIcons.shield,
              iconColor: SchooKeepColors.primary,
              iconBg: const Color(0xFFEFF6FF),
              title: 'Confidentiality Agreement',
              subtitle: 'Signed on April 12, 2026',
            ),
            const SizedBox(height: 8),
            _certCard(
              icon: LucideIcons.fileText,
              iconColor: SchooKeepColors.primary,
              iconBg: const Color(0xFFEFF6FF),
              title: 'FERPA Training Certificate',
              subtitle: 'Completed April 15, 2026 • Valid until April 2027',
            ),
            const SizedBox(height: 8),
            _certCard(
              icon: LucideIcons.shield,
              iconColor: SchooKeepColors.primary,
              iconBg: const Color(0xFFEFF6FF),
              title: 'Student Safety Protocols',
              subtitle: 'Last reviewed May 1, 2026',
            ),
            const SizedBox(height: 8),
            _certCard(
              icon: LucideIcons.fileText,
              iconColor: SchooKeepColors.accent,
              iconBg: SchooKeepColors.greenChipBg,
              title: 'First Aid & CPR Certification',
              subtitle: 'Valid until December 2026',
            ),
            const SizedBox(height: 16),
            _infoNotice(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: SchooKeepColors.surface,
                  side: const BorderSide(color: SchooKeepColors.error, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _confirmLogout(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
                    SizedBox(width: 8),
                    Text('Log Out',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.error)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('SchooKeep v2.1.0 • Bus Driver Portal',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    return SchooKeepCard(
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
                alignment: Alignment.center,
                child: const Icon(LucideIcons.user, size: 32, color: SchooKeepColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userInfo['name']!,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('${_userInfo['role']} • ${_userInfo['employeeId']}',
                        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.bus, size: 14, color: SchooKeepColors.primary),
                          const SizedBox(width: 6),
                          Text(_userInfo['route']!,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _infoRow('Email', _userInfo['email']!),
          const SizedBox(height: 8),
          _infoRow('Phone', _userInfo['phone']!),
          const SizedBox(height: 8),
          _infoRow('Last Login', _userInfo['lastLogin']!),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
        ),
      ],
    );
  }

  Widget _certCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    bool activeBadge = false,
  }) {
    return SchooKeepCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
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
          if (activeBadge) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: SchooKeepColors.greenChipBg, borderRadius: BorderRadius.circular(6)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.lock, size: 12, color: SchooKeepColors.greenChipText),
                  SizedBox(width: 4),
                  Text('Active',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SchooKeepColors.greenChipText)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: const Text(
        'All boarding and drop-off events are logged with parent notifications. Records are maintained for safety and compliance.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
      ),
    );
  }
}
