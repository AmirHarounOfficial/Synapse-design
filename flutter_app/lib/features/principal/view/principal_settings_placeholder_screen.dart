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
  static const String _school = 'Lakewood Elementary';

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr(en: 'Sign out?', ar: 'تسجيل الخروج؟')),
        content: Text(context.tr(en: 'Are you sure you want to sign out?', ar: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(context.tr(en: 'Cancel', ar: 'إلغاء'))),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr(en: 'Sign out', ar: 'تسجيل الخروج'), style: const TextStyle(color: SchooKeepColors.error)),
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
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(context.tr(en: 'Close', ar: 'إغلاق')))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(title: context.tr(en: 'Settings', ar: 'الإعدادات')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(context),
            const SizedBox(height: 24),

            // Notifications
            _sectionTitle(context.tr(en: 'Notifications', ar: 'الإشعارات')),
            const SizedBox(height: 12),
            _group([
              _toggleRow(
                LucideIcons.users,
                context.tr(en: 'Staff activity', ar: 'نشاط وحضور الكادر'),
                context.tr(en: 'Clock-in & coverage updates', ar: 'تحديثات الحضور والتغطية الطبية'),
                _staffActivity,
                (v) => setState(() => _staffActivity = v),
              ),
              _toggleRow(
                LucideIcons.cloudOff,
                context.tr(en: 'Weather advisories', ar: 'تنبيهات الأحوال الجوية'),
                context.tr(en: 'AQI & sandstorm alerts', ar: 'تنبيهات جودة الهواء والعواصف'),
                _advisories,
                (v) => setState(() => _advisories = v),
              ),
              _toggleRow(
                LucideIcons.shield,
                context.tr(en: 'Compliance alerts', ar: 'تنبيهات الامتثال والموافقات'),
                context.tr(en: 'Consents & document renewals', ar: 'تجديد موافقة أولياء الأمور والمستندات'),
                _complianceAlerts,
                (v) => setState(() => _complianceAlerts = v),
              ),
              _toggleRow(
                LucideIcons.barChart3,
                context.tr(en: 'Weekly digest', ar: 'التقرير التلخيصي الأسبوعي'),
                context.tr(en: 'Summary email every Sunday', ar: 'إرسال ملخص بالبريد كل يوم أحد'),
                _weeklyDigest,
                (v) => setState(() => _weeklyDigest = v),
              ),
            ]),
            const SizedBox(height: 24),

            // Language
            _sectionTitle(context.tr(en: 'Language', ar: 'اللغة')),
            const SizedBox(height: 12),
            _group([
              _navRow(
                LucideIcons.languages,
                context.tr(en: 'App language', ar: 'لغة التطبيق'),
                isRTL ? 'العربية (RTL)' : 'English',
                onTap: () => context.read<LocaleCubit>().toggleLanguage(),
              ),
            ]),
            const SizedBox(height: 24),

            // School management
            _sectionTitle(context.tr(en: 'School Management', ar: 'إدارة المدرسة')),
            const SizedBox(height: 12),
            _group([
              _navRow(
                LucideIcons.settings,
                context.tr(en: 'School settings', ar: 'إعدادات وملف المدرسة'),
                context.tr(en: 'Info, branding & calendar', ar: 'البيانات، الشعار والتقويم'),
                onTap: () => context.go('/principal/school-setup'),
              ),
              _navRow(
                LucideIcons.shield,
                context.tr(en: 'Legal & compliance', ar: 'الوثائق القانونية والامتثال'),
                context.tr(en: 'Documents & consent status', ar: 'حالة الموافقات والاتفاقيات الرسمية'),
                onTap: () => context.go('/principal/legal-documents'),
              ),
              _navRow(
                LucideIcons.lock,
                context.tr(en: 'Audit log', ar: 'سجل التدقيق والنشاطات'),
                context.tr(en: 'Tamper-proof activity history', ar: 'سجل الحركات غير القابل للتعديل'),
                onTap: () => context.go('/principal/audit'),
              ),
            ]),
            const SizedBox(height: 24),

            // About & Help
            _sectionTitle(context.tr(en: 'About & Help', ar: 'حول الدعم والدعم الفني')),
            const SizedBox(height: 12),
            _group([
              _navRow(
                LucideIcons.helpCircle,
                context.tr(en: 'Contact support', ar: 'الاتصال بالدعم الفني'),
                null,
                onTap: () => _showInfo(
                  context.tr(en: 'Contact support', ar: 'الاتصال بالدعم الفني'),
                  context.tr(
                    en: 'Reach the SchooKeep support team at support@schookeep.ae or call 800-SCHOOL (800-724665) during business hours.',
                    ar: 'يمكنك التواصل مع فريق دعم SchooKeep عبر support@schookeep.ae أو الاتصال على 800-724665 خلال أوقات الدوام.',
                  ),
                ),
              ),
              _navRow(
                LucideIcons.shield,
                context.tr(en: 'UAE PDPL Privacy Declaration', ar: 'إعلان خصوصية البيانات الإماراتي (PDPL)'),
                context.tr(en: 'Governed by Federal Decree-Law No. 45 of 2021', ar: 'خاضع للمرسوم بقانون اتحادي رقم 45 لسنة 2021'),
                onTap: () => _showInfo(
                  context.tr(en: 'UAE PDPL Privacy Declaration', ar: 'إعلان خصوصية البيانات الإماراتي (PDPL)'),
                  context.tr(
                    en: 'Student health data is processed in accordance with UAE Federal Decree-Law No. 45 of 2021 (PDPL) and DHA School Health Guidelines.',
                    ar: 'تمت معالجة البيانات الصحية للطلاب وفقاً لأحكام قانون حماية البيانات الشخصية الإماراتي ولوائح هيئة الصحة بدبي.',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.tr(en: 'Version 1.0.0 (Build 2026.05.25)', ar: 'الإصدار 1.0.0 (بناء 2026.05.25)'),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // Sign out
            SchooKeepCard(
              padding: EdgeInsets.zero,
              borderColor: SchooKeepColors.error,
              onTap: _handleSignOut,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
          ],
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
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
                  child: Text(
                    context.tr(en: 'Principal', ar: 'مدير المدرسة'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1E40AF)),
                  ),
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
