import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `TeacherWeatherRestriction.tsx`. Active advisory banner, the
/// list of indoor-restricted students, and a confirm-acknowledgment CTA that
/// locks into a confirmed state with a timestamp. Localized in EN & AR.
class TeacherWeatherRestrictionScreen extends StatefulWidget {
  const TeacherWeatherRestrictionScreen({super.key});

  @override
  State<TeacherWeatherRestrictionScreen> createState() => _TeacherWeatherRestrictionScreenState();
}

class _TeacherWeatherRestrictionScreenState extends State<TeacherWeatherRestrictionScreen> {
  bool _isConfirmed = false;
  String? _confirmedAt;

  final _restrictedStudents = const [
    (id: '1', name: 'Sarah Williams', initials: 'SW'),
    (id: '2', name: 'Alex Martinez', initials: 'AM'),
    (id: '3', name: 'Jordan Lee', initials: 'JL'),
  ];

  void _confirm(bool isRTL) {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? (isRTL ? 'ص' : 'AM') : (isRTL ? 'م' : 'PM');
    setState(() {
      _confirmedAt = '${h.toString().padLeft(2, '0')}:$m $period';
      _isConfirmed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        title: context.tr(en: 'Weather Restriction', ar: 'قيود الطقس والأنشطة الخارجية'),
      ),
      bottomBar: _confirmBar(isRTL),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _alertBanner(context),
            const SizedBox(height: 16),
            _instructions(context),
            const SizedBox(height: 16),
            for (final s in _restrictedStudents) ...[
              _studentCard(s.name, s.initials),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            if (!_isConfirmed) _pendingAck(context) else _confirmedAck(context),
          ],
        ),
      ),
    );
  }

  Widget _alertBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 24, color: SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Active Weather Advisory', ar: 'تنبيه جوي نشط'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    en: 'AQI Advisory — respiratory sensitivity',
                    ar: 'تنبيه مؤشر جودة الهواء — حساسية الجهاز التنفسي',
                  ),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.amberText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Text(
        context.tr(
          en: 'The following students must remain indoors during this advisory:',
          ar: 'يجب أن يبقى الطلاب التالون داخل المبنى أثناء هذا التنبيه الجوي:',
        ),
        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
      ),
    );
  }

  Widget _studentCard(String name, String initials) {
    return AccentCard(
      background: SchooKeepColors.surface,
      accentColor: SchooKeepColors.warning,
      accentWidth: 3,
      radius: 12,
      padding: const EdgeInsets.all(12),
      borderColor: SchooKeepColors.border,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: SchooKeepColors.amberChipBg, shape: BoxShape.circle),
            child: Text(initials,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.warning)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _pendingAck(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Required acknowledgment:', ar: 'الإقرار والتأكيد المطلوب:'),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(
              en: 'I have ensured the above students remain indoors',
              ar: 'أقر بأني تأكدت من بقاء الطلاب المذكورين أعلاه داخل المبنى',
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _confirmedAck(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.greenChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.accent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Confirmed at $_confirmedAt', ar: 'تم التأكيد الساعة $_confirmedAt'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.greenChipText),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    en: 'Acknowledgment has been logged and locked',
                    ar: 'تم تسجيل التأكيد وحفظه في النظام',
                  ),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.greenChipText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(LucideIcons.check, size: 20, color: SchooKeepColors.accent),
        ],
      ),
    );
  }

  Widget _confirmBar(bool isRTL) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Material(
            color: _isConfirmed ? SchooKeepColors.border : SchooKeepColors.warning,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _isConfirmed ? null : () => _confirm(isRTL),
              child: Center(
                child: Text(
                  _isConfirmed
                      ? context.tr(en: 'Confirmed', ar: 'تم التأكيد')
                      : context.tr(en: 'Confirm Acknowledgment', ar: 'تأكيد الالتزام بالتعليمات'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _isConfirmed ? const Color(0xFF94A3B8) : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
