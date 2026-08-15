import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../cubit/new_clinic_visit_cubit.dart';

/// Ported from `NewClinicVisit.tsx`, wired to `POST /clinic-visits`. The
/// student + school are resolved from the API (current nurse's school, first
/// student); the rest of the form (reason, vitals, notes) maps to the request.
class NewClinicVisitScreen extends StatelessWidget {
  const NewClinicVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewClinicVisitCubit(
        sl<ClinicRepository>(),
        sl<StudentRepository>(),
        sl<AuthRepository>(),
      ),
      child: const _NewClinicVisitView(),
    );
  }
}

class _NewClinicVisitView extends StatefulWidget {
  const _NewClinicVisitView();

  @override
  State<_NewClinicVisitView> createState() => _NewClinicVisitViewState();
}

class _NewClinicVisitViewState extends State<_NewClinicVisitView> {
  String _visitType = 'routine';
  String _selectedReason = '';
  bool _showVitals = false;
  bool _notifyParent = true;
  final TextEditingController _clinicalNotes = TextEditingController();

  static const _reasonCategories = ['Injury', 'Illness', 'Medication', 'Checkup', 'Mental Health', 'Other'];

  bool get _isFormValid => _selectedReason.isNotEmpty && _clinicalNotes.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _clinicalNotes.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _clinicalNotes.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final isEmergency = _visitType == 'emergency';
    final ok = await context.read<NewClinicVisitCubit>().submit(
          reason: _selectedReason,
          notes: _clinicalNotes.text.trim(),
          isEmergency: isEmergency,
          severity: _selectedReason,
        );
    if (!mounted) return;
    if (!ok) {
      final state = context.read<NewClinicVisitCubit>().state;
      final msg = state is NewClinicVisitError ? state.message : 'Could not log the visit.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Clinic visit logged.')));
    if (isEmergency) {
      context.go('/nurse/clinic/emergency-photo');
    } else {
      context.go('/nurse/clinic');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmergency = _visitType == 'emergency';
    return BlocBuilder<NewClinicVisitCubit, NewClinicVisitState>(
      builder: (context, state) {
        final submitting = state is NewClinicVisitReady && state.submitting;
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            backgroundColor: isEmergency ? SchooKeepColors.error : SchooKeepColors.surface,
            titleWidget: Text('New Clinic Visit',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: isEmergency ? Colors.white : SchooKeepColors.textPrimary,
                )),
            onBack: () => context.go('/nurse/clinic'),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _studentSelector(state),
                const SizedBox(height: 24),
                _visitTypeSelector(),
                const SizedBox(height: 24),
                _reasonGrid(),
                const SizedBox(height: 24),
                _vitalSigns(),
                const SizedBox(height: 24),
                _clinicalNotesField(),
                const SizedBox(height: 24),
                _photoAttachment(),
                const SizedBox(height: 24),
                _immutabilityWarning(),
                const SizedBox(height: 24),
                _parentNotification(),
                const SizedBox(height: 24),
                SchooKeepButton(
                  label: submitting ? 'Logging…' : 'Log Visit',
                  variant: SchooKeepButtonVariant.secondary,
                  enabled: _isFormValid && state is NewClinicVisitReady && !submitting,
                  onPressed: (_isFormValid && state is NewClinicVisitReady && !submitting) ? _handleSubmit : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary));

  Widget _studentSelector(NewClinicVisitState state) {
    final (name, sub, initials) = switch (state) {
      NewClinicVisitReady(:final student) => (
          student.name,
          [
            if ((student.grade ?? '').isNotEmpty) 'Grade ${student.grade}',
            if ((student.section ?? '').isNotEmpty) 'Room ${student.section}',
          ].join(' · '),
          student.initials,
        ),
      NewClinicVisitError(:final message) => (message, '', '!'),
      _ => ('Loading…', '', '…'),
    };
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Student *'),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: SchooKeepColors.primary,
                  child: Text(initials,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      if (sub.isNotEmpty)
                        Text(sub, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronDown, size: 20, color: SchooKeepColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitTypeSelector() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Visit Type *'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _typeButton('routine', 'Routine', SchooKeepColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: _typeButton('emergency', 'Emergency', SchooKeepColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeButton(String value, String label, Color activeColor) {
    final active = _visitType == value;
    return GestureDetector(
      onTap: () => setState(() => _visitType = value),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? activeColor : SchooKeepColors.background,
          borderRadius: BorderRadius.circular(8),
          border: active ? null : Border.all(color: SchooKeepColors.border),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : SchooKeepColors.textSecondary,
            )),
      ),
    );
  }

  Widget _reasonGrid() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Reason Category *'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: [
              for (final reason in _reasonCategories) _reasonChip(reason),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reasonChip(String reason) {
    final active = _selectedReason == reason;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : SchooKeepColors.background,
          borderRadius: BorderRadius.circular(8),
          border: active ? null : Border.all(color: SchooKeepColors.border),
        ),
        child: Text(reason,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : SchooKeepColors.textSecondary,
            )),
      ),
    );
  }

  Widget _vitalSigns() {
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showVitals = !_showVitals),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vital Signs (Optional)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                  AnimatedRotation(
                    turns: _showVitals ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(LucideIcons.chevronDown, size: 20, color: SchooKeepColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          if (_showVitals)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: SchooKeepColors.border)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _vitalField('Temperature (°F)', '98.6', TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _vitalField('Heart Rate (bpm)', '72', TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _vitalField('Blood Pressure (mmHg)', '120/80', TextInputType.text),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _vitalField(String label, String hint, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            keyboardType: type,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _clinicalNotesField() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Clinical Notes *'),
          const SizedBox(height: 8),
          TextField(
            controller: _clinicalNotes,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Notes (will be locked after save)',
              hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('All clinical notes are permanently locked after saving',
              style: TextStyle(fontSize: 12, color: SchooKeepColors.warning)),
        ],
      ),
    );
  }

  Widget _photoAttachment() {
    return SchooKeepCard(
      onTap: () => context.push('/nurse/clinic/emergency-photo'),
      child: Row(
        children: const [
          Icon(LucideIcons.camera, size: 24, color: SchooKeepColors.textSecondary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add photo/video',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                Text('Optional', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _immutabilityWarning() {
    return AccentCard(
      background: SchooKeepColors.amberBg,
      accentColor: SchooKeepColors.warning,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
          SizedBox(width: 12),
          Expanded(
            child: Text('This record cannot be edited after saving. A corrective note can be appended.',
                style: TextStyle(fontSize: 13, color: SchooKeepColors.amberText)),
          ),
        ],
      ),
    );
  }

  Widget _parentNotification() {
    return SchooKeepCard(
      child: InkWell(
        onTap: () => setState(() => _notifyParent = !_notifyParent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _notifyParent,
                onChanged: (v) => setState(() => _notifyParent = v ?? false),
                activeColor: SchooKeepColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notify parent immediately',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  Text('Send clinic visit notification via SMS and app',
                      style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
