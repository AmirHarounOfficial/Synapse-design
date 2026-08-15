import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/repositories/student_repository.dart';

/// Ported from `AddMedicationStep3.tsx`. English-only. Medication summary,
/// confirmation checklist (last item locked), state-compliance note, and a
/// permanent-record confirmation dialog. Confirming submits the medication to
/// the API (`POST /medications`).
///
/// The 3-step wizard does not persist its inputs across screens (each step is
/// independent local state in the source), so this step submits the values
/// shown in its summary card. The student is resolved by name via
/// `GET /students` to obtain the required `student_id`.
class AddMedicationStep3Screen extends StatefulWidget {
  const AddMedicationStep3Screen({super.key});

  @override
  State<AddMedicationStep3Screen> createState() => _AddMedicationStep3ScreenState();
}

class _AddMedicationStep3ScreenState extends State<AddMedicationStep3Screen> {
  bool _physicianOrder = true;
  bool _parentAuth = true;
  bool _photoCapture = true;
  bool _doseSchedule = true;
  final bool _stateCompliance = true;
  bool _submitting = false;

  final MedicationRepository _medRepo = sl<MedicationRepository>();
  final StudentRepository _studentRepo = sl<StudentRepository>();

  // Summary values shown on this screen (the wizard does not pass them along).
  static const String _summaryStudentName = 'Maya Chen';
  static const String _summaryMedicationName = 'Methylphenidate';
  static const String _summaryDosage = '10mg';

  bool get _allChecked =>
      _physicianOrder && _parentAuth && _photoCapture && _doseSchedule && _stateCompliance;

  void _handleSubmit() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: SchooKeepColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.info, size: 24, color: SchooKeepColors.warning),
                  ),
                  const SizedBox(height: 16),
                  const Text('Confirm Medication Record',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('This medication record is permanent and cannot be deleted. Proceed?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
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
                        _submit();
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
      },
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Resolve the student id from the summary's student name.
      final page = await _studentRepo.list(query: _summaryStudentName);
      if (page.items.isEmpty) {
        throw StateError('Student "$_summaryStudentName" not found.');
      }
      final studentId = page.items.first.id;
      await _medRepo.create(
        studentId: studentId,
        name: _summaryMedicationName,
        dosage: _summaryDosage,
        status: 'pending',
        requiresPhysician: true,
      );
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Medication added successfully!')));
      context.go('/nurse/medications');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final message = e is StateError ? e.message : MedicationRepository.messageFor(e);
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: SchooKeepColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Add Medication',
        centerTitle: true,
        onBack: () => context.go('/nurse/medications/add/step2'),
        actions: const [
          Center(
            child: Text('Step 3 of 3',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepProgress(activeStep: 3),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary card
                SchooKeepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Medication Summary',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      SizedBox(height: 12),
                      _SummaryRow('Student', 'Maya Chen - Grade 5'),
                      _SummaryRow('Medication', 'Methylphenidate 10mg'),
                      _SummaryRow('Type', 'Permanent'),
                      _SummaryRow('Daily Doses', '1 dose'),
                      _SummaryRow('Dose Time', '08:00 AM', last: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Confirmation checklist
                SchooKeepCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Confirmation Checklist',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      const SizedBox(height: 16),
                      _checkRow('Physician order on file', _physicianOrder,
                          (v) => setState(() => _physicianOrder = v)),
                      const SizedBox(height: 12),
                      _checkRow('Parent authorization signed', _parentAuth,
                          (v) => setState(() => _parentAuth = v)),
                      const SizedBox(height: 12),
                      _checkRow('Medication photo captured', _photoCapture,
                          (v) => setState(() => _photoCapture = v)),
                      const SizedBox(height: 12),
                      _checkRow('Dose schedule set', _doseSchedule,
                          (v) => setState(() => _doseSchedule = v)),
                      const SizedBox(height: 12),
                      _checkRow('State compliance verified', _stateCompliance, null),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // State compliance note
                AccentCard(
                  background: const Color(0xFFEFF6FF),
                  accentColor: SchooKeepColors.primary,
                  accentWidth: 4,
                  radius: 12,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(LucideIcons.info, size: 20, color: SchooKeepColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your state requires a licensed RN for medication administration. This task cannot be delegated.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.accent,
                      disabledBackgroundColor: SchooKeepColors.accent.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: (_allChecked && !_submitting) ? _handleSubmit : null,
                    child: Text(_submitting ? 'Adding…' : 'Add Medication',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool checked, ValueChanged<bool>? onChanged) {
    final disabled = onChanged == null;
    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: InkWell(
        onTap: disabled ? null : () => onChanged(!checked),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: checked,
                onChanged: disabled ? null : (v) => onChanged(v ?? false),
                activeColor: SchooKeepColors.accent,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.activeStep});
  final int activeStep;

  @override
  Widget build(BuildContext context) {
    Color barColor(int step) {
      if (step < activeStep) return SchooKeepColors.accent;
      if (step == activeStep) return SchooKeepColors.primary;
      return SchooKeepColors.border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Row(
        children: [
          for (var step = 1; step <= 3; step++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: barColor(step), borderRadius: BorderRadius.circular(999)),
              ),
            ),
            if (step < 3) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}
