import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../cubit/teacher_clinic_referral_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

enum _Severity { minor, moderate, emergency }

/// Ported from `TeacherClinicReferral.tsx`, wired to the API. Student search
/// hits `GET /students`, photo attach uses `image_picker`, and submit creates a
/// clinic visit (`POST /clinic-visits`).
///
/// NOTE: clinic-visit writes are nurse-only on the backend, so a teacher submit
/// returns 403; the mapped error is shown rather than a fake success.
class TeacherClinicReferralScreen extends StatelessWidget {
  const TeacherClinicReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeacherClinicReferralCubit(
        sl<ClinicRepository>(),
        sl<StudentRepository>(),
        sl<AuthRepository>(),
      ),
      child: const _TeacherClinicReferralView(),
    );
  }
}

class _TeacherClinicReferralView extends StatefulWidget {
  const _TeacherClinicReferralView();

  @override
  State<_TeacherClinicReferralView> createState() => _TeacherClinicReferralViewState();
}

class _TeacherClinicReferralViewState extends State<_TeacherClinicReferralView> {
  final ImagePicker _picker = ImagePicker();
  bool _isEmergency = false;
  Student? _selectedStudent;
  String _searchQuery = '';
  bool _showResults = false;
  String _description = '';
  _Severity? _severity;
  String? _location;
  XFile? _media;
  bool _isSuccess = false;
  bool _submitting = false;

  final _searchController = TextEditingController();

  static const _locations = ['Classroom', 'Hallway', 'Cafeteria', 'Field', 'Gym', 'Playground'];

  bool get _canSubmit =>
      _selectedStudent != null && _description.trim().isNotEmpty && _severity != null && _location != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectStudent(Student s) {
    setState(() {
      _selectedStudent = s;
      _searchQuery = '';
      _searchController.clear();
      _showResults = false;
    });
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 80);
      if (!mounted) return;
      if (file != null) setState(() => _media = file);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Could not access photos.')));
    }
  }

  String _severityLabel(_Severity s) => switch (s) {
        _Severity.minor => 'minor',
        _Severity.moderate => 'moderate',
        _Severity.emergency => 'severe',
      };

  Future<void> _submit() async {
    if (!_canSubmit || _submitting) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<TeacherClinicReferralCubit>().submit(
          student: _selectedStudent!,
          description: _description.trim(),
          severity: _severityLabel(_severity!),
          location: _location!,
          isEmergency: _isEmergency,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _isSuccess = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/teacher/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return SchooKeepScaffold(
        reserveBottomNav: true,
        scrollable: false,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: SchooKeepColors.greenChipBg, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.check, size: 32, color: SchooKeepColors.accent),
                ),
                const SizedBox(height: 16),
                const Text('Referral Sent to Clinic',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 8),
                Text(_selectedStudent?.name ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.amberChipBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _PulseDot(),
                      SizedBox(width: 8),
                      Text('Awaiting nurse response',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        title: 'Clinic Referral',
      ),
      bottomBar: _submitBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _emergencyToggle(),
            const SizedBox(height: 24),
            _studentSelector(),
            const SizedBox(height: 24),
            _descriptionField(),
            const SizedBox(height: 24),
            _mediaSection(),
            const SizedBox(height: 24),
            _severitySection(),
            const SizedBox(height: 24),
            _locationSection(),
          ],
        ),
      ),
    );
  }

  Widget _emergencyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isEmergency ? const Color(0xFFFEE2E2) : SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isEmergency ? SchooKeepColors.error : SchooKeepColors.border, width: _isEmergency ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_isEmergency) ...[
                const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.error),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text('Mark as Emergency',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _isEmergency ? SchooKeepColors.error : SchooKeepColors.textPrimary)),
              ),
              Switch(
                value: _isEmergency,
                activeThumbColor: Colors.white,
                activeTrackColor: SchooKeepColors.error,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: SchooKeepColors.border,
                onChanged: (v) => setState(() {
                  _isEmergency = v;
                  if (v) _severity = _Severity.emergency;
                }),
              ),
            ],
          ),
          if (_isEmergency)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Nurse will be notified immediately',
                  style: TextStyle(fontSize: 12, color: SchooKeepColors.error)),
            ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
              text: text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          if (required)
            const TextSpan(text: ' *', style: TextStyle(fontSize: 14, color: SchooKeepColors.error)),
        ]),
      ),
    );
  }

  Widget _studentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Select Student', required: true),
        if (_selectedStudent != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Row(
              children: [
                _smallAvatar(_selectedStudent!.initials),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedStudent!.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      Text([
                        if ((_selectedStudent!.grade ?? '').isNotEmpty) 'Grade ${_selectedStudent!.grade}',
                        if ((_selectedStudent!.section ?? '').isNotEmpty) _selectedStudent!.section!,
                      ].join(' · '),
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _selectedStudent = null),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(LucideIcons.x, size: 16, color: SchooKeepColors.textSecondary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          TextField(
            controller: _searchController,
            onChanged: (v) {
              setState(() {
                _searchQuery = v;
                _showResults = true;
              });
              context.read<TeacherClinicReferralCubit>().search(v);
            },
            onTap: () => setState(() => _showResults = true),
            decoration: _inputDecoration('Search student name...',
                prefix: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary)),
          ),
          if (_showResults && _searchQuery.isNotEmpty)
            BlocBuilder<TeacherClinicReferralCubit, DataState<List<Student>>>(
              builder: (context, state) {
                final results = state is DataLoaded<List<Student>> ? state.data : const <Student>[];
                if (state is DataLoading) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                if (state is DataError<List<Student>>) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(state.message, style: const TextStyle(fontSize: 12, color: SchooKeepColors.error)),
                  );
                }
                if (results.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SchooKeepColors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < results.length; i++)
                        InkWell(
                          onTap: () => _selectStudent(results[i]),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: i == results.length - 1
                                  ? null
                                  : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                _smallAvatar(results[i].initials),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(results[i].name,
                                          style: const TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                                      Text([
                                        if ((results[i].grade ?? '').isNotEmpty) 'Grade ${results[i].grade}',
                                        if ((results[i].section ?? '').isNotEmpty) results[i].section!,
                                      ].join(' · '),
                                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ],
    );
  }

  Widget _descriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Incident Description', required: true),
        TextField(
          maxLines: 4,
          onChanged: (v) => setState(() => _description = v),
          decoration: _inputDecoration('Describe what happened...'),
        ),
      ],
    );
  }

  Widget _mediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Photo or Video (Optional)'),
        Row(
          children: [
            Expanded(child: _mediaButton(LucideIcons.camera, 'Take Photo', ImageSource.camera)),
            const SizedBox(width: 8),
            Expanded(child: _mediaButton(LucideIcons.image, 'Choose from Gallery', ImageSource.gallery)),
          ],
        ),
        if (_media != null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(LucideIcons.check, size: 16, color: SchooKeepColors.accent),
                SizedBox(width: 8),
                Text('1 photo attached', style: TextStyle(fontSize: 13, color: SchooKeepColors.accent)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _mediaButton(IconData icon, String label, ImageSource source) {
    return SizedBox(
      height: 44,
      child: Material(
        color: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), side: const BorderSide(color: SchooKeepColors.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pickMedia(source),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _severitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Severity', required: true),
        Row(
          children: [
            Expanded(child: _severityButton(_Severity.minor, 'Minor', SchooKeepColors.accent, disabled: _isEmergency)),
            const SizedBox(width: 8),
            Expanded(child: _severityButton(_Severity.moderate, 'Moderate', SchooKeepColors.warning, disabled: _isEmergency)),
            const SizedBox(width: 8),
            Expanded(child: _severityButton(_Severity.emergency, 'Emergency', SchooKeepColors.error)),
          ],
        ),
      ],
    );
  }

  Widget _severityButton(_Severity value, String label, Color selectedColor, {bool disabled = false}) {
    final selected = _severity == value;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: SizedBox(
        height: 44,
        child: Material(
          color: selected ? selectedColor : SchooKeepColors.surface,
          shape: selected
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), side: BorderSide.none)
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), side: const BorderSide(color: SchooKeepColors.border)),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: disabled ? null : () => setState(() => _severity = value),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: selected ? Colors.white : SchooKeepColors.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Location', required: true),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.6,
          children: [
            for (final loc in _locations)
              Material(
                color: _location == loc ? SchooKeepColors.primary : SchooKeepColors.surface,
                shape: _location == loc
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), side: BorderSide.none)
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), side: const BorderSide(color: SchooKeepColors.border)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _location = loc),
                  child: Center(
                    child: Text(loc,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _location == loc ? Colors.white : SchooKeepColors.textSecondary)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _submitBar() {
    final bg = _isEmergency && _canSubmit
        ? SchooKeepColors.error
        : _canSubmit
            ? SchooKeepColors.primary
            : SchooKeepColors.border;
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: (_canSubmit && !_submitting) ? _submit : null,
              child: Center(
                child: _submitting
                    ? const SizedBox(
                        width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEmergency ? 'Send Emergency Referral' : 'Send to Clinic',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _canSubmit ? Colors.white : const Color(0xFF94A3B8))),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
      prefixIcon: prefix,
      filled: true,
      fillColor: SchooKeepColors.surface,
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
        borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
      ),
    );
  }

  Widget _smallAvatar(String initials) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
      child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.4).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: SchooKeepColors.warning, shape: BoxShape.circle),
      ),
    );
  }
}
