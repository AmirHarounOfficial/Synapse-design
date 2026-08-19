import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class SecretaryStudentListScreen extends StatefulWidget {
  const SecretaryStudentListScreen({super.key});

  @override
  State<SecretaryStudentListScreen> createState() => _SecretaryStudentListScreenState();
}

class _Student {
  const _Student({
    required this.id,
    required this.name,
    required this.initials,
    required this.grade,
    required this.className,
    required this.consentStatus,
    required this.consentBg,
    required this.consentFg,
    required this.documentStatus,
    required this.documentBg,
    required this.documentFg,
  });
  final String id;
  final String name;
  final String initials;
  final String grade;
  final String className;
  final String consentStatus;
  final Color consentBg;
  final Color consentFg;
  final String documentStatus;
  final Color documentBg;
  final Color documentFg;
}

class _SecretaryStudentListScreenState extends State<SecretaryStudentListScreen> {
  String _searchQuery = '';
  String _filterGrade = 'all';

  static const Color _greenBg = Color(0xFFD1FAE5);
  static const Color _greenFg = SchooKeepColors.accent;
  static const Color _amberBg = Color(0xFFFEF3C7);
  static const Color _amberFg = SchooKeepColors.warning;
  static const Color _redBg = Color(0xFFFEE2E2);
  static const Color _redFg = SchooKeepColors.error;

  @override
  Widget build(BuildContext context) {
    final students = [
      _Student(
        id: '1',
        name: 'Maya Thompson',
        initials: 'MT',
        grade: context.tr(en: '4th Grade', ar: 'الصف الرابع'),
        className: context.tr(en: 'Ms. Johnson', ar: 'أ. أمل الجابري'),
        consentStatus: context.tr(en: 'Complete', ar: 'مكتمل'),
        consentBg: _greenBg,
        consentFg: _greenFg,
        documentStatus: context.tr(en: 'Up to date', ar: 'محدث بالكامل'),
        documentBg: _greenBg,
        documentFg: _greenFg,
      ),
      _Student(
        id: '2',
        name: 'Ethan Williams',
        initials: 'EW',
        grade: context.tr(en: '5th Grade', ar: 'الصف الخامس'),
        className: context.tr(en: 'Mr. Davis', ar: 'أ. خالد المنصوري'),
        consentStatus: context.tr(en: 'Complete', ar: 'مكتمل'),
        consentBg: _greenBg,
        consentFg: _greenFg,
        documentStatus: context.tr(en: 'Expiring soon', ar: 'ينتهي قريباً'),
        documentBg: _amberBg,
        documentFg: _amberFg,
      ),
      _Student(
        id: '3',
        name: 'Sophia Martinez',
        initials: 'SM',
        grade: context.tr(en: '4th Grade', ar: 'الصف الرابع'),
        className: context.tr(en: 'Ms. Johnson', ar: 'أ. أمل الجابري'),
        consentStatus: context.tr(en: 'Pending', ar: 'معلق'),
        consentBg: _amberBg,
        consentFg: _amberFg,
        documentStatus: context.tr(en: 'Missing', ar: 'مفقود'),
        documentBg: _redBg,
        documentFg: _redFg,
      ),
      _Student(
        id: '4',
        name: 'Liam Chen',
        initials: 'LC',
        grade: context.tr(en: '3rd Grade', ar: 'الصف الثالث'),
        className: context.tr(en: 'Mrs. Anderson', ar: 'أ. مريم السويدي'),
        consentStatus: context.tr(en: 'Complete', ar: 'مكتمل'),
        consentBg: _greenBg,
        consentFg: _greenFg,
        documentStatus: context.tr(en: 'Up to date', ar: 'محدث بالكامل'),
        documentBg: _greenBg,
        documentFg: _greenFg,
      ),
    ];

    final filtered = students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGrade = _filterGrade == 'all' || s.grade == _filterGrade;
      return matchesSearch && matchesGrade;
    }).toList();

    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SchooKeepCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _studentRow(filtered[i]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr(en: 'Students', ar: 'سجل الطلاب والملفات الإدارية'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go('/secretary/import-students'),
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(LucideIcons.upload, size: 22, color: SchooKeepColors.textPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go('/secretary/notifications'),
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
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
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                decoration: InputDecoration(
                  hintText: context.tr(en: 'Search students...', ar: 'البحث عن طالب باسمه أو فصله...'),
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterGrade,
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown, size: 16, color: SchooKeepColors.textSecondary),
                  style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(context.tr(en: 'All Grades', ar: 'جميع الصفوف'))),
                    DropdownMenuItem(value: context.tr(en: '3rd Grade', ar: 'الصف الثالث'), child: Text(context.tr(en: '3rd Grade', ar: 'الصف الثالث'))),
                    DropdownMenuItem(value: context.tr(en: '4th Grade', ar: 'الصف الرابع'), child: Text(context.tr(en: '4th Grade', ar: 'الصف الرابع'))),
                    DropdownMenuItem(value: context.tr(en: '5th Grade', ar: 'الصف الخامس'), child: Text(context.tr(en: '5th Grade', ar: 'الصف الخامس'))),
                  ],
                  onChanged: (v) => setState(() => _filterGrade = v ?? 'all'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentRow(_Student student) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/secretary/student/${student.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: Text(student.initials,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${student.grade} • ${student.className}',
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SchooKeepBadge(
                          label: student.consentStatus,
                          background: student.consentBg,
                          foreground: student.consentFg,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        SchooKeepBadge(
                          label: student.documentStatus,
                          background: student.documentBg,
                          foreground: student.documentFg,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
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
