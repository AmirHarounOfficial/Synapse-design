import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ParentProfileNotActive.tsx`. Shows incomplete onboarding state:
/// a setup-progress bar, a step checklist, an info card with percentage, and a
/// "Continue Setup" CTA that routes to the first incomplete step. No app bar.
class ParentProfileNotActiveScreen extends StatelessWidget {
  const ParentProfileNotActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = <({String id, String title, bool completed})>[
      (id: 'code', title: context.tr(en: 'School code verified', ar: 'تم التحقق من رمز المدرسة'), completed: true),
      (id: 'emergency', title: context.tr(en: 'Emergency consent signed', ar: 'تم توقيع موافقة الطوارئ'), completed: true),
      (id: 'privacy', title: context.tr(en: 'Privacy agreement signed', ar: 'تم توقيع اتفاقية الخصوصية'), completed: false),
      (id: 'documents', title: context.tr(en: 'Documents uploaded', ar: 'تم تحميل الوثائق'), completed: false),
      (id: 'pickups', title: context.tr(en: 'Authorized pickups added', ar: 'تمت إضافة أشخاص الاستلام'), completed: false),
    ];

    final completedCount = steps.where((s) => s.completed).length;
    final fraction = completedCount / steps.length;
    final percent = (fraction * 100).round();

    void handleContinue() {
      final next = steps.where((s) => !s.completed).firstOrNull;
      switch (next?.id) {
        case 'emergency':
          context.go('/parent/onboarding/emergency-consent');
        case 'privacy':
          context.go('/parent/onboarding/privacy-agreement');
        case 'documents':
          context.go('/parent/onboarding/documents');
        case 'pickups':
          context.go('/parent/onboarding/authorized-pickups');
        default:
          context.go('/parent/onboarding/code');
      }
    }

    return SchooKeepScaffold(
      scrollable: false,
      backgroundColor: SchooKeepColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: SchooKeepColors.amberChipBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.alertTriangle, size: 56, color: SchooKeepColors.warning),
              ),
              const SizedBox(height: 32),
              Text(
                context.tr(en: 'Setup Required', ar: 'الإعداد مطلوب'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: SchooKeepColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  en: "Complete your child's health profile to access all features",
                  ar: 'أكمل الملف الصحي لطفلك للوصول إلى جميع الميزات',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 32),
              // Progress header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(en: 'Setup Progress', ar: 'تقدم الإعداد'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: SchooKeepColors.textPrimary,
                    ),
                  ),
                  Text(
                    context.tr(
                      en: '$completedCount of ${steps.length}',
                      ar: '$completedCount من ${steps.length}',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: const AlwaysStoppedAnimation<Color>(SchooKeepColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              // Steps list
              for (final step in steps) ...[
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: step.completed
                            ? SchooKeepColors.greenChipBg
                            : SchooKeepColors.amberChipBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.completed ? LucideIcons.checkCircle : LucideIcons.circle,
                        size: 16,
                        color: step.completed ? SchooKeepColors.accent : SchooKeepColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: step.completed ? FontWeight.normal : FontWeight.w500,
                          color: step.completed
                              ? SchooKeepColors.textSecondary
                              : SchooKeepColors.textPrimary,
                          decoration: step.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SchooKeepColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SchooKeepColors.border),
                ),
                child: Text(
                  context.tr(
                    en: "Your setup is $percent% complete. Finish the remaining steps to activate Maya's health profile and enable real-time health monitoring.",
                    ar: 'اكتمل الإعداد بنسبة $percent%. أكمل الخطوات المتبقية لتفعيل الملف الصحي لمايا وتمكين المراقبة الصحية الفورية.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, height: 1.5, color: SchooKeepColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
      bottomBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          border: Border(top: BorderSide(color: SchooKeepColors.border)),
        ),
        child: SchooKeepButton(
          label: context.tr(en: 'Continue Setup', ar: 'متابعة الإعداد'),
          onPressed: handleContinue,
        ),
      ),
    );
  }
}
