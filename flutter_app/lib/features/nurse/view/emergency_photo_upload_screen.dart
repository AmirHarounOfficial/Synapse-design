import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/document_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../cubit/emergency_photo_upload_cubit.dart';

class EmergencyPhotoUploadScreen extends StatelessWidget {
  const EmergencyPhotoUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmergencyPhotoUploadCubit(
        sl<ClinicRepository>(),
        sl<DocumentRepository>(),
        sl<StudentRepository>(),
        sl<AuthRepository>(),
      ),
      child: const _EmergencyPhotoUploadView(),
    );
  }
}

class _EmergencyPhotoUploadView extends StatefulWidget {
  const _EmergencyPhotoUploadView();

  @override
  State<_EmergencyPhotoUploadView> createState() => _EmergencyPhotoUploadViewState();
}

class _EmergencyPhotoUploadViewState extends State<_EmergencyPhotoUploadView> {
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;
  bool _capturing = false;
  String _selectedLocation = '';
  final TextEditingController _description = TextEditingController();
  String _severity = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _description.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _photo != null &&
      _selectedLocation.isNotEmpty &&
      _description.text.trim().isNotEmpty &&
      _severity.isNotEmpty;

  Future<void> _handleCapture() async {
    setState(() => _capturing = true);
    try {
      final file = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1600, imageQuality: 80);
      if (!mounted) return;
      setState(() => _photo = file);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.tr(en: 'Could not access the camera.', ar: 'تعذر الوصول إلى الكاميرا.'))));
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<EmergencyPhotoUploadCubit>().submit(
          location: _selectedLocation,
          description: _description.text.trim(),
          severity: _severity,
          photoPath: _photo?.path,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.go('/nurse/clinic/emergency-consent');
  }

  static (Color bg, Color fg, Color border) _severityStyle(String level) {
    switch (level) {
      case 'minor':
        return (SchooKeepColors.greenChipBg, SchooKeepColors.greenChipText, SchooKeepColors.accent);
      case 'moderate':
        return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText, SchooKeepColors.warning);
      case 'severe':
        return (const Color(0xFFFEE2E2), const Color(0xFF991B1B), SchooKeepColors.error);
      default:
        return (SchooKeepColors.background, SchooKeepColors.textSecondary, SchooKeepColors.border);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyPhotoUploadCubit, EmergencyPhotoUploadState>(
      builder: (context, state) {
        final studentLabel = switch (state) {
          EmergencyUploadReady(:final student) => [
              student.name,
              if ((student.grade ?? '').isNotEmpty) '${context.tr(en: 'Grade', ar: 'الصف')} ${student.grade}',
            ].join(' · '),
          EmergencyUploadError(:final message) => message,
          _ => context.tr(en: 'Loading…', ar: 'جاري التحميل...'),
        };
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            backgroundColor: SchooKeepColors.error,
            titleWidget: Text(
              context.tr(en: 'Emergency Report', ar: 'تقرير حادثة طارئة'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            onBack: () => context.go('/nurse/clinic'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _emergencyBanner(context, studentLabel),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _photoSection(context),
                    const SizedBox(height: 24),
                    _locationSection(context),
                    const SizedBox(height: 24),
                    _descriptionSection(context),
                    const SizedBox(height: 24),
                    _severitySection(context),
                    const SizedBox(height: 24),
                    _submitButton(context, state is EmergencyUploadReady),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emergencyBanner(BuildContext context, String studentLabel) {
    return Container(
      width: double.infinity,
      color: SchooKeepColors.error,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Text(
            context.tr(en: '🚨 Emergency Visit in Progress', ar: '🚨 زيارة طوارئ قيد المعالجة الآن'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(studentLabel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
        ],
      ),
    );
  }

  Widget _photoSection(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Incident Photo/Video *', ar: 'صورة/فيديو الإصابة أو الحادثة *'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: _photo != null ? const Color(0xFF374151) : const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: _photoContent(context),
          ),
          if (_photo != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _handleCapture,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SchooKeepColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SchooKeepColors.border),
                ),
                child: Text(
                  context.tr(en: 'Retake', ar: 'إعادة الالتقاط'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoContent(BuildContext context) {
    if (_capturing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 4, color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              context.tr(en: 'Opening camera…', ar: 'جاري فتح الكاميرا...'),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    if (_photo != null) {
      return Image.file(File(_photo!.path), fit: BoxFit.cover, width: double.infinity, height: 200);
    }
    return Center(
      child: GestureDetector(
        onTap: _handleCapture,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.camera, size: 48, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              context.tr(en: 'Tap to capture', ar: 'اضغط للالتقاط'),
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationSection(BuildContext context) {
    final locations = [
      context.tr(en: 'Classroom', ar: 'الفصل الدراسي'),
      context.tr(en: 'Hallway', ar: 'الممر'),
      context.tr(en: 'Cafeteria', ar: 'الكافتيريا'),
      context.tr(en: 'Playground', ar: 'الملعب'),
      context.tr(en: 'Gym', ar: 'الصالة الرياضية'),
      context.tr(en: 'Other', ar: 'مكان آخر'),
    ];
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Student Location *', ar: 'موقع وقوع الحادثة بالمدرسة *'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final loc in locations) _locationChip(loc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationChip(String loc) {
    final active = _selectedLocation == loc;
    return GestureDetector(
      onTap: () => setState(() => _selectedLocation = loc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : SchooKeepColors.background,
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: SchooKeepColors.border),
        ),
        child: Text(loc,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : SchooKeepColors.textSecondary,
            )),
      ),
    );
  }

  Widget _descriptionSection(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Incident Description *', ar: 'وصف تفصيلي للحادثة والإصابة *'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _description,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: context.tr(en: 'Describe the incident in detail...', ar: 'أدخل تفاصيل الإصابة والأعراض المعاينة...'),
              hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _severitySection(BuildContext context) {
    final severityOptions = [
      (level: 'minor', label: context.tr(en: 'Minor', ar: 'طفيفة'), description: context.tr(en: 'No immediate medical attention needed', ar: 'لا تتطلب عناية طبية طارئة عاجلة')),
      (level: 'moderate', label: context.tr(en: 'Moderate', ar: 'متوسطة'), description: context.tr(en: 'May require medical evaluation', ar: 'قد تتطلب تقييماً وطبابة متخصصة')),
      (level: 'severe', label: context.tr(en: 'Severe', ar: 'حرجة للغاية'), description: context.tr(en: 'Requires immediate medical attention', ar: 'تتطلب عناية وطوارئ فورية')),
    ];

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Severity Assessment *', ar: 'تقييم درجة خطورة الإصابة *'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < severityOptions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _severityOption(severityOptions[i]),
          ],
        ],
      ),
    );
  }

  Widget _severityOption(({String level, String label, String description}) option) {
    final selected = _severity == option.level;
    final (bg, fg, border) = _severityStyle(option.level);
    return GestureDetector(
      onTap: () => setState(() => _severity = option.level),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? bg : SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? border : SchooKeepColors.border, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(option.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? fg : SchooKeepColors.textPrimary,
                )),
            const SizedBox(height: 4),
            Text(option.description,
                style: TextStyle(fontSize: 12, color: selected ? fg : SchooKeepColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context, bool ready) {
    final enabled = _isFormValid && !_isSubmitting && ready;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: SchooKeepColors.error,
          disabledBackgroundColor: SchooKeepColors.error.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: enabled ? _handleSubmit : null,
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.tr(en: 'Sending to school administration and parent...', ar: 'جاري الإرسال لإدارة المدرسة وولي الأمر...'),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.alertTriangle, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    context.tr(en: 'Send Emergency Report', ar: 'إرسال بلاغ الحادثة الإسعافي'),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
