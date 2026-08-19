import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/dev_flags.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _countdown = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  bool get _isComplete => _controllers.every((c) => c.text.isNotEmpty);

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && !RegExp(r'^\d$').hasMatch(value)) {
      _controllers[index].text = '';
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verify() {
    if (_isComplete) context.go('/biometric');
  }

  void _resend() {
    if (_countdown == 0) {
      for (final c in _controllers) {
        c.clear();
      }
      setState(() => _countdown = 45);
      _startCountdown();
      _focusNodes[0].requestFocus();
    }
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Verify your identity', ar: 'تأكيد الهوية'),
        centerTitle: true,
        onBack: () => context.go('/login'),
      ),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      body: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SchooKeepColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.shieldCheck, size: 32, color: SchooKeepColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr(en: 'Enter verification code', ar: 'أدخل رمز التحقق'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              en: 'A 6-digit code was sent to admin@schookeep.ae',
              ar: 'تم إرسال رمز مكون من 6 أرقام إلى admin@schookeep.ae',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 32),
          // OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final focused = _focusNodes[i].hasFocus;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 48,
                  height: 56,
                  child: KeyboardListener(
                    focusNode: FocusNode(skipTraversal: true),
                    onKeyEvent: (event) => _onKey(i, event),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onChanged: (v) => _onChanged(i, v),
                      onTap: () => setState(() {}),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: SchooKeepColors.surface,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: focused ? SchooKeepColors.primary : SchooKeepColors.border,
                            width: focused ? 2 : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: Center(
              child: _countdown > 0
                  ? Text(
                      context.tr(
                        en: 'Resend in ${_formatTime(_countdown)}',
                        ar: 'إعادة الإرسال خلال ${_formatTime(_countdown)}',
                      ),
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                    )
                  : TextButton(
                      onPressed: _resend,
                      child: Text(
                        context.tr(en: 'Resend code', ar: 'إعادة إرسال الرمز'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: _isComplete ? 1 : 0.4,
            child: SchooKeepButton(
              label: context.tr(en: 'Verify', ar: 'تأكيد'),
              enabled: _isComplete,
              onPressed: _verify,
            ),
          ),
          if (kDevBypassOtp) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/biometric'),
              child: const Text(
                'Skip verification (dev)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
