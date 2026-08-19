import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../cubit/student_promotion_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

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
        content: Text(context.tr(
          en: 'This action cannot be undone. Execute year-end promotion?',
          ar: 'لا يمكن التراجع عن هذا الإجراء إطلاقاً. هل ترغب في ترفيع السجلات الطلابية بنهاية العام؟',
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr(en: 'Cancel', ar: 'إلغاء'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.tr(en: 'OK', ar: 'موافق'))),
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
      title: context.tr(en: 'Year-End Promotion', ar: 'ترفيع السجلات الصحية الطلابية للعام الجديد'),
      onBack: () => context.safeBack(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<StudentPromotionCubit, StudentPromotionState>(
          builder: (context, state) {
            if (state is StudentPromotionDone) {
              return _resultView(context, state.summary);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _warningBanner(context),
                const SizedBox(height: 16),
                _progressIndicator(),
                const SizedBox(height: 16),
                _step1Card(context),
                if (_step >= 2) ...[
                  const SizedBox(height: 16),
                  _step2Card(context),
                ],
                if (_step >= 3) ...[
                  const SizedBox(height: 16),
                  _step3Card(context, state),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _warningBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: '⚠ Critical System Action', ar: '⚠ إجراء نظام حرج'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    en: 'This action promotes all students one grade level and archives graduating students. It cannot be undone.',
                    ar: 'يقوم هذا الإجراء بنقل جميع الطلاب إلى الصف الدراسي التالي وأرشفة الخريجين. لا يمكن التراجع عنه بعد ذلك.',
                  ),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5),
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

  Widget _step1Card(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stepBadge(1, _step > 1 ? SchooKeepColors.accent : SchooKeepColors.primary),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Review Summary', ar: 'مراجعة الملخص العام'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
              en: 'Every student in your school with a numeric grade will be advanced one level. Students on a non-numeric grade are left unchanged and reported as skipped.',
              ar: 'سيتم ترفيع كل طالب في المدرسة لديه صف دراسي رقمي إلى المستوى التالي. أما الطلاب في الصفوف غير الرقمية فيتم استثناؤهم.',
            ),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.info, size: 16, color: SchooKeepColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: context.tr(en: 'New school year start date: ', ar: 'تاريخ بدء العام الدراسي الجديد: '),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                      ),
                      const TextSpan(text: _newYearStart, style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF))),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          if (_step == 1) ...[
            const SizedBox(height: 16),
            _primaryButton(context.tr(en: 'Confirm & Continue', ar: 'تأكيد والمتابعة'), () => setState(() => _step = 2)),
          ],
        ],
      ),
    );
  }

  Widget _step2Card(BuildContext context) {
    final matches = _confirmation.text == _requiredText;
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stepBadge(2, _step > 2 ? SchooKeepColors.accent : SchooKeepColors.primary),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Type Confirmation', ar: 'إدخال نص التأكيد'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(en: 'Type "$_requiredText" to unlock', ar: 'اكتب "$_requiredText" لتفعيل الترفيع'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
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
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    context.tr(en: 'Confirmation text matches', ar: 'نص التأكيد متطابق ✓'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF065F46)),
                  ),
                ],
              ),
            ),
          ],
          if (_step == 2 && matches) ...[
            const SizedBox(height: 16),
            _primaryButton(context.tr(en: 'Continue to Final Step', ar: 'الانتقال للخطوة الأخيرة'), () => setState(() => _step = 3)),
          ],
        ],
      ),
    );
  }

  Widget _step3Card(BuildContext context, StudentPromotionState state) {
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
              Text(
                context.tr(en: 'Final Confirmation', ar: 'التأكيد النهائي للتنفيذ'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(en: 'Final Warning', ar: 'تحذير نهائي'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                          en: 'This action is irreversible. All students will be promoted immediately. Graduating students will be permanently archived.',
                          ar: 'هذا الإجراء نهائي وغير قابل للإلغاء. سيتم ترفيع كافة الطلاب فوراً وأرشفة الخريجين.',
                        ),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B), height: 1.5),
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
              label: Text(
                submitting
                    ? context.tr(en: 'Promoting…', ar: 'جاري الترفيع...')
                    : context.tr(en: 'Execute Promotion', ar: 'تنفيذ الترفيع للعام الجديد'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultView(BuildContext context, Map<String, dynamic> summary) {
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr(en: 'Year-end promotion complete.', ar: 'اكتملت عملية ترفيع السجلات بنجاح.'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _resultStat(context.tr(en: 'Promoted', ar: 'تم ترفيعهم'), promotedCount, SchooKeepColors.accent, LucideIcons.arrowUpCircle)),
            const SizedBox(width: 12),
            Expanded(child: _resultStat(context.tr(en: 'Skipped', ar: 'تم استثناؤهم'), skippedCount, SchooKeepColors.warning, LucideIcons.minusCircle)),
          ],
        ),
        if (promoted.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailCard(context.tr(en: 'Promoted students', ar: 'الطلاب الذي تم ترفيعهم'), [
            for (final p in promoted)
              _detailRow(
                (p is Map ? p['name']?.toString() : null) ?? 'Student',
                (p is Map) ? context.tr(en: 'Grade ${p['from_grade']} → ${p['to_grade']}', ar: 'الصف ${p['from_grade']} ← ${p['to_grade']}') : '',
              ),
          ]),
        ],
        if (skipped.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailCard(context.tr(en: 'Skipped students', ar: 'الطلاب المستثنون'), [
            for (final s in skipped)
              _detailRow(
                (s is Map ? s['name']?.toString() : null) ?? 'Student',
                (s is Map) ? '${context.tr(en: 'Grade', ar: 'الصف')} ${s['grade'] ?? '—'} · ${_reasonLabel(context, s['reason']?.toString())}' : '',
              ),
          ]),
        ],
        const SizedBox(height: 16),
        _primaryButton(context.tr(en: 'Done', ar: 'تم'), () => context.go('/principal/home')),
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

  static String _reasonLabel(BuildContext context, String? reason) {
    switch (reason) {
      case 'non_numeric_grade':
        return context.tr(en: 'Non-numeric grade', ar: 'صف غير رقمي');
      default:
        return reason == null || reason.isEmpty ? context.tr(en: 'Skipped', ar: 'مستثنى') : reason;
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
