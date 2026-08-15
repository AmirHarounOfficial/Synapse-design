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
import '../cubit/emergency_consent_request_cubit.dart';
import '../widgets/emergency_call_button.dart';

/// Ported from `EmergencyConsentRequest.tsx`, wired to `GET /emergency-consents`
/// (latest pending). Awaiting-parent-authorization screen with a circular
/// countdown timer that auto-escalates at zero, an incident summary, escalation
/// notice, status log timeline, and an action button stack. Bilingual.
///
/// NOTE: the API has no endpoint to *create* a consent request, so this screen
/// surfaces the most recent pending consent rather than issuing a new one.
class EmergencyConsentRequestScreen extends StatelessWidget {
  const EmergencyConsentRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmergencyConsentRequestCubit(sl<ClinicRepository>()),
      child: const _EmergencyConsentRequestView(),
    );
  }
}

class _EmergencyConsentRequestView extends StatefulWidget {
  const _EmergencyConsentRequestView();

  @override
  State<_EmergencyConsentRequestView> createState() => _EmergencyConsentRequestViewState();
}

class _EmergencyConsentRequestViewState extends State<_EmergencyConsentRequestView> {
  int _timeRemaining = 572; // 9:32 in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining <= 1) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) context.go('/nurse/clinic/emergency-escalation');
        });
        setState(() => _timeRemaining = 0);
      } else {
        setState(() => _timeRemaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return BlocBuilder<EmergencyConsentRequestCubit, DataState<EmergencyConsent?>>(
      builder: (context, state) {
        final consent = state is DataLoaded<EmergencyConsent?> ? state.data : null;
        final loadError = state is DataError<EmergencyConsent?> ? state.message : null;
        return _buildBody(context, isRTL, consent, loadError);
      },
    );
  }

  Widget _buildBody(BuildContext context, bool isRTL, EmergencyConsent? consent, String? loadError) {
    final minutes = (_timeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeRemaining % 60).toString().padLeft(2, '0');
    final displayTime = '$minutes:$seconds';
    final progress = _timeRemaining / 600;

    return SchooKeepScaffold(
      reserveBottomNav: false,
      appBar: SchooKeepAppBar(
        centerTitle: true,
        titleWidget: Text(
          isRTL ? 'تفويض الحالات الطارئة' : 'Emergency Authorization',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.error),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _CountdownPainter(progress),
                      child: Center(
                        child: Text(displayTime,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: SchooKeepColors.error)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(isRTL ? 'بانتظار موافقة ولي الأمر...' : 'Waiting for parent response...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (loadError != null) _loadErrorBanner(loadError),
            if (loadError != null) const SizedBox(height: 24),
            _incidentSummary(isRTL, consent),
            const SizedBox(height: 24),
            _requiredAction(isRTL),
            const SizedBox(height: 24),
            _escalationNotice(isRTL),
            const SizedBox(height: 24),
            _statusLog(isRTL),
            const SizedBox(height: 24),
            const EmergencyCallButton(variant: EmergencyCallVariant.danger),
            const SizedBox(height: 12),
            _outlineButton(
              label: isRTL ? 'الاتصال بالطبيب المناوب' : 'Contact on-call physician',
              color: SchooKeepColors.physicianTeal,
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(isRTL
                        ? 'اتصال بالطبيب المناوب: د. أمينة الهاشمي على الرقم +971 50 123 4567...'
                        : 'Dialing on-call physician Dr. Amina Al-Hashimi at +971 50 123 4567...'),
                  ));
              },
            ),
            const SizedBox(height: 12),
            _outlineButton(
              label: isRTL ? 'الاتصال بولي الأمر الآن' : 'Call Parent Now',
              color: SchooKeepColors.primary,
              onTap: () => context.go('/nurse/clinic/emergency-escalation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlineButton({required String label, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.phone, size: 20, color: color),
              const SizedBox(width: 8),
              Flexible(child: Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, size: 18, color: SchooKeepColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: SchooKeepColors.amberText))),
          TextButton(
            onPressed: () => context.read<EmergencyConsentRequestCubit>().load(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _incidentSummary(bool isRTL, EmergencyConsent? consent) {
    final studentLabel = consent != null ? 'Student #${consent.studentId}' : 'Maya Chen';
    final description = (consent?.details ?? '').isNotEmpty
        ? consent!.details!
        : (isRTL
            ? 'سقوط الطالبة من ألعاب ساحة المدرسة. إصابة ظاهرة في الذراع الأيسر وتشتكي الطالبة من ألم شديد وصعوبة في تحريكها.'
            : 'Student fell from playground equipment. Visible injury to left arm. Student reports pain and difficulty moving arm.');
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'ملخص الحادثة' : 'Incident Summary',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(8)),
            child: const Icon(LucideIcons.camera, size: 48, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _summaryRow(isRTL ? 'الطالب' : 'Student', value: studentLabel),
          _summaryRow(isRTL ? 'الموقع' : 'Location', value: isRTL ? 'الملعب المدرسي' : 'Playground'),
          _summaryRowBadge(isRTL ? 'درجة الخطورة' : 'Severity', badgeLabel: isRTL ? 'حرجة جداً' : 'Severe'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRTL ? 'الوصف بالتفصيل' : 'Description',
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, {required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: SchooKeepColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _summaryRowBadge(String label, {required String badgeLabel}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: SchooKeepColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          SchooKeepBadge(
            label: badgeLabel,
            background: const Color(0xFFFEE2E2),
            foreground: const Color(0xFF991B1B),
          ),
        ],
      ),
    );
  }

  Widget _requiredAction(bool isRTL) {
    return AccentCard(
      background: const Color(0xFFFEE2E2),
      accentColor: SchooKeepColors.error,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'بانتظار تفويض ولي الأمر' : 'Awaiting Parent Authorization',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
          const SizedBox(height: 8),
          Text(
            isRTL
                ? 'نقل إسعافي طارئ إلى مستشفى الجليلة التخصصي للأطفال'
                : "Emergency transport to Al Jalila Children's Specialty Hospital",
            style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
          ),
        ],
      ),
    );
  }

  Widget _escalationNotice(bool isRTL) {
    return AccentCard(
      background: SchooKeepColors.amberBg,
      accentColor: SchooKeepColors.warning,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isRTL
                  ? 'إذا لم يتم الرد خلال 10 دقائق، سيتم طلب الإسعاف وتصعيد الحالة تلقائياً.'
                  : 'If no response within 10 minutes, an emergency call (998) will be placed automatically.',
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.amberText, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusLog(bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'سجل الحالة الطارئة' : 'Status Log',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 16),
          _logItem(
            color: SchooKeepColors.accent,
            icon: LucideIcons.check,
            title: isRTL ? 'تم إرسال الطلب للموقع' : 'Request sent',
            time: '10:22 AM',
            connector: true,
          ),
          _logItem(
            color: SchooKeepColors.primary,
            icon: LucideIcons.eye,
            title: isRTL ? 'تم الاطلاع من ولي الأمر' : 'Parent viewed',
            time: '10:24 AM',
            connector: true,
          ),
          _logItemPending(isRTL),
        ],
      ),
    );
  }

  Widget _logItem({
    required Color color,
    required IconData icon,
    required String title,
    required String time,
    required bool connector,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              if (connector) const Expanded(child: SizedBox(width: 2, child: ColoredBox(color: SchooKeepColors.border))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                  Text(time, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logItemPending(bool isRTL) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: SchooKeepColors.warning, shape: BoxShape.circle),
          child: const Icon(LucideIcons.clock, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isRTL ? 'بانتظار الرد...' : 'Awaiting response...',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: const [
                  _Dot(),
                  SizedBox(width: 4),
                  _Dot(),
                  SizedBox(width: 4),
                  _Dot(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: SchooKeepColors.warning, shape: BoxShape.circle),
    );
  }
}

class _CountdownPainter extends CustomPainter {
  _CountdownPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 54.0;
    final bgPaint = Paint()
      ..color = SchooKeepColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final fgPaint = Paint()
      ..color = SchooKeepColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CountdownPainter oldDelegate) => oldDelegate.progress != progress;
}
