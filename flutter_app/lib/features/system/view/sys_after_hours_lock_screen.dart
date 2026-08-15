import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/simulator_frame.dart';

/// Ported from `SysAfterHoursLock.tsx` (SYS-01). A blurred dashboard behind a
/// 0.85 black overlay with a centred lock card. Staff roles are locked outside
/// school hours; entering a valid emergency code (`9999` or `EMERGENCY2026`)
/// shows the override-accepted card. A demo role selector switches between the
/// locked staff view and the unrestricted Parent view.
class SysAfterHoursLockScreen extends StatefulWidget {
  const SysAfterHoursLockScreen({super.key});

  @override
  State<SysAfterHoursLockScreen> createState() => _SysAfterHoursLockScreenState();
}

class _SysAfterHoursLockScreenState extends State<SysAfterHoursLockScreen> {
  String _role = 'Nurse';
  final _codeController = TextEditingController();
  String _error = '';
  bool _success = false;

  bool get _isLocked => _role != 'Parent';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _override() {
    final code = _codeController.text;
    if (code == '9999' || code.toUpperCase() == 'EMERGENCY2026') {
      setState(() {
        _success = true;
        _error = '';
      });
    } else {
      setState(() {
        _error = 'Invalid authorization code. Please try again or contact your Principal.';
        _success = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimulatorFrame(
      statusTime: '7:15 PM',
      statusBarDark: false,
      statusBarColor: SimColors.slate900,
      deviceColor: SimColors.slate800,
      controls: SimDemoControls(
        label: 'SYS-01 Demo Controls',
        trailing: _RoleDropdown(
          value: _role,
          items: const ['Nurse', 'Teacher', 'Counselor', 'Secretary', 'Parent'],
          onChanged: (v) => setState(() {
            _role = v;
            _success = false;
            _error = '';
            _codeController.clear();
          }),
        ),
      ),
      child: Stack(
        children: [
          const _BlurredDashboard(),
          if (_isLocked)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.85),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _success ? const _OverrideAcceptedCard() : _buildLockCard(),
                  ),
                ),
              ),
            )
          else
            Positioned.fill(
              child: ColoredBox(
                color: SimColors.slate950.withValues(alpha: 0.1),
                child: Center(
                  child: Padding(padding: const EdgeInsets.all(24), child: _buildParentCard()),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLockCard() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SimColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: SimColors.slate50, shape: BoxShape.circle),
              child: const Icon(LucideIcons.lock, size: 48, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'System Locked',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          const Text(
            'SchooKeep is only accessible during school hours (Mon–Fri, 7:30 AM – 5:00 PM).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.4, color: SimColors.slate500),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: SimColors.slate50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SimColors.slate100),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.shieldAlert, size: 16, color: Color(0xFFF59E0B)),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Next access: Tomorrow at 7:30 AM',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: SimColors.slate100),
          const SizedBox(height: 16),
          const Text(
            'EMERGENCY EXCEPTION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SimColors.slate500, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'If you have an emergency authorization code from your Principal, enter it below:',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _codeController,
            obscureText: true,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Enter emergency code',
              hintStyle: const TextStyle(color: SimColors.slate400),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SimColors.slate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SimColors.slate400, width: 2),
              ),
            ),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFF43F5E))),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _override,
            style: OutlinedButton.styleFrom(
              backgroundColor: SimColors.white,
              side: const BorderSide(color: SimColors.slate200),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Override Access', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                SizedBox(width: 6),
                Icon(LucideIcons.arrowRight, size: 16, color: Color(0xFF1E293B)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Try demo bypass code: ', style: TextStyle(fontSize: 10, color: SimColors.slate400)),
                TextSpan(text: '9999', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SimColors.slate500)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParentCard() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
            child: const Icon(LucideIcons.checkCircle2, size: 24, color: Color(0xFF059669)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Parent Access Unrestricted',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF064E3B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are logged in under a Parent role. Parents maintain unrestricted 24/7 access to view child health records, dose history, and bus tracking.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF047857)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go('/parent/app/home'),
              child: const Text('Go to Parent Dashboard',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverrideAcceptedCard extends StatelessWidget {
  const _OverrideAcceptedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: SimColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
            child: const Icon(LucideIcons.checkCircle2, size: 40, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 16),
          const Text('Override Accepted',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          const Text(
            'Emergency bypass granted. Temporary access is unlocked.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: SimColors.slate500),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(999)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.refreshCw, size: 14, color: Color(0xFF059669)),
                SizedBox(width: 8),
                Text('Loading SchooKeep Portal...',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The blurred mock dashboard rendered behind the lock overlay.
class _BlurredDashboard extends StatelessWidget {
  const _BlurredDashboard();

  @override
  Widget build(BuildContext context) {
    Widget card({double height = 0}) => Container(
          height: height == 0 ? null : height,
          decoration: BoxDecoration(
            color: SimColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SimColors.slate200),
          ),
          padding: const EdgeInsets.all(12),
        );

    return ColoredBox(
      color: SimColors.slate50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: AlignmentDirectional.centerStart,
              decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(8)),
              child: const Text('SchooKeep Dashboard',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            card(height: 112),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: card(height: 96)),
                const SizedBox(width: 12),
                Expanded(child: card(height: 96)),
              ],
            ),
            const SizedBox(height: 12),
            card(height: 144),
          ],
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.value, required this.items, required this.onChanged});
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
