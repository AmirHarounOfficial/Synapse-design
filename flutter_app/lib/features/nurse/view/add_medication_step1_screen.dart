import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class AddMedicationStep1Screen extends StatefulWidget {
  const AddMedicationStep1Screen({super.key});

  @override
  State<AddMedicationStep1Screen> createState() => _AddMedicationStep1ScreenState();
}

class _AddMedicationStep1ScreenState extends State<AddMedicationStep1Screen> {
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

  void _handleUpload() {
    if (_photoCapture != 'idle') return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr(en: 'Photo selected from library', ar: 'تم اختيار صورة من مكتبة الصور'))),
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
        title: context.tr(en: 'Add Medication', ar: 'إضافة دواء جديد'),
        centerTitle: true,
        onBack: () => context.go('/nurse/medications'),
        actions: [
          Center(
            child: Text(context.tr(en: 'Step 1 of 3', ar: 'الخطوة 1 من 3'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepProgress(activeStep: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                            Center(child: _viewfinderContent(context)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr(en: 'Point camera at medication label', ar: 'وجه الكاميرا نحو ملصق عبوة الدواء'),
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SchooKeepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr(en: 'Instructions', ar: 'تعليمات التصوير'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      const SizedBox(height: 12),
                      _NumberedItem(1, context.tr(en: 'Place bottle face-up', ar: 'ضع العلبة بشكل واضح أمام الكاميرا')),
                      const SizedBox(height: 8),
                      _NumberedItem(2, context.tr(en: 'Ensure label is fully visible', ar: 'تأكد من وضوح وقراءة الملصق بالكامل')),
                      const SizedBox(height: 8),
                      _NumberedItem(3, context.tr(en: 'Hold steady in good lighting', ar: 'حافظ على ثبات الكاميرا في إضاءة جيدة')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AccentCard(
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
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 13, color: SchooKeepColors.amberText),
                            children: [
                              TextSpan(text: context.tr(en: 'FDA requires: ', ar: 'متطلبات هيئة الصحة: '), style: const TextStyle(fontWeight: FontWeight.w600)),
                              TextSpan(
                                text: context.tr(
                                  en: 'medication must be in original labeled container with student name, medication name, and dosage visible.',
                                  ar: 'يجب أن يكون الدواء في عبوته الأصلية المختومة مع وضوح اسم الطالب والجرعة والاسم التجاري.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                      _photoCapture == 'capturing'
                          ? context.tr(en: 'Capturing...', ar: 'جاري التقاط الصورة...')
                          : context.tr(en: 'Capture Photo', ar: 'التقاط صورة الملصق'),
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
                    label: Text(
                      context.tr(en: 'Upload from Photos', ar: 'تحميل من مكتبة الصور'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.primary),
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

  Widget _viewfinderContent(BuildContext context) {
    switch (_photoCapture) {
      case 'capturing':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 4, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(context.tr(en: 'Capturing...', ar: 'جاري التقاط الصورة...'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        );
      case 'captured':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
                child: Icon(LucideIcons.check, size: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(context.tr(en: 'Photo captured!', ar: 'تم التقاط الصورة بنجاح!'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
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
