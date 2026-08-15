import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ParentChildConfirmation.tsx`. Shows the matched child's profile
/// (from mock API data) with confirm / reject actions. No app bar — progress
/// bar at 25%.
class ParentChildConfirmationScreen extends StatelessWidget {
  const ParentChildConfirmationScreen({super.key});

  static const String _firstName = 'Maya';
  static const String _lastName = 'Thompson';
  static const String _grade = '4th Grade';
  static const String _school = 'Lakeside Elementary School';
  static const String _schoolId = 'LS-2024-0892';

  @override
  Widget build(BuildContext context) {
    const initials = 'MT';

    return SchooKeepScaffold(
      backgroundColor: SchooKeepColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Bar — 25%
          const _ProgressBar(fraction: 0.25),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    initials,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Child Info
                const Text(
                  '$_firstName $_lastName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  _grade,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 4),
                const Text(
                  _school,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(en: 'ID: $_schoolId', ar: 'المعرف: $_schoolId'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 32),
                // Confirmation Prompt
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SchooKeepColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.tr(en: 'Is this your child?', ar: 'هل هذا طفلك؟'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: SchooKeepColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(
                          en: "This information was entered by your school's administrative staff.",
                          ar: 'تم إدخال هذه المعلومات من قبل الطاقم الإداري لمدرستك.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: SchooKeepColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Action Buttons
                _ActionButton(
                  label: context.tr(en: 'Yes, continue', ar: 'نعم، متابعة'),
                  icon: LucideIcons.checkCircle,
                  filled: true,
                  onTap: () => context.go('/parent/onboarding/emergency-consent'),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: context.tr(en: 'No, wrong child', ar: 'لا، الطفل الخطأ'),
                  icon: LucideIcons.alertCircle,
                  filled: false,
                  onTap: () => context.go('/parent/onboarding/code'),
                ),
                const SizedBox(height: 32),
                // Privacy Note
                Text(
                  context.tr(
                    en: "If this information is incorrect, please contact your school's main office.",
                    ar: 'إذا كانت هذه المعلومات غير صحيحة، يرجى الاتصال بالمكتب الرئيسي لمدرستك.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : SchooKeepColors.textPrimary;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: filled ? SchooKeepColors.accent : SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(8),
        shape: filled
            ? null
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: SchooKeepColors.border),
              ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: Row(
        children: [
          Expanded(
            flex: (fraction * 1000).round(),
            child: const ColoredBox(color: SchooKeepColors.primary),
          ),
          Expanded(
            flex: 1000 - (fraction * 1000).round(),
            child: const ColoredBox(color: Color(0xFFF3F4F6)),
          ),
        ],
      ),
    );
  }
}
