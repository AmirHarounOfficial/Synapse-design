import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

class _Consideration {
  const _Consideration({
    required this.id,
    required this.studentName,
    required this.initials,
    required this.restriction,
    required this.type,
  });
  final String id;
  final String studentName;
  final String initials;
  final String restriction;
  final String type; // activity | dietary | environmental
}

/// Ported from `TeacherHealthConsiderations.tsx`. FERPA notice, weather-
/// restricted-today section, full considerations list with type chips, privacy
/// disclaimer, and an info modal explaining FERPA.
class TeacherHealthConsiderationsScreen extends StatefulWidget {
  const TeacherHealthConsiderationsScreen({super.key});

  @override
  State<TeacherHealthConsiderationsScreen> createState() => _TeacherHealthConsiderationsScreenState();
}

class _TeacherHealthConsiderationsScreenState extends State<TeacherHealthConsiderationsScreen> {
  final _considerations = const [
    _Consideration(
        id: '1', studentName: 'Emma Rodriguez', initials: 'ER', restriction: 'No vigorous outdoor activity', type: 'activity'),
    _Consideration(
        id: '2', studentName: 'Marcus Chen', initials: 'MC', restriction: 'Peanut-free environment required', type: 'dietary'),
    _Consideration(
        id: '3',
        studentName: 'Sarah Williams',
        initials: 'SW',
        restriction: 'Indoor activities during dust advisories',
        type: 'environmental'),
  ];

  final _weatherRestricted = const [
    (id: '3', studentName: 'Sarah Williams', initials: 'SW', restriction: 'Must remain indoors during dust advisory'),
  ];

  (Color, Color) _typeColors(String type) => switch (type) {
        'activity' => (const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
        'dietary' => (SchooKeepColors.amberChipBg, SchooKeepColors.amberText),
        'environmental' => (const Color(0xFFF3E8FF), const Color(0xFF6B21A8)),
        _ => (SchooKeepColors.border, SchooKeepColors.textSecondary),
      };

  String _typeLabel(String type) => switch (type) {
        'activity' => 'Activity',
        'dietary' => 'Dietary',
        'environmental' => 'Environmental',
        _ => 'Other',
      };

  void _showFerpaModal() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FERPA Privacy Protection',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'Under the Family Educational Rights and Privacy Act (FERPA), detailed medical information is confidential. You can only view activity restrictions necessary for safe classroom management.',
                style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Full medical records are maintained by the school nurse and accessible only to authorized healthcare personnel.',
                style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SchooKeepColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Understood',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        title: 'Health Considerations',
        actions: [
          InkWell(
            onTap: _showFerpaModal,
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(LucideIcons.info, size: 24, color: SchooKeepColors.textSecondary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ferpaBanner(),
            const SizedBox(height: 16),
            if (_weatherRestricted.isNotEmpty) ...[
              _dividerLabel('Restricted from Outdoor Activities Today'),
              const SizedBox(height: 12),
              for (final s in _weatherRestricted) ...[
                _weatherCard(s.studentName, s.initials, s.restriction),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
            ],
            Text('All Health Considerations'.toUpperCase(),
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            for (final c in _considerations) ...[
              _considerationCard(c),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            _disclaimer(),
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
            child: Text(
              'You are viewing activity restrictions only. Medical details are confidential per FERPA regulations.',
              style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerLabel(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: SchooKeepColors.warning, thickness: 1, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(text.toUpperCase(),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.warning, letterSpacing: 0.5)),
        ),
        const Expanded(child: Divider(color: SchooKeepColors.warning, thickness: 1, height: 1)),
      ],
    );
  }

  Widget _weatherCard(String name, String initials, String restriction) {
    return _leftBorderCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(initials, SchooKeepColors.amberChipBg, SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.alertCircle, size: 16, color: SchooKeepColors.warning),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(restriction, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _considerationCard(_Consideration c) {
    final (bg, fg) = _typeColors(c.type);
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(c.initials, const Color(0xFFEFF6FF), SchooKeepColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(c.studentName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                      child: Text(_typeLabel(c.type),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(c.restriction, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: 'Privacy Notice: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
                    TextSpan(
                        text:
                            'You cannot access full medical records. These restrictions are provided to support safe classroom activities only.',
                        style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5)),
                  ]),
                ),
                SizedBox(height: 8),
                Text('For medical emergencies, contact the school nurse immediately at ext. 4521.',
                    style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leftBorderCard({required Widget child}) {
    return AccentCard(
      background: SchooKeepColors.surface,
      accentColor: SchooKeepColors.warning,
      accentWidth: 3,
      radius: 12,
      padding: const EdgeInsets.all(12),
      borderColor: SchooKeepColors.border,
      child: child,
    );
  }

  Widget _avatar(String initials, Color bg, Color fg) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(initials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
