import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../cubit/student_promotion_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `PrincipalStudentPromotion.tsx`, wired to `POST /students/promote`
/// via [StudentPromotionCubit]. A 3-step destructive wizard: review → type-to-
/// confirm → execute. Execution calls the cubit and, once done, replaces the
/// wizard with the real promotion summary (promoted / skipped counts + details).
class PrincipalStudentPromotionScreen extends StatelessWidget {
  const PrincipalStudentPromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentPromotionCubit(sl<AnalyticsRepository>()),
      child: const _PrincipalStudentPromotionView(),
    );
  }
}

class _PrincipalStudentPromotionView extends StatefulWidget {
  const _PrincipalStudentPromotionView();

  @override
  State<_PrincipalStudentPromotionView> createState() => _PrincipalStudentPromotionViewState();
}

class _PrincipalStudentPromotionViewState extends State<_PrincipalStudentPromotionView> {
  int _step = 1;
  final _confirmation = TextEditingController();

  static const _requiredText = 'PROMOTE LAKEWOOD ELEMENTARY';
  static const _newYearStart = 'September 2, 2026';

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _handleExecute() async {
    if (_confirmation.text != _requiredText) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('This action cannot be undone. Execute year-end promotion?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<StudentPromotionCubit>().promote();
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: 'Year-End Promotion',
      onBack: () => context.safeBack(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<StudentPromotionCubit, StudentPromotionState>(
          builder: (context, state) {
            if (state is StudentPromotionDone) {
              return _resultView(state.summary);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _warningBanner(),
                const SizedBox(height: 16),
                _progressIndicator(),
                const SizedBox(height: 16),
                _step1Card(),
                if (_step >= 2) ...[
                  const SizedBox(height: 16),
                  _step2Card(),
                ],
                if (_step >= 3) ...[
                  const SizedBox(height: 16),
                  _step3Card(state),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _warningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠ Critical System Action',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                SizedBox(height: 4),
                Text(
                  'This action promotes all students one grade level and archives graduating students. It cannot be undone.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressIndicator() {
    return Row(
      children: [
        for (int s = 1; s <= 3; s++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: s <= _step ? SchooKeepColors.primary : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (s < 3) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _stepBadge(int n, Color bg) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text('$n', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _step1Card() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stepBadge(1, _step > 1 ? SchooKeepColors.accent : SchooKeepColors.primary),
              const SizedBox(width: 8),
              const Text('Review Summary',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Every student in your school with a numeric grade will be advanced one level. Students on a non-numeric grade (e.g. KG, Reception) are left unchanged and reported as skipped. Exact counts are confirmed after you execute.',
            style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.info, size: 16, color: SchooKeepColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: 'New school year start date: ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                      TextSpan(text: _newYearStart, style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF))),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          if (_step == 1) ...[
            const SizedBox(height: 16),
            _primaryButton('Confirm & Continue', () => setState(() => _step = 2)),
          ],
        ],
      ),
    );
  }

  Widget _step2Card() {
    final matches = _confirmation.text == _requiredText;
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stepBadge(2, _step > 2 ? SchooKeepColors.accent : SchooKeepColors.primary),
              const SizedBox(width: 8),
              const Text('Type Confirmation',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Type "$_requiredText" to unlock',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: TextField(
              controller: _confirmation,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: _requiredText,
                hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: SchooKeepColors.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
                ),
              ),
            ),
          ),
          if (matches) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SchooKeepColors.accent),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.accent),
                  SizedBox(width: 8),
                  Text('Confirmation text matches',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF065F46))),
                ],
              ),
            ),
          ],
          if (_step == 2 && matches) ...[
            const SizedBox(height: 16),
            _primaryButton('Continue to Final Step', () => setState(() => _step = 3)),
          ],
        ],
      ),
    );
  }

  Widget _step3Card(StudentPromotionState state) {
    final submitting = state is StudentPromotionSubmitting;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.error, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stepBadge(3, SchooKeepColors.error),
              const SizedBox(width: 8),
              const Text('Final Confirmation',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.error),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.error),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Final Warning',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
                      SizedBox(height: 4),
                      Text(
                        'This action is irreversible. All students will be promoted immediately. Graduating students will be permanently archived.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF991B1B), height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state is StudentPromotionError) ...[
            const SizedBox(height: 12),
            Text(state.message,
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.error, fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.error,
                disabledBackgroundColor: SchooKeepColors.error.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: submitting ? null : _handleExecute,
              icon: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(LucideIcons.alertTriangle, size: 20, color: Colors.white),
              label: Text(submitting ? 'Promoting…' : 'Execute Promotion',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultView(Map<String, dynamic> summary) {
    final promotedCount = (summary['promoted_count'] as num?)?.toInt() ?? 0;
    final skippedCount = (summary['skipped_count'] as num?)?.toInt() ?? 0;
    final details = (summary['details'] as Map?) ?? const {};
    final promoted = (details['promoted'] as List?) ?? const [];
    final skipped = (details['skipped'] as List?) ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.accent),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.accent),
              SizedBox(width: 12),
              Expanded(
                child: Text('Year-end promotion complete.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF065F46))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _resultStat('Promoted', promotedCount, SchooKeepColors.accent, LucideIcons.arrowUpCircle)),
            const SizedBox(width: 12),
            Expanded(child: _resultStat('Skipped', skippedCount, SchooKeepColors.warning, LucideIcons.minusCircle)),
          ],
        ),
        if (promoted.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailCard('Promoted students', [
            for (final p in promoted)
              _detailRow(
                (p is Map ? p['name']?.toString() : null) ?? 'Student',
                (p is Map) ? 'Grade ${p['from_grade']} → ${p['to_grade']}' : '',
              ),
          ]),
        ],
        if (skipped.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailCard('Skipped students', [
            for (final s in skipped)
              _detailRow(
                (s is Map ? s['name']?.toString() : null) ?? 'Student',
                (s is Map) ? 'Grade ${s['grade'] ?? '—'} · ${_reasonLabel(s['reason']?.toString())}' : '',
              ),
          ]),
        ],
        const SizedBox(height: 16),
        _primaryButton('Done', () => context.go('/principal/home')),
      ],
    );
  }

  Widget _resultStat(String label, int value, Color color, IconData icon) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _detailCard(String title, List<Widget> rows) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 8),
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String name, String meta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
          Text(meta, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  static String _reasonLabel(String? reason) {
    switch (reason) {
      case 'non_numeric_grade':
        return 'Non-numeric grade';
      default:
        return reason == null || reason.isEmpty ? 'Skipped' : reason;
    }
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: SchooKeepColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
      ),
    );
  }
}
