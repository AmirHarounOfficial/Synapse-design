import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ParentSetupComplete.tsx`. Success confirmation screen with a
/// scaled-in check icon, a "What's next" list, and a "Go to Dashboard" CTA.
/// Progress bar shown complete (solid green). The source's scale-in animation
/// is reproduced with a [TweenAnimationBuilder].
class ParentSetupCompleteScreen extends StatelessWidget {
  const ParentSetupCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: false,
      backgroundColor: SchooKeepColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar — complete (solid green)
          const SizedBox(
            height: 4,
            child: ColoredBox(color: SchooKeepColors.accent),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: SchooKeepColors.greenChipBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.checkCircle, size: 56, color: SchooKeepColors.accent),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.tr(en: "You're all set!", ar: 'كل شيء جاهز!'),
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
                      en: "Maya's health profile is now active.",
                      ar: 'أصبح الملف الصحي لمايا نشطاً الآن.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
                  ),
                  const SizedBox(height: 48),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.tr(en: "What's next", ar: 'ما التالي'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _nextItem(
                    LucideIcons.bell,
                    context.tr(
                      en: "You'll get alerts when Maya visits the clinic",
                      ar: 'ستتلقى تنبيهات عند زيارة مايا للعيادة',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _nextItem(
                    LucideIcons.clock,
                    context.tr(
                      en: 'Report medication times here',
                      ar: 'أبلغ عن أوقات الأدوية هنا',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _nextItem(
                    LucideIcons.fileText,
                    context.tr(
                      en: 'View health records anytime',
                      ar: 'اعرض السجلات الصحية في أي وقت',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          border: Border(top: BorderSide(color: SchooKeepColors.border)),
        ),
        child: SchooKeepButton(
          label: context.tr(en: 'Go to Dashboard', ar: 'اذهب إلى لوحة التحكم'),
          onPressed: () => context.go('/parent/app/home'),
        ),
      ),
    );
  }

  Widget _nextItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: SchooKeepColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: SchooKeepColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
