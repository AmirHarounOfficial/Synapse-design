import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `TeacherStudentReleaseNotification.tsx`. An overlay-style
/// "student called to clinic" alert pinned near the top, with an acknowledge
/// button that flips to a confirmation banner then returns home after 1.5s.
class TeacherStudentReleaseNotificationScreen extends StatefulWidget {
  const TeacherStudentReleaseNotificationScreen({super.key});

  @override
  State<TeacherStudentReleaseNotificationScreen> createState() =>
      _TeacherStudentReleaseNotificationScreenState();
}

class _TeacherStudentReleaseNotificationScreenState extends State<TeacherStudentReleaseNotificationScreen> {
  bool _isAcknowledged = false;

  static const _studentName = 'Maya Chen';

  String _time() {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _acknowledge() {
    setState(() => _isAcknowledged = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/teacher/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isAcknowledged) _alertCard() else _confirmedBanner(),
            const SizedBox(height: 16),
            // Background content (teacher's current screen)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: const Text(
                'This notification appears as an overlay on your current screen',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.primary, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                child: const Icon(LucideIcons.stethoscope, size: 20, color: SchooKeepColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Student Called to Clinic',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('$_studentName has been called to the clinic',
                        style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(_time(), style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _acknowledge,
              child: const Text('Acknowledge',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmedBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.greenChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.accent),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Notification acknowledged',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.greenChipText)),
        ],
      ),
    );
  }
}
