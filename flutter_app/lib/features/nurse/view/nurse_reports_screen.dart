import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class NurseReportsScreen extends StatelessWidget {
  const NurseReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      (id: 'generate', title: context.tr(en: 'Generate Report', ar: 'إنشاء تقرير جديد'), description: context.tr(en: 'Create daily, weekly, or custom reports', ar: 'إعداد تقارير يومية أو أسبوعية أو مخصصة'), badge: null, path: '/nurse/reports/generate'),
      (id: 'documents', title: context.tr(en: 'Document Review', ar: 'مراجعة المستندات'), description: context.tr(en: 'Review pending parent submissions', ar: 'مراجعة طلبات ومستندات أولياء الأمور المعلقة'), badge: 3, path: '/nurse/documents/review'),
      (id: 'medication', title: context.tr(en: 'Medication Reports', ar: 'تقارير الأدوية والجرعات'), description: context.tr(en: 'Dose logs and compliance tracking', ar: 'سجلات إعطاء الأدوية وتتبع الالتزام'), badge: null, path: null),
      (id: 'clinic', title: context.tr(en: 'Clinic Visit Reports', ar: 'تقارير زيارات العيادة'), description: context.tr(en: 'Visit statistics and trends', ar: 'إحصائيات ومؤشرات الزيارات الطبية'), badge: null, path: null),
      (id: 'compliance', title: context.tr(en: 'Compliance Reports', ar: 'تقارير الامتثال والفحوصات'), description: context.tr(en: 'Required screenings and documentation', ar: 'الفحوصات الشاملة والوثائق المطلوبة'), badge: null, path: null),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(title: context.tr(en: 'Reports', ar: 'التقارير الطبية والصحية')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          children: [
            for (final s in sections)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: s.path == null ? 0.5 : 1,
                  child: SchooKeepCard(
                    onTap: s.path == null ? null : () => context.go(s.path!),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.fileText, size: 24, color: SchooKeepColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(s.title,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                                  if (s.badge != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(color: SchooKeepColors.error, shape: BoxShape.circle),
                                      child: Text('${s.badge}',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(s.description,
                                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (s.path != null) ...[
                          const SizedBox(width: 8),
                          const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
