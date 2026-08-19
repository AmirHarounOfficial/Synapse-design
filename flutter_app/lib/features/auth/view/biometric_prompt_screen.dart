import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';

class BiometricPromptScreen extends StatelessWidget {
  const BiometricPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void next() => context.go('/agreement');

    return ColoredBox(
      color: SchooKeepColors.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: next,
              child: const ColoredBox(color: Color(0x4D000000)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: SchooKeepColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: SchooKeepColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.scan, size: 40, color: SchooKeepColors.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr(en: 'Enable Face ID?', ar: 'تفعيل Face ID؟'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr(
                        en: 'Sign in faster next time without entering your password.',
                        ar: 'سجل الدخول بشكل أسرع في المرة القادمة دون الحاجة لإدخال كلمة المرور.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SchooKeepColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: next,
                        child: Text(
                          context.tr(en: 'Enable Face ID', ar: 'تفعيل Face ID'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: next,
                        child: Text(
                          context.tr(en: 'Not now', ar: 'ليس الآن'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
