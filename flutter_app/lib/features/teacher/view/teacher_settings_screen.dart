import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Teacher settings screen with full bilingual support (English & Arabic).
class TeacherSettingsScreen extends StatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  State<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends State<TeacherSettingsScreen> {
  bool _weatherAlerts = true;
  bool _clinicNotifications = true;
  bool _systemAnnouncements = true;

  static const _nameEn = 'Sarah Johnson';
  static const _nameAr = 'سارة جونسون';
  static const _initials = 'SJ';
  static const _roomEn = 'Room 204';
  static const _roomAr = 'قاعة 204';
  static const _gradeEn = 'Grade 5 Homeroom';
  static const _gradeAr = 'معلمة الصف الخامس';
  static const _schoolEn = 'Lincoln Elementary School';
  static const _schoolAr = 'مدرسة الشروق النموذجية';

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
              Text(
                context.tr(en: 'Sign Out?', ar: 'تسجيل الخروج؟'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  en: 'Are you sure you want to sign out?\nYou will need to sign in again to access SchooKeep.',
                  ar: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟\nستحتاج لإعادة تسجيل الدخول للوصول للتطبيق.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
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
                        child: Text(
                          context.tr(en: 'Cancel', ar: 'إلغاء'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                        ),
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
                        child: Text(
                          context.tr(en: 'Sign out', ar: 'تسجيل الخروج'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
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
        title: context.tr(en: 'Settings', ar: 'الإعدادات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(),
            const SizedBox(height: 24),
            _sectionLabel(context.tr(en: 'Notification Preferences', ar: 'تفضيلات الإشعارات')),
            const SizedBox(height: 12),
            _notificationPrefs(),
            const SizedBox(height: 24),
            _sectionLabel(context.tr(en: 'My Students', ar: 'طلابي')),
            const SizedBox(height: 12),
            _rosterButton(),
            const SizedBox(height: 24),
            _sectionLabel(context.tr(en: 'Data & Privacy', ar: 'البيانات والخصوصية')),
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
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: SchooKeepColors.textSecondary,
          letterSpacing: 0.5,
        ),
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
                  children: [
                    Text(
                      context.tr(en: _nameEn, ar: _nameAr),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
                    Text(
                      '${context.tr(en: _roomEn, ar: _roomAr)} — ${context.tr(en: _gradeEn, ar: _gradeAr)}',
                      style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                    ),
                    Text(
                      context.tr(en: _schoolEn, ar: _schoolAr),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
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
              child: Text(
                context.tr(en: 'View confidentiality agreement', ar: 'عرض اتفاقية سرية البيانات الموقعة'),
                style: const TextStyle(
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
                    children: [
                      Text(
                        context.tr(en: 'Medical alerts for my students', ar: 'التنبيهات الطبية لطلابي'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(en: 'Required — cannot be disabled', ar: 'إلزامي — لا يمكن إيقافه'),
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                      ),
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
          _toggleRow(
            context.tr(en: 'Weather advisories', ar: 'تنبيهات الأحوال الجوية'),
            _weatherAlerts,
            (v) => setState(() => _weatherAlerts = v),
          ),
          const Divider(height: 1, color: SchooKeepColors.border),
          _toggleRow(
            context.tr(en: 'Clinic call notifications', ar: 'إشعارات استدعاء العيادة الطبية'),
            _clinicNotifications,
            (v) => setState(() => _clinicNotifications = v),
          ),
          const Divider(height: 1, color: SchooKeepColors.border),
          _toggleRow(
            context.tr(en: 'System announcements', ar: 'تنبيهات وإعلانات النظام'),
            _systemAnnouncements,
            (v) => setState(() => _systemAnnouncements = v),
          ),
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
      onTap: () => context.go('/teacher/health-considerations'),
      child: Row(
        children: [
          const Icon(LucideIcons.users, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr(en: 'View my class roster', ar: 'عرض قائمة طلاب الفصل والحالات الصحية'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
          ),
          const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            en: 'Confidentiality agreement (UAE PDPL Compliant)',
                            ar: 'اتفاقية سرية المعلومات (وفق قانون حماية البيانات الإماراتي)',
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr(en: 'Signed August 15, 2025', ar: 'موقعة بتاريخ 15 أغسطس 2025'),
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
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
                Expanded(
                  child: Text(
                    context.tr(en: 'My data access level', ar: 'مستوى صلاحية الاطلاع بالبيانات'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.tr(en: 'Contraindications only — read-only', ar: 'موانع علاجية فقط — قراءة فقط'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                  ),
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
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: SchooKeepColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _showSignOutDialog,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Sign out', ar: 'تسجيل الخروج'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
