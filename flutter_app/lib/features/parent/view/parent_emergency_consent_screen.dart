import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentEmergencyConsent.tsx`. A scroll-to-bottom legal document
/// followed by a signature step. The source uses an HTML canvas to draw a
/// signature; there is no signature package here, so the canvas is replicated
/// as a bordered, dashed "signature pad" that the user taps to sign — a
/// setState-backed `_signed` boolean stands in for the captured signature.
class ParentEmergencyConsentScreen extends StatefulWidget {
  const ParentEmergencyConsentScreen({super.key});

  @override
  State<ParentEmergencyConsentScreen> createState() =>
      _ParentEmergencyConsentScreenState();
}

class _ParentEmergencyConsentScreenState
    extends State<ParentEmergencyConsentScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _scrolledToBottom = false;
  bool _isSigning = false;
  bool _signed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrolledToBottom &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 10) {
      setState(() => _scrolledToBottom = true);
    }
  }

  void _handleContinue() {
    if (_signed) {
      context.go('/parent/onboarding/privacy-agreement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: false,
      backgroundColor: SchooKeepColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProgressBar(fraction: 0.375),
          SchooKeepAppBar(
            title: context.tr(
              en: 'Step 1 of 4 — Emergency Care Consent',
              ar: 'الخطوة 1 من 4 — موافقة الرعاية الطارئة',
            ),
            centerTitle: true,
            onBack: () => context.safeBack(),
          ),
          Expanded(
            child: _isSigning ? _buildSigning(context) : _buildDocument(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDocument(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Amber Notice
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SchooKeepColors.amberChipBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.warning),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 20, color: Color(0xFFD97706)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(
                        en: 'Required Legal Document',
                        ar: 'وثيقة قانونية مطلوبة',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.amberText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(
                        en: 'This document cannot be pre-filled. Please read carefully before signing.',
                        ar: 'لا يمكن تعبئة هذه الوثيقة مسبقاً. يرجى القراءة بعناية قبل التوقيع.',
                      ),
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.amberText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    en: 'Emergency Medical Care Authorization',
                    ar: 'تفويض الرعاية الطبية الطارئة',
                  ),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ..._sections(context),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SchooKeepColors.border),
                  ),
                  child: Text(
                    context.tr(
                      en: 'By signing below, I acknowledge that I have read, understand, and agree to all terms of this Emergency Medical Care Authorization.',
                      ar: 'بالتوقيع أدناه، أقر بأنني قرأت وفهمت ووافقت على جميع شروط تفويض الرعاية الطبية الطارئة هذا.',
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: SchooKeepColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom action
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: SchooKeepColors.surface,
            border: Border(top: BorderSide(color: SchooKeepColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_scrolledToBottom) ...[
                Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(
                        en: 'Scroll to bottom to continue',
                        ar: 'مرر إلى الأسفل للمتابعة',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              SchooKeepButton(
                label: context.tr(en: 'Continue to Sign', ar: 'متابعة للتوقيع'),
                enabled: _scrolledToBottom,
                onPressed: () => setState(() => _isSigning = true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _sections(BuildContext context) {
    final sections = <({String title, String body})>[
      (
        title: context.tr(
          en: '1. Emergency Transport Authorization',
          ar: '1. تفويض النقل الطارئ',
        ),
        body: context.tr(
          en: 'I hereby authorize school officials to seek emergency medical care for my child when I cannot be reached immediately. This includes transportation by ambulance or emergency vehicle to the nearest appropriate medical facility.',
          ar: 'أفوض بموجب هذا مسؤولي المدرسة بطلب الرعاية الطبية الطارئة لطفلي عندما يتعذر الوصول إليّ فوراً. ويشمل ذلك النقل بسيارة إسعاف أو مركبة طوارئ إلى أقرب منشأة طبية مناسبة.',
        ),
      ),
      (
        title: context.tr(
          en: '2. First Aid Administration Consent',
          ar: '2. موافقة تقديم الإسعافات الأولية',
        ),
        body: context.tr(
          en: 'I consent to first aid treatment by trained school personnel including, but not limited to: wound care, ice pack application, CPR administration, and AED use if medically necessary.',
          ar: 'أوافق على علاج الإسعافات الأولية من قبل موظفي المدرسة المدربين بما في ذلك، على سبيل المثال لا الحصر: العناية بالجروح، وتطبيق كمادات الثلج، وإجراء الإنعاش القلبي الرئوي، واستخدام جهاز إزالة الرجفان إذا لزم الأمر طبياً.',
        ),
      ),
      (
        title: context.tr(
          en: '3. Medication Administration Rights',
          ar: '3. حقوق إعطاء الأدوية',
        ),
        body: context.tr(
          en: 'I authorize the school nurse or designated personnel to administer emergency medications including epinephrine auto-injectors (EpiPen), asthma rescue inhalers, glucose tablets for hypoglycemia, or other life-saving medications as prescribed by a physician.',
          ar: 'أفوض ممرضة المدرسة أو الموظفين المعينين بإعطاء أدوية الطوارئ بما في ذلك حاقن الإبينفرين التلقائي (إيبي بن)، وأجهزة استنشاق الربو الإنقاذية، وأقراص الجلوكوز لنقص السكر، أو أدوية أخرى منقذة للحياة حسب وصف الطبيب.',
        ),
      ),
      (
        title: context.tr(
          en: '4. Medical Information Sharing',
          ar: '4. مشاركة المعلومات الطبية',
        ),
        body: context.tr(
          en: 'I authorize school health personnel to share necessary medical information with emergency medical technicians (EMTs), hospital staff, and other medical providers in emergency situations.',
          ar: 'أفوض موظفي الصحة المدرسية بمشاركة المعلومات الطبية الضرورية مع فنيي الطوارئ الطبية وموظفي المستشفى وغيرهم من مقدمي الخدمات الطبية في حالات الطوارئ.',
        ),
      ),
      (
        title: context.tr(
          en: '5. Limitation of Liability',
          ar: '5. تحديد المسؤولية',
        ),
        body: context.tr(
          en: 'I understand that school personnel are not medical professionals (except licensed school nurses) and will act in good faith. I agree to hold the school, its employees, and volunteers harmless from liability when providing emergency care.',
          ar: 'أتفهم أن موظفي المدرسة ليسوا متخصصين طبيين (باستثناء ممرضات المدرسة المرخصات) وسيتصرفون بحسن نية. أوافق على إعفاء المدرسة وموظفيها ومتطوعيها من المسؤولية عند تقديم الرعاية الطارئة.',
        ),
      ),
      (
        title: context.tr(
          en: '6. Parent/Guardian Notification',
          ar: '6. إشعار ولي الأمر',
        ),
        body: context.tr(
          en: 'I understand that school personnel will make every reasonable effort to contact me immediately in case of emergency, but that emergency care may be administered before I am reached.',
          ar: 'أتفهم أن موظفي المدرسة سيبذلون كل جهد معقول للاتصال بي فوراً في حالة الطوارئ، ولكن قد يتم تقديم الرعاية الطارئة قبل الوصول إليّ.',
        ),
      ),
      (
        title: context.tr(
          en: '7. Duration and Revocation',
          ar: '7. المدة والإلغاء',
        ),
        body: context.tr(
          en: "This authorization remains in effect for the current school year and must be renewed annually. I may revoke this authorization in writing at any time, but understand that this may affect my child's ability to participate in certain school activities.",
          ar: 'يظل هذا التفويض سارياً للعام الدراسي الحالي ويجب تجديده سنوياً. يمكنني إلغاء هذا التفويض كتابياً في أي وقت، لكنني أتفهم أن ذلك قد يؤثر على قدرة طفلي على المشاركة في أنشطة مدرسية معينة.',
        ),
      ),
    ];
    return [
      for (final s in sections) ...[
        const SizedBox(height: 8),
        Text(
          s.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: SchooKeepColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.body,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: SchooKeepColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
      ],
    ];
  }

  Widget _buildSigning(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr(en: 'Sign Below', ar: 'وقّع أدناه'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              en: 'Draw your signature with your finger or stylus',
              ar: 'ارسم توقيعك بإصبعك أو القلم',
            ),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(child: _SignaturePad(signed: _signed, onSign: () => setState(() => _signed = true))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SchooKeepColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Column(
              children: [
                _kvRow(context.tr(en: 'Date', ar: 'التاريخ'), 'May 25, 2026'),
                const SizedBox(height: 8),
                _kvRow(
                  context.tr(en: 'Parent/Guardian', ar: 'ولي الأمر'),
                  'Jennifer Thompson',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SchooKeepButton(
                  label: context.tr(en: 'Clear', ar: 'مسح'),
                  variant: SchooKeepButtonVariant.outline,
                  onPressed: () => setState(() => _signed = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SchooKeepButton(
                  label: context.tr(en: 'Sign & Continue', ar: 'وقّع وتابع'),
                  enabled: _signed,
                  onPressed: _handleContinue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kvRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: SchooKeepColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Mock signature pad — taps to "sign" in lieu of a real canvas drawing.
class _SignaturePad extends StatelessWidget {
  const _SignaturePad({required this.signed, required this.onSign});
  final bool signed;
  final VoidCallback onSign;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: signed ? null : onSign,
      child: DottedBorderBox(
        child: Center(
          child: signed
              ? Text(
                  'Jennifer Thompson',
                  style: TextStyle(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF1F2937),
                    fontFamily: 'cursive',
                  ),
                )
              : Text(
                  context.tr(en: 'Tap to sign', ar: 'اضغط للتوقيع'),
                  style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                ),
        ),
      ),
    );
  }
}

/// A dashed-border container that mimics the dashed signature canvas frame.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(color: SchooKeepColors.surface, child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
