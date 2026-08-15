import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the legacy Parent portal (ported from `ParentLayout.tsx`).
/// The `Profile` tab points at `/parent/profile`, which has no screen in the
/// legacy portal (the route is not registered in `routes.tsx`), matching the
/// source where that tab is a dead link.
const parentLegacyTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', route: '/parent/dashboard'),
  SchooKeepTab(icon: LucideIcons.pill, label: 'Medications', route: '/parent/medications'),
  SchooKeepTab(icon: LucideIcons.user, label: 'Profile', route: '/parent/profile'),
  SchooKeepTab(icon: LucideIcons.bell, label: 'Alerts', route: '/parent/notifications'),
];
