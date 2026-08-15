import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/data/auth_repository.dart';

/// Principal settings (the React route originally rendered a "Settings screen
/// placeholder" div). Built to match the other roles' settings screens
/// (see `nurse_settings_screen.dart`): a profile header, notification toggles,
/// a language toggle, school-management shortcuts, about/help info dialogs and a
/// sign-out that clears auth and returns to `/login`.
class PrincipalSettingsPlaceholderScreen extends StatefulWidget {
  const PrincipalSettingsPlaceholderScreen({super.key});

  @override
  State<PrincipalSettingsPlaceholderScreen> createState() => _PrincipalSettingsPlaceholderScreenState();
}

class _PrincipalSettingsPlaceholderScreenState extends State<PrincipalSettingsPlaceholderScreen> {
  bool _staffActivity = true;
  bool _advisories = true;
  bool _complianceAlerts = true;
  bool _weeklyDigest = false;

  static const String _name = 'Dr. Linda Rodriguez';
  static const String _initials = 'LR';
  static const String _role = 'Principal';
  static const String _school = 'Lakewood Elementary';

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج · Sign out?'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟\nAre you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign out', style: TextStyle(color: SchooKeepColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await sl<AuthRepository>().logout();
    if (!mounted) return;
    context.go('/login');
  }

  void _showInfo(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: const SchooKeepAppBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(),
            const SizedBox(height: 24),

            // Notifications
            _sectionTitle('Notifications'),
            const SizedBox(height: 12),
            _group([
              _toggleRow(LucideIcons.users, 'Staff activity', 'Clock-in & coverage updates', _staffActivity,
                  (v) => setState(() => _staffActivity = v)),
              _toggleRow(LucideIcons.cloudOff, 'Weather advisories', 'AQI & sandstorm alerts', _advisories,
                  (v) => setState(() => _advisories = v)),
              _toggleRow(LucideIcons.shield, 'Compliance alerts', 'Consents & document renewals', _complianceAlerts,
                  (v) => setState(() => _complianceAlerts = v)),
              _toggleRow(LucideIcons.barChart3, 'Weekly digest', 'Summary email every Sunday', _weeklyDigest,
                  (v) => setState(() => _weeklyDigest = v)),
            ]),
            const SizedBox(height: 24),

            // Language
            _sectionTitle('Language'),
            const SizedBox(height: 12),
            _group([
              _navRow(
                LucideIcons.languages,
                'App language',
                isRTL ? 'العربية (RTL)' : 'English',
                onTap: () => context.read<LocaleCubit>().toggleLanguage(),
              ),
            ]),
            const SizedBox(height: 24),

            // School management
            _sectionTitle('School Management'),
            const SizedBox(height: 12),
            _group([
              _navRow(LucideIcons.settings, 'School settings', 'Info, branding & calendar',
                  onTap: () => context.go('/principal/school-setup')),
              _navRow(LucideIcons.shield, 'Legal & compliance', 'Documents & consent status',
                  onTap: () => context.go('/principal/legal-documents')),
              _navRow(LucideIcons.lock, 'Audit log', 'Tamper-proof activity history',
                  onTap: () => context.go('/principal/audit')),
            ]),
            const SizedBox(height: 24),

            // About & Help
            _sectionTitle('About & Help'),
            const SizedBox(height: 12),
            _group([
              _navRow(LucideIcons.helpCircle, 'Contact support', null,
                  onTap: () => _showInfo('Contact support',
                      'Reach the SchooKeep support team at support@schookeep.ae or call +971 4 000 0000 during business hours.')),
              _navRow(LucideIcons.shield, 'UAE PDPL Privacy Declaration',
                  'Governed by Federal Decree-Law No. 45 of 2021',
                  onTap: () => _showInfo('UAE PDPL Privacy Declaration',
                      'Student health data is processed in accordance with UAE Federal Decree-Law No. 45 of 2021 (PDPL) and DHA School Health Guidelines.')),
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

  Widget _profileCard() {
    return SchooKeepCard(
      child: Row(
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
                const Text(_school, style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(999)),
                  child: const Text(_role,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1E40AF))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
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
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
            const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
