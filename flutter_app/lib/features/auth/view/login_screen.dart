import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/auth/admin_session.dart';
import '../../../core/config/dev_flags.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_repository.dart';

/// Ported from `Login.tsx`. Floating-label email/password, show/hide toggle,
/// inline validation, and the language toggle. Wordmark rebranded to SchooKeep.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _submitting = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    final email = _email.text.trim();
    final password = _password.text;
    final rtl = context.read<LocaleCubit>().state.isRTL;

    if (email.isEmpty) {
      setState(() => _emailError = rtl ? 'البريد الإلكتروني مطلوب' : 'Email is required');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _emailError =
          rtl ? 'يرجى إدخال بريد إلكتروني صالح للمدرسة' : 'Please enter a valid school email');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = rtl ? 'كلمة المرور مطلوبة' : 'Password is required');
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = rtl
          ? 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل'
          : 'Password must be at least 6 characters');
      return;
    }

    setState(() => _submitting = true);
    final isAdminCreds = email.toLowerCase().contains('admin') ||
        email.toLowerCase().contains('principal') ||
        email.toLowerCase().contains('sys') ||
        email.toLowerCase().contains('schookeep');
    await AdminSession.setAdminMode(isAdminCreds);
    try {
      final user = await sl<AuthRepository>().login(email, password);
      if (!mounted) return;
      final isAdminUser = user.role == 'admin' ||
          user.role == 'principal' ||
          user.role == 'vice_principal' ||
          user.email.contains('admin');
      await AdminSession.setAdminMode(isAdminUser);
      if (!mounted) return;
      // Real auth succeeded → go straight to the user's role home.
      context.go(user.homeRoute);
    } on AuthException catch (e) {
      if (!mounted) return;
      // If the backend is unreachable, fall back to the demo 2FA flow so the
      // UI is still explorable offline; otherwise surface the error inline.
      // While testing (kDevBypassOtp) skip the OTP step entirely.
      if (e.message.contains('server')) {
        context.go(kDevBypassOtp ? '/biometric' : '/verify');
        return;
      }
      setState(() => _emailError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Schools provision SchooKeep accounts centrally — there is no self-service
  /// reset. Mirrors the prototype's static "contact your administrator" copy by
  /// surfacing the recovery path in a bottom sheet.
  void _showForgotPasswordSheet(bool isRTL) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: SchooKeepColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(LucideIcons.keyRound, size: 24, color: SchooKeepColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isRTL ? 'إعادة تعيين كلمة المرور' : 'Reset your password',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        isRTL
                            ? 'تتم إدارة حسابات SchooKeep مركزياً من قبل مدرستك. يرجى التواصل مع مسؤول المدرسة لإعادة تعيين كلمة المرور أو استعادة الوصول إلى حسابك.'
                            : 'SchooKeep accounts are managed centrally by your school. Contact your school administrator to reset your password or restore access to your account.',
                        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(isRTL ? 'حسناً' : 'Got it',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final lang = context.languageCode;

    return ColoredBox(
      color: SchooKeepColors.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 345),
              child: Container(
                decoration: BoxDecoration(
                  color: SchooKeepColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SchooKeepColors.border),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo + language toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: SchooKeepColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('S',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            const SizedBox(width: 8),
                            const Text('SchooKeep',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                          ],
                        ),
                        InkWell(
                          onTap: () => context.read<LocaleCubit>().toggleLanguage(),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: SchooKeepColors.border),
                            ),
                            child: Text(lang == 'en' ? 'العربية' : 'English',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isRTL ? 'مرحباً بك مجدداً' : 'Welcome back',
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRTL ? 'سجل الدخول باستخدام البريد الإلكتروني للمدرسة' : 'Sign in with your school email',
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    _Field(
                      controller: _email,
                      label: isRTL ? 'البريد الإلكتروني للمدرسة' : 'School email',
                      error: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() => _emailError = null),
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      controller: _password,
                      label: isRTL ? 'كلمة المرور' : 'Password',
                      error: _passwordError,
                      obscure: !_showPassword,
                      onChanged: (_) => setState(() => _passwordError = null),
                      suffix: IconButton(
                        icon: Icon(_showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 20, color: SchooKeepColors.textSecondary),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPasswordSheet(isRTL),
                        child: Text(isRTL ? 'هل نسيت كلمة المرور؟' : 'Forgot password?',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SchooKeepColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submitting ? null : _signIn,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isRTL ? 'تسجيل الدخول' : 'Sign in',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      const Expanded(child: Divider(color: SchooKeepColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(isRTL ? 'هل أنت جديد هنا؟' : 'New here?',
                            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                      ),
                      const Expanded(child: Divider(color: SchooKeepColors.border)),
                    ]),
                    const SizedBox(height: 16),
                    Text(
                      isRTL ? 'اتصل بمسؤول المدرسة الخاص بك' : 'Contact your school administrator',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A bordered input with a floating label and optional inline error row.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.error,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? error;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(color: SchooKeepColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            floatingLabelStyle: TextStyle(color: hasError ? SchooKeepColors.error : SchooKeepColors.primary),
            labelStyle: const TextStyle(color: SchooKeepColors.textSecondary),
            filled: true,
            fillColor: SchooKeepColors.surface,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? SchooKeepColors.error : SchooKeepColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? SchooKeepColors.error : SchooKeepColors.primary, width: 2),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Icon(LucideIcons.alertCircle, size: 16, color: SchooKeepColors.error),
              const SizedBox(width: 6),
              Expanded(child: Text(error!, style: const TextStyle(fontSize: 13, color: SchooKeepColors.error))),
            ]),
          ),
      ],
    );
  }
}
