import 'dart:async';

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
import '../../nurse/cubit/student_list_cubit.dart';
import 'counselor_dashboard_screen.dart';

const Color _counselorPurple = Color(0xFF7C3AED);
const Color _counselorPurpleBg = Color(0xFFF3F0FF);

/// Ported from `CounselorStudentsList.tsx`, wired to `GET /students` via the
/// shared [StudentRepository]/[StudentListCubit]. The white header holds the
/// title row plus an inline (debounced) search field. Recent-tag counts and the
/// "Trend" chip aren't exposed by the students endpoint, so they're omitted.
class CounselorStudentsListScreen extends StatelessWidget {
  const CounselorStudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentListCubit(sl<StudentRepository>()),
      child: const _CounselorStudentsListView(),
    );
  }
}

class _CounselorStudentsListView extends StatefulWidget {
  const _CounselorStudentsListView();

  @override
  State<_CounselorStudentsListView> createState() => _CounselorStudentsListViewState();
}

class _CounselorStudentsListViewState extends State<_CounselorStudentsListView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _reload() => context.read<StudentListCubit>().load(query: _searchQuery);

  void _onSearchChanged(String v) {
    setState(() => _searchQuery = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _reload);
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Expanded(
            child: BlocBuilder<StudentListCubit, DataState<List<Student>>>(
              builder: (context, state) {
                return switch (state) {
                  DataLoading() => const Center(child: CircularProgressIndicator()),
                  DataError(:final message) => _errorView(message),
                  DataLoaded(:final data) => _list(data),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
              fullWidth: false,
              onPressed: _reload,
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<Student> students) {
    if (students.isEmpty) {
      return Center(
        child: Text(
          context.tr(en: 'No students found', ar: 'لم يتم العثور على طلاب'),
          style: const TextStyle(color: SchooKeepColors.textSecondary),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < students.length; i++) ...[
                if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                _studentRow(students[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(en: 'Students', ar: 'قائمة الطلاب'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                  ),
                  InkWell(
                    onTap: () => showCounselorNotificationsSheet(context),
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(LucideIcons.bell, size: 24, color: SchooKeepColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: context.tr(en: 'Search students...', ar: 'البحث عن طالب...'),
                  hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _counselorPurple, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentRow(Student s) {
    final grade = [
      if ((s.grade ?? '').isNotEmpty) s.grade,
      if ((s.section ?? '').isNotEmpty) s.section,
    ].whereType<String>().join(' • ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/counselor/student-tags/${s.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _counselorPurpleBg, shape: BoxShape.circle),
                child: Text(_initials(s.name),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _counselorPurple)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    if (grade.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(grade, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
