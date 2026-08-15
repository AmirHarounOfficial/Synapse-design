import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/simulator_frame.dart';

typedef _Step = ({String label, bool completed, bool required});

/// Ported from `SysConsentPending.tsx` (SYS-03). A parent home dashboard gated
/// by an amber onboarding-checklist card. Until setup is complete the dashboard
/// below is blurred and locked; "Complete setup" runs a brief loading state,
/// marks all steps done, and reveals a success banner + unblurred content.
class SysConsentPendingScreen extends StatefulWidget {
  const SysConsentPendingScreen({super.key});

  @override
  State<SysConsentPendingScreen> createState() => _SysConsentPendingScreenState();
}

class _SysConsentPendingScreenState extends State<SysConsentPendingScreen> {
  bool _completed = false;
  bool _loading = false;

  static const List<_Step> _initialSteps = [
    (label: 'School code entry', completed: true, required: false),
    (label: 'Confirm child connection', completed: true, required: false),
    (label: 'Emergency medical consent', completed: false, required: true),
    (label: 'Upload immunization records', completed: false, required: true),
    (label: 'Designate authorized pickups', completed: true, required: false),
  ];

  late List<_Step> _steps = List.of(_initialSteps);

  int get _completedCount => _steps.where((s) => s.completed).length;
  int get _progressPercent => ((_completedCount / _steps.length) * 100).round();

  void _completeSetup() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _steps = [for (final s in _steps) (label: s.label, completed: true, required: s.required)];
        _completed = true;
        _loading = false;
      });
    });
  }

  void _reset() {
    setState(() {
      _steps = List.of(_initialSteps);
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimulatorFrame(
      statusTime: '2:15 PM',
      deviceColor: SimColors.slate50,
      controls: SimDemoControls(
        label: 'SYS-03 Demo Controls',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_completed)
              TextButton(
                onPressed: _reset,
                child: const Text('Reset Gate', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'State: ', style: TextStyle(fontSize: 11, color: SimColors.slate400)),
                TextSpan(
                  text: _completed ? 'Unlocked' : 'Locked',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _completed ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          _appBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _completed ? _successBanner() : _gateCard(),
                  const SizedBox(height: 16),
                  _lockableSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: SimColors.white,
        border: Border(bottom: BorderSide(color: SimColors.slate200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Maya's Health Home",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: SimColors.slate100, shape: BoxShape.circle),
            child: const Text('JT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }

  Widget _gateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.alertTriangle, size: 20, color: Color(0xFFF59E0B)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your child's health profile is not yet active",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    SizedBox(height: 2),
                    Text('Onboarding checklist incomplete. Complete remaining steps to activate portal.',
                        style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0x80FDE68A)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Setup Checklist',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    Text('$_completedCount of ${_steps.length} steps ($_progressPercent%)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _progressPercent / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0x66FDE68A),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final step in _steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (step.completed)
                    const Icon(LucideIcons.checkCircle2, size: 16, color: Color(0xFF059669))
                  else
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFBBF24), width: 2),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: step.completed ? SimColors.slate500 : const Color(0xFF1E293B),
                        decoration: step.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (step.required && !step.completed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Required',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _loading ? const Color(0xFFFCD34D) : const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: _loading ? null : _completeSetup,
              child: _loading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        SizedBox(width: 8),
                        Text('Verifying consent files...',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Complete setup', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(width: 6),
                        Icon(LucideIcons.chevronRight, size: 16, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _successBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
            child: const Icon(LucideIcons.checkCircle2, size: 24, color: Color(0xFF059669)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Profile Fully Active!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
                SizedBox(height: 2),
                Text("Thank you, James! Maya's medical dossier has been securely synced with the school nurse.",
                    style: TextStyle(fontSize: 11, color: Color(0xFF059669))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockableSection() {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _dashCard('Medication Administrations', LucideIcons.pill, 'Ritalin administered', '10:30 AM by Nurse Reynolds'),
        const SizedBox(height: 16),
        _activityCard(),
        const SizedBox(height: 16),
        _clinicCard(),
      ],
    );

    if (_completed) return content;

    return Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
              child: content,
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SimColors.slate900.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: SimColors.slate900.withValues(alpha: 0.1)),
                  ),
                  child: Icon(LucideIcons.lock, size: 24, color: SimColors.slate800.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 8),
                const Text('Health Features Blocked',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                const SizedBox(
                  width: 200,
                  child: Text(
                    'Emergency records, meds history, and activity logs are locked until health profile is active.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dashCard(String title, IconData icon, String desc, String meta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SimColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SimColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: const Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                ],
              ),
              const Text('Today', style: TextStyle(fontSize: 10, color: SimColors.slate400)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SimColors.slate50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SimColors.slate100),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                  child: Icon(icon, size: 16, color: const Color(0xFF6366F1)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(desc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    Text(meta, style: const TextStyle(fontSize: 10, color: SimColors.slate500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard() {
    const activity = [
      (desc: 'Ritalin administered', time: '10:30 AM'),
      (desc: 'Boarded Route 12', time: '7:45 AM'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SimColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SimColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity Log', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          for (final a in activity)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: SimColors.slate100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(a.desc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                  Text(a.time, style: const TextStyle(fontSize: 10, color: SimColors.slate400)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _clinicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SimColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SimColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Clinic Visits', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SimColors.slate50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SimColors.slate100),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.fileText, size: 16, color: SimColors.slate400),
                SizedBox(width: 8),
                Text('Minor scratch treated • 3 days ago', style: TextStyle(fontSize: 12, color: SimColors.slate500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
