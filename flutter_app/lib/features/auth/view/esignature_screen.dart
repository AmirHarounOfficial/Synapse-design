import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:signature/signature.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class ESignatureScreen extends StatefulWidget {
  const ESignatureScreen({super.key});

  @override
  State<ESignatureScreen> createState() => _ESignatureScreenState();
}

class _ESignatureScreenState extends State<ESignatureScreen> {
  late final SignatureController _controller;
  bool _hasSignature = false;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  late final String _signatureTime;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 2,
      penColor: SchooKeepColors.textPrimary,
      exportBackgroundColor: SchooKeepColors.surface,
    );
    _controller.addListener(() {
      final has = _controller.isNotEmpty;
      if (has != _hasSignature && mounted) setState(() => _hasSignature = has);
    });
    _signatureTime = _formatNow();
  }

  String _formatNow() {
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${hour12.toString().padLeft(2, '0')}:$minute $ampm';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasSignature || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) context.go('/principal/home');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _hasSignature && !_isSubmitting;

    return Stack(
      children: [
        ColoredBox(
          color: SchooKeepColors.background,
          child: Column(
            children: [
              const StatusBarSpacer(),
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: SchooKeepColors.surface,
                  border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr(en: 'Sign & Confirm', ar: 'التوقيع والتأكيد'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
                    Text(
                      context.tr(en: 'Step 2 of 2', ar: 'الخطوة 2 من 2'),
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SchooKeepCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: SchooKeepColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.fileText, size: 20, color: SchooKeepColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.tr(
                                  en: 'By signing, you agree to maintain confidentiality of all student health data in your care.',
                                  ar: 'بالتوقيع أدناه، فإنك توافق على الالتزام بالسرية التامة لجميع البيانات الصحية الطلابية.',
                                ),
                                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SchooKeepCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr(en: 'Your Signature', ar: 'التوقيع الإلكتروني'),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                                ),
                                TextButton(
                                  onPressed: () => _controller.clear(),
                                  child: Text(
                                    context.tr(en: 'Clear', ar: 'مسح'),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: DottedBorderBox(
                                child: Stack(
                                  children: [
                                    Signature(
                                      controller: _controller,
                                      width: double.infinity,
                                      height: 200,
                                      backgroundColor: SchooKeepColors.surface,
                                    ),
                                    if (!_hasSignature)
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: Center(
                                            child: Text(
                                              context.tr(en: 'Sign here', ar: 'وقع هنا'),
                                              style: const TextStyle(fontSize: 16, color: SchooKeepColors.border),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr(en: 'Signed: $_signatureTime', ar: 'تاريخ التوقيع: $_signatureTime'),
                              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Opacity(
                        opacity: canSubmit ? 1 : 0.4,
                        child: SizedBox(
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: SchooKeepColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: canSubmit ? _submit : null,
                            child: _isSubmitting
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.tr(en: 'Submitting...', ar: 'جاري الإرسال...'),
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ],
                                  )
                                : Text(
                                    context.tr(en: 'Submit Signature', ar: 'إرسال التوقيع'),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showSuccess)
          const Positioned.fill(child: _SuccessOverlay()),
      ],
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRectPainter(),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SchooKeepColors.border
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    final radius = Radius.circular(8);
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, radius);
    final path = Path()..addRRect(rrect);
    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashed.addPath(metric.extractPath(distance, distance + dash), Offset.zero);
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SchooKeepColors.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
              child: const Icon(LucideIcons.checkCircle, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr(en: 'Agreement Complete', ar: 'تمت الموافقة والتوقيع بنجاح'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(en: 'Redirecting to dashboard...', ar: 'جاري توجيهك إلى لوحة التحكم...'),
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
