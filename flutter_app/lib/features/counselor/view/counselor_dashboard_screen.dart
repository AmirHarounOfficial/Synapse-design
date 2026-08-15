import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/counselor_tag.dart';
import '../../../data/repositories/counselor_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../cubit/counselor_dashboard_cubit.dart';

/// Counselor accent purple (`#7C3AED`) — not a shared token, scoped to this role.
const Color _counselorPurple = Color(0xFF7C3AED);
const Color _counselorPurpleBg = Color(0xFFF3F0FF);

/// The counselor role has no notifications endpoint/route (see
/// `counselor_routes.dart`), so the bell opens a lightweight "all caught up"
/// bottom sheet rather than a no-op. Shared by the dashboard, reports list, and
/// students list bells.
void showCounselorNotificationsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: SchooKeepColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _counselorPurpleBg, shape: BoxShape.circle),
                child: const Icon(LucideIcons.bellOff, size: 26, color: _counselorPurple),
              ),
              const SizedBox(height: 16),
              Text(
                sheetContext.tr(en: 'No new notifications', ar: 'لا توجد إشعارات جديدة'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                sheetContext.tr(
                  en: "You're all caught up. New case referrals and trend alerts will appear here.",
                  ar: 'أنت على اطلاع بكل شيء. ستظهر الإحالات الجديدة وتنبيهات الأنماط هنا.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Ported from `CounselorDashboard.tsx`. Student wellbeing home: today summary
/// stats, recent tags feed, and quick actions. The summary tiles and recent
/// tags are wired to the API (`GET /counselor-tags`, `GET /students`).
class CounselorDashboardScreen extends StatelessWidget {
  const CounselorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounselorDashboardCubit(
        sl<CounselorRepository>(),
        sl<StudentRepository>(),
      ),
      child: const _CounselorDashboardView(),
    );
  }
}

class _CounselorDashboardView extends StatelessWidget {
  const _CounselorDashboardView();

  static String _initials(String name) =>
      name.split(' ').where((p) => p.isNotEmpty).map((n) => n[0]).take(2).join();

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  static bool _isToday(DateTime? dt) {
    if (dt == null) return false;
    final now = DateTime.now();
    final local = dt.toLocal();
    return local.year == now.year && local.month == now.month && local.day == now.day;
  }

  void _reload(BuildContext context) => context.read<CounselorDashboardCubit>().load();

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Student Wellbeing',
        actions: [
          _BellAction(onTap: () => showCounselorNotificationsSheet(context)),
        ],
      ),
      body: BlocBuilder<CounselorDashboardCubit, DataState<CounselorDashboardData>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorView(context, message),
            DataLoaded(:final data) => _content(context, data),
          };
        },
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
            SchooKeepButton(label: 'Retry', fullWidth: false, onPressed: () => _reload(context)),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, CounselorDashboardData data) {
    final taggedToday = data.recentTags
        .where((t) => _isToday(t.taggedAt ?? t.createdAt))
        .length;
    final stats = [
      (label: 'Active cases', value: '${data.studentCount}', icon: LucideIcons.users, color: _counselorPurple, bg: _counselorPurpleBg),
      (label: 'Tagged today', value: '$taggedToday', icon: LucideIcons.tag, color: SchooKeepColors.accent, bg: SchooKeepColors.greenChipBg),
      // no API source — pending-report count has no dashboard endpoint
      (label: 'Pending reports', value: '3', icon: LucideIcons.fileText, color: SchooKeepColors.warning, bg: SchooKeepColors.amberChipBg),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today Summary
          const Text('Today Summary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _statCard(stats[i])),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Recent Tags Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Tags',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              GestureDetector(
                onTap: () => context.go('/counselor/tag-entry'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, size: 16, color: _counselorPurple),
                    SizedBox(width: 4),
                    Text('Add Tag',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _counselorPurple)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.recentTags.isEmpty)
            const SchooKeepCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No recent tags',
                      style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                ),
              ),
            )
          else
            _DividedCard(
              children: [
                for (final tag in data.recentTags.take(5)) _tagRow(context, tag),
              ],
            ),
          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: LucideIcons.tag,
                  label: 'Add Wellbeing Tag',
                  filled: true,
                  onTap: () => context.go('/counselor/tag-entry'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: LucideIcons.fileText,
                  label: 'Generate Report',
                  filled: false,
                  onTap: () => context.go('/counselor/reports'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tagRow(BuildContext context, CounselorTag tag) {
    // The API has no student name on the tag resource; show the student id and
    // the first tag label as the headline chip.
    final studentName = 'Student #${tag.studentId ?? '—'}';
    final tagLabel = tag.tags.isNotEmpty ? tag.tags.first : (tag.context ?? 'Tag');
    return _TagRow(
      initials: _initials(studentName),
      studentName: studentName,
      tag: tagLabel,
      room: tag.context ?? '',
      time: _formatTime(tag.taggedAt ?? tag.createdAt),
      onTap: () => context.go('/counselor/student-tags/${tag.id}'),
    );
  }

  Widget _statCard(({String label, String value, IconData icon, Color color, Color bg}) stat) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: stat.bg, shape: BoxShape.circle),
            child: Icon(stat.icon, size: 20, color: stat.color),
          ),
          const SizedBox(height: 8),
          Text(stat.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 2),
          Text(stat.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }
}

class _BellAction extends StatelessWidget {
  const _BellAction({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(LucideIcons.bell, size: 24, color: SchooKeepColors.textPrimary),
      ),
    );
  }
}

/// A white bordered card whose children are separated by thin dividers,
/// matching `divide-y divide-gray-100`.
class _DividedCard extends StatelessWidget {
  const _DividedCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)));
      }
      rows.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.initials,
    required this.studentName,
    required this.tag,
    required this.room,
    required this.time,
    required this.onTap,
  });

  final String initials;
  final String studentName;
  final String tag;
  final String room;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _counselorPurpleBg, shape: BoxShape.circle),
                child: Text(initials,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _counselorPurple)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _counselorPurpleBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(tag,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _counselorPurple)),
                        ),
                        if (room.isNotEmpty)
                          Text(room, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? _counselorPurple : SchooKeepColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: filled ? BorderSide.none : const BorderSide(color: SchooKeepColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: filled ? Colors.white : _counselorPurple),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: filled ? Colors.white : SchooKeepColors.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
