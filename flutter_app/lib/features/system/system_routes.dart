import 'package:go_router/go_router.dart';

import 'view/ramadan_mode_screen.dart';
import 'view/sys_after_hours_lock_screen.dart';
import 'view/sys_consent_pending_screen.dart';
import 'view/sys_session_expiry_screen.dart';
import 'view/sys_weather_advisory_screen.dart';
import 'view/system_state_showcase_screen.dart';

/// Special "System States" overlays (iPhone 16 Pro simulators). These are
/// full-screen and live outside any role shell. Paths match the System section
/// of `src/app/routes.tsx` exactly.
final List<RouteBase> systemRoutes = [
  GoRoute(path: '/system/after-hours', builder: (c, s) => const SysAfterHoursLockScreen()),
  GoRoute(path: '/system/weather-advisory', builder: (c, s) => const SysWeatherAdvisoryScreen()),
  GoRoute(path: '/system/consent-pending', builder: (c, s) => const SysConsentPendingScreen()),
  GoRoute(path: '/system/session-expiry', builder: (c, s) => const SysSessionExpiryScreen()),
  GoRoute(path: '/system/simulator', builder: (c, s) => const SystemStateShowcaseScreen()),
  GoRoute(path: '/system/ramadan', builder: (c, s) => const RamadanModeScreen()),
];
