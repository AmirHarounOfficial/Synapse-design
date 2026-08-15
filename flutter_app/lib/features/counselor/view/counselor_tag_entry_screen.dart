import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/counselor_repository.dart';
import '../../../data/repositories/student_repository.dart';
import 'package:schookeep/core/router/safe_back.dart';

const Color _counselorPurple = Color(0xFF7C3AED);
const Color _counselorPurpleBg = Color(0xFFF3F0FF);

/// Ported from `CounselorTagEntry.tsx`, wired to the API. Student search hits
/// `GET /students`; "Log Tag" POSTs to `/counselor-tags`. Auto-captured
/// environmental context is sent as the tag's `context` (the live value still
/// uses the design's static AQI string — no weather feed on this screen).
class CounselorTagEntryScreen extends StatefulWidget {
  const CounselorTagEntryScreen({super.key});

  @override
  State<CounselorTagEntryScreen> createState() => _CounselorTagEntryScreenState();
}

class _CounselorTagEntryScreenState extends State<CounselorTagEntryScreen> {
  final StudentRepository _students = sl<StudentRepository>();
  final CounselorRepository _counselor = sl<CounselorRepository>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  Student? _selectedStudent;
  final List<String> _selectedTags = [];

  List<Student> _results = const [];
  bool _searching = false;
  bool _submitting = false;

  static const String _environmentalContext = 'AQI Advisory, Indoor only';

  static const _availableTags = [
    'Sensory overload',
    'Confusion / disorientation',
    'Headache',
    'Anxiety / tension',
    'Low mood',
    'Withdrawn',
    'Sad',
    'Restless',
    'Difficulty focusing',
    'Other (free text)',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  void _onSearchChanged(String v) {
    setState(() {
      _searchQuery = v;
      if (_selectedStudent != null && v != _selectedStudent!.name) _selectedStudent = null;
    });
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(v));
  }

  Future<void> _runSearch(String query) async {
    setState(() => _searching = true);
    try {
      final page = await _students.list(query: query);
      if (!mounted) return;
      setState(() => _results = page.items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _results = const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else if (_selectedTags.length < 3) {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_selectedStudent == null || _selectedTags.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _counselor.createTag(
        studentId: _selectedStudent!.id,
        tags: _selectedTags,
        notes: _notesController.text.trim(),
        context: _environmentalContext,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Wellbeing tag logged.')));
      context.go('/counselor/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(CounselorRepository.messageFor(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final showResults = _searchQuery.isNotEmpty && _selectedStudent == null;
    final canSubmit = _selectedStudent != null && _selectedTags.isNotEmpty && !_submitting;

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        title: 'Add Wellbeing Tag',
      ),
      bottomBar: _bottomBar(canSubmit),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student selector
            const Text('Student',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 8),
            _searchField(),
            if (showResults) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: Container(
                  decoration: BoxDecoration(
                    color: SchooKeepColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SchooKeepColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                        )
                      : _results.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('No students found',
                                  style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var i = 0; i < _results.length; i++) ...[
                                    if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                                    _studentResult(_results[i]),
                                  ],
                                ],
                              ),
                            ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Environmental context
            _environmentalContextCard(),
            const SizedBox(height: 16),

            // Psychosocial tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Psychosocial Tags',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                Text('${_selectedTags.length}/3 selected',
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in _availableTags) _tagChip(tag),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            const Text('Notes (optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              minLines: 3,
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Context or observations (confidential)',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: SchooKeepColors.surface,
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _counselorPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.amberChipBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: 'Privacy Notice: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'These notes are visible only to you and the school Principal.'),
                  ],
                  style: TextStyle(fontSize: 12, color: SchooKeepColors.amberText, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search student name...',
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
          filled: true,
          fillColor: SchooKeepColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _counselorPurple, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _studentResult(Student student) {
    final selected = _selectedStudent?.id == student.id;
    final grade = [
      if ((student.grade ?? '').isNotEmpty) student.grade,
      if ((student.section ?? '').isNotEmpty) student.section,
    ].whereType<String>().join(' • ');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() {
          _selectedStudent = student;
          _searchController.text = student.name;
          _searchQuery = student.name;
        }),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _counselorPurpleBg, shape: BoxShape.circle),
                child: Text(_initials(student.name),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _counselorPurple)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    if (grade.isNotEmpty)
                      Text(grade, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
              if (selected) const Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _environmentalContextCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.cloud, size: 16, color: SchooKeepColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Environmental Context (auto-captured)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E40AF))),
                SizedBox(height: 2),
                Text('Current conditions: $_environmentalContext',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String tag) {
    final selected = _selectedTags.contains(tag);
    final disabled = !selected && _selectedTags.length >= 3;

    final Color bg;
    final Color fg;
    if (selected) {
      bg = _counselorPurple;
      fg = Colors.white;
    } else if (disabled) {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF9CA3AF);
    } else {
      bg = _counselorPurpleBg;
      fg = _counselorPurple;
    }

    return GestureDetector(
      onTap: disabled ? null : () => _toggleTag(tag),
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(tag, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fg)),
      ),
    );
  }

  Widget _bottomBar(bool canSubmit) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: canSubmit ? SchooKeepColors.accent : const Color(0xFFE5E7EB),
            disabledBackgroundColor: const Color(0xFFE5E7EB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: canSubmit ? _handleSubmit : null,
          child: _submitting
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Log Tag',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: canSubmit ? Colors.white : const Color(0xFF9CA3AF),
                  )),
        ),
      ),
    );
  }
}
