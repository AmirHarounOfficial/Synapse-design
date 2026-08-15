import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Back-navigation helper that never throws "GoError: There is nothing to pop".
///
/// Many screens are reached via `context.go(...)`, which *replaces* the
/// navigation stack rather than pushing onto it — so calling `context.pop()`
/// from their back button has nothing to pop and throws. [safeBack] pops when a
/// page is available and otherwise navigates to a sensible home for the current
/// section (or [fallback] when provided).
extension SafeBackX on BuildContext {
  void safeBack([String? fallback]) {
    if (canPop()) {
      pop();
      return;
    }
    go(fallback ?? _homeForLocation(GoRouterState.of(this).uri.path));
  }
}

/// Maps the current location to the home screen of its section. Longer, more
/// specific prefixes are listed first so `/parent/app/...` resolves before
/// `/parent/...`.
String _homeForLocation(String path) {
  const homes = <(String, String)>[
    ('/parent/app', '/parent/app/home'),
    ('/parent/onboarding', '/parent/onboarding/code'),
    ('/parent', '/parent/dashboard'),
    ('/nurse', '/nurse/dashboard'),
    ('/teacher', '/teacher/home'),
    ('/counselor', '/counselor/home'),
    ('/secretary', '/secretary/home'),
    ('/principal', '/principal/home'),
    ('/physician', '/physician/dashboard'),
    ('/vice-principal', '/vice-principal/home'),
    ('/bus', '/bus/route'),
    ('/cafeteria', '/cafeteria/alerts'),
    ('/security', '/security/pickups'),
  ];
  for (final (prefix, home) in homes) {
    if (path == prefix || path.startsWith('$prefix/')) return home;
  }
  return '/login';
}
