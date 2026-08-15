import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/authorized_person.dart';
import '../../../data/models/pickup.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/pickup_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../cubit/manual_verification_cubit.dart';

/// Ported from `SecurityManualVerification.tsx`, now wired to the API. Searches
/// students (`GET /students?q=`), shows the authorized pickup person on file
/// (derived from `GET /pickups?student_id=`), then on a match releases the
/// pending pickup (`POST /pickups/{id}/release`) or denies it.
class SecurityManualVerificationScreen extends StatelessWidget {
  const SecurityManualVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManualVerificationCubit(sl<StudentRepository>(), sl<PickupRepository>()),
      child: const _ManualVerificationView(),
    );
  }
}

class _ManualVerificationView extends StatefulWidget {
  const _ManualVerificationView();

  @override
  State<_ManualVerificationView> createState() => _ManualVerificationViewState();
}

class _ManualVerificationViewState extends State<_ManualVerificationView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<ManualVerificationCubit>().search(v);
    });
  }

  void _showConfirmation({
    required bool match,
    required Student student,
    required AuthorizedPerson? person,
    required Pickup? pickup,
  }) {
    final cubit = context.read<ManualVerificationCubit>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => _ConfirmationDialog(
        match: match,
        studentName: student.name,
        personName: person?.name ?? 'the authorized person',
        onCancel: () => Navigator.of(dialogContext).pop(),
        onConfirm: () async {
          Navigator.of(dialogContext).pop();
          if (match) {
            if (pickup != null) {
              final ok = await cubit.release(pickup);
              if (!ok) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Could not record the release. Please try again.')),
                );
                return;
              }
              router.go('/security/authorized-confirmation', extra: pickup);
            } else {
              // No pending pickup to release; still show the confirmation
              // (the queue had no open request for this student).
              router.go('/security/authorized-confirmation');
            }
          } else {
            router.go('/security/pickups');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Manual Verification',
        centerTitle: true,
        onBack: () => context.go('/security/scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ManualVerificationCubit, ManualVerificationState>(
          builder: (context, state) {
            return switch (state) {
              ManualDetailLoading(:final student) => _verificationSection(student, null, null, loading: true),
              ManualDetailLoaded(:final student, :final person, :final pickup) =>
                _verificationSection(student, person, pickup),
              ManualDetailError(:final student, :final message) =>
                _verificationError(student, message),
              _ => _searchSection(state),
            };
          },
        ),
      ),
    );
  }

  Widget _searchSection(ManualVerificationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SchooKeepCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SEARCH FOR STUDENT',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type student name...',
                  hintStyle: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary),
                  prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
                  constraints: const BoxConstraints(minHeight: 52),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SchooKeepColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state is ManualSearchLoading) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ] else if (state is ManualSearchError) ...[
          const SizedBox(height: 16),
          SchooKeepCard(
            child: Column(
              children: [
                Text(state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                const SizedBox(height: 12),
                SchooKeepButton(
                  label: 'Retry',
                  fullWidth: false,
                  onPressed: () => context.read<ManualVerificationCubit>().search(_searchController.text),
                ),
              ],
            ),
          ),
        ] else if (state is ManualSearchResults) ...[
          const SizedBox(height: 16),
          Text('RESULTS (${state.students.length})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SchooKeepColors.textSecondary,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 8),
          if (state.students.isEmpty)
            SchooKeepCard(
              child: Center(
                child: Text('No students found matching "${_searchController.text}"',
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
              ),
            )
          else
            for (final s in state.students) ...[
              SchooKeepCard(
                onTap: () => context.read<ManualVerificationCubit>().select(s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(_gradeLabel(s), style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ],
    );
  }

  static String _gradeLabel(Student s) {
    final parts = [
      if ((s.grade ?? '').isNotEmpty) 'Grade ${s.grade}',
      if ((s.section ?? '').isNotEmpty) s.section,
    ].whereType<String>().toList();
    return parts.join(' • ');
  }

  Widget _verificationError(Student s, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
        const SizedBox(height: 16),
        SchooKeepButton(
          label: 'Retry',
          onPressed: () => context.read<ManualVerificationCubit>().select(s),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.read<ManualVerificationCubit>().backToSearch(),
          child: const Text('Search Different Student',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
        ),
      ],
    );
  }

  Widget _verificationSection(Student s, AuthorizedPerson? person, Pickup? pickup, {bool loading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            border: Border.all(color: const Color(0xFFDBEAFE)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Compare the person's physical ID to the information shown below. Both name and photo must match.",
            style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        SchooKeepCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STUDENT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
              const SizedBox(height: 8),
              Text(s.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 4),
              Text(_gradeLabel(s), style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (person == null)
          SchooKeepCard(
            child: const Text(
              'No authorized pickup person is on file for this student. Escalate to administration before releasing.',
              style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
            ),
          )
        else
          SchooKeepCard(
            borderColor: SchooKeepColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AUTHORIZED PICKUP PERSON',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                      child: Text(person.initials,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(person.name,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(person.relationship ?? '',
                              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.amberChipBg,
                    border: Border.all(color: SchooKeepColors.warning),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Verify: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(
                            text:
                                "Does the person's government-issued ID match the name above? Do they appear to match the photo on file?"),
                      ],
                      style: TextStyle(fontSize: 12, color: SchooKeepColors.amberText, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: SchooKeepColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: loading
                ? null
                : () => _showConfirmation(match: true, student: s, person: person, pickup: pickup),
            icon: const Icon(LucideIcons.check, size: 24, color: Colors.white),
            label: const Text('ID Matches ✓',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: SchooKeepColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: loading
                ? null
                : () => _showConfirmation(match: false, student: s, person: person, pickup: pickup),
            icon: const Icon(LucideIcons.x, size: 24, color: Colors.white),
            label: const Text('ID Does Not Match ✗',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            onPressed: () => context.read<ManualVerificationCubit>().backToSearch(),
            child: const Text('Search Different Student',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.match,
    required this.studentName,
    required this.personName,
    required this.onCancel,
    required this.onConfirm,
  });
  final bool match;
  final String studentName;
  final String personName;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SchooKeepColors.surface,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: match ? SchooKeepColors.greenChipBg : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(match ? LucideIcons.check : LucideIcons.x,
                    size: 32, color: match ? SchooKeepColors.accent : SchooKeepColors.error),
              ),
              const SizedBox(height: 16),
              Text(match ? 'Confirm Student Release' : 'Deny Pickup Request',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              if (match) ...[
                Text('Release $studentName to $personName?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'This action will be logged with your security guard ID and timestamp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ),
              ] else
                const Text(
                  'This will log a denied pickup attempt and notify administration immediately.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: SchooKeepColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: onCancel,
                        child: const Text('Cancel',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: match ? SchooKeepColors.accent : SchooKeepColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: onConfirm,
                        child: const Text('Confirm',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
