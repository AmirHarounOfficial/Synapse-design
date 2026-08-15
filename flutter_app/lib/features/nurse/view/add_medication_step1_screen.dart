import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `AddMedicationStep1.tsx`. English-only. Camera viewfinder with a
/// simulated capture flow (`idle -> capturing -> captured`) that auto-advances
/// to step 2.
class AddMedicationStep1Screen extends StatefulWidget {
  const AddMedicationStep1Screen({super.key});

  @override
  State<AddMedicationStep1Screen> createState() => _AddMedicationStep1ScreenState();
}

class _AddMedicationStep1ScreenState extends State<AddMedicationStep1Screen> {
  /// 'idle' | 'capturing' | 'captured'
  String _photoCapture = 'idle';

  void _handleCapture() {
    setState(() => _photoCapture = 'capturing');
    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _photoCapture = 'captured');
      Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        context.go('/nurse/medications/add/step2');
      });
    });
  }

  /// "Upload from Photos" — there is no native gallery picker available
  /// (file_picker is disallowed), so we treat a chosen photo the same as a
  /// successful capture: confirm and advance to step 2.
  void _handleUpload() {
    if (_photoCapture != 'idle') return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo selected from library')),
    );
    setState(() => _photoCapture = 'captured');
    Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.go('/nurse/medications/add/step2');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Add Medication',
        centerTitle: true,
        onBack: () => context.go('/nurse/medications'),
        actions: const [
          Center(
            child: Text('Step 1 of 3',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          const _StepProgress(activeStep: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Camera viewfinder
                Center(
                  child: Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        height: 240,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            const _CornerFrame(top: true, left: true),
                            const _CornerFrame(top: true, left: false),
                            const _CornerFrame(top: false, left: true),
                            const _CornerFrame(top: false, left: false),
                            Center(child: _viewfinderContent()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Point camera at medication label',
                          style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Instructions card
                SchooKeepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Instructions',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      SizedBox(height: 12),
                      _NumberedItem(1, 'Place bottle face-up'),
                      SizedBox(height: 8),
                      _NumberedItem(2, 'Ensure label is fully visible'),
                      SizedBox(height: 8),
                      _NumberedItem(3, 'Hold steady in good lighting'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Requirement notice
                AccentCard(
                  background: SchooKeepColors.amberBg,
                  accentColor: SchooKeepColors.warning,
                  accentWidth: 4,
                  radius: 12,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: 13, color: SchooKeepColors.amberText),
                            children: [
                              TextSpan(text: 'FDA requires: ', style: TextStyle(fontWeight: FontWeight.w600)),
                              TextSpan(
                                  text:
                                      'medication must be in original labeled container with student name, medication name, and dosage visible.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.primary,
                      disabledBackgroundColor: SchooKeepColors.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _photoCapture == 'idle' ? _handleCapture : null,
                    child: Text(
                      _photoCapture == 'capturing' ? 'Capturing...' : 'Capture Photo',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _photoCapture == 'idle' ? _handleUpload : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: SchooKeepColors.surface,
                      side: const BorderSide(color: SchooKeepColors.primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(LucideIcons.upload, size: 20, color: SchooKeepColors.primary),
                    label: const Text('Upload from Photos',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewfinderContent() {
    switch (_photoCapture) {
      case 'capturing':
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 4, color: Colors.white),
            ),
            SizedBox(height: 12),
            Text('Capturing...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        );
      case 'captured':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 48,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
                child: Icon(LucideIcons.check, size: 32, color: Colors.white),
              ),
            ),
            SizedBox(height: 12),
            Text('Photo captured!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        );
      case 'idle':
      default:
        return const Icon(LucideIcons.camera, size: 64, color: SchooKeepColors.textSecondary);
    }
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.activeStep});
  final int activeStep;

  @override
  Widget build(BuildContext context) {
    Color barColor(int step) {
      if (step < activeStep) return SchooKeepColors.accent;
      if (step == activeStep) return SchooKeepColors.primary;
      return SchooKeepColors.border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Row(
        children: [
          for (var step = 1; step <= 3; step++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: barColor(step),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            if (step < 3) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _CornerFrame extends StatelessWidget {
  const _CornerFrame({required this.top, required this.left});
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: SchooKeepColors.primary, width: 2);
    return Positioned(
      top: top ? 16 : null,
      bottom: top ? null : 16,
      left: left ? 16 : null,
      right: left ? null : 16,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: top ? BorderSide.none : side,
            left: left ? side : BorderSide.none,
            right: left ? BorderSide.none : side,
          ),
        ),
      ),
    );
  }
}

class _NumberedItem extends StatelessWidget {
  const _NumberedItem(this.number, this.text);
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number.', style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary))),
      ],
    );
  }
}
