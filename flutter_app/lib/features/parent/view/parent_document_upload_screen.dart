import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/document_repository.dart';
import '../../../data/repositories/student_repository.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from the named export `ParentDocumentUploadScreen` in
/// `ParentDocumentUpload.tsx`. Lists nurse-requested documents; the parent picks
/// which child the documents are for, then taps a document to capture a photo or
/// choose a file, which is uploaded to `POST /documents` (multipart) and left
/// pending for nurse review. Success is shown once every required document is in.
class ParentDocumentUploadScreen extends StatefulWidget {
  const ParentDocumentUploadScreen({super.key});

  @override
  State<ParentDocumentUploadScreen> createState() =>
      _ParentDocumentUploadScreenState();
}

enum _UploadSource { camera, gallery, file }

class _PendingDocument {
  const _PendingDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.required,
  });
  final String id;
  final String name;
  final String type; // backend document `type`
  final bool required;
}

const _maxBytes = 10 * 1024 * 1024; // 10 MB (matches backend `max:10240`)
const _allowedExt = ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp'];

class _ParentDocumentUploadScreenState
    extends State<ParentDocumentUploadScreen> {
  final _docRepo = sl<DocumentRepository>();
  final _studentRepo = sl<StudentRepository>();
  final _imagePicker = ImagePicker();

  // Child selection
  bool _loadingChildren = true;
  String? _childrenError;
  List<Student> _children = const [];
  Student? _selectedChild;

  // Upload state
  String? _uploadingDoc;
  int _uploadProgress = 0;
  final Set<String> _uploadedDocs = {};

  late final List<_PendingDocument> _pendingDocuments;

  @override
  void initState() {
    super.initState();
    final isRTL = context.read<LocaleCubit>().state.isRTL;
    _pendingDocuments = [
      _PendingDocument(
        id: '1',
        type: 'immunization',
        name: isRTL ? 'سجل التطعيمات المحدّث' : 'Updated Immunization Record',
        required: true,
      ),
      _PendingDocument(
        id: '2',
        type: 'emergency_contact',
        name: isRTL ? 'نموذج جهة اتصال الطوارئ' : 'Emergency Contact Form',
        required: true,
      ),
      _PendingDocument(
        id: '3',
        type: 'photo_id',
        name: isRTL ? 'هوية مصوّرة (ولي الأمر/الوصي)' : 'Photo ID (Parent/Guardian)',
        required: false,
      ),
    ];
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _loadingChildren = true;
      _childrenError = null;
    });
    try {
      final page = await _studentRepo.list();
      if (!mounted) return;
      setState(() {
        _children = page.items;
        _selectedChild = page.items.isNotEmpty ? page.items.first : null;
        _loadingChildren = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _childrenError = DocumentRepository.messageFor(e);
        _loadingChildren = false;
      });
    }
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? SchooKeepColors.error : null,
    ));
  }

  Future<void> _handleDocumentClick(_PendingDocument doc) async {
    if (_uploadedDocs.contains(doc.id) || _uploadingDoc != null) return;
    final isRTL = context.read<LocaleCubit>().state.isRTL;

    if (_selectedChild == null) {
      _snack(isRTL ? 'يرجى اختيار الطالب أولاً' : 'Please select a child first');
      return;
    }

    final source = await showModalBottomSheet<_UploadSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UploadOptionsSheet(isRTL: isRTL),
    );
    if (source == null || !mounted) return;

    final picked = await _pickBytes(source, isRTL);
    if (picked == null || !mounted) return;

    await _upload(doc, picked.$1, picked.$2, isRTL);
  }

  /// Returns (bytes, filename) or null if the user cancelled / it was invalid.
  Future<(List<int>, String)?> _pickBytes(
      _UploadSource source, bool isRTL) async {
    try {
      if (source == _UploadSource.file) {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: _allowedExt,
          withData: true,
        );
        final file = result?.files.singleOrNull;
        if (file == null) return null;
        final bytes = file.bytes;
        if (bytes == null) {
          _snack(isRTL ? 'تعذّر قراءة الملف' : 'Could not read the file',
              error: true);
          return null;
        }
        return _validate(bytes, file.name, isRTL);
      } else {
        final xfile = await _imagePicker.pickImage(
          source: source == _UploadSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 2400,
          imageQuality: 85,
        );
        if (xfile == null) return null;
        final bytes = await xfile.readAsBytes();
        return _validate(bytes, xfile.name, isRTL);
      }
    } catch (e) {
      _snack(isRTL ? 'تعذّر اختيار الملف' : 'Could not select the file',
          error: true);
      return null;
    }
  }

  (List<int>, String)? _validate(List<int> bytes, String name, bool isRTL) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    if (!_allowedExt.contains(ext)) {
      _snack(
        isRTL
            ? 'نوع ملف غير مدعوم. المسموح: PDF، JPG، PNG'
            : 'Unsupported file type. Allowed: PDF, JPG, PNG',
        error: true,
      );
      return null;
    }
    if (bytes.length > _maxBytes) {
      _snack(
        isRTL
            ? 'الملف كبير جداً (الحد الأقصى 10 ميغابايت)'
            : 'File is too large (10MB maximum)',
        error: true,
      );
      return null;
    }
    return (bytes, name);
  }

  Future<void> _upload(
      _PendingDocument doc, List<int> bytes, String filename, bool isRTL) async {
    setState(() {
      _uploadingDoc = doc.id;
      _uploadProgress = 0;
    });
    try {
      await _docRepo.uploadBytes(
        bytes: bytes,
        filename: filename,
        studentId: _selectedChild!.id,
        type: doc.type,
        title: doc.name,
        onProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _uploadProgress = ((sent / total) * 100).clamp(0, 100).round());
        },
      );
      if (!mounted) return;
      setState(() {
        _uploadingDoc = null;
        _uploadProgress = 0;
        _uploadedDocs.add(doc.id);
      });
      _snack(isRTL ? 'تم إرسال المستند للمراجعة' : 'Document submitted for review');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadingDoc = null;
        _uploadProgress = 0;
      });
      _snack(DocumentRepository.messageFor(e), error: true);
    }
  }

  Future<void> _pickChild(bool isRTL) async {
    if (_children.length < 2) return;
    final chosen = await showModalBottomSheet<Student>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChildPickerSheet(
        isRTL: isRTL,
        children: _children,
        selectedId: _selectedChild?.id,
      ),
    );
    if (chosen != null && mounted) setState(() => _selectedChild = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final allDocsUploaded = _pendingDocuments
        .where((d) => d.required)
        .every((doc) => _uploadedDocs.contains(doc.id));

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: isRTL ? 'رفع مستند' : 'Upload Document',
        centerTitle: true,
        onBack: () => context.safeBack(),
      ),
      body: allDocsUploaded && _uploadedDocs.isNotEmpty
          ? _successBody(isRTL)
          : _listBody(isRTL),
    );
  }

  Widget _successBody(bool isRTL) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
                color: SchooKeepColors.greenChipBg, shape: BoxShape.circle),
            child: const Icon(LucideIcons.checkCircle,
                size: 56, color: SchooKeepColors.accent),
          ),
          const SizedBox(height: 24),
          Text(
            isRTL ? 'تم إرسال جميع المستندات ✓' : 'All Documents Submitted ✓',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            isRTL
                ? 'تم إرسال مستنداتك إلى ممرضة المدرسة للمراجعة. ستتلقى إشعاراً عند الموافقة عليها.'
                : "Your documents have been submitted to the school nurse for review. You'll receive a notification when they're approved.",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 32),
          for (final doc in _pendingDocuments)
            if (_uploadedDocs.contains(doc.id))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SchooKeepColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.checkCircle,
                          size: 20, color: SchooKeepColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(doc.name,
                            style: const TextStyle(
                                fontSize: 14,
                                color: SchooKeepColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 32),
          SchooKeepButton(
            label: isRTL ? 'تم' : 'Done',
            onPressed: () => context.go('/parent/app/home'),
          ),
        ],
      ),
    );
  }

  Widget _listBody(bool isRTL) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _childSelector(isRTL),
          const SizedBox(height: 12),
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.primary),
            ),
            child: Text(
              isRTL
                  ? 'طلبت ممرضة المدرسة المستندات التالية. اضغط على كل نوع مستند للرفع.'
                  : 'The school nurse has requested the following documents. Tap each document type to upload.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
            ),
          ),
          const SizedBox(height: 16),
          for (final doc in _pendingDocuments) ...[
            _documentCard(doc, isRTL),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          // Requirements info
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
                  isRTL ? 'متطلبات المستندات' : 'Document Requirements',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 8),
                _bullet(isRTL
                    ? 'صيغ الملفات: PDF، JPG، PNG'
                    : 'File formats: PDF, JPG, PNG'),
                _bullet(isRTL
                    ? 'الحد الأقصى لحجم الملف: 10 ميغابايت'
                    : 'Maximum file size: 10MB'),
                _bullet(isRTL
                    ? 'يجب أن تكون الصور واضحة ومقروءة'
                    : 'Images must be clear and legible'),
                _bullet(isRTL
                    ? 'يجب أن تكون جميع المعلومات مرئية'
                    : 'All information must be visible'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _childSelector(bool isRTL) {
    if (_loadingChildren) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text(isRTL ? 'جارٍ تحميل الأبناء...' : 'Loading children...',
                style: const TextStyle(
                    fontSize: 13, color: SchooKeepColors.textSecondary)),
          ],
        ),
      );
    }
    if (_childrenError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.error),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(_childrenError!,
                  style: const TextStyle(
                      fontSize: 13, color: SchooKeepColors.error)),
            ),
            TextButton(
              onPressed: _loadChildren,
              child: Text(isRTL ? 'إعادة' : 'Retry'),
            ),
          ],
        ),
      );
    }

    final child = _selectedChild;
    final multiple = _children.length > 1;
    return Material(
      color: SchooKeepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SchooKeepColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: multiple ? () => _pickChild(isRTL) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(LucideIcons.user,
                  size: 20, color: SchooKeepColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRTL ? 'المستندات مخصّصة لـ' : 'Uploading documents for',
                      style: const TextStyle(
                          fontSize: 11, color: SchooKeepColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child == null
                          ? (isRTL ? 'لا يوجد طالب' : 'No student')
                          : _childLabel(child, isRTL),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: SchooKeepColors.textPrimary),
                    ),
                  ],
                ),
              ),
              if (multiple)
                const RtlIcon(LucideIcons.chevronDown,
                    size: 20, color: SchooKeepColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  static String _childLabel(Student s, bool isRTL) {
    final name = isRTL ? (s.nameAr ?? s.name) : s.name;
    final grade = s.grade;
    if (grade != null && grade.isNotEmpty) {
      return isRTL ? '$name • الصف $grade' : '$name • Grade $grade';
    }
    return name;
  }

  Widget _documentCard(_PendingDocument doc, bool isRTL) {
    final isUploaded = _uploadedDocs.contains(doc.id);
    final isUploading = _uploadingDoc == doc.id;
    final disabled = isUploaded || _uploadingDoc != null;

    return Opacity(
      opacity: isUploaded || isUploading ? 0.85 : (disabled ? 0.6 : 1),
      child: Material(
        color: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SchooKeepColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : () => _handleDocumentClick(doc),
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
                          Text(doc.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: SchooKeepColors.textPrimary)),
                          if (doc.required && !isUploaded) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isRTL ? 'مفقود' : 'MISSING',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: SchooKeepColors.error),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isUploaded)
                      const Icon(LucideIcons.checkCircle,
                          size: 24, color: SchooKeepColors.accent)
                    else if (isUploading)
                      const Icon(LucideIcons.upload,
                          size: 24, color: SchooKeepColors.primary)
                    else
                      const Icon(LucideIcons.alertCircle,
                          size: 24, color: SchooKeepColors.error),
                  ],
                ),
                if (isUploading) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isRTL ? 'جارٍ الرفع...' : 'Uploading...',
                          style: const TextStyle(
                              fontSize: 12,
                              color: SchooKeepColors.textSecondary)),
                      Text('$_uploadProgress%',
                          style: const TextStyle(
                              fontSize: 12,
                              color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress / 100 : null,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          SchooKeepColors.primary),
                    ),
                  ),
                ],
                if (isUploaded) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SchooKeepColors.greenChipBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SchooKeepColors.accent),
                    ),
                    child: Text(
                      isRTL
                          ? 'تم إرسال المستند لمراجعة الممرضة'
                          : 'Document submitted for nurse review',
                      style: const TextStyle(
                          fontSize: 12, color: SchooKeepColors.greenChipText),
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

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style:
                  TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: SchooKeepColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _ChildPickerSheet extends StatelessWidget {
  const _ChildPickerSheet({
    required this.isRTL,
    required this.children,
    required this.selectedId,
  });
  final bool isRTL;
  final List<Student> children;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment:
                    isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  isRTL ? 'اختر الطالب' : 'Select child',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textPrimary),
                ),
              ),
            ),
            for (final s in children)
              ListTile(
                leading: const Icon(LucideIcons.user,
                    color: SchooKeepColors.primary),
                title: Text(
                  _ParentDocumentUploadScreenState._childLabel(s, isRTL),
                  style: const TextStyle(
                      fontSize: 15, color: SchooKeepColors.textPrimary),
                ),
                trailing: s.id == selectedId
                    ? const Icon(LucideIcons.check,
                        color: SchooKeepColors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop(s),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _UploadOptionsSheet extends StatelessWidget {
  const _UploadOptionsSheet({required this.isRTL});
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'رفع مستند' : 'Upload Document',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  _option(
                    context,
                    icon: LucideIcons.camera,
                    title: isRTL ? 'التقاط صورة' : 'Take Photo',
                    subtitle: isRTL
                        ? 'استخدم الكاميرا لالتقاط المستند'
                        : 'Use camera to capture document',
                    source: _UploadSource.camera,
                  ),
                  const SizedBox(height: 8),
                  _option(
                    context,
                    icon: LucideIcons.file,
                    title: isRTL ? 'اختيار ملف' : 'Choose File',
                    subtitle: isRTL
                        ? 'اختر ملف PDF أو مستند'
                        : 'Select PDF or document file',
                    source: _UploadSource.file,
                  ),
                  const SizedBox(height: 8),
                  _option(
                    context,
                    icon: LucideIcons.image,
                    title: isRTL ? 'مكتبة الصور' : 'Photo Library',
                    subtitle: isRTL
                        ? 'اختر من الصور الموجودة'
                        : 'Choose from existing photos',
                    source: _UploadSource.gallery,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: SchooKeepColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(isRTL ? 'إلغاء' : 'Cancel',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.textPrimary)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required _UploadSource source,
  }) {
    return Material(
      color: SchooKeepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: SchooKeepColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).pop(source),
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
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: SchooKeepColors.textPrimary)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: SchooKeepColors.textSecondary)),
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
