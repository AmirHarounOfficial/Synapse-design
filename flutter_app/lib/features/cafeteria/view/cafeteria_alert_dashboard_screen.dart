import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/cafeteria_alert.dart';
import '../../../data/models/halal_certification.dart';
import '../../../data/repositories/cafeteria_repository.dart';
import '../cubit/cafeteria_alert_list_cubit.dart';
import '../cubit/halal_certification_cubit.dart';
import '../widgets/halal_badge.dart';

/// Ported from `CafeteriaAlertDashboard.tsx`, now wired to the API. Today's
/// allergen-alert list (`GET /cafeteria-alerts`) with a Halal status banner
/// (`GET /halal-certifications`), a compliance acknowledgment block, and
/// per-alert cards whose action acknowledges the alert (`POST .../acknowledge`).
class CafeteriaAlertDashboardScreen extends StatelessWidget {
  const CafeteriaAlertDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CafeteriaAlertListCubit(sl<CafeteriaRepository>())),
        BlocProvider(create: (_) => HalalCertificationCubit(sl<CafeteriaRepository>())),
      ],
      child: const _CafeteriaAlertDashboardView(),
    );
  }
}

class _CafeteriaAlertDashboardView extends StatefulWidget {
  const _CafeteriaAlertDashboardView();

  @override
  State<_CafeteriaAlertDashboardView> createState() => _CafeteriaAlertDashboardViewState();
}

class _CafeteriaAlertDashboardViewState extends State<_CafeteriaAlertDashboardView> {
  bool _isAcknowledged = false;
  String? _acknowledgedAt;
  bool _checkedAllergens = false;
  bool _checkedHalal = false;

  String _nowTime() {
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  void _handleAcknowledge() {
    setState(() {
      _acknowledgedAt = _nowTime();
      _isAcknowledged = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr(en: 'Allergens & Halal compliance confirmed!', ar: 'تم تسجيل تأكيد الامتثال بنجاح'))),
    );
  }

  Future<void> _handleDelivered(CafeteriaAlert alert) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<CafeteriaAlertListCubit>().acknowledge(alert.id);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok
            ? context.tr(en: 'Meal delivery confirmed.', ar: 'تم تسجيل تسليم الوجبة')
            : context.tr(en: 'Could not confirm. Please try again.', ar: 'تعذّر التأكيد. حاول مرة أخرى')),
      ),
    );
  }

  ({Color bg, Color fg, Color border}) _severityColors(CafeteriaAlert a) {
    if (a.isHalalIssue || a.severity == 'critical') {
      return (bg: const Color(0xFFFEE2E2), fg: const Color(0xFF991B1B), border: const Color(0xFFDC2626));
    }
    if (a.severity == 'warning') {
      return (bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E), border: const Color(0xFFF59E0B));
    }
    return (bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1E40AF), border: const Color(0xFF2563EB));
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final canAcknowledge = _checkedAllergens && _checkedHalal;
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final todaysDate = '${months[now.month - 1]} ${now.day}, ${now.year}';

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRTL ? 'قيود الوجبات المدرسية لليوم' : "Today's Meal Restrictions",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
            ),
            Text(todaysDate, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          ],
        ),
        actions: [
          Tooltip(
            message: context.tr(en: 'Live alerts', ar: 'تنبيهات مباشرة'),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => context.go('/cafeteria/realtime-alert'),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(LucideIcons.radio, size: 24, color: SchooKeepColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _halalBannerSection(isRTL),
            const SizedBox(height: 16),
            _isAcknowledged ? _acknowledgedBanner(isRTL) : _acknowledgeBlock(isRTL, canAcknowledge),
            const SizedBox(height: 16),
            _alertsSection(isRTL),
          ],
        ),
      ),
    );
  }

  Widget _alertsSection(bool isRTL) {
    return BlocBuilder<CafeteriaAlertListCubit, DataState<List<CafeteriaAlert>>>(
      builder: (context, state) {
        return switch (state) {
          DataLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
          DataError(:final message) => _errorView(message, () => context.read<CafeteriaAlertListCubit>().load()),
          DataLoaded(:final data) => _alertsList(isRTL, data),
        };
      },
    );
  }

  Widget _alertsList(bool isRTL, List<CafeteriaAlert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL
              ? 'الطلاب الذين لديهم قيود غذائية (${alerts.length})'
              : 'Students with Restrictions (${alerts.length})',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        if (alerts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                isRTL ? 'لا توجد قيود غذائية لليوم' : 'No meal restrictions today',
                style: const TextStyle(color: SchooKeepColors.textSecondary),
              ),
            ),
          )
        else
          for (final alert in alerts) ...[
            _alertCard(isRTL, alert),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _errorView(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(label: 'Retry', fullWidth: false, onPressed: onRetry),
          ],
        ),
      ),
    );
  }

  Widget _halalBannerSection(bool isRTL) {
    return BlocBuilder<HalalCertificationCubit, DataState<List<HalalCertification>>>(
      builder: (context, state) {
        final cert = switch (state) {
          DataLoaded(:final data) => data.isNotEmpty ? data.first : null,
          _ => null,
        };
        return _halalBanner(isRTL, cert);
      },
    );
  }

  Widget _halalBanner(bool isRTL, HalalCertification? cert) {
    final expLabel = cert?.expiryDate;
    return AccentCard(
      background: SchooKeepColors.surface,
      accentColor: SchooKeepColors.halalGreen,
      accentWidth: 4,
      radius: 12,
      borderColor: SchooKeepColors.border,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'حالة التوافق مع الشريعة الإسلامية' : 'Halal Certification Status',
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  isRTL ? 'جميع الوجبات المقدمة اليوم معتمدة وحلال ✓' : 'All meals today are Halal-certified ✓',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.halalGreen),
                ),
                const SizedBox(height: 2),
                Text(
                  expLabel == null
                      ? (isRTL ? 'صلاحية الشهادة: —' : 'Certificate Exp: —')
                      : (isRTL ? 'صلاحية الشهادة: $expLabel' : 'Certificate Exp: $expLabel'),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const HalalBadge(),
        ],
      ),
    );
  }

  Widget _acknowledgeBlock(bool isRTL, bool canAcknowledge) {
    return AccentCard(
      background: SchooKeepColors.amberBg,
      accentColor: SchooKeepColors.warning,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 24, color: SchooKeepColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isRTL
                      ? 'يرجى تأكيد مراجعة قائمة المواد المسببة للحساسية لليوم والامتثال لمتطلبات الحلال قبل بدء تقديم الطعام.'
                      : "Please confirm review of today's allergen list and Halal-compliance before starting meal service.",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFFDE68A)),
          const SizedBox(height: 12),
          _checkRow(
            checked: _checkedAllergens,
            onChanged: (v) => setState(() => _checkedAllergens = v),
            label: isRTL ? 'أؤكد مراجعة قائمة الحساسية لليوم' : "I have reviewed today's allergen list",
          ),
          const SizedBox(height: 4),
          _checkRow(
            checked: _checkedHalal,
            onChanged: (v) => setState(() => _checkedHalal = v),
            label: isRTL ? 'أؤكد أن جميع الوجبات المقدمة اليوم حلال معتمدة' : 'I confirm all meals today are Halal-certified',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: canAcknowledge ? SchooKeepColors.warning : const Color(0xFFFDE68A),
                disabledBackgroundColor: const Color(0xFFFDE68A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: canAcknowledge ? _handleAcknowledge : null,
              child: Text(
                isRTL ? 'تأكيد وقبول الالتزام' : 'Confirm Compliance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: canAcknowledge ? Colors.white : const Color(0xFFFCD34D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow({required bool checked, required ValueChanged<bool> onChanged, required String label}) {
    return InkWell(
      onTap: () => onChanged(!checked),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: checked,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: SchooKeepColors.warning,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.amberText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _acknowledgedBanner(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.greenChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.accent),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.check, size: 20, color: SchooKeepColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isRTL
                  ? 'تم تأكيد وقبول المراجعة في تمام الساعة $_acknowledgedAt ✓'
                  : 'List & Halal compliance acknowledged at $_acknowledgedAt ✓',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.greenChipText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard(bool isRTL, CafeteriaAlert alert) {
    if (alert.acknowledged) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.accent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
              child: const Icon(LucideIcons.check, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                  Text(
                    isRTL ? 'تم التأكيد' : 'Acknowledged',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final colors = _severityColors(alert);
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go('/cafeteria/detail/${alert.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(alert.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                    ),
                    const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
                  ],
                ),
                if (alert.message.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(alert.message,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.fg)),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: SchooKeepColors.greenChipBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.check, size: 16, color: SchooKeepColors.greenChipText),
                      const SizedBox(width: 8),
                      Text(isRTL ? 'وجبة خاصة مطلوبة' : 'Special meal required',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.greenChipText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.physicianTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _handleDelivered(alert),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.check, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(isRTL ? 'تأكيد تسليم الوجبة للطالب' : 'Meal Delivered',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
