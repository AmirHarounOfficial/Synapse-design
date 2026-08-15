import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/simulator_frame.dart';

typedef _StateInfo = ({String id, String title, String description, IconData icon, String route});

const List<_StateInfo> _states = [
  (
    id: 'SYS-01',
    title: 'After-Hours Lock',
    description: 'Applies locks to staff roles after-hours, leaving parents unrestricted. Includes principal code bypass.',
    icon: LucideIcons.lock,
    route: '/system/after-hours',
  ),
  (
    id: 'SYS-02',
    title: 'AQI/Weather Banner',
    description: 'Active top-pinned advisory banner. Opens custom bottom sheets detailing restricted students or parental reassurance.',
    icon: LucideIcons.alertTriangle,
    route: '/system/weather-advisory',
  ),
  (
    id: 'SYS-03',
    title: 'Onboarding Consent',
    description: 'Amber border pending card placed at top of parent home. Blurs and locks all features until complete.',
    icon: LucideIcons.fileCheck2,
    route: '/system/consent-pending',
  ),
  (
    id: 'SYS-04',
    title: 'Session Timeout',
    description: 'A slide-up HIPAA warning sheet ticking down to auto-logout for clinical and administrative staff.',
    icon: LucideIcons.clock,
    route: '/system/session-expiry',
  ),
  (
    id: 'SYS-05',
    title: 'Ramadan Mode',
    description: 'Compressed school day timings, persistent alert banners, and rescheduled clinical dose reminders.',
    icon: LucideIcons.moon,
    route: '/system/ramadan',
  ),
];

/// Ported from `SystemStateShowcase.tsx`. The React version is a wide desktop
/// workbench with an interactive iPhone simulator; here it is adapted to the
/// phone-width app as a selector hub: each safety-critical system state is a
/// card that launches its full standalone screen.
class SystemStateShowcaseScreen extends StatelessWidget {
  const SystemStateShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SimColors.slate900,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SimColors.slate800.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.smartphone, size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('SchooKeep System States',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x99312E81),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF4338CA)),
                      ),
                      child: const Text('iPhone 16 Pro Simulator',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFA5B4FC), letterSpacing: 1)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Interactive mockup presentation highlighting custom safety-critical gates, warnings, and overlays.',
                      style: TextStyle(fontSize: 12, color: SimColors.slate400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(LucideIcons.sparkles, size: 16, color: Color(0xFF818CF8)),
                  SizedBox(width: 6),
                  Text('SELECT SYSTEM STATE TO DEMO',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SimColors.slate400, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 12),
              for (final s in _states) ...[
                _StateCard(info: s),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(LucideIcons.rotateCcw, size: 14, color: SimColors.slate200),
                  label: const Text('Return to Map',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SimColors.slate200)),
                  style: TextButton.styleFrom(
                    backgroundColor: SimColors.slate800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.info});
  final _StateInfo info;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF151F32),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(info.route),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: SimColors.slate800, borderRadius: BorderRadius.circular(8)),
                child: Icon(info.icon, size: 16, color: SimColors.slate400),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${info.id} — ${info.title}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(info.description, style: const TextStyle(fontSize: 11, height: 1.4, color: SimColors.slate400)),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 16, color: SimColors.slate500),
            ],
          ),
        ),
      ),
    );
  }
}
