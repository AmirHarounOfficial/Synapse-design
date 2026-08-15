import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `SecretaryStudentList.tsx`. Searchable, grade-filterable student
/// directory with consent/document status chips. The white header (title +
/// search + grade filter) sits in the app-bar region; results below. Inline
/// mock data.
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

  static const List<_Student> _students = [
    _Student(
      id: '1',
      name: 'Maya Thompson',
      initials: 'MT',
      grade: '4th Grade',
      className: 'Ms. Johnson',
      consentStatus: 'Complete',
      consentBg: _greenBg,
      consentFg: _greenFg,
      documentStatus: 'Up to date',
      documentBg: _greenBg,
      documentFg: _greenFg,
    ),
    _Student(
      id: '2',
      name: 'Ethan Williams',
      initials: 'EW',
      grade: '5th Grade',
      className: 'Mr. Davis',
      consentStatus: 'Complete',
      consentBg: _greenBg,
      consentFg: _greenFg,
      documentStatus: 'Expiring soon',
      documentBg: _amberBg,
      documentFg: _amberFg,
    ),
    _Student(
      id: '3',
      name: 'Sophia Martinez',
      initials: 'SM',
      grade: '4th Grade',
      className: 'Ms. Johnson',
      consentStatus: 'Pending',
      consentBg: _amberBg,
      consentFg: _amberFg,
      documentStatus: 'Missing',
      documentBg: _redBg,
      documentFg: _redFg,
    ),
    _Student(
      id: '4',
      name: 'Liam Chen',
      initials: 'LC',
      grade: '3rd Grade',
      className: 'Mrs. Anderson',
      consentStatus: 'Complete',
      consentBg: _greenBg,
      consentFg: _greenFg,
      documentStatus: 'Up to date',
      documentBg: _greenBg,
      documentFg: _greenFg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGrade = _filterGrade == 'all' || s.grade == _filterGrade;
      return matchesSearch && matchesGrade;
    }).toList();

    return SchooKeepScaffold(
      reserveBottomNav: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
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

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Students',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
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
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 44,
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search students...',
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
          // Grade filter
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
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Grades')),
                    DropdownMenuItem(value: '3rd Grade', child: Text('3rd Grade')),
                    DropdownMenuItem(value: '4th Grade', child: Text('4th Grade')),
                    DropdownMenuItem(value: '5th Grade', child: Text('5th Grade')),
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
