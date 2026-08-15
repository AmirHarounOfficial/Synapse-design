import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/emergency_consent.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../cubit/emergency_consent_response_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentEmergencyConsentResponse.tsx`, wired to
/// `GET /emergency-consents` (latest pending) + `POST /emergency-consents/{id}/respond`.
/// Once the parent authorizes or declines, a permanently-logged confirmation
/// view is shown.
class ParentEmergencyConsentResponseScreen extends StatelessWidget {
  const ParentEmergencyConsentResponseScreen({super.key, this.consentId});

  final int? consentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmergencyConsentResponseCubit(sl<ClinicRepository>(), consentId: consentId),
      child: const _ParentEmergencyConsentResponseView(),
    );
  }
}

class _ParentEmergencyConsentResponseView extends StatefulWidget {
  const _ParentEmergencyConsentResponseView();

  @override
  State<_ParentEmergencyConsentResponseView> createState() =>
      _ParentEmergencyConsentResponseViewState();
}

class _ParentEmergencyConsentResponseViewState
    extends State<_ParentEmergencyConsentResponseView> {
  static const int _totalSeconds = 1800; // 30 minutes
  int _timeRemaining = 503; // 8:23
  bool _showConfirmation = false;
  String? _responseType; // 'authorize' | 'decline'
  bool _submitting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_timeRemaining > 0) _timeRemaining--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  double get _progress => _timeRemaining / _totalSeconds;

  Future<void> _respond(bool authorize) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<EmergencyConsentResponseCubit>().respond(authorize);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() {
      _responseType = authorize ? 'authorize' : 'decline';
      _showConfirmation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    if (_showConfirmation) {
      return _buildConfirmation(context, isRTL);
    }
    return BlocBuilder<EmergencyConsentResponseCubit, DataState<EmergencyConsent>>(
      builder: (context, state) {
        final loadError = state is DataError<EmergencyConsent> ? state.message : null;
        return _buildRequest(context, isRTL, loadError);
      },
    );
  }

  Widget _buildConfirmation(BuildContext context, bool isRTL) {
    final isAuthorize = _responseType == 'authorize';
    return SchooKeepScaffold(
      reserveBottomNav: true,
      backgroundColor: SchooKeepColors.surface,
      appBar: SchooKeepAppBar(onBack: () => context.safeBack()),
      bottomBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          border: Border(top: BorderSide(color: SchooKeepColors.border)),
        ),
        child: SchooKeepButton(
          label: isRTL ? 'تم' : 'Done',
          onPressed: () => context.go('/parent/app/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isAuthorize
                    ? SchooKeepColors.greenChipBg
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuthorize ? LucideIcons.checkCircle : LucideIcons.phone,
                size: 56,
                color: isAuthorize ? SchooKeepColors.accent : SchooKeepColors.error,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isAuthorize
                  ? (isRTL ? 'تم تفويض النقل' : 'Transport Authorized')
                  : (isRTL ? 'تم رفض الطلب' : 'Request Declined'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: SchooKeepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isAuthorize
                  ? (isRTL
                      ? 'تم إخطار ممرضة المدرسة وستشرع في النقل الطارئ إلى مركز لايكوود الطبي.'
                      : 'School nurse has been notified and will proceed with emergency transport to Lakewood Medical Center.')
                  : (isRTL
                      ? 'تم إخطار ممرضة المدرسة وستتصل بك فوراً لمناقشة الخطوات التالية.'
                      : 'School nurse has been notified and will call you immediately to discuss next steps.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Column(
                children: [
                  _kvRow(isRTL ? 'سُجّل الرد في' : 'Response logged at', '2:45 PM'),
                  const SizedBox(height: 8),
                  _kvRow(isRTL ? 'ولي الأمر/الوصي' : 'Parent/Guardian',
                      'James Thompson'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.primary),
              ),
              child: Text(
                isRTL
                    ? 'تم تسجيل هذا الرد بشكل دائم للامتثال ولا يمكن تعديله.'
                    : 'This response has been permanently logged for compliance and cannot be modified.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequest(BuildContext context, bool isRTL, String? loadError) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      backgroundColor: SchooKeepColors.surface,
      appBar: SchooKeepAppBar(onBack: () => context.safeBack()),
      bottomBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          border: Border(top: BorderSide(color: SchooKeepColors.border)),
        ),
        child: Column(
          children: [
            SchooKeepButton(
              label: _submitting ? (isRTL ? 'جارٍ الإرسال…' : 'Submitting…') : (isRTL ? 'تفويض' : 'Authorize'),
              icon: LucideIcons.checkCircle,
              height: 56,
              variant: SchooKeepButtonVariant.primary,
              enabled: !_submitting,
              onPressed: _submitting ? null : () => _respond(true),
            ),
            const SizedBox(height: 12),
            _DangerOutlineButton(
              label: isRTL ? 'رفض / اتصل بي' : 'Decline / Call me',
              icon: LucideIcons.phone,
              height: 56,
              onPressed: _submitting ? () {} : () => _respond(false),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red header
          Container(
            height: 120,
            color: SchooKeepColors.error,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              isRTL ? '🚨 مطلوب تفويض طارئ' : '🚨 Emergency Authorization Required',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loadError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SchooKeepColors.amberChipBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SchooKeepColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.info, size: 18, color: SchooKeepColors.warning),
                        const SizedBox(width: 8),
                        Expanded(child: Text(loadError, style: const TextStyle(fontSize: 12, color: SchooKeepColors.amberText))),
                        TextButton(
                          onPressed: () => context.read<EmergencyConsentResponseCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Countdown timer
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(90, 90),
                              painter: _CountdownPainter(progress: _progress),
                            ),
                            Text(
                              _formatTime(_timeRemaining),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: SchooKeepColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isRTL
                            ? 'تنتهي صلاحية الطلب خلال ${_formatTime(_timeRemaining)}'
                            : 'Request expires in ${_formatTime(_timeRemaining)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: SchooKeepColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Incident summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SchooKeepColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL ? 'ملخص الحادث' : 'Incident Summary',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: SchooKeepColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 192,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isRTL ? 'صورة رفعتها الممرضة' : 'Photo uploaded by nurse',
                          style: const TextStyle(
                            fontSize: 13,
                            color: SchooKeepColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _kvRow(isRTL ? 'الموقع' : 'Location',
                          isRTL ? 'عيادة المدرسة' : 'School Clinic'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isRTL ? 'الخطورة' : 'Severity',
                            style: const TextStyle(
                              fontSize: 13,
                              color: SchooKeepColors.textSecondary,
                            ),
                          ),
                          SchooKeepBadge(
                            label: isRTL ? 'عالية' : 'HIGH',
                            background: const Color(0xFFFEE2E2),
                            foreground: SchooKeepColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRTL ? 'الوصف' : 'Description',
                        style: const TextStyle(
                          fontSize: 13,
                          color: SchooKeepColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRTL
                            ? 'الطالب يعاني من رد فعل تحسسي شديد. تم إعطاء حقنة الإبينفرين في الساعة 2:38 مساءً. الأعراض تتحسن لكن يتطلب تقييماً طبياً فورياً.'
                            : 'Student experiencing severe allergic reaction. EpiPen administered at 2:38 PM. Symptoms improving but requires immediate medical evaluation.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: SchooKeepColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Requested action
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SchooKeepColors.primary, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL ? 'الإجراء المطلوب' : 'REQUESTED ACTION',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: SchooKeepColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRTL
                            ? 'تفويض النقل إلى مركز لايكوود الطبي'
                            : 'Authorize transport to Lakewood Medical Center',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: SchooKeepColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Warning
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.amberChipBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SchooKeepColors.warning),
                  ),
                  child: Text(
                    isRTL
                        ? 'سيتم تسجيل ردك بشكل دائم ولا يمكن تغييره. ستتصرف ممرضة المدرسة بناءً على تفويضك.'
                        : 'Your response will be permanently logged and cannot be changed. School nurse will proceed based on your authorization.',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.amberText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SchooKeepColors.textPrimary)),
      ],
    );
  }
}

class _CountdownPainter extends CustomPainter {
  const _CountdownPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 40.0;
    final center = Offset(size.width / 2, size.height / 2);
    final track = Paint()
      ..color = const Color(0xFFFEE2E2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final arc = Paint()
      ..color = SchooKeepColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_CountdownPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _DangerOutlineButton extends StatelessWidget {
  const _DangerOutlineButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SchooKeepColors.error, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: SchooKeepColors.error),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: SchooKeepColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
