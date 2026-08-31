import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/bias_incident_repository.dart';
import '../../../data/repositories/student_repository.dart';

/// Screen allowing teachers to report a racism, bias, or discrimination incident.
class TeacherBiasReportScreen extends StatefulWidget {
  const TeacherBiasReportScreen({super.key});

  @override
  State<TeacherBiasReportScreen> createState() => _TeacherBiasReportScreenState();
}

class _TeacherBiasReportScreenState extends State<TeacherBiasReportScreen> {
  final StudentRepository _studentRepo = sl<StudentRepository>();
  final BiasIncidentRepository _biasRepo = sl<BiasIncidentRepository>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _actionTakenController = TextEditingController();
  final TextEditingController _witnessesController = TextEditingController();

  Timer? _debounce;
  String _searchQuery = '';
  Student? _selectedStudent;
  List<Student> _searchResults = const [];
  bool _searching = false;
  bool _submitting = false;

  String _selectedCategory = 'verbal_slur';
  String _selectedLocation = 'classroom';
  String _selectedSeverity = 'medium';

  static const _categories = [
    (id: 'verbal_slur', en: 'Verbal slur / Offensive remark', ar: 'إساءة لفظية / ملاحظة مسيئة'),
    (id: 'exclusion', en: 'Microaggression / Exclusion', ar: 'تميز / استبعاد متعمد'),
    (id: 'harassment', en: 'Physical harassment / Bullying', ar: 'مضايقة جسدية / تنمر'),
    (id: 'symbol_graffiti', en: 'Offensive symbol / Graffiti', ar: 'رموز مسيئة / كتابات حائطية'),
    (id: 'religious_ethnic_bias', en: 'Religious / Cultural bias', ar: 'تمييز ديني / ثقافي'),
    (id: 'other', en: 'Other bias behavior', ar: 'سلوك تمييزي آخر'),
  ];

  static const _locations = [
    (id: 'classroom', en: 'Classroom', ar: 'الفصل الدراسي'),
    (id: 'hallway', en: 'Hallway / Corridor', ar: 'الممر / الممرات'),
    (id: 'cafeteria', en: 'Cafeteria / Lunchroom', ar: 'الكافتيريا / المطعم'),
    (id: 'playground', en: 'Playground / Sports Field', ar: 'الملعب / الفناء'),
    (id: 'online', en: 'Online / Social Media', ar: 'عبر الإنترنت / وسائل التواصل'),
  ];

  static const _severities = [
    (id: 'low', en: 'Low (Educational chat needed)', ar: 'منخفض (حوار توجيهي)'),
    (id: 'medium', en: 'Medium (Counseling required)', ar: 'متوسط (يتطلب إرشاد نفسي)'),
    (id: 'high', en: 'High (Parent & Admin notification)', ar: 'عالي (إخطار الإدارة والوالدين)'),
    (id: 'critical', en: 'Critical (Immediate safety intervention)', ar: 'حرج (تدخل فوري للطوارئ)'),
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _descriptionController.dispose();
    _actionTakenController.dispose();
    _witnessesController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() {
      _searchQuery = v;
      if (_selectedStudent != null && v != _selectedStudent!.name) {
        _selectedStudent = null;
      }
    });
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      setState(() => _searchResults = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(v));
  }

  Future<void> _runSearch(String query) async {
    setState(() => _searching = true);
    try {
      final page = await _studentRepo.list(query: query);
      if (!mounted) return;
      setState(() => _searchResults = page.items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _searchResults = const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedStudent == null || _descriptionController.text.trim().isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _biasRepo.create(
        studentId: _selectedStudent!.id,
        studentName: _selectedStudent!.name,
        reporterRole: 'teacher',
        reporterName: 'Sarah Jenkins (Classroom Teacher)',
        location: _selectedLocation,
        category: _selectedCategory,
        severity: _selectedSeverity,
        description: _descriptionController.text.trim(),
        immediateActionTaken: _actionTakenController.text.trim().isEmpty ? null : _actionTakenController.text.trim(),
        witnesses: _witnessesController.text.trim().isEmpty ? null : _witnessesController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(context.tr(
            en: 'Anti-bias report submitted to Guidance Counselor.',
            ar: 'تم إرسال بلاغ التمييز إلى المرشد الطلابي بنجاح.',
          )),
        ));
      context.go('/teacher/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final showResults = _searchQuery.isNotEmpty && _selectedStudent == null;
    final canSubmit = _selectedStudent != null && _descriptionController.text.trim().isNotEmpty && !_submitting;

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        title: context.tr(en: 'Report Bias Incident', ar: 'الإبلاغ عن حادث تمييز / عنصرية'),
      ),
      bottomBar: _bottomBar(canSubmit),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldAlert, size: 20, color: SchooKeepColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr(
                        en: 'All anti-bias reports are routed confidentially to the Guidance Counselor & Principal for review.',
                        ar: 'تُرسل جميع تقارير مناهضة التمييز بسرية تامة للمرشد الطلابي وإدارة المدرسة للمراجعة.',
                      ),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Student Selector
            Text(
              context.tr(en: 'Involved Student', ar: 'الطالب المعني'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            _searchField(),
            if (showResults) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: Container(
                  decoration: BoxDecoration(
                    color: SchooKeepColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SchooKeepColors.border),
                  ),
                  child: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                        )
                      : _searchResults.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                context.tr(en: 'No students found', ar: 'لم يتم العثور على طالب'),
                                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                              itemBuilder: (_, i) => _studentTile(_searchResults[i]),
                            ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Category Selection
            Text(
              context.tr(en: 'Incident Category', ar: 'فئة الحادثة التمييزية'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _categories)
                  ChoiceChip(
                    selected: _selectedCategory == c.id,
                    label: Text(context.tr(en: c.en, ar: c.ar)),
                    selectedColor: SchooKeepColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _selectedCategory == c.id ? Colors.white : SchooKeepColors.textPrimary,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = c.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            Text(
              context.tr(en: 'Location', ar: 'موقع الحادثة'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  items: [
                    for (final l in _locations)
                      DropdownMenuItem(
                        value: l.id,
                        child: Text(context.tr(en: l.en, ar: l.ar), style: const TextStyle(fontSize: 14)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _selectedLocation = v ?? _selectedLocation),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Severity Rating
            Text(
              context.tr(en: 'Severity Assessment', ar: 'درجة خطورة الحادثة'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSeverity,
                  isExpanded: true,
                  items: [
                    for (final s in _severities)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(context.tr(en: s.en, ar: s.ar), style: const TextStyle(fontSize: 14)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _selectedSeverity = v ?? _selectedSeverity),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Incident Description
            Text(
              context.tr(en: 'Factual Description of Event', ar: 'الوصف التفصيلي المستند للحقائق'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr(
                  en: 'Describe objectively what occurred, language used, or actions witnessed...',
                  ar: 'اكتب وصفاً موضوعياً لما حدث، الألفاظ أو التصرفات التي تم رصدها...',
                ),
                filled: true,
                fillColor: SchooKeepColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
              ),
            ),
            const SizedBox(height: 16),

            // Immediate Action Taken
            Text(
              context.tr(en: 'Immediate Action Taken (optional)', ar: 'الإجراء الفوري المتخذ (اختياري)'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _actionTakenController,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr(
                  en: 'e.g., Separated parties, addressed comment, reassured student...',
                  ar: 'مثال: الفصل بين الطلاب، توضيح رفض السلوك، طمأنة الطالب...',
                ),
                filled: true,
                fillColor: SchooKeepColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
              ),
            ),
            const SizedBox(height: 16),

            // Witnesses
            Text(
              context.tr(en: 'Witnesses / Present Staff (optional)', ar: 'الشهود / الكادر المتواجد (اختياري)'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _witnessesController,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr(en: 'Names of other students or staff present', ar: 'أسماء الطلاب أو الموظفين المتواجدين'),
                filled: true,
                fillColor: SchooKeepColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
        decoration: InputDecoration(
          hintText: context.tr(en: 'Search student name...', ar: 'ابحث عن اسم الطالب...'),
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: SchooKeepColors.textSecondary),
          filled: true,
          fillColor: SchooKeepColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
        ),
      ),
    );
  }

  Widget _studentTile(Student student) {
    return ListTile(
      dense: true,
      title: Text(student.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text('${student.grade ?? ''} • ${student.section ?? ''}', style: const TextStyle(fontSize: 12)),
      onTap: () => setState(() {
        _selectedStudent = student;
        _searchController.text = student.name;
        _searchResults = const [];
      }),
    );
  }

  Widget _bottomBar(bool canSubmit) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: canSubmit ? SchooKeepColors.primary : const Color(0xFFE5E7EB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: canSubmit ? _handleSubmit : null,
          child: _submitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(
                  context.tr(en: 'Submit Bias Incident Report', ar: 'إرسال بلاغ التمييز والعنصرية'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: canSubmit ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
        ),
      ),
    );
  }
}
