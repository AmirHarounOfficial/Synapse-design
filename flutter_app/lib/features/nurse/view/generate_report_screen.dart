import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `GenerateReport.tsx`. Report-type picker, date range, student
/// scope, includable sections, physician co-signature toggle and a generate
/// CTA that spins then navigates to the preview. Bilingual.
class GenerateReportScreen extends StatefulWidget {
  const GenerateReportScreen({super.key});

  @override
  State<GenerateReportScreen> createState() => _GenerateReportScreenState();
}

class _GenerateReportScreenState extends State<GenerateReportScreen> {
  String _selectedType = 'daily';
  DateTime _startDate = DateTime(2026, 6, 15);
  DateTime _endDate = DateTime(2026, 6, 15);
  String _studentScope = 'all'; // all | specific
  final TextEditingController _specificController = TextEditingController();
  bool _isGenerating = false;
  bool _submitForCoSignature = true;

  bool _clinicVisits = true;
  bool _medicationLog = true;
  bool _documentStatus = true;
  bool _healthScreening = true;

  static const List<({String id, String enName, String arName, String enDesc, String arDesc, IconData icon})> _reportTypes = [
    (id: 'daily', enName: 'Daily Summary', arName: 'الملخص اليومي', enDesc: 'All activities for a single day', arDesc: 'جميع الأنشطة والزيارات ليوم واحد', icon: LucideIcons.calendar),
    (id: 'weekly', enName: 'Weekly Clinic', arName: 'التقرير الأسبوعي للعيادة', enDesc: 'Clinic visit statistics and trends', arDesc: 'إحصائيات وزيارات العيادة الأسبوعية والتطورات', icon: LucideIcons.activity),
    (id: 'medication', enName: 'Medication Log', arName: 'سجل الأدوية اليومي', enDesc: 'All medication administration records', arDesc: 'جميع سجلات إعطاء الأدوية للطلاب بالعيادة', icon: LucideIcons.clipboard),
    (id: 'screening', enName: 'Periodic Health Screening', arName: 'الفحوصات الطبية الدورية', enDesc: 'Vision, hearing, growth screenings', arDesc: 'نتائج فحص النظر والسمع والنمو الدورية للطلاب', icon: LucideIcons.users),
    (id: 'annual', enName: 'Annual Report', arName: 'التقرير السنوي الشامل', enDesc: 'Comprehensive year-end report', arDesc: 'تقرير شامل ومفصل لجميع البيانات الصحية بنهاية العام', icon: LucideIcons.fileText),
  ];

  static const String _nurseName = 'Emily Smith';
  static const String _licenseNumber = 'RN-4521';

  @override
  void dispose() {
    _specificController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleGenerate() {
    setState(() => _isGenerating = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      context.go('/nurse/reports/preview?cosign=$_submitForCoSignature');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        centerTitle: true,
        onBack: () => context.safeBack(),
        title: isRTL ? 'إنشاء تقرير طبي' : 'Generate Report',
      ),
      bottomBar: _generateBar(isRTL),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report type
            Text(isRTL ? 'نوع التقرير الطبي' : 'Report Type',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 12),
            for (final t in _reportTypes) ...[
              _reportTypeCard(isRTL, t),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),

            // Date range
            Text(isRTL ? 'الفترة الزمنية للتقرير' : 'Date Range',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _dateColumn(isRTL ? 'تاريخ البدء' : 'Start Date', _startDate, () => _pickDate(true))),
                const SizedBox(width: 12),
                Expanded(child: _dateColumn(isRTL ? 'تاريخ الانتهاء' : 'End Date', _endDate, () => _pickDate(false))),
              ],
            ),
            const SizedBox(height: 24),

            // Student scope
            Text(isRTL ? 'نطاق طلاب التقرير' : 'Student Scope',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 12),
            _scopeRow('all', isRTL ? 'جميع الطلاب بالمدرسة' : 'All students'),
            const SizedBox(height: 8),
            _scopeRow('specific', isRTL ? 'طالب محدد فقط' : 'Specific student'),
            if (_studentScope == 'specific') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _specificController,
                decoration: InputDecoration(
                  hintText: isRTL ? 'ابحث عن اسم الطالب...' : 'Search student name...',
                  hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
                  filled: true,
                  fillColor: SchooKeepColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SchooKeepColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SchooKeepColors.physicianTeal),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Include sections
            Text(isRTL ? 'الأقسام المشمولة بالتقرير' : 'Include Sections',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 12),
            SchooKeepCard(
              child: Column(
                children: [
                  _sectionCheckbox(_clinicVisits, isRTL ? 'ملخص زيارات العيادة المدرسية' : 'Clinic visits summary',
                      (v) => setState(() => _clinicVisits = v)),
                  _sectionCheckbox(_medicationLog, isRTL ? 'سجل إعطاء الأدوية والجرعات' : 'Medication administration log',
                      (v) => setState(() => _medicationLog = v)),
                  _sectionCheckbox(_documentStatus, isRTL ? 'حالة التراخيص والمستندات الطبية' : 'Document status',
                      (v) => setState(() => _documentStatus = v)),
                  _sectionCheckbox(_healthScreening, isRTL ? 'نتائج الفحوصات الطبية الدورية' : 'Health screening results',
                      (v) => setState(() => _healthScreening = v)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  _sectionCheckbox(_submitForCoSignature,
                      isRTL ? 'إرسال للتوقيع المشترك للطبيب' : 'Submit for Physician Co-Signature',
                      (v) => setState(() => _submitForCoSignature = v),
                      bold: true),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 32, top: 2),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        isRTL
                            ? 'سيتم إرسال التقرير الطبي للطبيب المناوب للمراجعة والتوقيع الثنائي لاعتماده نهائياً.'
                            : 'Report will be routed to the on-duty school physician for review and dual-signature before final release.',
                        style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Signature info card
            SchooKeepCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isRTL
                          ? 'سيتم توقيع التقرير رقمياً بواسطة: $_nurseName · ترخيص: $_licenseNumber بموجب قانون المعاملات الإلكترونية الإماراتي.'
                          : 'Report will be digitally signed by: $_nurseName · License #$_licenseNumber under UAE Electronic Transactions Law.',
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
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

  Widget _reportTypeCard(bool isRTL, ({String id, String enName, String arName, String enDesc, String arDesc, IconData icon}) t) {
    final selected = _selectedType == t.id;
    return Material(
      color: selected ? const Color(0xFFF0FDFA) : SchooKeepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? SchooKeepColors.physicianTeal : SchooKeepColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedType = t.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? SchooKeepColors.physicianTeal : SchooKeepColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(t.icon, size: 20, color: selected ? Colors.white : SchooKeepColors.physicianTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? t.arName : t.enName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(isRTL ? t.arDesc : t.enDesc,
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                const Icon(LucideIcons.check, size: 20, color: SchooKeepColors.physicianTeal),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateColumn(String label, DateTime value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Text(_fmt(value), style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
          ),
        ),
      ],
    );
  }

  Widget _scopeRow(String value, String label) {
    return InkWell(
      onTap: () => setState(() => _studentScope = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Row(
          children: [
            _RadioDot(selected: _studentScope == value, color: SchooKeepColors.physicianTeal),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _sectionCheckbox(bool value, String label, ValueChanged<bool> onChanged, {bool bold = false}) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                activeColor: SchooKeepColors.physicianTeal,
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                    color: SchooKeepColors.textPrimary,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _generateBar(bool isRTL) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: SchooKeepColors.physicianTeal,
            disabledBackgroundColor: SchooKeepColors.physicianTeal.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isGenerating ? null : _handleGenerate,
          child: _isGenerating
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(isRTL ? 'جاري إنشاء التقرير...' : 'Generating Report...',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                )
              : Text(isRTL ? 'إنشاء التقرير الطبي' : 'Generate Report',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.color});
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? color : SchooKeepColors.border, width: 2),
          ),
          child: selected
              ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
