import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/paginated.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/student_repository.dart';

class StudentInventoryDirectoryScreen extends StatefulWidget {
  const StudentInventoryDirectoryScreen({super.key});
  @override
  State<StudentInventoryDirectoryScreen> createState() =>
      _StudentInventoryDirectoryScreenState();
}

class _StudentInventoryDirectoryScreenState
    extends State<StudentInventoryDirectoryScreen> {
  final _search = TextEditingController();
  Paginated<Student>? _students;
  String? _error;
  bool _loading = true;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({int page = 1}) async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final students = await sl<StudentRepository>().list(
        query: _search.text.trim(),
        page: page,
        forInventory: true,
      );
      if (!mounted || request != _request) return;
      setState(() {
        _students = students;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || request != _request) return;
      setState(() {
        _error = StudentRepository.messageFor(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Student Inventory', ar: 'مخزون الطلاب'),
        onBack: () => context.go('/nurse/medications/inventory'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'school',
                  icon: const Icon(LucideIcons.building, size: 16),
                  label: Text(
                    context.tr(en: 'School stock', ar: 'مخزون المدرسة'),
                  ),
                ),
                ButtonSegment(
                  value: 'students',
                  icon: const Icon(LucideIcons.users, size: 16),
                  label: Text(
                    context.tr(en: 'Student stock', ar: 'مخزون الطلاب'),
                  ),
                ),
              ],
              selected: const {'students'},
              onSelectionChanged: (_) =>
                  context.go('/nurse/medications/inventory'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _search,
              onSubmitted: (_) => _load(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: context.tr(
                  en: 'Student name or Emirates ID',
                  ar: 'اسم الطالب أو رقم الهوية',
                ),
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: IconButton(
                  tooltip: context.tr(en: 'Search', ar: 'بحث'),
                  onPressed: () => _load(),
                  icon: const Icon(LucideIcons.arrowRight),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(_error!, textAlign: TextAlign.center),
                        ),
                        TextButton(
                          onPressed: () => _load(),
                          child: Text(
                            context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
                          ),
                        ),
                      ],
                    ),
                  )
                : _students!.items.isEmpty
                ? Center(
                    child: Text(
                      context.tr(
                        en: 'No students found',
                        ar: 'لم يتم العثور على طلاب',
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _students!.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = _students!.items[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(student.initials)),
                        title: Text(
                          context.isRTL
                              ? student.nameAr ?? student.name
                              : student.name,
                        ),
                        subtitle: Text(
                          [
                            student.grade,
                            student.section,
                          ].whereType<String>().join(' - '),
                        ),
                        trailing: const Icon(LucideIcons.chevronRight),
                        onTap: () => context.go(
                          '/nurse/students/${student.id}/inventory',
                        ),
                      );
                    },
                  ),
          ),
          if (!_loading &&
              _error == null &&
              _students != null &&
              _students!.lastPage > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: context.tr(
                    en: 'Previous page',
                    ar: 'الصفحة السابقة',
                  ),
                  onPressed: _students!.currentPage > 1
                      ? () => _load(page: _students!.currentPage - 1)
                      : null,
                  icon: const Icon(LucideIcons.chevronLeft),
                ),
                Text('${_students!.currentPage} / ${_students!.lastPage}'),
                IconButton(
                  tooltip: context.tr(en: 'Next page', ar: 'الصفحة التالية'),
                  onPressed: _students!.hasMore
                      ? () => _load(page: _students!.currentPage + 1)
                      : null,
                  icon: const Icon(LucideIcons.chevronRight),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
