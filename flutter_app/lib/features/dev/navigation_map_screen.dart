import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/localization/l10n_ext.dart';
import '../../core/localization/locale_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';

class NavigationMapScreen extends StatelessWidget {
  const NavigationMapScreen({super.key});

  static const _sections = <({String titleEn, String titleAr, List<({String labelEn, String labelAr, String route})> links})>[
    (
      titleEn: 'Authentication & Entry',
      titleAr: 'التوثيق والدخول',
      links: [
        (labelEn: 'Splash', labelAr: 'الشاشة الافتتاحية', route: '/splash'),
        (labelEn: 'Login', labelAr: 'تسجيل الدخول', route: '/login'),
        (labelEn: '2FA Verify', labelAr: 'التحقق بخطوتين', route: '/verify'),
        (labelEn: 'Biometric', labelAr: 'بصمة الوجه', route: '/biometric'),
        (labelEn: 'Confidentiality', labelAr: 'اتفاقية السرية', route: '/agreement'),
        (labelEn: 'E-Signature', labelAr: 'التوقيع الإلكتروني', route: '/signature'),
      ]
    ),
    (
      titleEn: 'Principal & Leadership',
      titleAr: 'مدير المدرسة والقيادة',
      links: [
        (labelEn: 'Principal Portal', labelAr: 'بوابة المدير الرئيسي', route: '/principal/home'),
        (labelEn: 'Staff Management', labelAr: 'إدارة الكادر المدرسي', route: '/principal/staff'),
        (labelEn: 'Health Analytics', labelAr: 'التحليلات الصحية', route: '/principal/analytics'),
      ]
    ),
    (
      titleEn: 'Nurse Clinical Operations',
      titleAr: 'عمليات ممرض المدرسة',
      links: [
        (labelEn: 'Nurse Dashboard', labelAr: 'لوحة تحكم الممرض', route: '/nurse/dashboard'),
        (labelEn: 'Pharmacy Inventory (CRUD)', labelAr: 'مخزون الصيدلية (إدارة وتدقيق)', route: '/nurse/medications/inventory'),
        (labelEn: 'Medications List', labelAr: 'قائمة الأدوية', route: '/nurse/medications'),
        (labelEn: 'Clinic Visits', labelAr: 'زيارات العيادة', route: '/nurse/clinic'),
      ]
    ),
    (
      titleEn: 'Parent App & Portal',
      titleAr: 'تطبيق ولي الأمر',
      links: [
        (labelEn: 'Parent App Home', labelAr: 'الرئيسية لولي الأمر', route: '/parent/app/home'),
        (labelEn: 'Health History', labelAr: 'السجل الصحي', route: '/parent/app/health'),
        (labelEn: 'Medication Log', labelAr: 'سجل الأدوية', route: '/parent/app/medications'),
      ]
    ),
    (
      titleEn: 'Teacher Classroom',
      titleAr: 'واجهة المعلم للفصل',
      links: [
        (labelEn: 'Teacher Portal', labelAr: 'بوابة المعلم', route: '/teacher/home'),
      ]
    ),
    (
      titleEn: 'Secretary Desk',
      titleAr: 'مكتب السكرتير',
      links: [
        (labelEn: 'Secretary Portal', labelAr: 'بوابة السكرتارية', route: '/secretary/home'),
      ]
    ),
    (
      titleEn: 'School Physician',
      titleAr: 'طبيب المدرسة',
      links: [
        (labelEn: 'Physician Portal', labelAr: 'بوابة الطبيب', route: '/physician/dashboard'),
      ]
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state.languageCode;
    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'SchooKeep — Navigation', ar: 'سينابس — خريطة التنقل'),
        actions: [
          InkWell(
            onTap: () => context.read<LocaleCubit>().toggleLanguage(),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Text(
                lang == 'en' ? 'العربية' : 'English',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in _sections) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 12),
                child: Text(
                  context.tr(en: section.titleEn, ar: section.titleAr),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SchooKeepColors.textSecondary),
                ),
              ),
              ...section.links.map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SchooKeepCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    onTap: () => context.go(l.route),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(en: l.labelEn, ar: l.labelAr),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                          ),
                        ),
                        const RtlIcon(LucideIcons.chevronRight, size: 18, color: SchooKeepColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
