import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/student_repository.dart';
import '../cubit/secretary_student_detail_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Secretary student-detail screen. Reached from the secretary student list
/// (`/secretary/student/:id`). Wired to `GET /students/{id}` via
/// [SecretaryStudentDetailCubit] + `DataState`. Shows the student's identity
/// (name, grade, section), medical summary, and allergens.
class SecretaryStudentDetailScreen extends StatelessWidget {
  const SecretaryStudentDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final studentId = int.tryParse(id) ?? 0;
    return BlocProvider(
      create: (_) => SecretaryStudentDetailCubit(sl<StudentRepository>(), studentId),
      child: const _SecretaryStudentDetailView(),
    );
  }
}

class _SecretaryStudentDetailView extends StatelessWidget {
  const _SecretaryStudentDetailView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'ملف الطالب' : 'Student Profile',
        centerTitle: true,
        onBack: () =>
            context.canPop() ? context.safeBack() : context.go('/secretary/students'),
      ),
      body: BlocBuilder<SecretaryStudentDetailCubit, DataState<Student>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _errorView(context, message, isRTL),
            DataLoaded(:final data) => _content(context, data, isRTL),
          };
        },
      ),
    );
  }

  Widget _errorView(BuildContext context, String message, bool isRTL) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: isRTL ? 'إعادة المحاولة' : 'Retry',
              fullWidth: false,
              onPressed: () => context.read<SecretaryStudentDetailCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, Student s, bool isRTL) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _heroCard(s, isRTL),
        const SizedBox(height: 16),
        _identityCard(s, isRTL),
        if ((s.medicalSummary ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          _medicalSummaryCard(s, isRTL),
        ],
        const SizedBox(height: 16),
        _allergensCard(s, isRTL),
      ],
    );
  }

  Widget _heroCard(Student s, bool isRTL) {
    final displayName = isRTL && (s.nameAr?.isNotEmpty ?? false) ? s.nameAr! : s.name;
    final subtitleParts = <String>[
      if ((s.grade ?? '').isNotEmpty) '${isRTL ? 'الصف' : 'Grade'} ${s.grade}',
      if ((s.section ?? '').isNotEmpty) '${isRTL ? 'الشعبة' : 'Section'} ${s.section}',
    ];
    return SchooKeepCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(s.initials,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                if (subtitleParts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitleParts.join(' · '),
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                ],
                const SizedBox(height: 10),
                _profilePill(s.profileActive, isRTL),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePill(bool active, bool isRTL) {
    final bg = active ? SchooKeepColors.greenChipBg : const Color(0xFFFEE2E2);
    final fg = active ? SchooKeepColors.greenChipText : SchooKeepColors.error;
    final label = active
        ? (isRTL ? 'ملف نشط' : 'Profile active')
        : (isRTL ? 'ملف غير نشط' : 'Profile inactive');
    return SchooKeepBadge(
      label: label,
      icon: active ? LucideIcons.checkCircle : LucideIcons.alertCircle,
      background: bg,
      foreground: fg,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _identityCard(Student s, bool isRTL) {
    final rows = <({String label, String value, bool mono})>[
      if ((s.emiratesId ?? '').isNotEmpty)
        (label: isRTL ? 'رقم الهوية الإماراتية' : 'Emirates ID (EID)', value: s.emiratesId!, mono: true),
      if ((s.dateOfBirth ?? '').isNotEmpty)
        (label: isRTL ? 'تاريخ الميلاد' : 'Date of Birth', value: s.dateOfBirth!, mono: false),
      if ((s.gender ?? '').isNotEmpty)
        (label: isRTL ? 'الجنس' : 'Gender', value: s.gender!, mono: false),
      if ((s.bloodType ?? '').isNotEmpty)
        (label: isRTL ? 'فصيلة الدم' : 'Blood Type', value: s.bloodType!, mono: false),
      if ((s.curriculum ?? '').isNotEmpty)
        (label: isRTL ? 'المنهج الدراسي' : 'Curriculum', value: s.curriculum!, mono: false),
    ];
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'بيانات الطالب' : 'Student Details',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text(isRTL ? 'لا توجد بيانات إضافية' : 'No additional details on file',
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary))
          else
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _field(rows[i].label, rows[i].value, mono: rows[i].mono),
            ],
        ],
      ),
    );
  }

  Widget _field(String label, String value, {bool mono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary, letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: SchooKeepColors.textPrimary,
              fontFamily: mono ? 'monospace' : null,
            )),
      ],
    );
  }

  Widget _medicalSummaryCard(Student s, bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.clipboardList, size: 16, color: SchooKeepColors.primary),
              const SizedBox(width: 8),
              Text(isRTL ? 'الملخص الطبي' : 'Medical Summary',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(s.medicalSummary!,
              style: const TextStyle(fontSize: 13, height: 1.5, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _allergensCard(Student s, bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Text(isRTL ? 'الحساسية' : 'Allergens',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          if (s.allergens.isEmpty)
            Text(isRTL ? 'لا توجد حساسية مسجلة' : 'No known allergens',
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary))
          else
            for (var i = 0; i < s.allergens.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _allergenRow(s.allergens[i], isRTL),
            ],
        ],
      ),
    );
  }

  Widget _allergenRow(StudentAllergen a, bool isRTL) {
    final name = isRTL && (a.allergenAr?.isNotEmpty ?? false) ? a.allergenAr! : a.allergen;
    final (bg, fg) = _severityStyle(a.severity);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              if ((a.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(a.notes!,
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ],
          ),
        ),
        if ((a.severity ?? '').isNotEmpty) ...[
          const SizedBox(width: 8),
          SchooKeepBadge(
            label: _severityLabel(a.severity!, isRTL),
            background: bg,
            foreground: fg,
            fontSize: 11,
          ),
        ],
      ],
    );
  }

  static (Color bg, Color fg) _severityStyle(String? severity) {
    switch ((severity ?? '').toLowerCase()) {
      case 'severe':
        return (const Color(0xFFFEE2E2), SchooKeepColors.error);
      case 'moderate':
        return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText);
      case 'mild':
        return (SchooKeepColors.greenChipBg, SchooKeepColors.greenChipText);
      default:
        return (SchooKeepColors.border, SchooKeepColors.textSecondary);
    }
  }

  static String _severityLabel(String severity, bool isRTL) {
    if (!isRTL) return severity[0].toUpperCase() + severity.substring(1);
    switch (severity.toLowerCase()) {
      case 'severe':
        return 'شديدة';
      case 'moderate':
        return 'متوسطة';
      case 'mild':
        return 'خفيفة';
      default:
        return severity;
    }
  }
}
