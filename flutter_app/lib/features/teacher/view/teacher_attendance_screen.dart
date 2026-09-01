import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

enum _AttStatus { present, late, absent }

class _Student {
  _Student({required this.id, required this.name, required this.initials, required this.room, this.status});
  final String id;
  final String name;
  final String initials;
  final String room;
  _AttStatus? status;
}

/// Ported from `TeacherAttendance.tsx`. Searchable student roster with
/// per-student present/late/absent toggles, a progress footer, and a success
/// state on submit (auto-returns home after 2s). Localized in EN & AR.
class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  String _searchQuery = '';
  bool _showSuccess = false;

  final List<_Student> _students = [
    _Student(id: '1', name: 'Alex Anderson', initials: 'AA', room: '204', status: _AttStatus.present),
    _Student(id: '2', name: 'Emma Rodriguez', initials: 'ER', room: '204', status: _AttStatus.present),
    _Student(id: '3', name: 'Marcus Chen', initials: 'MC', room: '204'),
    _Student(id: '4', name: 'Sarah Williams', initials: 'SW', room: '204', status: _AttStatus.late),
    _Student(id: '5', name: 'James Taylor', initials: 'JT', room: '204'),
    _Student(id: '6', name: 'Olivia Brown', initials: 'OB', room: '204'),
    _Student(id: '7', name: 'Sophia Davis', initials: 'SD', room: '204'),
    _Student(id: '8', name: 'Liam Anderson', initials: 'LA', room: '204', status: _AttStatus.present),
    _Student(id: '9', name: 'Ava Garcia', initials: 'AG', room: '204', status: _AttStatus.present),
    _Student(id: '10', name: 'Noah Wilson', initials: 'NW', room: '204', status: _AttStatus.present),
  ];

  int get _markedCount => _students.where((s) => s.status != null).length;
  int get _totalCount => _students.length;
  bool get _allMarked => _markedCount == _totalCount;

  List<_Student> get _filtered =>
      _students.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  void _setStatus(_Student student, _AttStatus status) => setState(() => student.status = status);

  void _submit() {
    if (!_allMarked) return;
    setState(() => _showSuccess = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/teacher/home');
    });
  }

  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _monthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String _dateShort(bool isAr) {
    final now = DateTime.now();
    final m = isAr ? _monthsAr[now.month - 1] : _monthsEn[now.month - 1];
    return '$m ${now.day}';
  }

  String _dateLong(bool isAr) {
    final now = DateTime.now();
    final m = isAr ? _monthsAr[now.month - 1] : _monthsEn[now.month - 1];
    return '$m ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRTL;

    if (_showSuccess) {
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
                Text(
                  context.tr(en: 'Attendance Submitted', ar: 'تم إرسال سجل الحضور والغياب'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    en: '$_markedCount students marked for ${_dateShort(isAr)}',
                    ar: 'تم تسجيل $_markedCount طالب بتاريخ ${_dateShort(isAr)}',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr(en: 'Attendance', ar: 'حضور وغياب الفصل'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            Text(_dateLong(isAr), style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _allMarked ? _submit : null,
            child: Text(
              context.tr(en: 'Submit', ar: 'إرسال'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _allMarked ? SchooKeepColors.primary : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: SchooKeepColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: context.tr(en: 'Search by name...', ar: 'ابحث باسم الطالب...'),
                hintStyle: const TextStyle(color: SchooKeepColors.textSecondary),
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
                filled: true,
                fillColor: SchooKeepColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
              ),
            ),
          ),
          const Divider(height: 1, color: SchooKeepColors.border),
          // Student list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final s in _filtered) ...[
                  _studentCard(context, s),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          _footer(context),
        ],
      ),
    );
  }

  Widget _studentCard(BuildContext context, _Student s) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: Text(s.initials,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    Text(
                      context.tr(en: 'Room ${s.room}', ar: 'غرفة ${s.room}'),
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statusButton(s, _AttStatus.present, context.tr(en: 'Present', ar: 'حاضر'), SchooKeepColors.accent)),
              const SizedBox(width: 8),
              Expanded(child: _statusButton(s, _AttStatus.late, context.tr(en: 'Late', ar: 'متأخر'), SchooKeepColors.warning)),
              const SizedBox(width: 8),
              Expanded(child: _statusButton(s, _AttStatus.absent, context.tr(en: 'Absent', ar: 'غائب'), SchooKeepColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(_Student s, _AttStatus type, String label, Color selectedColor) {
    final selected = s.status == type;
    return SizedBox(
      height: 44,
      child: Material(
        color: selected ? selectedColor : SchooKeepColors.surface,
        shape: selected
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide.none,
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: SchooKeepColors.border),
              ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _setStatus(s, type),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : SchooKeepColors.textSecondary,
                )),
          ),
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final pct = ((_markedCount / _totalCount) * 100).round();
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(en: '$_markedCount of $_totalCount marked', ar: 'تم تسجيل $_markedCount من أصل $_totalCount'),
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
              ),
              Text('$pct%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _markedCount / _totalCount,
              minHeight: 8,
              backgroundColor: SchooKeepColors.border,
              valueColor: const AlwaysStoppedAnimation(SchooKeepColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Material(
              color: _allMarked ? SchooKeepColors.primary : SchooKeepColors.border,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _allMarked ? _submit : null,
                child: Center(
                  child: Text(
                    context.tr(en: 'Submit Attendance', ar: 'إرسال سجل الحضور والغياب'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _allMarked ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
