import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Bus driver settings screen with full bilingual support (English & Arabic).
class BusDriverSettingsScreen extends StatelessWidget {
  const BusDriverSettingsScreen({super.key});

  static const String _nameEn = 'Robert Anderson';
  static const String _nameAr = 'روبرت أندرسون';
  static const String _employeeId = 'BD-128';
  static const String _roleEn = 'Bus Driver';
  static const String _roleAr = 'سائق حافلة مدرسية';
  static const String _routeEn = 'Route 12';
  static const String _routeAr = 'مسار 12';
  static const String _email = 'r.anderson@school.edu';
  static const String _phone = '(555) 123-4567';

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
              Text(
                context.tr(en: 'Log Out of SchooKeep?', ar: 'تسجيل الخروج من التطبيق؟'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  en: 'You will need to re-authenticate with 2FA to access the bus driver portal again.',
                  ar: 'ستحتاج للتحقق عبر المصادقة الثنائية (2FA) للوصول لبوابة حافلة المدرسة مجدداً.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
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
                        child: Text(
                          context.tr(en: 'Log Out', ar: 'تسجيل الخروج'),
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
      appBar: SchooKeepAppBar(title: context.tr(en: 'Settings', ar: 'الإعدادات')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(context),
            const SizedBox(height: 16),
            Text(
              context.tr(en: 'COMPLIANCE & CERTIFICATIONS', ar: 'الامتثال والشهادات المعتمدة'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SchooKeepColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _certCard(
              context,
              icon: LucideIcons.fileText,
              iconColor: SchooKeepColors.accent,
              iconBg: SchooKeepColors.greenChipBg,
              title: context.tr(en: 'CDL License (Class B)', ar: 'رخصة قيادة الحافلات (فئة ثقيلة)'),
              subtitle: context.tr(en: 'Valid until August 2027', ar: 'سارية حتى أغسطس 2027'),
              activeBadge: true,
            ),
            const SizedBox(height: 8),
            _certCard(
              context,
              icon: LucideIcons.shield,
              iconColor: SchooKeepColors.primary,
              iconBg: const Color(0xFFEFF6FF),
              title: context.tr(en: 'Confidentiality Agreement', ar: 'اتفاقية حماية سرية بيانات الطلاب'),
              subtitle: context.tr(en: 'Signed on April 12, 2026', ar: 'موقعة بتاريخ 12 أبريل 2026'),
            ),
            const SizedBox(height: 8),
            _certCard(
              context,
              icon: LucideIcons.fileText,
              iconColor: SchooKeepColors.primary,
              iconBg: const Color(0xFFEFF6FF),
              title: context.tr(en: 'FERPA Training Certificate', ar: 'شهادة تدريب سلامة وحماية الطلاب'),
              subtitle: context.tr(en: 'Completed April 15, 2026 • Valid until April 2027', ar: 'مكتملة في 15 أبريل 2026 • سارية حتى أبريل 2027'),
            ),
            const SizedBox(height: 8),
            _certCard(
              context,
              icon: LucideIcons.shield,
              iconColor: SchooKeepColors.primary,
              iconBg: const Color(0xFFEFF6FF),
              title: context.tr(en: 'Student Safety Protocols', ar: 'بروتوكولات السلامة في الحافلة'),
              subtitle: context.tr(en: 'Last reviewed May 1, 2026', ar: 'آخر مراجعة 1 مايو 2026'),
            ),
            const SizedBox(height: 8),
            _certCard(
              context,
              icon: LucideIcons.fileText,
              iconColor: SchooKeepColors.accent,
              iconBg: SchooKeepColors.greenChipBg,
              title: context.tr(en: 'First Aid & CPR Certification', ar: 'شهادة الإسعافات الأولية والإنعاش الرئوي'),
              subtitle: context.tr(en: 'Valid until December 2026', ar: 'سارية حتى ديسمبر 2026'),
            ),
            const SizedBox(height: 16),
            _infoNotice(context),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(en: 'Log Out', ar: 'تسجيل الخروج'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.error),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                context.tr(en: 'SchooKeep v2.1.0 • Bus Driver Portal', ar: 'سكوكيب v2.1.0 • بوابة سائق الحافلة'),
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
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
                    Text(
                      context.tr(en: _nameEn, ar: _nameAr),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr(en: _roleEn, ar: _roleAr)} • $_employeeId',
                      style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.bus, size: 14, color: SchooKeepColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            context.tr(en: _routeEn, ar: _routeAr),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                          ),
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
          _infoRow(context.tr(en: 'Email', ar: 'البريد الإلكتروني'), _email),
          const SizedBox(height: 8),
          _infoRow(context.tr(en: 'Phone', ar: 'رقم الهاتف'), _phone),
          const SizedBox(height: 8),
          _infoRow(
            context.tr(en: 'Last Login', ar: 'آخر تسجيل دخول'),
            context.tr(en: 'May 25, 2026 at 6:48 AM', ar: '25 مايو 2026 الساعة 6:48 صباحاً'),
          ),
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
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _certCard(
    BuildContext context, {
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
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.lock, size: 12, color: SchooKeepColors.greenChipText),
                  const SizedBox(width: 4),
                  Text(
                    context.tr(en: 'Active', ar: 'سارية'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SchooKeepColors.greenChipText),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoNotice(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Text(
        context.tr(
          en: 'All boarding and drop-off events are logged with parent notifications. Records are maintained for safety and compliance.',
          ar: 'يتم تسجيل جميع عمليات صعود ونزول الطلاب وإرسال إشعارات فورية لأولياء الأمور. يتم حفظ السجلات لضمان السلامة والامتثال.',
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
      ),
    );
  }
}
