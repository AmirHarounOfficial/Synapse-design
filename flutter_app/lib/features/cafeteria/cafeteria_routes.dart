import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import 'cafeteria_tabs.dart';
import 'view/cafeteria_alert_dashboard_screen.dart';
import 'view/cafeteria_allergen_detail_screen.dart';
import 'view/cafeteria_delivery_history_screen.dart';
import 'view/cafeteria_empty_state_screen.dart';
import 'view/cafeteria_realtime_alert_screen.dart';
import 'view/cafeteria_settings_screen.dart';

/// All Cafeteria routes (ported from the `/cafeteria` section of `routes.tsx`).
/// Every screen lives inside the role shell (bottom nav) — the layout treats the
/// detail, realtime-alert, and empty screens as part of the Alerts tab.
final List<RouteBase> cafeteriaRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: cafeteriaTabs, child: child),
    routes: [
      GoRoute(path: '/cafeteria/alerts', builder: (c, s) => const CafeteriaAlertDashboardScreen()),
      GoRoute(
        path: '/cafeteria/detail/:id',
        builder: (c, s) => CafeteriaAllergenDetailScreen(id: s.pathParameters['id'] ?? '1'),
      ),
      GoRoute(path: '/cafeteria/realtime-alert', builder: (c, s) => const CafeteriaRealtimeAlertScreen()),
      GoRoute(path: '/cafeteria/history', builder: (c, s) => const CafeteriaDeliveryHistoryScreen()),
      GoRoute(path: '/cafeteria/empty', builder: (c, s) => const CafeteriaEmptyStateScreen()),
      GoRoute(path: '/cafeteria/settings', builder: (c, s) => const CafeteriaSettingsScreen()),
    ],
  ),
];
