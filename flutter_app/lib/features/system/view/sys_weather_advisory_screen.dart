import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../data/models/weather_advisory.dart';
import '../../../data/repositories/system_repository.dart';
import '../cubit/sys_advisory_cubit.dart';
import '../widgets/simulator_frame.dart';

/// One restricted-student record (mirrors the inline array in the React source).
typedef _RestrictedStudent = ({String name, String grade, String room, String condition, String note});

const List<_RestrictedStudent> _restrictedStudents = [
  (name: 'Maya Thompson', grade: '4th Grade', room: 'Room 204', condition: 'Severe Asthma', note: 'Requires inhaler (Albuterol) prior to physical activity if outdoors.'),
  (name: 'Liam Carter', grade: '2nd Grade', room: 'Room 112', condition: 'Severe Grass Allergies', note: 'Avoid dry winds/recess outdoors when AQI exceeds 150.'),
  (name: 'Sophia Chen', grade: '5th Grade', room: 'Room 301', condition: 'Exercise-Induced Bronchospasm', note: 'Has active PE waiver for high AQI days.'),
];

/// Ported from `SysWeatherAdvisory.tsx` (SYS-02), wired to fetch the active
/// advisory from `GET /weather-advisories?active=1`. The amber AQI banner shows
/// only when an advisory is active and uses its message text; tapping it opens a
/// bottom sheet whose content depends on the demo role: parents see a "child is
/// safe indoors" reassurance, staff see the restricted-students list (the
/// restricted list itself remains static demo data — no API source).
class SysWeatherAdvisoryScreen extends StatelessWidget {
  const SysWeatherAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SysAdvisoryCubit(sl<SystemRepository>()),
      child: const _SysWeatherAdvisoryView(),
    );
  }
}

class _SysWeatherAdvisoryView extends StatefulWidget {
  const _SysWeatherAdvisoryView();

  @override
  State<_SysWeatherAdvisoryView> createState() => _SysWeatherAdvisoryViewState();
}

class _SysWeatherAdvisoryViewState extends State<_SysWeatherAdvisoryView> {
  String _role = 'Nurse';
  bool _bannerDismissed = false;
  bool _sheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final isParent = _role == 'Parent';
    final state = context.watch<SysAdvisoryCubit>().state;
    final WeatherAdvisory? advisory =
        state is DataLoaded<WeatherAdvisory?> ? state.data : null;
    final loading = state is DataLoading<WeatherAdvisory?>;
    final bannerVisible = !_bannerDismissed && advisory != null;
    final bannerText = (advisory?.message.isNotEmpty ?? false)
        ? advisory!.message
        : 'AQI Advisory Active — Tap for details';

    return SimulatorFrame(
      statusTime: '10:45 AM',
      deviceColor: SimColors.slate100,
      controls: SimDemoControls(
        label: 'SYS-02 Demo Controls',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SimDropdown(
              value: _role,
              items: const ['Nurse', 'Teacher', 'Parent'],
              onChanged: (v) => setState(() {
                _role = v;
                _sheetOpen = false;
              }),
            ),
            if (advisory != null && _bannerDismissed) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => _bannerDismissed = false),
                child: const Text('Restore Banner', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _AppBar(title: isParent ? 'Parent Portal' : 'SchooKeep Clinical', initials: isParent ? 'JT' : 'RN'),
              if (loading)
                const LinearProgressIndicator(minHeight: 2)
              else if (bannerVisible)
                GestureDetector(
                  onTap: () => setState(() => _sheetOpen = true),
                  child: Container(
                    height: 48,
                    color: const Color(0xFFFEF3C7),
                    padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertTriangle, size: 20, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bannerText,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => setState(() => _bannerDismissed = true),
                            icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Expanded(child: _AdvisoryBody()),
            ],
          ),
          if (_sheetOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _sheetOpen = false),
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _DetailsSheet(
                isParent: isParent,
                onClose: () => setState(() => _sheetOpen = false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdvisoryBody extends StatelessWidget {
  const _AdvisoryBody();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SimColors.slate50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SimColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SimColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.cloudDrizzle, size: 16, color: Color(0xFF475569)),
                      SizedBox(width: 8),
                      Text('Local Conditions',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Expanded(child: _Stat(value: '156', label: 'AIR QUALITY (AQI)', valueColor: Color(0xFFE11D48))),
                      SizedBox(width: 12),
                      Expanded(child: _Stat(value: '84°F', label: 'TEMPERATURE', valueColor: Color(0xFF334155))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Active alert remains in effect for this zip code until 6:00 PM. Indoor protocols are advised for sensitive groups.',
                    style: TextStyle(fontSize: 12, height: 1.4, color: SimColors.slate500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SimColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SimColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('School Status',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      const Text('Indoor Recess Active',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet({required this.isParent, required this.onClose});
  final bool isParent;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: SimColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(999)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(999)),
                            child: const Text('UNHEALTHY (AQI 156)',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFBE123C))),
                          ),
                          const SizedBox(height: 4),
                          const Text('AQI Advisory Details',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                    _CloseButton(onClose: onClose),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Air quality is currently in the Unhealthy tier. High levels of fine particulate matter pose risks to respiratory health. All outdoor recess, physical education, and events have been moved indoors.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: SimColors.slate500),
                ),
                const SizedBox(height: 16),
                isParent ? const _ParentSafeCard() : const _RestrictedStudentsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentSafeCard extends StatelessWidget {
  const _ParentSafeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
                child: const Icon(LucideIcons.smile, size: 24, color: Color(0xFF059669)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your child is safe indoors',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                    SizedBox(height: 2),
                    Text('Lakeside Elementary School',
                        style: TextStyle(fontSize: 11, color: Color(0xFF047857))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFA7F3D0)),
          const SizedBox(height: 12),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Maya Thompson (4th Grade)', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' has been moved indoors. Recess and gym class will take place in the gym.'),
              ],
            ),
            style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF065F46)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.info, size: 16, color: Color(0xFF059669)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'School health team is monitoring air circulation systems, and inhaler access is prepared in the clinic.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestrictedStudentsList extends StatelessWidget {
  const _RestrictedStudentsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Restricted Students (${_restrictedStudents.length})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: SimColors.slate100, borderRadius: BorderRadius.circular(4)),
              child: const Text('My Classrooms', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final s in _restrictedStudents)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SimColors.slate50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SimColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(text: s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  TextSpan(text: '  ${s.grade} • ${s.room}', style: const TextStyle(fontSize: 10, color: SimColors.slate500)),
                                ]),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFFECDD3)),
                              ),
                              child: Text(s.condition, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFBE123C))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: SimColors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SimColors.slate100),
                          ),
                          child: Text(s.note, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.valueColor});
  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SimColors.slate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SimColors.slate100),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: valueColor)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SimColors.slate500)),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.title, required this.initials});
  final String title;
  final String initials;

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: SimColors.slate100, shape: BoxShape.circle),
            child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClose,
      customBorder: const CircleBorder(),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: SimColors.slate100, shape: BoxShape.circle),
        child: const Icon(LucideIcons.x, size: 16, color: SimColors.slate500),
      ),
    );
  }
}

class _SimDropdown extends StatelessWidget {
  const _SimDropdown({required this.value, required this.items, required this.onChanged});
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: SimColors.slate700,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF475569)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          dropdownColor: SimColors.slate700,
          style: const TextStyle(fontSize: 12, color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
          items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
