import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

typedef _SettingsItem = ({String label, IconData icon, String? badge, VoidCallback? action});

/// Ported from `VicePrincipalSettings.tsx`. Profile card with delegation note,
/// grouped settings sections, app info, sign-out (with confirm dialog) and a
/// legal notice. Data is mock.
class VicePrincipalSettingsScreen extends StatefulWidget {
  const VicePrincipalSettingsScreen({super.key});

  @override
  State<VicePrincipalSettingsScreen> createState() => _VicePrincipalSettingsScreenState();
}

class _VicePrincipalSettingsScreenState extends State<VicePrincipalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final sections = <({String title, List<_SettingsItem> items})>[
      (
        title: 'Account',
        items: [
          (label: 'Profile information', icon: LucideIcons.user, badge: null, action: null),
          (label: 'My access level', icon: LucideIcons.lock, badge: '2 granted', action: () => context.go('/vice-principal/permissions')),
          (label: 'Notification preferences', icon: LucideIcons.bell, badge: null, action: null),
        ],
      ),
      (
        title: 'Privacy & Security',
        items: [
          (label: 'Confidentiality agreement', icon: LucideIcons.shield, badge: 'Signed', action: null),
          (label: 'Data access scope', icon: LucideIcons.fileText, badge: 'View only', action: null),
        ],
      ),
      (
        title: 'Communication',
        items: [
          (label: 'Message Principal', icon: LucideIcons.mail, badge: null, action: () => context.go('/vice-principal/messages?compose=principal')),
        ],
      ),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: const SchooKeepAppBar(title: 'Settings'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileCard(),
          const SizedBox(height: 16),
          for (final section in sections) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(section.title.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: SchooKeepColors.textSecondary)),
            ),
            SchooKeepCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < section.items.length; i++) ...[
                    if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                    _settingsRow(section.items[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _appInfo(),
          const SizedBox(height: 16),
          _signOutButton(),
          const SizedBox(height: 16),
          _legalNotice(),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFEFF6FF),
                child: Text('VD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Victoria Davis',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Vice Principal', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    SizedBox(height: 8),
                    Text('v.davis@synapse.ae', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
            child: const Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF1E40AF)),
                children: [
                  TextSpan(text: 'Delegated role: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Permissions granted by Principal M. Davis on May 1, 2026'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(_SettingsItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.action,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                child: Icon(item.icon, size: 20, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    if (item.badge != null) ...[
                      const SizedBox(height: 2),
                      Text(item.badge!, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appInfo() {
    return SchooKeepCard(
      child: Column(
        children: [
          const Text('SchooKeep Health Manager',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('Version 2.1.0 (Build 487)',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            children: const [
              Text('UAE PDPL Privacy Declaration',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
              Text(' · ', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              Text('Terms of Service',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signOutButton() {
    return SchooKeepCard(
      onTap: _showSignOutDialog,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
          SizedBox(width: 8),
          Text('تسجيل الخروج · Sign out',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.error)),
        ],
      ),
    );
  }

  Widget _legalNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: const Text(
        'Access to SchooKeep is governed by UAE PDPL and DHA school health guidelines. All activities are logged for compliance and audit purposes under UAE regulations.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
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
                  'هل أنت متأكد من رغبتك في تسجيل الخروج؟\nYou\'ll need to sign in again to access your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5, color: SchooKeepColors.textSecondary),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
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
                            Navigator.of(dialogContext).pop();
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
      ),
    );
  }
}
