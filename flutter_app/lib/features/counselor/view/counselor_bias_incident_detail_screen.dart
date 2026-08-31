import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/bias_incident.dart';
import '../../../data/repositories/bias_incident_repository.dart';

/// Workspace screen for guidance counselors to review, triage, update status, and manage restorative action plans for reported bias incidents.
class CounselorBiasIncidentDetailScreen extends StatefulWidget {
  const CounselorBiasIncidentDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<CounselorBiasIncidentDetailScreen> createState() => _CounselorBiasIncidentDetailScreenState();
}

class _CounselorBiasIncidentDetailScreenState extends State<CounselorBiasIncidentDetailScreen> {
  final BiasIncidentRepository _repo = sl<BiasIncidentRepository>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _planController = TextEditingController();

  BiasIncident? _incident;
  bool _loading = true;
  bool _saving = false;

  String _status = 'under_review';
  String _severity = 'medium';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _planController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final incidentId = int.tryParse(widget.id) ?? 101;
    try {
      final data = await _repo.show(incidentId);
      if (!mounted) return;
      setState(() {
        _incident = data;
        _status = data.status;
        _severity = data.severity;
        _notesController.text = data.counselorNotes ?? '';
        _planController.text = data.resolutionPlan ?? '';
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges({bool markResolved = false}) async {
    if (_incident == null || _saving) return;
    setState(() => _saving = true);
    final targetStatus = markResolved ? 'resolved' : _status;
    try {
      final updated = await _repo.updateStatus(
        _incident!.id,
        status: targetStatus,
        severity: _severity,
        counselorNotes: _notesController.text.trim(),
        resolutionPlan: _planController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _incident = updated;
        _status = updated.status;
        _saving = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(context.tr(
            en: markResolved ? 'Incident case marked as Resolved.' : 'Case investigation updated.',
            ar: markResolved ? 'تم إغلاق وتسوية بلاغ التمييز.' : 'تم تحديث حالة التحقيق في البلاغ.',
          )),
        ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _escalateToPrincipal() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(context.tr(
          en: 'Case escalated to Principal Dashboard for formal administrative review.',
          ar: 'تم تصعيد القضية للوحة مدير المدرسة للمراجعة الإدارية الرسمية.',
        )),
      ));
  }

  static const _statuses = [
    (id: 'submitted', en: 'Submitted', ar: 'مُقدم جديد'),
    (id: 'under_review', en: 'Under Review / Investigation', ar: 'قيد التحقيق الميداني'),
    (id: 'action_plan_active', en: 'Action Plan Active', ar: 'خطة علاجية وإرشادية نشطة'),
    (id: 'resolved', en: 'Resolved & Closed', ar: 'مغلقة ومسواة بالكامل'),
  ];

  static const _severities = [
    (id: 'low', en: 'Low (Informal reflection & guidance)', ar: 'منخفض (حوار وتوجيه)'),
    (id: 'medium', en: 'Medium (Counseling & parent contact)', ar: 'متوسط (إرشاد وتواصل مع الأهل)'),
    (id: 'high', en: 'High (Parent conference & disciplinary track)', ar: 'عالي (اجتماع أولياء أمور وعقوبة)'),
    (id: 'critical', en: 'Critical (Safety Plan & Principal intervention)', ar: 'حرج (خطة أمان وتدخل الإدارة العليا)'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SchooKeepScaffold(
        appBar: SchooKeepAppBar(onBack: () => context.safeBack(), title: 'Loading Case...'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_incident == null) {
      return SchooKeepScaffold(
        appBar: SchooKeepAppBar(onBack: () => context.safeBack(), title: 'Case Not Found'),
        body: const Center(child: Text('Incident record not found.')),
      );
    }

    final item = _incident!;

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        title: context.tr(
          en: 'Incident Case #${item.id}',
          ar: 'قضية بلاغ رقم #${item.id}',
        ),
      ),
      bottomBar: _bottomBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Overview Card
            SchooKeepCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: SchooKeepColors.primary,
                        child: Text(
                          item.studentName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Reported by: ${item.reporterName}', style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 14, color: SchooKeepColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('Location: ${item.location.toUpperCase()}', style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                      if (item.busRouteNumber != null) ...[
                        const SizedBox(width: 8),
                        Text('(${item.busRouteNumber})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.primary)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Incident Description
            SchooKeepCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(en: 'Reported Factual Transcript', ar: 'نص التقرير المسجل'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(item.description, style: const TextStyle(fontSize: 14, height: 1.4, color: SchooKeepColors.textPrimary)),
                  if (item.immediateActionTaken != null) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),
                    Text(
                      context.tr(en: 'Reporter Immediate Action:', ar: 'الإجراء الفوري المتخذ من مقدم البلاغ:'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(item.immediateActionTaken!, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Counselor Triage Status & Severity Form
            Text(
              context.tr(en: 'Case Management Status', ar: 'حالة القضية والتقييم الإرشادي'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
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
                  value: _status,
                  isExpanded: true,
                  items: [
                    for (final s in _statuses)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(context.tr(en: s.en, ar: s.ar), style: const TextStyle(fontSize: 14)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              context.tr(en: 'Severity Classification', ar: 'تصنيف درجة الخطورة'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
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
                  value: _severity,
                  isExpanded: true,
                  items: [
                    for (final s in _severities)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(context.tr(en: s.en, ar: s.ar), style: const TextStyle(fontSize: 14)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _severity = v ?? _severity),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Counselor Confidential Notes
            Text(
              context.tr(en: 'Counselor Confidential Journal & Notes', ar: 'ملاحظات المرشد السرية وسجل التحقيق'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr(
                  en: 'Record interview notes, student reactions, and counselor observations...',
                  ar: 'سجل ملاحظات المقابلات، ردود فعل الطالب، وتوجيهات المرشد...',
                ),
                filled: true,
                fillColor: SchooKeepColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
              ),
            ),
            const SizedBox(height: 16),

            // Restorative Resolution Plan
            Text(
              context.tr(en: 'Restorative Resolution & Support Plan', ar: 'خطة الدعم والتسوية التربوية الإرشادية'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _planController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr(
                  en: 'Detail educational remediation, support for impacted student, parent meetings...',
                  ar: 'اصف خطوات المعالجة، دعم الطالب المتأثر، واجتماعات أولياء الأمور...',
                ),
                filled: true,
                fillColor: SchooKeepColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SchooKeepColors.border)),
              ),
            ),
            const SizedBox(height: 16),

            // Escalation Action Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: SchooKeepColors.warning),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _escalateToPrincipal,
                icon: const Icon(LucideIcons.shieldAlert, size: 18, color: SchooKeepColors.amberText),
                label: Text(
                  context.tr(en: 'Escalate to School Principal', ar: 'تصعيد القضية لمدير المدرسة'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.amberText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saving ? null : () => _saveChanges(markResolved: false),
                child: Text(
                  context.tr(en: 'Save Updates', ar: 'حفظ التحديثات'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saving ? null : () => _saveChanges(markResolved: true),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        context.tr(en: 'Mark Resolved', ar: 'إغلاق وتسوية'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
