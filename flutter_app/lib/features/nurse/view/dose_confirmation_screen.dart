import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/medication_repository.dart';

/// Ported from `DoseConfirmation.tsx`, now wired to the API. "Medication Due"
/// screen with a live updating clock, an administer confirmation dialog, and a
/// full-screen success overlay that auto-navigates back to the medications list.
///
/// When reached with [medicationId] and [studentId] query params, confirming
/// logs a "given" dose (`POST /dose-administrations`). Without ids (e.g. the
/// dashboard demo shortcut) it falls back to the original navigate-only flow.
class DoseConfirmationScreen extends StatefulWidget {
  const DoseConfirmationScreen({super.key, this.medicationId, this.studentId});

  final int? medicationId;
  final int? studentId;

  @override
  State<DoseConfirmationScreen> createState() => _DoseConfirmationScreenState();
}

class _DoseConfirmationScreenState extends State<DoseConfirmationScreen> {
  bool _showSuccess = false;
  bool _submitting = false;
  String _currentTime = '10:48 AM';
  static const int _minutesUntil = 12;
  String _confirmationTime = '';
  Timer? _timer;

  final MedicationRepository _repo = sl<MedicationRepository>();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = _formatTime(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime now, {bool withSeconds = false}) {
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour < 12 ? 'AM' : 'PM';
    final hh = hour12.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    if (withSeconds) {
      final ss = now.second.toString().padLeft(2, '0');
      return '$hh:$mm:$ss $period';
    }
    return '$hh:$mm $period';
  }

  void _handleAdminister() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => _confirmDialog(dialogContext),
    );
  }

  /// "Delay dose" — offer a short list of delay intervals in a bottom sheet.
  /// Picking one confirms the reschedule (in-app) and returns to the list.
  void _handleDelay() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SchooKeepColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        const options = [15, 30, 60];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text('Delay dose',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text('Reschedule this dose by:',
                    style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
              ),
              for (final minutes in options)
                ListTile(
                  leading: const Icon(LucideIcons.clock, size: 20, color: SchooKeepColors.primary),
                  title: Text('$minutes minutes',
                      style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDelay(minutes);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelay(int minutes) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dose delayed by $minutes minutes')),
    );
    context.go('/nurse/medications');
  }

  Future<void> _handleConfirm() async {
    final timestamp = _formatTime(DateTime.now(), withSeconds: true);
    final medId = widget.medicationId;
    final studentId = widget.studentId;

    // If we have a medication + student context, log the dose to the API.
    if (medId != null && studentId != null) {
      setState(() => _submitting = true);
      try {
        await _repo.logDose(medicationId: medId, studentId: studentId, status: 'given');
      } catch (e) {
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(MedicationRepository.messageFor(e)), backgroundColor: SchooKeepColors.error),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _confirmationTime = timestamp;
      _showSuccess = true;
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/nurse/medications');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _successScreen();
    }

    return SchooKeepScaffold(
      appBar: const SchooKeepAppBar(
        titleWidget: Text(
          'Medication Due',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.error),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _studentCard(),
            const SizedBox(height: 16),
            _medicationCard(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitting ? null : _handleAdminister,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.checkCircle, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Mark as Administered',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: _submitting ? null : _handleDelay,
                child: const Text('Delay dose',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentCard() {
    return SchooKeepCard(
      onTap: () => context.go('/nurse/students/maya-chen'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle),
            child: const Text('MC',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maya Chen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                Text('Grade 5 · Room 204', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Methylphenidate 10mg',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          const Text('Scheduled Time', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('11:00 AM',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 8),
              Text('Current time: $_currentTime',
                  style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: SchooKeepColors.amberChipBg, borderRadius: BorderRadius.circular(999)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.amberText),
                SizedBox(width: 6),
                Text('$_minutesUntil minutes until scheduled dose',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SchooKeepColors.border)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dose 2 of 3 today', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                SizedBox(height: 8),
                Text('14 doses remaining', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Physician order by Dr. Rodriguez on file ✓',
                      style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmDialog(BuildContext dialogContext) {
    return Dialog(
      backgroundColor: SchooKeepColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: SchooKeepColors.amberChipBg, shape: BoxShape.circle),
                child: const Icon(LucideIcons.alertTriangle, size: 24, color: SchooKeepColors.warning),
              ),
              const SizedBox(height: 16),
              const Text('Confirm Administration',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'This action is irreversible. Confirm administration of Methylphenidate 10mg to Maya Chen at $_currentTime?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SchooKeepColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _handleConfirm();
                  },
                  child: const Text('Confirm',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: SchooKeepColors.surface,
                    side: const BorderSide(color: SchooKeepColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successScreen() {
    return ColoredBox(
      color: SchooKeepColors.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
                child: const Icon(LucideIcons.checkCircle, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Dose Administered',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Recorded at $_confirmationTime',
                  style: const TextStyle(fontSize: 16, color: SchooKeepColors.textSecondary)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Record permanently locked',
                        style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
