import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/bias_incident.dart';
import '../../../data/repositories/bias_incident_repository.dart';

/// Master list inbox for guidance counselors to triage and resolve bias / racism incident reports.
class CounselorBiasIncidentsListScreen extends StatefulWidget {
  const CounselorBiasIncidentsListScreen({super.key});

  @override
  State<CounselorBiasIncidentsListScreen> createState() => _CounselorBiasIncidentsListScreenState();
}

class _CounselorBiasIncidentsListScreenState extends State<CounselorBiasIncidentsListScreen> {
  final BiasIncidentRepository _repo = sl<BiasIncidentRepository>();
  String _activeFilter = 'all';
  List<BiasIncident> _incidents = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.list();
      if (!mounted) return;
      setState(() {
        _incidents = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  ({String labelEn, String labelAr, Color bg, Color fg}) _statusStyle(String status) {
    return switch (status) {
      'submitted' => (
          labelEn: 'Submitted',
          labelAr: 'مُقدم جديد',
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFF92400E)
        ),
      'under_review' => (
          labelEn: 'Under Review',
          labelAr: 'قيد التحقيق',
          bg: const Color(0xFFDBEAFE),
          fg: const Color(0xFF1E40AF)
        ),
      'action_plan_active' => (
          labelEn: 'Action Plan Active',
          labelAr: 'خطة علاجية نشطة',
          bg: const Color(0xFFF3E8FF),
          fg: const Color(0xFF6B21A8)
        ),
      'resolved' => (
          labelEn: 'Resolved',
          labelAr: 'تمت التسوية',
          bg: const Color(0xFFD1FAE5),
          fg: const Color(0xFF065F46)
        ),
      _ => (
          labelEn: status,
          labelAr: status,
          bg: const Color(0xFFF3F4F6),
          fg: SchooKeepColors.textSecondary
        ),
    };
  }

  ({String labelEn, String labelAr, Color bg, Color fg}) _severityStyle(String severity) {
    return switch (severity) {
      'low' => (
          labelEn: 'Low Severity',
          labelAr: 'خطورة منخفضة',
          bg: const Color(0xFFF1F5F9),
          fg: SchooKeepColors.textSecondary
        ),
      'medium' => (
          labelEn: 'Medium Severity',
          labelAr: 'خطورة متوسطة',
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFF92400E)
        ),
      'high' => (
          labelEn: 'High Severity',
          labelAr: 'خطورة عالية',
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFF991B1B)
        ),
      'critical' => (
          labelEn: 'CRITICAL',
          labelAr: 'حرج للغاية',
          bg: const Color(0xFF991B1B),
          fg: Colors.white
        ),
      _ => (
          labelEn: severity,
          labelAr: severity,
          bg: const Color(0xFFF3F4F6),
          fg: SchooKeepColors.textSecondary
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _activeFilter == 'all'
        ? _incidents
        : _incidents.where((i) => i.status == _activeFilter).toList();

    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        title: context.tr(en: 'Anti-Bias Incident Hub', ar: 'مركز متابعة بلاغات التمييز والعنصرية'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _incidentCard(filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    final filters = [
      (id: 'all', en: 'All', ar: 'الكل'),
      (id: 'submitted', en: 'Submitted', ar: 'جديد'),
      (id: 'under_review', en: 'Under Review', ar: 'قيد التحقيق'),
      (id: 'action_plan_active', en: 'Active Plan', ar: 'خطة علاجية'),
      (id: 'resolved', en: 'Resolved', ar: 'مغلقة'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in filters) ...[
              GestureDetector(
                onTap: () => setState(() => _activeFilter = f.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _activeFilter == f.id ? SchooKeepColors.primary : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(999),
                    border: _activeFilter == f.id ? null : Border.all(color: SchooKeepColors.border),
                  ),
                  child: Text(
                    context.tr(en: f.en, ar: f.ar),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _activeFilter == f.id ? Colors.white : SchooKeepColors.textSecondary,
                    ),
                  ),
                ),
              ),
              if (f.id != filters.last.id) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.shieldCheck, size: 48, color: SchooKeepColors.accent),
            const SizedBox(height: 16),
            Text(
              context.tr(en: 'No Anti-Bias Incidents Found', ar: 'لا توجد بلاغات تمييز مسجلة'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                en: 'Reports submitted by teachers or bus drivers will appear here for counselor review.',
                ar: 'ستظهر التقارير المستقبلة من المعلمين والسائقين هنا لمراجعة المرشد الطلابي.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _incidentCard(BiasIncident item) {
    final status = _statusStyle(item.status);
    final severity = _severityStyle(item.severity);
    final reporterBadge = item.reporterRole == 'bus_driver'
        ? (labelEn: 'Bus Driver Report', labelAr: 'بلاغ سائق حافلة', icon: LucideIcons.bus)
        : (labelEn: 'Teacher Report', labelAr: 'بلاغ معلم', icon: LucideIcons.userCheck);

    return SchooKeepCard(
      padding: const EdgeInsets.all(16),
      onTap: () async {
        await context.push('/counselor/bias-incidents/${item.id}');
        _loadData();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: Text(
                  _initials(item.studentName),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(reporterBadge.icon, size: 12, color: SchooKeepColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          context.tr(en: reporterBadge.labelEn, ar: reporterBadge.labelAr),
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: status.bg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  context.tr(en: status.labelEn, ar: status.labelAr),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: status.fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: severity.bg, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  context.tr(en: severity.labelEn, ar: severity.labelAr),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: severity.fg),
                ),
              ),
              Text(
                'Location: ${item.location.toUpperCase()}',
                style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
