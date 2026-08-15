import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Principal role (ported from `PrincipalLayout.tsx`).
const principalTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', route: '/principal/home'),
  SchooKeepTab(icon: LucideIcons.users, label: 'Staff', route: '/principal/staff'),
  SchooKeepTab(icon: LucideIcons.barChart3, label: 'Analytics', route: '/principal/analytics'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', route: '/principal/settings'),
  SchooKeepTab(icon: LucideIcons.shield, label: 'Audit', route: '/principal/audit'),
];
