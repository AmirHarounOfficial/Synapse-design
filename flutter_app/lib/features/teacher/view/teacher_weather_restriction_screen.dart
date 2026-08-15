import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `TeacherWeatherRestriction.tsx`. Active advisory banner, the
/// list of indoor-restricted students, and a confirm-acknowledgment CTA that
/// locks into a confirmed state with a timestamp.
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

  static const _advisoryReason = 'AQI Advisory — respiratory sensitivity';

  void _confirm() {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    setState(() {
      _confirmedAt = '${h.toString().padLeft(2, '0')}:$m $period';
      _isConfirmed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        title: 'Weather Restriction',
      ),
      bottomBar: _confirmBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _alertBanner(),
            const SizedBox(height: 16),
            _instructions(),
            const SizedBox(height: 16),
            for (final s in _restrictedStudents) ...[
              _studentCard(s.name, s.initials),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            if (!_isConfirmed) _pendingAck() else _confirmedAck(),
          ],
        ),
      ),
    );
  }

  Widget _alertBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(LucideIcons.alertTriangle, size: 24, color: SchooKeepColors.warning),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Weather Advisory',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText)),
                SizedBox(height: 4),
                Text(_advisoryReason, style: TextStyle(fontSize: 13, color: SchooKeepColors.amberText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: const Text('The following students must remain indoors during this advisory:',
          style: TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
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

  Widget _pendingAck() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Required acknowledgment:', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          SizedBox(height: 4),
          Text('I have ensured the above students remain indoors',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _confirmedAck() {
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
                Text('Confirmed at $_confirmedAt',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.greenChipText)),
                const SizedBox(height: 4),
                const Text('Acknowledgment has been logged and locked',
                    style: TextStyle(fontSize: 13, color: SchooKeepColors.greenChipText)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(LucideIcons.check, size: 20, color: SchooKeepColors.accent),
        ],
      ),
    );
  }

  Widget _confirmBar() {
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
              onTap: _isConfirmed ? null : _confirm,
              child: Center(
                child: Text(_isConfirmed ? 'Confirmed' : 'Confirm Acknowledgment',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _isConfirmed ? const Color(0xFF94A3B8) : Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
