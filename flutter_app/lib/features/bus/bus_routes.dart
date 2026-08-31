import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import 'bus_tabs.dart';
import 'view/bus_bias_report_screen.dart';
import 'view/bus_driver_settings_screen.dart';
import 'view/bus_early_dismissal_screen.dart';
import 'view/bus_route_history_screen.dart';
import 'view/bus_route_overview_screen.dart';
import 'view/bus_student_boarding_screen.dart';
import 'view/bus_student_deboarding_screen.dart';

/// All Bus Driver routes. The 3 tab roots (route, history, settings) plus the
/// boarding/deboarding/early-dismissal sub-screens live inside the role shell
/// (bottom nav), matching `src/app/routes.tsx` `/bus/*` and `BusDriverLayout`.
final List<RouteBase> busRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: busTabs, child: child),
    routes: [
      GoRoute(path: '/bus/route', builder: (c, s) => const BusRouteOverviewScreen()),
      GoRoute(path: '/bus/report-bias', builder: (c, s) => const BusBiasReportScreen()),
      GoRoute(
        path: '/bus/boarding/:id',
        builder: (c, s) {
          final extra = s.extra is Map<String, dynamic> ? s.extra as Map<String, dynamic> : const {};
          return BusStudentBoardingScreen(
            id: s.pathParameters['id'] ?? '',
            routeId: extra['routeId'] as int?,
            studentName: extra['name'] as String?,
            stopName: extra['stopName'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/bus/deboarding/:id',
        builder: (c, s) {
          final extra = s.extra is Map<String, dynamic> ? s.extra as Map<String, dynamic> : const {};
          return BusStudentDeboardingScreen(
            id: s.pathParameters['id'] ?? '',
            routeId: extra['routeId'] as int?,
            studentName: extra['name'] as String?,
            stopName: extra['stopName'] as String?,
          );
        },
      ),
      GoRoute(path: '/bus/early-dismissal', builder: (c, s) => const BusEarlyDismissalScreen()),
      GoRoute(path: '/bus/history', builder: (c, s) => const BusRouteHistoryScreen()),
      GoRoute(path: '/bus/settings', builder: (c, s) => const BusDriverSettingsScreen()),
    ],
  ),
];
