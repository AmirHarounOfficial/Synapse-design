import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import 'vice_principal_tabs.dart';
import 'view/vice_principal_analytics_screen.dart';
import 'view/vice_principal_clinic_readiness_screen.dart';
import 'view/vice_principal_dashboard_screen.dart';
import 'view/vice_principal_equipment_checklist_screen.dart';
import 'view/vice_principal_messages_screen.dart';
import 'view/vice_principal_permissions_screen.dart';
import 'view/vice_principal_settings_screen.dart';

/// All Vice Principal routes. The 5 tab roots live inside the role shell
/// (bottom nav); the 2 full-screen flows are top-level GoRoutes. Exact paths
/// from `src/app/routes.tsx`.
final List<RouteBase> vicePrincipalRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: vicePrincipalTabs, child: child),
    routes: [
      GoRoute(path: '/vice-principal/home', builder: (c, s) => const VicePrincipalDashboardScreen()),
      GoRoute(path: '/vice-principal/analytics', builder: (c, s) => const VicePrincipalAnalyticsScreen()),
      GoRoute(path: '/vice-principal/clinic-readiness', builder: (c, s) => const VicePrincipalClinicReadinessScreen()),
      GoRoute(
        path: '/vice-principal/messages',
        builder: (c, s) => VicePrincipalMessagesScreen(
          composeMode: s.uri.queryParameters['compose'],
          prefillSubject: s.uri.queryParameters['subject'],
        ),
      ),
      GoRoute(path: '/vice-principal/settings', builder: (c, s) => const VicePrincipalSettingsScreen()),
    ],
  ),
  GoRoute(path: '/vice-principal/permissions', builder: (c, s) => const VicePrincipalPermissionsScreen()),
  GoRoute(path: '/vice-principal/equipment-checklist', builder: (c, s) => const VicePrincipalEquipmentChecklistScreen()),
];
