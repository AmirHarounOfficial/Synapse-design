import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from the DEFAULT (onboarding) component of `ParentDocumentUpload.tsx`.
/// Lists nurse-requested documents; tapping one opens an upload-method sheet
/// (camera / files / photos) and runs a simulated progress upload. When all
/// required documents are uploaded the screen switches to a success state.
class ParentDocumentUploadOnboardingScreen extends StatefulWidget {
  const ParentDocumentUploadOnboardingScreen({super.key});

  @override
  State<ParentDocumentUploadOnboardingScreen> createState() =>
      _ParentDocumentUploadOnboardingScreenState();
}

class _PendingDocument {
  const _PendingDocument({required this.id, required this.name, required this.required});
  final String id;
  final String name;
  final bool required;
}

class _ParentDocumentUploadOnboardingScreenState
    extends State<ParentDocumentUploadOnboardingScreen> {
  String? _uploadingDoc;
  int _uploadProgress = 0;
  final Set<String> _uploadedDocs = <String>{};
  Timer? _timer;

  List<_PendingDocument> _documents(BuildContext context) => [
        _PendingDocument(
          id: '1',
          name: context.tr(en: 'Updated Immunization Record', ar: 'سجل التطعيمات المحدّث'),
          required: true,
        ),
        _PendingDocument(
          id: '2',
          name: context.tr(en: 'Emergency Contact Form', ar: 'نموذج جهة اتصال الطوارئ'),
          required: true,
        ),
        _PendingDocument(
          id: '3',
          name: context.tr(en: 'Photo ID (Parent/Guardian)', ar: 'هوية مصورة (ولي الأمر)'),
          required: false,
        ),
      ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDocumentTap(String docId) {
    if (_uploadedDocs.contains(docId)) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _UploadOptionsSheet(
        onMethodSelected: () {
          Navigator.of(sheetContext).pop();
          _startUpload(docId);
        },
      ),
    );
  }

  void _startUpload(String docId) {
    setState(() {
      _uploadingDoc = docId;
      _uploadProgress = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        if (_uploadProgress >= 100) {
          timer.cancel();
          _uploadingDoc = null;
          _uploadedDocs.add(docId);
        } else {
          _uploadProgress += 10;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final docs = _documents(context);
    final allUploaded = docs.every((d) => _uploadedDocs.contains(d.id));

    return SchooKeepScaffold(
      scrollable: false,
      backgroundColor: SchooKeepColors.background,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Upload Document', ar: 'تحميل وثيقة'),
        centerTitle: true,
        onBack: () => context.safeBack(),
      ),
      body: allUploaded ? _buildSuccess(context, docs) : _buildList(context, docs),
    );
  }

  Widget _buildSuccess(BuildContext context, List<_PendingDocument> docs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: SchooKeepColors.greenChipBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.checkCircle, size: 56, color: SchooKeepColors.accent),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr(en: 'All Documents Submitted ✓', ar: 'تم إرسال جميع الوثائق ✓'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
              en: "Your documents have been submitted to the school nurse for review. You'll receive a notification when they're approved.",
              ar: 'تم إرسال وثائقك إلى ممرضة المدرسة للمراجعة. ستتلقى إشعاراً عند الموافقة عليها.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 32),
          for (final doc in docs) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      doc.name,
                      style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
          SchooKeepButton(
            label: context.tr(en: 'Done', ar: 'تم'),
            onPressed: () => context.go('/parent/app/home'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<_PendingDocument> docs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.primary),
            ),
            child: Text(
              context.tr(
                en: 'The school nurse has requested the following documents. Tap each document type to upload.',
                ar: 'طلبت ممرضة المدرسة الوثائق التالية. اضغط على كل نوع وثيقة للتحميل.',
              ),
              style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF1E40AF)),
            ),
          ),
          const SizedBox(height: 16),
          for (final doc in docs) ...[
            _documentCard(context, doc),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          // Requirements
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SchooKeepColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Document Requirements', ar: 'متطلبات الوثيقة'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _bullet(context.tr(en: 'File formats: PDF, JPG, PNG', ar: 'صيغ الملفات: PDF، JPG، PNG')),
                _bullet(context.tr(en: 'Maximum file size: 10MB', ar: 'الحد الأقصى لحجم الملف: 10 ميجابايت')),
                _bullet(context.tr(en: 'Images must be clear and legible', ar: 'يجب أن تكون الصور واضحة ومقروءة')),
                _bullet(context.tr(en: 'All information must be visible', ar: 'يجب أن تكون جميع المعلومات مرئية')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '• $text',
        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
      ),
    );
  }

  Widget _documentCard(BuildContext context, _PendingDocument doc) {
    final isUploaded = _uploadedDocs.contains(doc.id);
    final isUploading = _uploadingDoc == doc.id;
    final disabled = isUploaded || isUploading;

    Widget trailing;
    if (isUploaded) {
      trailing = const Icon(LucideIcons.checkCircle, size: 24, color: SchooKeepColors.accent);
    } else if (isUploading) {
      trailing = const Icon(LucideIcons.upload, size: 24, color: SchooKeepColors.primary);
    } else {
      trailing = const Icon(LucideIcons.alertCircle, size: 24, color: SchooKeepColors.error);
    }

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SchooKeepColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : () => _onDocumentTap(doc.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.textPrimary,
                            ),
                          ),
                          if (doc.required && !isUploaded) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                context.tr(en: 'MISSING', ar: 'مفقود'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: SchooKeepColors.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    trailing,
                  ],
                ),
                if (isUploading) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(en: 'Uploading...', ar: 'جارٍ التحميل...'),
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                      ),
                      Text(
                        '$_uploadProgress%',
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _uploadProgress / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: const AlwaysStoppedAnimation<Color>(SchooKeepColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadOptionsSheet extends StatelessWidget {
  const _UploadOptionsSheet({required this.onMethodSelected});
  final VoidCallback onMethodSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr(en: 'Upload Document', ar: 'تحميل وثيقة'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _option(
                  icon: LucideIcons.camera,
                  title: context.tr(en: 'Take Photo', ar: 'التقاط صورة'),
                  subtitle: context.tr(
                    en: 'Use camera to capture document',
                    ar: 'استخدم الكاميرا لالتقاط الوثيقة',
                  ),
                  onTap: onMethodSelected,
                ),
                const SizedBox(height: 8),
                _option(
                  icon: LucideIcons.file,
                  title: context.tr(en: 'Choose File', ar: 'اختر ملفاً'),
                  subtitle: context.tr(
                    en: 'Select PDF or document file',
                    ar: 'حدد ملف PDF أو وثيقة',
                  ),
                  onTap: onMethodSelected,
                ),
                const SizedBox(height: 8),
                _option(
                  icon: LucideIcons.image,
                  title: context.tr(en: 'Photo Library', ar: 'مكتبة الصور'),
                  subtitle: context.tr(
                    en: 'Choose from existing photos',
                    ar: 'اختر من الصور الموجودة',
                  ),
                  onTap: onMethodSelected,
                ),
                const SizedBox(height: 16),
                SchooKeepButton(
                  label: context.tr(en: 'Cancel', ar: 'إلغاء'),
                  variant: SchooKeepButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _option({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: SchooKeepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: SchooKeepColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 24, color: SchooKeepColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
