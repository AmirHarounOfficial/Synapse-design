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
import '../cubit/student_list_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

class StudentSearchScreen extends StatelessWidget {
  const StudentSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentListCubit(sl<StudentRepository>()),
      child: const _StudentSearchView(),
    );
  }
}

class _StudentSearchView extends StatefulWidget {
  const _StudentSearchView();

  @override
  State<_StudentSearchView> createState() => _StudentSearchViewState();
}

class _StudentSearchViewState extends State<_StudentSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  String _activeGrade = 'all';
  bool _onlyAllergies = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _reload() => context.read<StudentListCubit>().load(
        query: _searchQuery,
        grade: _activeGrade,
      );

  void _onSearchChanged(String v) {
    setState(() => _searchQuery = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _reload);
  }

  static Color _avatarColor(int seed) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
    ];
    return colors[seed.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Students', ar: 'دليل الطلاب والملفات الصحية'),
        centerTitle: true,
        onBack: () => context.canPop() ? context.safeBack() : context.go('/nurse/dashboard'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchBar(context),
          _gradeFilterRow(context),
          _quickFilters(context),
          Expanded(
            child: BlocBuilder<StudentListCubit, DataState<List<Student>>>(
              builder: (context, state) {
                return switch (state) {
                  DataLoading() => const Center(child: CircularProgressIndicator()),
                  DataError(:final message) => _errorView(context, message),
                  DataLoaded(:final data) => _list(context, data),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'), fullWidth: false, onPressed: _reload),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<Student> all) {
    final results = _onlyAllergies ? all.where((s) => s.allergens.isNotEmpty).toList() : all;
    if (results.isEmpty) {
      return Center(
        child: Text(context.tr(en: 'No students found', ar: 'لا يوجد طلاب مطابقون للبحث'), style: const TextStyle(color: SchooKeepColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              context.tr(
                en: '${results.length} ${results.length == 1 ? 'student' : 'students'}',
                ar: '${results.length} طالب مسجل',
              ),
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
            ),
          );
        }
        return _studentCard(context, results[i - 1]);
      },
    );
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: context.tr(en: 'Search by name, ID, or class…', ar: 'ابحث باسم الطالب، الهوية، أو الفصل...'),
            hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
            filled: true,
            fillColor: SchooKeepColors.background,
            prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 20, color: SchooKeepColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            contentPadding: EdgeInsets.zero,
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
    );
  }

  Widget _gradeFilterRow(BuildContext context) {
    final gradeFilters = [
      (id: 'all', label: context.tr(en: 'All Grades', ar: 'جميع الصفوف')),
      (id: '1', label: '${context.tr(en: 'Grade', ar: 'الصف')} 1'),
      (id: '2', label: '${context.tr(en: 'Grade', ar: 'الصف')} 2'),
      (id: '3', label: '${context.tr(en: 'Grade', ar: 'الصف')} 3'),
      (id: '4', label: '${context.tr(en: 'Grade', ar: 'الصف')} 4'),
      (id: '5', label: '${context.tr(en: 'Grade', ar: 'الصف')} 5'),
      (id: '6', label: '${context.tr(en: 'Grade', ar: 'الصف')} 6'),
    ];

    return Container(
      width: double.infinity,
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in gradeFilters) ...[
              _gradeChip(f.id, f.label),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _gradeChip(String id, String label) {
    final active = _activeGrade == id;
    return GestureDetector(
      onTap: () {
        setState(() => _activeGrade = id);
        _reload();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : SchooKeepColors.background,
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: SchooKeepColors.border),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : SchooKeepColors.textSecondary,
            )),
      ),
    );
  }

  Widget _quickFilters(BuildContext context) {
    return Container(
      width: double.infinity,
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _quickChip(context.tr(en: 'Has Allergies', ar: 'لديهم حساسيات ومحاذير'), _onlyAllergies, () => setState(() => _onlyAllergies = !_onlyAllergies)),
        ],
      ),
    );
  }

  Widget _quickChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : SchooKeepColors.textSecondary,
            )),
      ),
    );
  }

  Widget _studentCard(BuildContext context, Student s) {
    final subtitle = [
      if ((s.grade ?? '').isNotEmpty) '${context.tr(en: 'Grade', ar: 'الصف')} ${s.grade}',
      if ((s.section ?? '').isNotEmpty) s.section,
      if ((s.emiratesId ?? '').isNotEmpty) s.emiratesId,
    ].whereType<String>().join(' • ');

    return Material(
      color: SchooKeepColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/nurse/students/${s.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _avatarColor(s.id),
                child: Text(s.initials,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
              if (s.allergens.isNotEmpty) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final a in s.allergens.take(2)) ...[
                      _alertChip(a.allergen),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _alertChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: SchooKeepColors.amberChipBg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText)),
    );
  }
}
