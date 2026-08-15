import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ParentSchoolCodeEntry.tsx`. Entry screen (no app bar) with a
/// progress bar, logo, invitation-code input formatted as XXXX-XXXX, a continue
/// CTA, and an "I don't have a code" info bottom sheet.
class ParentSchoolCodeEntryScreen extends StatefulWidget {
  const ParentSchoolCodeEntryScreen({super.key});

  @override
  State<ParentSchoolCodeEntryScreen> createState() =>
      _ParentSchoolCodeEntryScreenState();
}

class _ParentSchoolCodeEntryScreenState
    extends State<ParentSchoolCodeEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _code = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatCode(String value) {
    final cleaned =
        value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (cleaned.length > 4) {
      final end = cleaned.length < 8 ? cleaned.length : 8;
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, end)}';
    }
    return cleaned;
  }

  void _onChanged(String value) {
    final formatted = _formatCode(value);
    if (formatted != value) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() => _code = formatted);
  }

  bool get _isValidCode => _code.replaceAll('-', '').length == 8;

  void _handleContinue() {
    if (_isValidCode) {
      context.go('/parent/onboarding/confirm-child');
    }
  }

  void _showInfoSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _InfoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      backgroundColor: SchooKeepColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Bar — 12.5%
          const _ProgressBar(fraction: 0.125),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                const SizedBox(height: 0),
                Center(
                  child: Text(
                    context.tr(en: 'SchooKeep', ar: 'SchooKeep'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Content
                Text(
                  context.tr(
                    en: "Set up your child's health profile",
                    ar: 'قم بإعداد الملف الصحي لطفلك',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr(
                    en: 'Enter the invitation code from your school',
                    ar: 'أدخل رمز الدعوة من مدرستك',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SchooKeepColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                // Code Input
                SizedBox(
                  height: 64,
                  child: TextField(
                    controller: _controller,
                    onChanged: _onChanged,
                    maxLength: 9,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: SchooKeepColors.textPrimary,
                      letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'XXXX-XXXX',
                      hintStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4,
                        color: SchooKeepColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: SchooKeepColors.border,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: SchooKeepColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Continue Button
                SchooKeepButton(
                  label: context.tr(en: 'Continue', ar: 'متابعة'),
                  enabled: _isValidCode,
                  onPressed: _handleContinue,
                ),
                const SizedBox(height: 16),
                // Help Link
                Center(
                  child: TextButton(
                    onPressed: _showInfoSheet,
                    child: Text(
                      context.tr(
                        en: "I don't have a code",
                        ar: 'ليس لدي رمز',
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _InfoSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.info, size: 24, color: SchooKeepColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr(
              en: 'Need an Invitation Code?',
              ar: 'هل تحتاج إلى رمز دعوة؟',
            ),
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
              en: 'Contact your school secretary to receive your invitation code. Each code is unique to your child and expires after first use.',
              ar: 'اتصل بأمين مدرستك للحصول على رمز الدعوة. كل رمز فريد لطفلك وينتهي بعد الاستخدام الأول.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: SchooKeepColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SchooKeepButton(
            label: context.tr(en: 'Got it', ar: 'حسناً'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
