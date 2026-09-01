import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class _Exemption {
  const _Exemption({
    required this.id,
    required this.name,
    required this.initials,
    required this.gradeEn,
    required this.gradeAr,
    required this.restrictionEn,
    required this.restrictionAr,
    this.weatherLinked = false,
  });
  final String id;
  final String name;
  final String initials;
  final String gradeEn;
  final String gradeAr;
  final String restrictionEn;
  final String restrictionAr;
  final bool weatherLinked;
}

/// Ported from `TeacherActivityExemptions.tsx`. FERPA banner, weather-linked
/// exemptions during an AQI advisory, the active-exemptions list, and a PE
/// teacher note. Falls back to an empty-state card when there are none. Localized in EN & AR.
class TeacherActivityExemptionsScreen extends StatelessWidget {
  const TeacherActivityExemptionsScreen({super.key});

  static const _hasWeatherAdvisory = true;

  static const _activeExemptions = [
    _Exemption(
        id: '1',
        name: 'Emma Rodriguez',
        initials: 'ER',
        gradeEn: '5th Grade',
        gradeAr: 'الصف الخامس',
        restrictionEn: 'No vigorous physical activity',
        restrictionAr: 'ممنوع من النشاط البدني المجهد'),
    _Exemption(
        id: '2',
        name: 'Marcus Chen',
        initials: 'MC',
        gradeEn: '5th Grade',
        gradeAr: 'الصف الخامس',
        restrictionEn: 'Light activity only',
        restrictionAr: 'أنشطة خفيفة فقط'),
    _Exemption(
        id: '3',
        name: 'James Taylor',
        initials: 'JT',
        gradeEn: '5th Grade',
        gradeAr: 'الصف الخامس',
        restrictionEn: 'No swimming',
        restrictionAr: 'ممنوع من حصص السباحة'),
  ];

  static const _weatherLinkedExemptions = [
    _Exemption(
        id: '4',
        name: 'Sarah Williams',
        initials: 'SW',
        gradeEn: '5th Grade',
        gradeAr: 'الصف الخامس',
        restrictionEn: 'Indoor only today — weather advisory',
        restrictionAr: 'البقاء بالداخل اليوم بسبب التنبيه الجوي',
        weatherLinked: true),
    _Exemption(
        id: '5',
        name: 'Alex Martinez',
        initials: 'AM',
        gradeEn: '5th Grade',
        gradeAr: 'الصف الخامس',
        restrictionEn: 'Indoor only today — weather advisory',
        restrictionAr: 'البقاء بالداخل اليوم بسبب التنبيه الجوي',
        weatherLinked: true),
    _Exemption(
        id: '6',
        name: 'Jordan Lee',
        initials: 'JL',
        gradeEn: '5th Grade',
        gradeAr: 'الصف الخامس',
        restrictionEn: 'Indoor only today — weather advisory',
        restrictionAr: 'البقاء بالداخل اليوم بسبب التنبيه الجوي',
        weatherLinked: true),
  ];

  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _monthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String _todaysDate(bool isAr) {
    final now = DateTime.now();
    final m = isAr ? _monthsAr[now.month - 1] : _monthsEn[now.month - 1];
    return '$m ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRTL;
    final hasExemptions = _activeExemptions.isNotEmpty || _weatherLinkedExemptions.isNotEmpty;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr(en: 'Activity Exemptions', ar: 'إعفاءات التربية الرياضية والأنشطة'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            Text(_todaysDate(isAr), style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ferpaBanner(context),
            const SizedBox(height: 16),
            if (hasExemptions) ...[
              if (_hasWeatherAdvisory && _weatherLinkedExemptions.isNotEmpty) ...[
                _aqiDividerLabel(context),
                const SizedBox(height: 12),
                _aqiSummary(context),
                const SizedBox(height: 12),
                for (final s in _weatherLinkedExemptions) ...[
                  _exemptionCard(context, s, weather: true),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
              ],
              if (_activeExemptions.isNotEmpty) ...[
                Text(
                  context.tr(en: 'Active Exemptions', ar: 'الإعفاءات الرياضية النشطة').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                for (final s in _activeExemptions) ...[
                  _exemptionCard(context, s, weather: false),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
              ],
              _peNote(context),
            ] else
              _emptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _ferpaBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 20, color: SchooKeepColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr(
                en: 'You are viewing activity restrictions only. Medical conditions are confidential.',
                ar: 'تعرض هذه الشاشة قيود الأنشطة فقط. التفاصيل الحالات الصحية سرية.',
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aqiDividerLabel(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: SchooKeepColors.warning, thickness: 1, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.warning),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'During Current AQI Advisory', ar: 'خلال تنبيه جودة الهواء الحالي'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: SchooKeepColors.warning,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: Divider(color: SchooKeepColors.warning, thickness: 1, height: 1)),
      ],
    );
  }

  Widget _aqiSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Text(
        context.tr(
          en: '${_weatherLinkedExemptions.length} students must remain fully sedentary',
          ar: 'يجب على ${_weatherLinkedExemptions.length} طلاب عدم ممارسة أي نشاط جثماني مجهد',
        ),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText),
      ),
    );
  }

  Widget _exemptionCard(BuildContext context, _Exemption s, {required bool weather}) {
    final content = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: weather ? SchooKeepColors.amberChipBg : const Color(0xFFEFF6FF), shape: BoxShape.circle),
          child: Text(s.initials,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: weather ? SchooKeepColors.warning : SchooKeepColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(s.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr(en: s.gradeEn, ar: s.gradeAr),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(en: s.restrictionEn, ar: s.restrictionAr),
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
    if (weather) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: AccentCard(
          background: SchooKeepColors.surface,
          accentColor: SchooKeepColors.warning,
          accentWidth: 3,
          radius: 12,
          padding: const EdgeInsets.all(12),
          borderColor: SchooKeepColors.border,
          child: content,
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: content,
    );
  }

  Widget _peNote(BuildContext context) {
    final count = _activeExemptions.length + _weatherLinkedExemptions.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 16, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: context.tr(en: "Students excused from today's class: ", ar: 'إجمالي الطلاب المعفيين من حصة اليوم: '),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
                ),
                TextSpan(
                  text: '$count',
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Column(
          children: [
            const _CircleIcon(bg: SchooKeepColors.greenChipBg, icon: LucideIcons.checkCircle, color: SchooKeepColors.accent),
            const SizedBox(height: 16),
            Text(
              context.tr(en: 'No Activity Restrictions Today', ar: 'لا توجد قيود على الأنشطة اليوم'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(en: 'All students are cleared for regular physical activity', ar: 'جميع الطلاب مصرح لهم بالمشاركة في الرياضة العادية'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.bg, required this.icon, required this.color});
  final Color bg;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 32, color: color),
    );
  }
}
