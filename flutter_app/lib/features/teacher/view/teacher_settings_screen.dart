import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `TeacherSettings.tsx`. Profile card, notification preference
/// toggles (medical alerts locked on), class roster link, data & privacy rows,
/// and a sign-out flow with a bilingual confirmation dialog.
class TeacherSettingsScreen extends StatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  State<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends State<TeacherSettingsScreen> {
  bool _weatherAlerts = true;
  bool _clinicNotifications = true;
  bool _systemAnnouncements = true;

  static const _name = 'Sarah Johnson';
  static const _initials = 'SJ';
  static const _room = 'Room 204';
  static const _grade = 'Grade 5 Homeroom';
  static const _school = 'Lincoln Elementary School';
  static const _agreementSignedDate = 'August 15, 2025';

  void _showSignOutDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('تسجيل الخروج · Sign Out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'هل أنت متأكد من رغبتك في تسجيل الخروج؟\nYou will need to sign in again to access SchooKeep.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: SchooKeepColors.border),
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

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        title: 'Settings',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(),
            const SizedBox(height: 24),
            _sectionLabel('Notification Preferences'),
            const SizedBox(height: 12),
            _notificationPrefs(),
            const SizedBox(height: 24),
            _sectionLabel('My Students'),
            const SizedBox(height: 12),
            _rosterButton(),
            const SizedBox(height: 24),
            _sectionLabel('Data & Privacy'),
            const SizedBox(height: 12),
            _dataPrivacy(),
            const SizedBox(height: 24),
            _signOutButton(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.5),
      );

  Widget _profileCard() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(_name,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    Text('$_room — $_grade', style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                    Text(_school, style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.go('/agreement'),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: AlignmentDirectional.centerStart,
              child: const Text(
                'View confidentiality agreement',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: SchooKeepColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationPrefs() {
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        children: [
          // Medical alerts — locked ON
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Medical alerts for my students',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Required — cannot be disabled',
                          style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                Opacity(
                  opacity: 0.5,
                  child: IgnorePointer(
                    child: Switch(
                      value: true,
                      activeThumbColor: Colors.white,
                      activeTrackColor: SchooKeepColors.primary,
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: SchooKeepColors.border),
          _toggleRow('Weather advisories', _weatherAlerts, (v) => setState(() => _weatherAlerts = v)),
          const Divider(height: 1, color: SchooKeepColors.border),
          _toggleRow('Clinic call notifications', _clinicNotifications, (v) => setState(() => _clinicNotifications = v)),
          const Divider(height: 1, color: SchooKeepColors.border),
          _toggleRow('System announcements', _systemAnnouncements, (v) => setState(() => _systemAnnouncements = v)),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: SchooKeepColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: SchooKeepColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _rosterButton() {
    return SchooKeepCard(
      // No standalone roster screen exists; the per-student health-considerations
      // list is the teacher's class roster view.
      onTap: () => context.go('/teacher/health-considerations'),
      child: Row(
        children: const [
          Icon(LucideIcons.users, size: 20, color: SchooKeepColors.textSecondary),
          SizedBox(width: 12),
          Expanded(
            child: Text('View my class roster',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
          RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
        ],
      ),
    );
  }

  Widget _dataPrivacy() {
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => context.go('/agreement'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confidentiality agreement (UAE PDPL Compliant)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                        SizedBox(height: 2),
                        Text('Signed $_agreementSignedDate',
                            style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: SchooKeepColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(LucideIcons.shield, size: 20, color: SchooKeepColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('My data access level',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Contraindications only — read-only',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _signOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), side: const BorderSide(color: SchooKeepColors.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _showSignOutDialog,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
              SizedBox(width: 8),
              Text('تسجيل الخروج · Sign out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
