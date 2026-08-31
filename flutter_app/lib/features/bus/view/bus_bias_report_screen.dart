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

/// Screen allowing bus drivers to report a racism, bias, or harassment incident during student transit.
class BusBiasReportScreen extends StatefulWidget {
  const BusBiasReportScreen({super.key});

  @override
  State<BusBiasReportScreen> createState() => _BusBiasReportScreenState();
}

class _BusBiasReportScreenState extends State<BusBiasReportScreen> {
  final StudentRepository _studentRepo = sl<StudentRepository>();
  final BiasIncidentRepository _biasRepo = sl<BiasIncidentRepository>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _routeController = TextEditingController(text: 'Route #12 (North Campus)');
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
  String _selectedSeverity = 'high';

  static const _categories = [
    (id: 'verbal_slur', en: 'Verbal slur / Chanting', ar: 'إساءة لفظية / هتافات مسيئة'),
    (id: 'exclusion', en: 'Seat exclusion / Bullying', ar: 'استبعاد من المقاعد / مضايقة'),
    (id: 'harassment', en: 'Physical harassment', ar: 'اعتداء جسدي / احتكاك مسيء'),
    (id: 'symbol_graffiti', en: 'Bus Seat Graffiti / Markings', ar: 'كتابات مسيئة على مقاعد الحافلة'),
    (id: 'other', en: 'Other transit incident', ar: 'حادث آخر أثناء النقل'),
  ];

  static const _severities = [
    (id: 'medium', en: 'Medium (Driver verbal warning issued)', ar: 'متوسط (تم تحذير الطالب يدوياً)'),
    (id: 'high', en: 'High (Immediate Counselor & Parent Notice)', ar: 'عالي (إبلاغ فوري للمرشد والأهالي)'),
    (id: 'critical', en: 'Critical (Safety Stop & Admin Response)', ar: 'حرج (إيقاف الحافلة واستدعاء الإدارة)'),
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _routeController.dispose();
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
        reporterRole: 'bus_driver',
        reporterName: 'Robert Vance (Bus Driver)',
        location: 'bus',
        busRouteNumber: _routeController.text.trim(),
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
            en: 'Transit bias report submitted to Guidance Counselor & Transport Supervisor.',
            ar: 'تم إرسال بلاغ التمييز بالحافلة للمرشد الطلابي ومشرف النقل.',
          )),
        ));
      context.go('/bus/route-overview');
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
        title: context.tr(en: 'Report Bus Transit Bias', ar: 'الإبلاغ عن حادث تمييز في الحافلة'),
      ),
      bottomBar: _bottomBar(canSubmit),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.amberChipBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.bus, size: 20, color: SchooKeepColors.amberText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr(
                        en: 'Bus transport bias reports are transmitted immediately to Guidance Counselors & School Administration.',
                        ar: 'تُرسل بلاغات التمييز في الحافلات فوراً للمرشد الطلابي وإدارة المدرسة.',
                      ),
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.amberText, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bus Route #
            Text(
              context.tr(en: 'Bus Route / Vehicle', ar: 'مسار الحافلة / المركبة'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _routeController,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: SchooKeepColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
              ),
            ),
            const SizedBox(height: 16),

            // Student Selector
            Text(
              context.tr(en: 'Student Involved', ar: 'الطالب المعني بالسلوك'),
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
                                context.tr(en: 'No student matched', ar: 'لم يتم العثور على طالب'),
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
              context.tr(en: 'Incident Type', ar: 'نوع الحادثة التمييزية'),
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

            // Severity Rating
            Text(
              context.tr(en: 'Severity Level', ar: 'مستوى الخطورة'),
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

            // Description
            Text(
              context.tr(en: 'Factual Description of Transit Incident', ar: 'وصف واقعة الحافلة بالتفصيل'),
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
                  en: 'Describe what occurred, stop location, approximate time, words or actions used...',
                  ar: 'اصف ما حدث، توقف الحافلة، الوقت التقريبي، والألفاظ أو الأفعال الصادرة...',
                ),
                filled: true,
                fillColor: SchooKeepColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
              ),
            ),
            const SizedBox(height: 16),

            // Driver Immediate Safety Action
            Text(
              context.tr(en: 'Driver Action Taken (e.g. seat change, verbal warning)', ar: 'إجراء السائق الفوري (تغيير المقعد، تحذير شفوي)'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _actionTakenController,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr(
                  en: 'e.g., Moved student to front row, notified bus monitor...',
                  ar: 'مثال: نقل الطالب للمقعد الأمامي، إبلاغ مشرف الحافلة...',
                ),
                filled: true,
                fillColor: SchooKeepColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
              ),
            ),
            const SizedBox(height: 16),

            // Bus Monitor / Witnesses
            Text(
              context.tr(en: 'Bus Monitor / Witnesses Present (optional)', ar: 'مشرف الحافلة / الشهود (اختياري)'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _witnessesController,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr(en: 'e.g., Bus Monitor A. Rodriguez', ar: 'مثال: مشرف الحافلة أ. رودريغيز'),
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
          hintText: context.tr(en: 'Search student by name...', ar: 'ابحث عن اسم الطالب...'),
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
                  context.tr(en: 'Submit Transit Bias Report', ar: 'إرسال بلاغ التمييز في الحافلة'),
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
