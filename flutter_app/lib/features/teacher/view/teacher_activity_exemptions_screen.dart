import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

class _Exemption {
  const _Exemption({
    required this.id,
    required this.name,
    required this.initials,
    required this.grade,
    required this.restriction,
    this.weatherLinked = false,
  });
  final String id;
  final String name;
  final String initials;
  final String grade;
  final String restriction;
  final bool weatherLinked;
}

/// Ported from `TeacherActivityExemptions.tsx`. FERPA banner, weather-linked
/// exemptions during an AQI advisory, the active-exemptions list, and a PE
/// teacher note. Falls back to an empty-state card when there are none.
class TeacherActivityExemptionsScreen extends StatelessWidget {
  const TeacherActivityExemptionsScreen({super.key});

  static const _hasWeatherAdvisory = true;

  static const _activeExemptions = [
    _Exemption(id: '1', name: 'Emma Rodriguez', initials: 'ER', grade: '5th Grade', restriction: 'No vigorous physical activity'),
    _Exemption(id: '2', name: 'Marcus Chen', initials: 'MC', grade: '5th Grade', restriction: 'Light activity only'),
    _Exemption(id: '3', name: 'James Taylor', initials: 'JT', grade: '5th Grade', restriction: 'No swimming'),
  ];

  static const _weatherLinkedExemptions = [
    _Exemption(
        id: '4',
        name: 'Sarah Williams',
        initials: 'SW',
        grade: '5th Grade',
        restriction: 'Indoor only today — weather advisory',
        weatherLinked: true),
    _Exemption(
        id: '5',
        name: 'Alex Martinez',
        initials: 'AM',
        grade: '5th Grade',
        restriction: 'Indoor only today — weather advisory',
        weatherLinked: true),
    _Exemption(
        id: '6',
        name: 'Jordan Lee',
        initials: 'JL',
        grade: '5th Grade',
        restriction: 'Indoor only today — weather advisory',
        weatherLinked: true),
  ];

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _todaysDate() {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasExemptions = _activeExemptions.isNotEmpty || _weatherLinkedExemptions.isNotEmpty;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Activity Exemptions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            Text(_todaysDate(), style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ferpaBanner(),
            const SizedBox(height: 16),
            if (hasExemptions) ...[
              if (_hasWeatherAdvisory && _weatherLinkedExemptions.isNotEmpty) ...[
                _aqiDividerLabel(),
                const SizedBox(height: 12),
                _aqiSummary(),
                const SizedBox(height: 12),
                for (final s in _weatherLinkedExemptions) ...[
                  _exemptionCard(s, weather: true),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
              ],
              if (_activeExemptions.isNotEmpty) ...[
                Text('Active Exemptions'.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                for (final s in _activeExemptions) ...[
                  _exemptionCard(s, weather: false),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
              ],
              _peNote(),
            ] else
              _emptyState(),
          ],
        ),
      ),
    );
  }

  Widget _ferpaBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(LucideIcons.info, size: 20, color: SchooKeepColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text('You are viewing activity restrictions only. Medical conditions are confidential.',
                style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _aqiDividerLabel() {
    return Row(
      children: [
        const Expanded(child: Divider(color: SchooKeepColors.warning, thickness: 1, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.warning),
              SizedBox(width: 8),
              Text('During Current AQI Advisory',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.warning, letterSpacing: 0.5)),
            ],
          ),
        ),
        const Expanded(child: Divider(color: SchooKeepColors.warning, thickness: 1, height: 1)),
      ],
    );
  }

  Widget _aqiSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Text('${_weatherLinkedExemptions.length} students must remain fully sedentary',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText)),
    );
  }

  Widget _exemptionCard(_Exemption s, {required bool weather}) {
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
                  Text(s.grade, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(s.restriction, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
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

  Widget _peNote() {
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
                const TextSpan(
                    text: "Students excused from today's class: ",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
                TextSpan(
                    text: '$count',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
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
          children: const [
            _CircleIcon(bg: SchooKeepColors.greenChipBg, icon: LucideIcons.checkCircle, color: SchooKeepColors.accent),
            SizedBox(height: 16),
            Text('No Activity Restrictions Today',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            SizedBox(height: 8),
            Text('All students are cleared for regular physical activity',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
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
