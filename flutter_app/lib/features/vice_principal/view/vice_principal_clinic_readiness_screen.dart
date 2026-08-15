import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../cubit/vice_principal_clinic_readiness_cubit.dart';

/// Ported from `VicePrincipalClinicReadiness.tsx`, wired to
/// `GET /analytics/clinic-readiness` via [VicePrincipalClinicReadinessCubit].
/// Renders the live readiness indicators (document compliance, medications
/// needing review, low supply, expiring documents), a forward-to-Principal CTA
/// and an info footer.
class VicePrincipalClinicReadinessScreen extends StatelessWidget {
  const VicePrincipalClinicReadinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          VicePrincipalClinicReadinessCubit(sl<AnalyticsRepository>()),
      child: const _ClinicReadinessView(),
    );
  }
}

class _ClinicReadinessView extends StatelessWidget {
  const _ClinicReadinessView();

  static int _asInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

  static num _asNum(Object? v) =>
      v is num ? v : num.tryParse('${v ?? ''}') ?? 0;

  void _reload(BuildContext context) =>
      context.read<VicePrincipalClinicReadinessCubit>().load();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Clinic Readiness Report',
        onBack: () => context.safeBack(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: BlocBuilder<VicePrincipalClinicReadinessCubit,
          DataState<Map<String, dynamic>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _error(context, message),
            DataLoaded(:final data) => _content(context, data),
          };
        },
      ),
    );
  }

  Widget _content(BuildContext context, Map<String, dynamic> data) {
    final total = _asInt(data['total_students']);
    final approved = _asInt(data['students_with_approved_document']);
    final pct = _asNum(data['students_with_approved_document_pct']);
    final needsReview = _asInt(data['medications_needing_physician_review']);
    final lowSupply = _asInt(data['low_supply_medications']);
    final expiringDocs = _asInt(data['expiring_documents']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _complianceCard(approved, total, pct),
        const SizedBox(height: 16),
        _statusSummary(needsReview, lowSupply, expiringDocs),
        const SizedBox(height: 16),
        _sectionHeader(LucideIcons.activity, 'Readiness Indicators'),
        const SizedBox(height: 12),
        SchooKeepCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _indicatorRow(LucideIcons.users, 'Total students',
                  '$total', SchooKeepColors.textPrimary),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              _indicatorRow(LucideIcons.fileText,
                  'Students with approved document', '$approved',
                  SchooKeepColors.accent),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              _indicatorRow(LucideIcons.stethoscope,
                  'Medications needing physician review', '$needsReview',
                  needsReview > 0
                      ? SchooKeepColors.error
                      : SchooKeepColors.textPrimary),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              _indicatorRow(LucideIcons.package,
                  'Low supply medications', '$lowSupply',
                  lowSupply > 0
                      ? SchooKeepColors.warning
                      : SchooKeepColors.textPrimary),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              _indicatorRow(LucideIcons.calendar,
                  'Expiring documents', '$expiringDocs',
                  expiringDocs > 0
                      ? SchooKeepColors.warning
                      : SchooKeepColors.textPrimary),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SchooKeepButton(
          label: 'Forward to Principal',
          icon: LucideIcons.mail,
          onPressed: () => context.go(
              '/vice-principal/messages?compose=principal&subject=Clinic Readiness Report'),
        ),
        const SizedBox(height: 16),
        _infoFooter(),
      ],
    );
  }

  Widget _complianceCard(int approved, int total, num pct) {
    final pctLabel = '${pct.toStringAsFixed(0)}%';
    return SchooKeepCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(
              pctLabel,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: SchooKeepColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Document compliance',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Text('$approved of $total students have approved documents',
                    style: const TextStyle(
                        fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusSummary(int needsReview, int lowSupply, int expiringDocs) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Summary',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusChip('$needsReview Needs Review', const Color(0xFFFEE2E2),
                  SchooKeepColors.error, SchooKeepColors.error),
              _statusChip('$lowSupply Low Supply', SchooKeepColors.amberChipBg,
                  SchooKeepColors.warning, SchooKeepColors.amberText),
              _statusChip('$expiringDocs Expiring Docs',
                  const Color(0xFFDBEAFE), SchooKeepColors.primary,
                  const Color(0xFF1E40AF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color bg, Color border, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: text)),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: SchooKeepColors.textPrimary),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: SchooKeepColors.textPrimary)),
      ],
    );
  }

  Widget _indicatorRow(
      IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: SchooKeepColors.textPrimary)),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _infoFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8)),
      child: const Text(
        'This report is generated from live clinic data. As Vice Principal, you can review and forward it to the Principal for budgetary and administrative action.',
        style: TextStyle(
            fontSize: 12, height: 1.5, color: SchooKeepColors.textSecondary),
      ),
    );
  }

  Widget _error(BuildContext context, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.error),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertCircle,
                  size: 20, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 13,
                        color: SchooKeepColors.error,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SchooKeepButton(
            label: 'Retry',
            fullWidth: false,
            onPressed: () => _reload(context)),
      ],
    );
  }
}
