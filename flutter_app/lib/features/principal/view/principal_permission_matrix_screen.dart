import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/role_capability.dart';
import '../../../data/repositories/permission_repository.dart';
import '../cubit/permission_matrix_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `PrincipalPermissionMatrix.tsx`, wired to `GET/PUT /permissions`.
/// A role × capability grid where each cell toggles allow/deny. Collected edits
/// surface a save bar that persists via the cubit.
class PrincipalPermissionMatrixScreen extends StatelessWidget {
  const PrincipalPermissionMatrixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PermissionMatrixCubit(sl<PermissionRepository>()),
      child: const _PrincipalPermissionMatrixView(),
    );
  }
}

class _PrincipalPermissionMatrixView extends StatefulWidget {
  const _PrincipalPermissionMatrixView();

  @override
  State<_PrincipalPermissionMatrixView> createState() => _PrincipalPermissionMatrixViewState();
}

class _PrincipalPermissionMatrixViewState extends State<_PrincipalPermissionMatrixView> {
  /// Working copy and pristine snapshot: role -> capability -> allowed.
  final Map<String, Map<String, bool>> _current = {};
  final Map<String, Map<String, bool>> _original = {};
  List<String> _roles = [];
  List<String> _capabilities = [];
  bool _saving = false;

  static const _border = Color(0xFFE2E8F0);
  static const double _cellW = 72;
  static const double _roleW = 112;

  static String _humanize(String s) => s
      .split(RegExp(r'[_\s-]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');

  void _sync(Map<String, List<RoleCapability>> matrix) {
    _current.clear();
    _original.clear();
    final caps = <String>[];
    final roles = <String>[];
    matrix.forEach((role, list) {
      roles.add(role);
      _current[role] = {};
      _original[role] = {};
      for (final c in list) {
        _current[role]![c.capability] = c.allowed;
        _original[role]![c.capability] = c.allowed;
        if (!caps.contains(c.capability)) caps.add(c.capability);
      }
    });
    _roles = roles;
    _capabilities = caps;
  }

  List<({String role, String capability, bool allowed})> _changes() {
    final out = <({String role, String capability, bool allowed})>[];
    for (final role in _roles) {
      final cur = _current[role]!;
      final orig = _original[role]!;
      cur.forEach((cap, val) {
        if (orig[cap] != val) out.add((role: role, capability: cap, allowed: val));
      });
    }
    return out;
  }

  Future<void> _save() async {
    final changes = _changes();
    if (changes.isEmpty) return;
    setState(() => _saving = true);
    final ok = await context.read<PermissionMatrixCubit>().save(changes);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission changes saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PermissionMatrixCubit, DataState<Map<String, List<RoleCapability>>>>(
      listener: (context, state) {
        if (state is DataLoaded<Map<String, List<RoleCapability>>>) {
          setState(() => _sync(state.data));
        }
      },
      builder: (context, state) {
        final changeCount = _changes().length;
        return SchooKeepScaffold(
          scrollable: true,
          appBar: SchooKeepAppBar(
            onBack: () => context.safeBack(),
            titleWidget: const Row(
              children: [
                Expanded(
                  child: Text('Permission Matrix',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                ),
                Icon(LucideIcons.info, size: 20, color: SchooKeepColors.primary),
              ],
            ),
          ),
          bottomBar: changeCount > 0 ? _saveBar(changeCount) : null,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ferpaNotice(),
                const SizedBox(height: 16),
                switch (state) {
                  DataLoading() => const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  DataError(:final message) => _errorBanner(message),
                  DataLoaded() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _matrix(),
                        const SizedBox(height: 16),
                        _legend(),
                      ],
                    ),
                },
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ferpaNotice() {
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
          Icon(LucideIcons.info, size: 16, color: SchooKeepColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'ℹ Permissions define the minimum necessary data exposure per role, in compliance with FERPA 34 CFR § 99.31.',
              style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(String error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        SchooKeepButton(
          label: 'Retry',
          fullWidth: false,
          onPressed: () => context.read<PermissionMatrixCubit>().load(),
        ),
      ],
    );
  }

  Widget _matrix() {
    if (_roles.isEmpty || _capabilities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('No permissions configured', style: TextStyle(color: SchooKeepColors.textSecondary)),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(_cellW),
        columnWidths: const {0: FixedColumnWidth(_roleW)},
        border: TableBorder.all(color: _border),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: SchooKeepColors.background),
            children: [
              _headerCell('Role', align: TextAlign.start, bg: SchooKeepColors.surface),
              for (final c in _capabilities) _headerCell(_humanize(c)),
            ],
          ),
          for (final role in _roles)
            TableRow(
              children: [
                Container(
                  color: SchooKeepColors.surface,
                  padding: const EdgeInsets.all(8),
                  child: Text(_humanize(role),
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                ),
                for (final c in _capabilities)
                  Container(
                    color: SchooKeepColors.surface,
                    height: 44,
                    alignment: Alignment.center,
                    child: _cell(role, c),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {TextAlign align = TextAlign.center, Color bg = SchooKeepColors.background}) {
    return Container(
      color: bg,
      padding: const EdgeInsets.all(8),
      child: Text(label,
          textAlign: align,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary, height: 1.1)),
    );
  }

  Widget _cell(String role, String capability) {
    final allowed = _current[role]?[capability] ?? false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _current[role]![capability] = !allowed),
      child: SizedBox(
        width: _cellW,
        height: 44,
        child: Icon(
          allowed ? LucideIcons.check : LucideIcons.x,
          size: 16,
          color: allowed ? SchooKeepColors.accent : SchooKeepColors.error,
        ),
      ),
    );
  }

  Widget _legend() {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Legend',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _legendRow(
                    const Icon(LucideIcons.check, size: 12, color: SchooKeepColors.accent), 'Allowed'),
              ),
              Expanded(
                child: _legendRow(const Icon(LucideIcons.x, size: 12, color: SchooKeepColors.error), 'Denied'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Tap any cell to toggle access for that role.',
              style: TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _legendRow(Widget icon, String label) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
      ],
    );
  }

  Widget _saveBar(int changeCount) {
    return Container(
      color: SchooKeepColors.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('You have $changeCount unsaved change${changeCount > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          SizedBox(
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
