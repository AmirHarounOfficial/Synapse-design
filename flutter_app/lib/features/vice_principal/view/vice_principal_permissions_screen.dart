import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';
import '../../../data/models/role_capability.dart';
import '../../../data/repositories/permission_repository.dart';
import '../cubit/vice_principal_permissions_cubit.dart';

/// Ported from `VicePrincipalPermissions.tsx`, wired to `GET /permissions` via
/// [VicePrincipalPermissionsCubit]. Read-only view of the role x capability
/// matrix: one card per role listing each capability with a granted/denied
/// badge, plus a request-access CTA and an info footer.
class VicePrincipalPermissionsScreen extends StatelessWidget {
  const VicePrincipalPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          VicePrincipalPermissionsCubit(sl<PermissionRepository>()),
      child: const _PermissionsView(),
    );
  }
}

class _PermissionsView extends StatelessWidget {
  const _PermissionsView();

  void _reload(BuildContext context) =>
      context.read<VicePrincipalPermissionsCubit>().load();

  static String _humanize(String raw) {
    if (raw.isEmpty) return raw;
    final spaced = raw.replaceAll('_', ' ').replaceAll('-', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: 'Permission Matrix',
        onBack: () => context.safeBack(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: BlocBuilder<VicePrincipalPermissionsCubit,
          DataState<Map<String, List<RoleCapability>>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => _error(context, message),
            DataLoaded(:final data) => _content(context, data),
          };
        },
      ),
    );
  }

  Widget _content(
      BuildContext context, Map<String, List<RoleCapability>> matrix) {
    final roles = matrix.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SchooKeepCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Role permission matrix',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: SchooKeepColors.textPrimary)),
              SizedBox(height: 4),
              Text('Granted and denied capabilities per role',
                  style: TextStyle(
                      fontSize: 12, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (roles.isEmpty)
          const SchooKeepCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No permission data',
                    style: TextStyle(color: SchooKeepColors.textSecondary)),
              ),
            ),
          )
        else
          for (final role in roles) ...[
            _roleCard(role, matrix[role] ?? const []),
            const SizedBox(height: 16),
          ],
        SchooKeepCard(
          onTap: () => context.go('/vice-principal/messages?compose=principal'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.mail, size: 20, color: SchooKeepColors.primary),
              SizedBox(width: 8),
              Text('Request additional permissions',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: SchooKeepColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8)),
          child: const Text(
            'Access levels are determined by the Principal. To request changes to your permissions, send a message explaining what additional access you need and why.',
            style: TextStyle(
                fontSize: 12, height: 1.5, color: SchooKeepColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _roleCard(String role, List<RoleCapability> caps) {
    return SchooKeepCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(_humanize(role),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary)),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          for (var i = 0; i < caps.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            _permissionRow(caps[i]),
          ],
        ],
      ),
    );
  }

  Widget _permissionRow(RoleCapability p) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.allowed
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              p.allowed ? LucideIcons.check : LucideIcons.x,
              size: 20,
              color:
                  p.allowed ? SchooKeepColors.accent : SchooKeepColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_humanize(p.capability),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: p.allowed
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    p.allowed ? 'Granted' : 'Not granted',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: p.allowed
                          ? SchooKeepColors.accent
                          : SchooKeepColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!p.allowed) ...[
            const SizedBox(width: 8),
            const Icon(LucideIcons.lock,
                size: 16, color: SchooKeepColors.textSecondary),
          ],
        ],
      ),
    );
  }

  Widget _error(BuildContext context, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Icon(LucideIcons.alertCircle,
                  size: 20, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 13,
                        color: SchooKeepColors.error,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SchooKeepButton(
            label: 'Retry',
            fullWidth: false,
            onPressed: () => _reload(context)),
      ],
    );
  }
}
