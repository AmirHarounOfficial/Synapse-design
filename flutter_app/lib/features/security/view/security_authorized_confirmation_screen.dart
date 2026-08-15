import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/pickup.dart';
import '../../../data/repositories/pickup_repository.dart';

/// Ported from `SecurityAuthorizedConfirmation.tsx`. Full-bleed green success
/// screen confirming a release. When reached with a verified [pickup] (from the
/// scanner or manual verification), it calls `POST /pickups/{id}/release` on
/// entry and shows the real student/person/time. Auto-redirects after 3s.
class SecurityAuthorizedConfirmationScreen extends StatefulWidget {
  const SecurityAuthorizedConfirmationScreen({super.key, this.pickup});

  /// The verified pickup to release. Null when navigated to directly (the
  /// screen then just shows a generic confirmation without a server call).
  final Pickup? pickup;

  @override
  State<SecurityAuthorizedConfirmationScreen> createState() => _SecurityAuthorizedConfirmationScreenState();
}

class _SecurityAuthorizedConfirmationScreenState extends State<SecurityAuthorizedConfirmationScreen> {
  late final String _currentTime;
  Timer? _timer;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    final hour12 = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    _currentTime = '${hour12.toString().padLeft(2, '0')}:$minute $period';

    _releaseIfNeeded();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) context.go('/security/pickups');
    });
  }

  Future<void> _releaseIfNeeded() async {
    final pickup = widget.pickup;
    // Only release if it isn't already released (the scan endpoint returns a
    // 'verified' pickup; manual verification may already have released it).
    if (pickup == null || pickup.isReleased) return;
    try {
      await sl<PickupRepository>().release(pickup.id);
    } catch (e) {
      if (mounted) setState(() => _error = PickupRepository.messageFor(e));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SchooKeepColors.accent,
      child: Column(
        children: [
          const SizedBox(
            height: SchooKeepTheme.statusBarHeight,
            child: ColoredBox(color: SchooKeepColors.accent),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 384),
                    child: Column(
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: Container(
                            width: 112,
                            height: 112,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.check, size: 80, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text('Student Released',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 16),
                        _detailsCard(),
                        const SizedBox(height: 24),
                        if (_error != null) ...[
                          _errorNotice(_error!),
                          const SizedBox(height: 24),
                        ],
                        _lockedNotice(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => context.go('/security/pickups'),
                            child: const Text('Return to Pickups',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.accent)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Redirecting automatically in 3 seconds...',
                            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {String? sub, bool divider = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
        if (sub != null) ...[
          Text(sub, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
        ],
        if (divider) ...[
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _detailsCard() {
    final pickup = widget.pickup;
    final studentName = pickup?.student?.name ?? 'Student';
    final person = pickup?.authorizedPerson;
    final personName = person?.name ?? 'Authorized person';
    final relationship = person?.relationship;
    final method = pickup?.isQr == true ? 'QR verified' : 'Manually verified';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('STUDENT', studentName),
          _detailRow('RELEASED TO', personName, sub: relationship),
          _detailRow('TIME', _currentTime),
          _detailRow('METHOD', method, divider: false),
        ],
      ),
    );
  }

  Widget _errorNotice(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 20, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _lockedNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lock, size: 20, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This release has been logged',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'Permanent record created for security and compliance purposes. Cannot be modified.',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
