import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:signature/signature.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ESignature.tsx`. A canvas signature pad (via the `signature`
/// package), a confidentiality summary, a timestamp, and a Submit button that
/// shows a spinner then a full-screen success overlay before routing to the
/// nurse dashboard.
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
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '${months[now.month - 1]} ${now.day}, ${now.year} at '
        '${hour12.toString().padLeft(2, '0')}:$minute $ampm';
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
        if (mounted) context.go('/nurse/dashboard');
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sign & Confirm',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
                    Text('Step 2 of 2', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary card
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
                            const Expanded(
                              child: Text(
                                'By signing, you agree to maintain confidentiality of all student health data in your care.',
                                style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Signature pad card
                      SchooKeepCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Your Signature',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                                ),
                                TextButton(
                                  onPressed: () => _controller.clear(),
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
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
                                      const Positioned.fill(
                                        child: IgnorePointer(
                                          child: Center(
                                            child: Text(
                                              'Sign here',
                                              style: TextStyle(fontSize: 16, color: SchooKeepColors.border),
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
                              'Signed: $_signatureTime',
                              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Submit button
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
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Submitting...',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ],
                                  )
                                : const Text('Submit Signature',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
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
        // Success overlay
        if (_showSuccess)
          const Positioned.fill(child: _SuccessOverlay()),
      ],
    );
  }
}

/// A 2px dashed-border container matching the React `border-2 border-dashed`.
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
            const Text(
              'Agreement Complete',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Redirecting to dashboard...',
              style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
