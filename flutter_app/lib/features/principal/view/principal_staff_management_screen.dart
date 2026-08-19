import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/staff.dart';
import '../../../data/repositories/staff_repository.dart';
import '../cubit/staff_list_cubit.dart';

class PrincipalStaffManagementScreen extends StatelessWidget {
  const PrincipalStaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffListCubit(sl<StaffRepository>()),
      child: const _PrincipalStaffManagementView(),
    );
  }
}

class _PrincipalStaffManagementView extends StatefulWidget {
  const _PrincipalStaffManagementView();

  @override
  State<_PrincipalStaffManagementView> createState() => _PrincipalStaffManagementViewState();
}

class _PrincipalStaffManagementViewState extends State<_PrincipalStaffManagementView> {
  String _searchQuery = '';
  String _activeFilter = 'all';

  void _reload() => context.read<StaffListCubit>().load();

  String _humanizeRole(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'nurse':
        return context.tr(en: 'Nurse', ar: 'ممرض/ممرضة');
      case 'teacher':
        return context.tr(en: 'Teacher', ar: 'معلم/معلمة');
      case 'secretary':
        return context.tr(en: 'Secretary', ar: 'سكرتير/أمانة سر');
      case 'physician':
        return context.tr(en: 'Physician', ar: 'طبيب المدرسة');
      case 'principal':
        return context.tr(en: 'Principal', ar: 'مدير المدرسة');
      case 'counselor':
        return context.tr(en: 'Counselor', ar: 'أخصائي اجتماعي');
      default:
        return role
            .split(RegExp(r'[_\s]+'))
            .where((w) => w.isNotEmpty)
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
    }
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  List<Staff> _filtered(List<Staff> all) {
    final q = _searchQuery.toLowerCase();
    return all.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(q) || s.email.toLowerCase().contains(q);
      if (_activeFilter == 'all') return matchesSearch;
      if (_activeFilter == 'active') return matchesSearch && s.isActive;
      if (_activeFilter == 'inactive') return matchesSearch && !s.isActive;
      return matchesSearch && s.role.toLowerCase() == _activeFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            titleWidget: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr(en: 'Staff Management', ar: 'إدارة الكادر المدرسي'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                GestureDetector(
                  onTap: () => context.go('/principal/add-staff'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.plus, size: 20, color: SchooKeepColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        context.tr(en: 'Add staff', ar: 'إضافة موظف'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchAndFilters(context),
              BlocBuilder<StaffListCubit, DataState<List<Staff>>>(
                builder: (context, state) {
                  return switch (state) {
                    DataLoading() => const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    DataError(:final message) => _errorBanner(context, message),
                    DataLoaded(:final data) => _list(context, data),
                  };
                },
              ),
            ],
          ),
        ),
        PositionedDirectional(
          bottom: 100,
          end: 16,
          child: Material(
            color: SchooKeepColors.primary,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go('/principal/add-staff'),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(LucideIcons.plus, size: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _list(BuildContext context, List<Staff> all) {
    final staff = _filtered(all);
    if (staff.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Text(
            context.tr(en: 'No staff found', ar: 'لم يتم العثور على موظفين'),
            style: const TextStyle(color: SchooKeepColors.textSecondary),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Column(
          children: [
            for (int i = 0; i < staff.length; i++) ...[
              if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              _staffTile(context, staff[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorBanner(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.error),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.alertCircle, size: 20, color: SchooKeepColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(error,
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.error, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SchooKeepButton(label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'), fullWidth: false, onPressed: _reload),
        ],
      ),
    );
  }

  Widget _searchAndFilters(BuildContext context) {
    final filters = <(String, String)>[
      ('all', context.tr(en: 'All', ar: 'الكل')),
      ('active', context.tr(en: 'Active', ar: 'نشط')),
      ('inactive', context.tr(en: 'Inactive', ar: 'غير نشط')),
      ('nurse', context.tr(en: 'Nurse', ar: 'ممرض/ة')),
      ('teacher', context.tr(en: 'Teacher', ar: 'معلم/ة')),
      ('secretary', context.tr(en: 'Secretary', ar: 'سكرتير/ة')),
    ];

    return Container(
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(LucideIcons.search, size: 20, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: context.tr(en: 'Search staff...', ar: 'بحث في الكادر المدرسي...'),
                      hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in filters) ...[
                  _filterChip(f.$1, f.$2),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final active = _activeFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : SchooKeepColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _staffTile(BuildContext context, Staff s) {
    final suspended = !s.isActive;
    return Opacity(
      opacity: suspended ? 0.6 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await context.push('/principal/edit-staff/${s.id}');
            if (mounted) _reload();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    _initials(s.name),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: suspended ? SchooKeepColors.textSecondary : SchooKeepColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _miniBadge(_humanizeRole(context, s.role), const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
                          _miniBadge(
                            suspended
                                ? context.tr(en: 'Inactive', ar: 'غير نشط')
                                : context.tr(en: 'Active', ar: 'نشط'),
                            suspended ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                            suspended ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
