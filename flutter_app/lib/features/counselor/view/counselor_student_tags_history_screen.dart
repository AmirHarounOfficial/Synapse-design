import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/counselor_tag.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/counselor_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../cubit/counselor_tags_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

const Color _counselorPurple = Color(0xFF7C3AED);
const Color _counselorPurpleBg = Color(0xFFF3F0FF);

/// Ported from `CounselorStudentTagsHistory.tsx`, wired to
/// `GET /counselor-tags?student_id=`. Shows the student header, a
/// repeated-pattern trend warning (3+ of the same tag), and the confidential
/// tag timeline. The counselor's display name isn't on the tags payload, so
/// each entry is marked "Logged confidentially".
class CounselorStudentTagsHistoryScreen extends StatelessWidget {
  const CounselorStudentTagsHistoryScreen({super.key, required this.id});

  final String id;

  int? get _studentId => int.tryParse(id);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounselorTagsCubit(sl<CounselorRepository>(), studentId: _studentId),
      child: _CounselorStudentTagsHistoryView(studentId: _studentId),
    );
  }
}

class _CounselorStudentTagsHistoryView extends StatefulWidget {
  const _CounselorStudentTagsHistoryView({required this.studentId});
  final int? studentId;

  @override
  State<_CounselorStudentTagsHistoryView> createState() => _CounselorStudentTagsHistoryViewState();
}

class _CounselorStudentTagsHistoryViewState extends State<_CounselorStudentTagsHistoryView> {
  Future<Student?>? _studentFuture;

  @override
  void initState() {
    super.initState();
    if (widget.studentId != null) {
      _studentFuture = sl<StudentRepository>().show(widget.studentId!).then<Student?>((s) => s).catchError((_) => null);
    }
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
      scrollable: false,
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        titleWidget: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wellbeing History',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _studentHeader(),
          Expanded(
            child: BlocBuilder<CounselorTagsCubit, DataState<List<CounselorTag>>>(
              builder: (context, state) {
                return switch (state) {
                  DataLoading() => const Center(child: CircularProgressIndicator()),
                  DataError(:final message) => _errorView(message),
                  DataLoaded(:final data) => _timeline(data),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: FutureBuilder<Student?>(
        future: _studentFuture,
        builder: (context, snap) {
          final student = snap.data;
          final name = student?.name ?? 'Student #${widget.studentId ?? '?'}';
          final grade = [
            if ((student?.grade ?? '').isNotEmpty) student!.grade,
            if ((student?.section ?? '').isNotEmpty) student!.section,
          ].whereType<String>().join(' • ');
          return Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _counselorPurpleBg, shape: BoxShape.circle),
                child: Text(_initials(name),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _counselorPurple)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    if (grade.isNotEmpty)
                      Text(grade, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
            ],
          );
        },
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
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: 'Retry',
              fullWidth: false,
              onPressed: () => context.read<CounselorTagsCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  /// Finds the most-repeated tag and its count, for the trend warning.
  ({String tag, int count})? _topRepeatedTag(List<CounselorTag> tags) {
    final counts = <String, int>{};
    for (final t in tags) {
      for (final tag in t.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return (tag: top.key, count: top.value);
  }

  Widget _timeline(List<CounselorTag> tags) {
    final top = _topRepeatedTag(tags);
    final showTrendWarning = top != null && top.count >= 3;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTrendWarning) ...[
            _trendWarning(top.tag, top.count),
            const SizedBox(height: 16),
          ],
          const Text('Tag Timeline',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          if (tags.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No wellbeing tags logged yet',
                  style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
            )
          else
            for (var i = 0; i < tags.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _timelineCard(tags[i]),
            ],
        ],
      ),
    );
  }

  Widget _trendWarning(String tag, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Repeated Pattern Detected',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText)),
                const SizedBox(height: 4),
                Text(
                  '"$tag" tag noted $count times in recent history — consider referral or environmental assessment.',
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.amberText),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.go('/counselor/generate-report'),
                  child: const Text('Generate referral report',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _formatTime(DateTime d) {
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  Widget _timelineCard(CounselorTag entry) {
    final at = (entry.taggedAt ?? entry.createdAt)?.toLocal();
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(at != null ? _formatDate(at) : '—',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
              Text(at != null ? _formatTime(at) : '',
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          if (entry.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in entry.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _counselorPurpleBg, borderRadius: BorderRadius.circular(999)),
                    child: Text(tag,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _counselorPurple)),
                  ),
              ],
            ),
          if ((entry.context ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.cloud, size: 16, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.context!,
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ),
              ],
            ),
          ],
          if ((entry.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),
            Text(entry.notes!,
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary, height: 1.5)),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(LucideIcons.lock, size: 12, color: SchooKeepColors.textSecondary),
              SizedBox(width: 8),
              Text('Logged confidentially',
                  style: TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
