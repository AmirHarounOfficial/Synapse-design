import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

typedef _SettingsItem = ({String label, IconData icon, String? badge, VoidCallback? action});

/// Ported from `VicePrincipalSettings.tsx`. Profile card with delegation note,
/// grouped settings sections, app info, sign-out (with confirm dialog) and a
/// legal notice. Fully localized for English and Arabic.
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
        title: context.tr(en: 'Account', ar: 'الحساب'),
        items: [
          (
            label: context.tr(en: 'Profile information', ar: 'معلومات الملف الشخصي'),
            icon: LucideIcons.user,
            badge: null,
            action: null,
          ),
          (
            label: context.tr(en: 'My access level', ar: 'مستوى الصلاحية الممنوح'),
            icon: LucideIcons.lock,
            badge: context.tr(en: '2 granted', ar: 'صلاحيتان ممنوحتان'),
            action: () => context.go('/vice-principal/permissions'),
          ),
          (
            label: context.tr(en: 'Notification preferences', ar: 'تفضيلات الإشعارات والتنبيهات'),
            icon: LucideIcons.bell,
            badge: null,
            action: null,
          ),
        ],
      ),
      (
        title: context.tr(en: 'Privacy & Security', ar: 'الخصوصية والأمان'),
        items: [
          (
            label: context.tr(en: 'Confidentiality agreement', ar: 'اتفاقية سرية المعلومات'),
            icon: LucideIcons.shield,
            badge: context.tr(en: 'Signed', ar: 'موقّعة'),
            action: null,
          ),
          (
            label: context.tr(en: 'Data access scope', ar: 'نطاق الوصول للبيانات'),
            icon: LucideIcons.fileText,
            badge: context.tr(en: 'View only', ar: 'للقراءة فقط'),
            action: null,
          ),
        ],
      ),
      (
        title: context.tr(en: 'Communication', ar: 'التواصل والرسائل'),
        items: [
          (
            label: context.tr(en: 'Message Principal', ar: 'مراسلة مدير المدرسة'),
            icon: LucideIcons.mail,
            badge: null,
            action: () => context.go('/vice-principal/messages?compose=principal'),
          ),
        ],
      ),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(title: context.tr(en: 'Settings', ar: 'الإعدادات')),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileCard(),
          const SizedBox(height: 16),
          for (final section in sections) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
              child: Text(
                section.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: SchooKeepColors.textSecondary,
                ),
              ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFEFF6FF),
                child: Text('VD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(en: 'Victoria Davis', ar: 'فيكتوريا ديفيس'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr(en: 'Vice Principal', ar: 'نائب مدير المدرسة'),
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    const Text('v.davis@schookeep.ae', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF1E40AF)),
                children: [
                  TextSpan(
                    text: context.tr(en: 'Delegated role: ', ar: 'الدور المفوض: '),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: context.tr(
                      en: 'Permissions granted by Principal M. Davis on May 1, 2026',
                      ar: 'تم منح الصلاحيات بواسطة مدير المدرسة م. ديفيس بتاريخ 1 مايو 2026',
                    ),
                  ),
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
                    Text(
                      item.label,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
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
          Text(
            context.tr(en: 'Version 2.1.0 (Build 487)', ar: 'الإصدار 2.1.0 (بناء 487)'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                context.tr(en: 'UAE PDPL Privacy Declaration', ar: 'إعلان خصوصية البيانات الإماراتي (PDPL)'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
              ),
              const Text(' · ', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              Text(
                context.tr(en: 'Terms of Service', ar: 'شروط الخدمة'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signOutButton() {
    return SchooKeepCard(
      onTap: _showSignOutDialog,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
          const SizedBox(width: 8),
          Text(
            context.tr(en: 'Sign out', ar: 'تسجيل الخروج'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.error),
          ),
        ],
      ),
    );
  }

  Widget _legalNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Text(
        context.tr(
          en: 'Access to SchooKeep is governed by UAE PDPL and DHA school health guidelines. All activities are logged for compliance and audit purposes under UAE regulations.',
          ar: 'تخضع صلاحيات الوصول لقانون حماية البيانات الإماراتي ولوائح هيئة الصحة بدبي للصحة المدرسية. يتم تسجيل جميع الأنشطة لأغراض التدقيق والامتثال.',
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
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
                Text(
                  context.tr(en: 'Sign out?', ar: 'تسجيل الخروج؟'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    en: 'Are you sure you want to sign out?\nYou\'ll need to sign in again to access your account.',
                    ar: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟\nستحتاج لإعادة تسجيل الدخول للوصول لحسابك.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: SchooKeepColors.textSecondary),
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
                            Navigator.of(dialogContext).pop();
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
      ),
    );
  }
}
