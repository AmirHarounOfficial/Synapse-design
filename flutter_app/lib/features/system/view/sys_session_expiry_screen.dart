import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/simulator_frame.dart';

enum _SessionState { active, warning, expired }

/// Ported from `SysSessionExpiry.tsx` (SYS-04). A HIPAA inactivity warning shown
/// as a slide-up bottom sheet with a live MM:SS auto-logout countdown. "Stay
/// signed in" resets to an active banner; "Sign out" or timer expiry shows the
/// expired banner then routes to /login. A demo toggle speeds the timer up (10s
/// per tick).
class SysSessionExpiryScreen extends StatefulWidget {
  const SysSessionExpiryScreen({super.key});

  @override
  State<SysSessionExpiryScreen> createState() => _SysSessionExpiryScreenState();
}

class _SysSessionExpiryScreenState extends State<SysSessionExpiryScreen> {
  bool _warningOpen = true;
  int _secondsLeft = 300;
  bool _accelerated = false;
  _SessionState _state = _SessionState.warning;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (!_warningOpen || _state != _SessionState.warning) return;
      setState(() {
        final next = _secondsLeft - (_accelerated ? 10 : 1);
        if (next <= 0) {
          _secondsLeft = 0;
          _state = _SessionState.expired;
          _warningOpen = false;
          timer.cancel();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) context.go('/login');
          });
        } else {
          _secondsLeft = next;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int total) {
    final mins = (total ~/ 60).toString().padLeft(2, '0');
    final secs = (total % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _staySignedIn() {
    setState(() {
      _secondsLeft = 300;
      _state = _SessionState.active;
      _warningOpen = false;
    });
  }

  void _signOut() {
    setState(() {
      _state = _SessionState.expired;
      _warningOpen = false;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/login');
    });
  }

  void _triggerWarning() {
    setState(() {
      _secondsLeft = 300;
      _state = _SessionState.warning;
      _warningOpen = true;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return SimulatorFrame(
      statusTime: '3:35 PM',
      deviceColor: SimColors.slate100,
      controls: SimDemoControls(
        label: 'SYS-04 Demo Controls',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _accelerated,
                    onChanged: (v) => setState(() => _accelerated = v ?? false),
                    side: const BorderSide(color: SimColors.slate400),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Speed up', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SimColors.slate200)),
              ],
            ),
            if (_state != _SessionState.warning)
              TextButton(
                onPressed: _triggerWarning,
                child: const Text('Re-Trigger', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
          ],
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _appBar(),
              Expanded(
                child: ColoredBox(
                  color: SimColors.slate50,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_state == _SessionState.active) _activeBanner(),
                        if (_state == _SessionState.expired) _expiredBanner(),
                        if (_state != _SessionState.warning) const SizedBox(height: 16),
                        _dossierCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_warningOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _staySignedIn,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: _warningSheet()),
          ],
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
          const Text('Nurse Admin Portal',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: SimColors.slate100, shape: BoxShape.circle),
            child: const Text('RN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }

  Widget _activeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.shieldCheck, size: 20, color: Color(0xFF059669)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session Renewed Successfully',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
                Text('Your secure connection has been extended. Next timeout check in 15 minutes.',
                    style: TextStyle(fontSize: 10, color: Color(0xFF047857))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _expiredBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDA4AF)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.refreshCw, size: 20, color: Color(0xFFE11D48)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session Expired',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF881337))),
                Text('You are being securely logged out due to inactivity...',
                    style: TextStyle(fontSize: 10, color: Color(0xFFBE123C))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dossierCard() {
    Widget bar(double widthFactor, {double height = 24}) => FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: widthFactor,
          child: Container(
            height: height,
            decoration: BoxDecoration(color: SimColors.slate100, borderRadius: BorderRadius.circular(4)),
          ),
        );

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
          const Text('ACTIVE CLINICAL DOSSIER',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SimColors.slate400, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          const Text('Medication Log Verification',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 10),
          bar(5 / 6),
          const SizedBox(height: 8),
          bar(2 / 3),
          const SizedBox(height: 8),
          bar(1, height: 40),
        ],
      ),
    );
  }

  Widget _warningSheet() {
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.clock, size: 14, color: Color(0xFFF43F5E)),
                          SizedBox(width: 6),
                          Text('SECURITY WARNING',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFBE123C))),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _staySignedIn,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: SimColors.slate100, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.x, size: 16, color: SimColors.slate500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Your session will expire in 5 minutes due to inactivity.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text(
                  'For security reasons and HIPAA compliance, clinical sessions automatically close after extended inactivity.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: SimColors.slate500),
                ),
                const SizedBox(height: 16),
                // Countdown clock
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SimColors.slate950,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    children: [
                      const Text('AUTO-LOGOUT COUNTDOWN',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E), letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(_secondsLeft),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: Color(0xFFFB7185),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _staySignedIn,
                    child: const Text('Stay signed in',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: SimColors.white,
                      side: const BorderSide(color: SimColors.slate200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _signOut,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.logOut, size: 16, color: SimColors.slate500),
                        SizedBox(width: 8),
                        Text('Sign out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      ],
                    ),
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
