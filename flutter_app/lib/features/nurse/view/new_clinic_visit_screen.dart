import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../cubit/new_clinic_visit_cubit.dart';

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
      final msg = state is NewClinicVisitError ? state.message : context.tr(en: 'Could not log the visit.', ar: 'تعذر تسجيل الزيارة.');
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.tr(en: 'Clinic visit logged.', ar: 'تم تسجيل زيادة العيادة بنجاح.'))));
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
            titleWidget: Text(
              context.tr(en: 'New Clinic Visit', ar: 'تسجيل زيارة عيادة جديدة'),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: isEmergency ? Colors.white : SchooKeepColors.textPrimary,
              ),
            ),
            onBack: () => context.go('/nurse/clinic'),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _studentSelector(context, state),
                const SizedBox(height: 24),
                _visitTypeSelector(context),
                const SizedBox(height: 24),
                _reasonGrid(context),
                const SizedBox(height: 24),
                _vitalSigns(context),
                const SizedBox(height: 24),
                _clinicalNotesField(context),
                const SizedBox(height: 24),
                _photoAttachment(context),
                const SizedBox(height: 24),
                _immutabilityWarning(context),
                const SizedBox(height: 24),
                _parentNotification(context),
                const SizedBox(height: 24),
                SchooKeepButton(
                  label: submitting
                      ? context.tr(en: 'Logging…', ar: 'جاري التسجيل...')
                      : context.tr(en: 'Log Visit', ar: 'حفظ وحفظ الزيارة'),
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

  Widget _studentSelector(BuildContext context, NewClinicVisitState state) {
    final (name, sub, initials) = switch (state) {
      NewClinicVisitReady(:final student) => (
          student.name,
          [
            if ((student.grade ?? '').isNotEmpty) '${context.tr(en: 'Grade', ar: 'الصف')} ${student.grade}',
            if ((student.section ?? '').isNotEmpty) '${context.tr(en: 'Room', ar: 'القاعة')} ${student.section}',
          ].join(' · '),
          student.initials,
        ),
      NewClinicVisitError(:final message) => (message, '', '!'),
      _ => (context.tr(en: 'Loading…', ar: 'جاري التحميل...'), '', '…'),
    };
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context.tr(en: 'Student *', ar: 'الطالب *')),
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

  Widget _visitTypeSelector(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context.tr(en: 'Visit Type *', ar: 'نوع الزيارة *')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _typeButton('routine', context.tr(en: 'Routine', ar: 'روتينية'), SchooKeepColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: _typeButton('emergency', context.tr(en: 'Emergency', ar: 'طوارئ'), SchooKeepColors.error)),
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

  Widget _reasonGrid(BuildContext context) {
    final reasonCategories = [
      context.tr(en: 'Injury', ar: 'إصابة'),
      context.tr(en: 'Illness', ar: 'مرض'),
      context.tr(en: 'Medication', ar: 'دواء'),
      context.tr(en: 'Checkup', ar: 'فحص'),
      context.tr(en: 'Mental Health', ar: 'صحة نفسية'),
      context.tr(en: 'Other', ar: 'أخرى'),
    ];

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context.tr(en: 'Reason Category *', ar: 'تصنيف السبب *')),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: [
              for (final reason in reasonCategories) _reasonChip(reason),
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

  Widget _vitalSigns(BuildContext context) {
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
                  Text(
                    context.tr(en: 'Vital Signs (Optional)', ar: 'العلامات الحيوية (اختياري)'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                  ),
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
                      Expanded(child: _vitalField(context.tr(en: 'Temperature (°F)', ar: 'درجة الحرارة (°F)'), '98.6', TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _vitalField(context.tr(en: 'Heart Rate (bpm)', ar: 'نبضات القلب (bpm)'), '72', TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _vitalField(context.tr(en: 'Blood Pressure (mmHg)', ar: 'ضغط الدم (mmHg)'), '120/80', TextInputType.text),
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

  Widget _clinicalNotesField(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context.tr(en: 'Clinical Notes *', ar: 'الملاحظات السريرية والتأريضية *')),
          const SizedBox(height: 8),
          TextField(
            controller: _clinicalNotes,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: context.tr(en: 'Notes (will be locked after save)', ar: 'أدخل الملاحظات السريرية (سيتم قفلها بعد الحفظ)'),
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
          Text(
            context.tr(en: 'All clinical notes are permanently locked after saving', ar: 'جميع الملاحظات السريرية تقفل نهائياً بعد الحفظ للحماية'),
            style: const TextStyle(fontSize: 12, color: SchooKeepColors.warning),
          ),
        ],
      ),
    );
  }

  Widget _photoAttachment(BuildContext context) {
    return SchooKeepCard(
      onTap: () => context.push('/nurse/clinic/emergency-photo'),
      child: Row(
        children: [
          const Icon(LucideIcons.camera, size: 24, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Add photo/video', ar: 'إرفاق صورة/فيديو سريري'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                Text(
                  context.tr(en: 'Optional', ar: 'اختياري'),
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _immutabilityWarning(BuildContext context) {
    return AccentCard(
      background: SchooKeepColors.amberBg,
      accentColor: SchooKeepColors.warning,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr(
                en: 'This record cannot be edited after saving. A corrective note can be appended.',
                ar: 'لا يمكن تعديل هذا السجل بعد الحفظ. يمكنك إضافة ملاحظة تصحيحية لاحقاً.',
              ),
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.amberText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _parentNotification(BuildContext context) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(en: 'Notify parent immediately', ar: 'إشعار ولي الأمر فوراً'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                  ),
                  Text(
                    context.tr(en: 'Send clinic visit notification via SMS and app', ar: 'إرسال إشعار زيارة العيادة عبر الرسائل النصية والتطبيق'),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
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
