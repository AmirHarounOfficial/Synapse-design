import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import '../../data/models/pickup.dart';
import 'security_tabs.dart';
import 'view/security_authorized_confirmation_screen.dart';
import 'view/security_manual_verification_screen.dart';
import 'view/security_pickup_history_screen.dart';
import 'view/security_pickup_queue_screen.dart';
import 'view/security_qr_scanner_screen.dart';
import 'view/security_settings_screen.dart';

/// All Security Guard routes (ported from the `/security` tree in `routes.tsx`).
/// Every screen lives inside the role shell (bottom nav), matching
/// `SecurityGuardLayout`'s `<Outlet/>`. `/security` redirects to the pickups tab.
final List<RouteBase> securityRoutes = [
  GoRoute(path: '/security', redirect: (c, s) => '/security/pickups'),
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: securityTabs, child: child),
    routes: [
      GoRoute(path: '/security/pickups', builder: (c, s) => const SecurityPickupQueueScreen()),
      GoRoute(path: '/security/scanner', builder: (c, s) => const SecurityQrScannerScreen()),
      GoRoute(path: '/security/manual-verification', builder: (c, s) => const SecurityManualVerificationScreen()),
      GoRoute(
        path: '/security/authorized-confirmation',
        builder: (c, s) => SecurityAuthorizedConfirmationScreen(pickup: s.extra as Pickup?),
      ),
      GoRoute(path: '/security/history', builder: (c, s) => const SecurityPickupHistoryScreen()),
      GoRoute(path: '/security/settings', builder: (c, s) => const SecuritySettingsScreen()),
    ],
  ),
];
