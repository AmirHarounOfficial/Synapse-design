import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';

/// Ported from `BusEarlyDismissal.tsx`. A full-bleed amber alert screen with a
/// student info card and a warning banner. Acknowledging it switches to a
/// success state, then routes back to the route overview after a short delay.
class BusEarlyDismissalScreen extends StatefulWidget {
  const BusEarlyDismissalScreen({super.key});

  @override
  State<BusEarlyDismissalScreen> createState() => _BusEarlyDismissalScreenState();
}

class _BusEarlyDismissalScreenState extends State<BusEarlyDismissalScreen> {
  bool _isAcknowledged = false;

  static const Map<String, dynamic> _student = {
    'name': 'Maya Chen',
    'grade': '3rd Grade',
    'stopNumber': 4,
    'reason': 'Medical appointment',
    'dismissedAt': '1:45 PM',
  };

  String get _nowTime {
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  void _handleAcknowledge() {
    setState(() => _isAcknowledged = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      context.go('/bus/route');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SchooKeepColors.amberChipBg,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 99),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384),
              child: _isAcknowledged ? _acknowledgedState() : _alertState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _alertState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.alertTriangle, size: 64, color: SchooKeepColors.warning),
        ),
        const SizedBox(height: 24),
        const Text('Early Dismissal Alert',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: SchooKeepColors.amberText)),
        const SizedBox(height: 16),
        _infoCard(),
        const SizedBox(height: 24),
        _warningBanner(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: SchooKeepColors.warning, width: 2),
              ),
            ),
            onPressed: _handleAcknowledge,
            child: const Text('Acknowledge Alert',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.warning)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('This acknowledgment will be logged for compliance purposes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: SchooKeepColors.amberText)),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(_student['name'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 8),
          Text(_student['grade'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
            child: Text('Usually at Stop ${_student['stopNumber']}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: SchooKeepColors.border),
          const SizedBox(height: 12),
          _detailRow('DISMISSAL TIME', _student['dismissedAt'] as String),
          const SizedBox(height: 12),
          _detailRow('REASON', _student['reason'] as String),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
      ],
    );
  }

  Widget _warningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: SchooKeepColors.warning, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('${_student['name']} will NOT be on the afternoon bus.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5)),
          const SizedBox(height: 8),
          Text('Do not wait at Stop ${_student['stopNumber']} this afternoon.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _acknowledgedState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.check, size: 64, color: SchooKeepColors.accent),
        ),
        const SizedBox(height: 24),
        const Text('Alert Acknowledged',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SchooKeepColors.greenChipText)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10))],
          ),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
                  children: [
                    const TextSpan(text: 'You have acknowledged the early dismissal for '),
                    TextSpan(
                        text: _student['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('This has been recorded at $_nowTime',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Returning to route overview...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: SchooKeepColors.amberText)),
      ],
    );
  }
}
