import 'package:go_router/go_router.dart';

import '../../features/auth/auth_routes.dart';
import '../../features/bus/bus_routes.dart';
import '../../features/cafeteria/cafeteria_routes.dart';
import '../../features/counselor/counselor_routes.dart';
import '../../features/dev/navigation_map_screen.dart';
import '../../features/nurse/nurse_routes.dart';
import '../../features/parent/parent_routes.dart';
import '../../features/physician/physician_routes.dart';
import '../../features/principal/principal_routes.dart';
import '../../features/secretary/secretary_routes.dart';
import '../../features/security/security_routes.dart';
import '../../features/system/system_routes.dart';
import '../../features/teacher/teacher_routes.dart';
import '../../features/vice_principal/vice_principal_routes.dart';

/// App route graph, mirroring `src/app/routes.tsx`.
///
/// Each role owns a `<role>_routes.dart` exposing a `List<RouteBase>`, spread in
/// below. `/` is the dev navigation index; unknown paths fall back to it.
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const NavigationMapScreen()),
    ...authRoutes,
    ...nurseRoutes,
    ...parentRoutes,
    ...teacherRoutes,
    ...cafeteriaRoutes,
    ...securityRoutes,
    ...busRoutes,
    ...counselorRoutes,
    ...secretaryRoutes,
    ...principalRoutes,
    ...physicianRoutes,
    ...vicePrincipalRoutes,
    ...systemRoutes,
  ],
  errorBuilder: (c, s) => const NavigationMapScreen(),
);
