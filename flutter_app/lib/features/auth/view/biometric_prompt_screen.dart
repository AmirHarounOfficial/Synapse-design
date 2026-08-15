import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';

/// Ported from `BiometricPrompt.tsx`. A dimmed backdrop over the page with a
/// bottom sheet prompting Face ID enrollment. Tapping the backdrop, the primary
/// CTA, or "Not now" all continue to the confidentiality agreement.
class BiometricPromptScreen extends StatelessWidget {
  const BiometricPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void next() => context.go('/agreement');

    return ColoredBox(
      color: SchooKeepColors.background,
      child: Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: next,
              child: const ColoredBox(color: Color(0x4D000000)),
            ),
          ),
          // Bottom sheet
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
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: SchooKeepColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    // Face ID icon
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
                    const Text(
                      'Enable Face ID?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sign in faster next time without entering your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
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
                        child: const Text(
                          'Enable Face ID',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: next,
                        child: const Text(
                          'Not now',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
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
