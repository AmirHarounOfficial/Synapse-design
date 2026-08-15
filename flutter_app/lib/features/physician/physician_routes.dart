import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/role_shell.dart';
import 'physician_tabs.dart';
import 'view/clinical_escalation_inbox_screen.dart';
import 'view/medication_protocol_review_screen.dart';
import 'view/physician_dashboard_screen.dart';
import 'view/physician_schedule_config_screen.dart';
import 'view/physician_settings_screen.dart';
import 'view/report_co_signature_screen.dart';

/// All Physician routes. The 4 tab roots + their sub-screens (protocol review,
/// report co-signature, schedule) live inside the role shell (teal bottom nav),
/// mirroring the React `PhysicianLayout` route tree. Exact paths from
/// `src/app/routes.tsx`.
final List<RouteBase> physicianRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(
      tabs: physicianTabs,
      activeColor: SchooKeepColors.physicianTeal,
      child: child,
    ),
    routes: [
      GoRoute(path: '/physician/dashboard', builder: (c, s) => const PhysicianDashboardScreen()),
      GoRoute(path: '/physician/protocols', builder: (c, s) => const MedicationProtocolReviewScreen()),
      GoRoute(
        path: '/physician/protocols/:id',
        builder: (c, s) => MedicationProtocolReviewScreen(id: s.pathParameters['id']),
      ),
      GoRoute(path: '/physician/escalations', builder: (c, s) => const ClinicalEscalationInboxScreen()),
      GoRoute(
        path: '/physician/co-sign/:id',
        builder: (c, s) => ReportCoSignatureScreen(id: s.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/physician/schedule', builder: (c, s) => const PhysicianScheduleConfigScreen()),
      GoRoute(path: '/physician/settings', builder: (c, s) => const PhysicianSettingsScreen()),
    ],
  ),
];
