import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../cubit/physician_dashboard_cubit.dart';

/// Ported from `PhysicianDashboard.tsx`, now wired to the API. Pending protocol
/// approvals come from `GET /medications?status=pending` (requires_physician),
/// escalations from emergency `GET /clinic-visits` (see
/// [PhysicianDashboardCubit]). The weekly schedule, duty toggle and reports
/// awaiting co-signature have no API source and stay static.
class PhysicianDashboardScreen extends StatelessWidget {
  const PhysicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhysicianDashboardCubit(
        sl<MedicationRepository>(),
        sl<ClinicRepository>(),
        sl<StudentRepository>(),
      ),
      child: const _PhysicianDashboardView(),
    );
  }
}

class _PhysicianDashboardView extends StatefulWidget {
  const _PhysicianDashboardView();

  @override
  State<_PhysicianDashboardView> createState() => _PhysicianDashboardViewState();
}

class _PhysicianDashboardViewState extends State<_PhysicianDashboardView> {
  bool _isOnSite = true; // no API source — local duty toggle

  static const _activeDays = [1, 2, 4]; // no API source — Monday, Tuesday, Thursday

  void _reload() => context.read<PhysicianDashboardCubit>().load();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    // no API source — physician name/profile are static
    final physicianName = isRTL ? 'أحمد الأنصاري' : 'Amina Al-Hashimi';

    final daysOfWeek = isRTL
        ? ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س']
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // no API source — reports awaiting co-signature have no backing endpoint
    final pendingReports = [
      (id: '1', title: 'Monthly Clinical Immunization Summary', dateRange: '01/05/2026 - 31/05/2026', nurse: 'Nurse Smith RN-4521'),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: _appBar(isRTL, physicianName),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: BlocBuilder<PhysicianDashboardCubit, DataState<PhysicianDashboardData>>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _scheduleCard(isRTL, daysOfWeek),
              const SizedBox(height: 16),
              ...switch (state) {
                DataLoading() => const [
                    SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  ],
                DataError(:final message) => [_errorView(message)],
                DataLoaded(:final data) => [
                    _escalationsSection(isRTL, data.escalations),
                    const SizedBox(height: 16),
                    _protocolsSection(isRTL, data.pendingProtocols),
                  ],
              },
              const SizedBox(height: 16),
              _reportsSection(isRTL, pendingReports),
            ],
          );
        },
      ),
    );
  }

  Widget _errorView(String message) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: SchooKeepColors.textSecondary)),
              const SizedBox(height: 16),
              SchooKeepButton(label: 'Retry', fullWidth: false, onPressed: _reload),
            ],
          ),
        ),
      ),
    );
  }

  SchooKeepAppBar _appBar(bool isRTL, String physicianName) {
    return SchooKeepAppBar(
      titleWidget: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/physician/settings'),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SchooKeepColors.physicianTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(isRTL ? 'د' : 'DR',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isRTL ? 'د. $physicianName' : 'Dr. $physicianName',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
              Text(isRTL ? 'طبيب المدرسة المناوب' : 'School Physician on Duty',
                  style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: () => context.go('/physician/settings'),
          borderRadius: BorderRadius.circular(999),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(LucideIcons.user, size: 20, color: SchooKeepColors.textSecondary),
          ),
        ),
      ],
    );
  }

  // no API source — weekly on-site schedule is not backed by an endpoint
  Widget _scheduleCard(bool isRTL, List<String> daysOfWeek) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isRTL ? 'جدول الدوام الأسبوعي' : 'Weekly On-Site Schedule',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
              GestureDetector(
                onTap: () => context.go('/physician/schedule'),
                child: Text(isRTL ? 'تعديل الجدول' : 'Manage Schedule',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.physicianTeal)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var idx = 0; idx < daysOfWeek.length; idx++)
                _dayChip(daysOfWeek[idx], active: _activeDays.contains(idx), today: idx == 1),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SchooKeepColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _isOnSite ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isOnSite
                        ? (isRTL ? 'متواجد بالمدرسة · حتى 3:00 م' : 'On-site · Until 3:00 PM')
                        : (isRTL ? 'تحت الطلب: +971 50 123 4567' : 'On-call: +971 50 123 4567'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _isOnSite = !_isOnSite),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SchooKeepColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: SchooKeepColors.border),
                    ),
                    child: Text(isRTL ? 'تغيير الحالة' : 'Toggle State',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayChip(String label, {required bool active, required bool today}) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? SchooKeepColors.physicianTeal : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: today ? Border.all(color: SchooKeepColors.physicianTeal, width: 2) : null,
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : SchooKeepColors.textSecondary,
          )),
    );
  }

  Widget _escalationsSection(bool isRTL, List<Escalation> escalations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.error),
                const SizedBox(width: 6),
                Text(isRTL ? 'الحالات الحرجة والتصعيدات' : 'Emergency Escalations',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
              ],
            ),
            _countBadge('${escalations.length}', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
          ],
        ),
        const SizedBox(height: 10),
        if (escalations.isEmpty)
          _emptyCard(isRTL ? 'لا توجد تصعيدات نشطة حالياً' : 'No active clinical escalations.')
        else
          for (final esc in escalations) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SchooKeepColors.error, width: 2),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go('/physician/escalations'),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(esc.studentName,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: SchooKeepColors.error, borderRadius: BorderRadius.circular(999)),
                                  child: Text(isRTL ? 'حالة حرجة' : 'CRITICAL',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ],
                            ),
                            if (esc.grade.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(esc.grade, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                            ],
                            const SizedBox(height: 4),
                            Text(esc.issue,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.error)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Text(_timeAgo(isRTL, esc.at),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                          ),
                          const SizedBox(height: 6),
                          const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _protocolsSection(bool isRTL, List<PendingProtocol> protocols) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isRTL ? 'طلبات الموافقة على الأدوية' : 'Pending Protocol Approvals',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
            _countBadge('${protocols.length}',
                SchooKeepColors.physicianTeal.withValues(alpha: 0.1), SchooKeepColors.physicianTeal),
          ],
        ),
        const SizedBox(height: 10),
        if (protocols.isEmpty)
          _emptyCheckCard(isRTL ? 'لا توجد بروتوكولات بانتظار المراجعة' : 'No protocols pending review.')
        else
          for (final p in protocols) ...[
            SchooKeepCard(
              onTap: () => context.go('/physician/protocols/${p.medication.id}'),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.studentName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(text: '${p.medicationLabel}${p.dose.isEmpty ? '' : ' · '}'),
                            TextSpan(text: p.dose, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ]),
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                        ),
                        if (p.proposedBy.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(isRTL ? 'مقدم من: ${p.proposedBy}' : 'Proposed by: ${p.proposedBy}',
                              style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SchooKeepColors.physicianTeal.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(isRTL ? 'مراجعة' : 'Review',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
                  ),
                  const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  // no API source — co-signature reports have no backing endpoint
  Widget _reportsSection(
    bool isRTL,
    List<({String id, String title, String dateRange, String nurse})> reports,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isRTL ? 'تقارير بانتظار التوقيع المشترك' : 'Reports Awaiting Co-Signature',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 10),
        if (reports.isEmpty)
          _emptyCard(isRTL ? 'لا توجد تقارير بانتظار التوقيع' : 'No reports pending co-signature.')
        else
          for (final rep in reports) ...[
            SchooKeepCard(
              onTap: () => context.go('/physician/co-sign/${rep.id}'),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.fileText, size: 20, color: SchooKeepColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rep.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(rep.dateRange, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(isRTL ? 'إعداد الممرضة: ${rep.nurse}' : 'Nurse: ${rep.nurse}',
                            style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  /// Relative "x min/hr ago" label from a timestamp.
  static String _timeAgo(bool isRTL, DateTime? dt) {
    if (dt == null) return isRTL ? 'الآن' : 'now';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return isRTL ? 'الآن' : 'now';
    if (diff.inMinutes < 60) {
      return isRTL ? 'قبل ${diff.inMinutes} د' : '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return isRTL ? 'قبل ${diff.inHours} س' : '${diff.inHours} hr ago';
    }
    return isRTL ? 'قبل ${diff.inDays} ي' : '${diff.inDays} d ago';
  }

  Widget _countBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
    );
  }

  Widget _emptyCheckCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.checkCircle, size: 32, color: Color(0xFF10B981)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }
}
