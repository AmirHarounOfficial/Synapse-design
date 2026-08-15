import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import 'principal_tabs.dart';
import 'view/principal_add_edit_staff_screen.dart';
import 'view/principal_after_hours_access_screen.dart';
import 'view/principal_annual_report_screen.dart';
import 'view/principal_audit_log_screen.dart';
import 'view/principal_dashboard_screen.dart';
import 'view/principal_health_analytics_screen.dart';
import 'view/principal_legal_documents_screen.dart';
import 'view/principal_permission_matrix_screen.dart';
import 'view/principal_school_setup_screen.dart';
import 'view/principal_settings_placeholder_screen.dart';
import 'view/principal_sms_wallet_screen.dart';
import 'view/principal_staff_management_screen.dart';
import 'view/principal_student_promotion_screen.dart';
import 'view/principal_weather_advisory_screen.dart';

/// All Principal routes. The 5 tab roots live inside the role shell (bottom
/// nav); the management/wizard flows are full-screen top-level routes. Paths
/// mirror `src/app/routes.tsx` exactly.
final List<RouteBase> principalRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: principalTabs, child: child),
    routes: [
      GoRoute(path: '/principal/home', builder: (c, s) => const PrincipalDashboardScreen()),
      GoRoute(path: '/principal/staff', builder: (c, s) => const PrincipalStaffManagementScreen()),
      GoRoute(path: '/principal/analytics', builder: (c, s) => const PrincipalHealthAnalyticsScreen()),
      GoRoute(path: '/principal/settings', builder: (c, s) => const PrincipalSettingsPlaceholderScreen()),
      GoRoute(path: '/principal/audit', builder: (c, s) => const PrincipalAuditLogScreen()),
    ],
  ),

  // Full-screen flows (no bottom nav).
  GoRoute(path: '/principal/add-staff', builder: (c, s) => const PrincipalAddEditStaffScreen()),
  GoRoute(
    path: '/principal/edit-staff/:staffId',
    builder: (c, s) => PrincipalAddEditStaffScreen(staffId: s.pathParameters['staffId']),
  ),
  GoRoute(path: '/principal/permission-matrix', builder: (c, s) => const PrincipalPermissionMatrixScreen()),
  GoRoute(path: '/principal/weather-advisory', builder: (c, s) => const PrincipalWeatherAdvisoryScreen()),
  GoRoute(path: '/principal/sms-wallet', builder: (c, s) => const PrincipalSmsWalletScreen()),
  GoRoute(path: '/principal/after-hours-access', builder: (c, s) => const PrincipalAfterHoursAccessScreen()),
  GoRoute(path: '/principal/annual-report', builder: (c, s) => const PrincipalAnnualReportScreen()),
  GoRoute(path: '/principal/student-promotion', builder: (c, s) => const PrincipalStudentPromotionScreen()),
  GoRoute(path: '/principal/school-setup', builder: (c, s) => const PrincipalSchoolSetupScreen()),
  GoRoute(path: '/principal/legal-documents', builder: (c, s) => const PrincipalLegalDocumentsScreen()),
];
