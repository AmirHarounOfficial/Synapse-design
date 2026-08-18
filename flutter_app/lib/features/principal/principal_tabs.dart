import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Principal role (ported from `PrincipalLayout.tsx`).
const principalTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', arLabel: 'الرئيسية', route: '/principal/home'),
  SchooKeepTab(icon: LucideIcons.users, label: 'Staff', arLabel: 'الموظفون', route: '/principal/staff'),
  SchooKeepTab(icon: LucideIcons.barChart3, label: 'Analytics', arLabel: 'التحليلات', route: '/principal/analytics'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', arLabel: 'الإعدادات', route: '/principal/settings'),
  SchooKeepTab(icon: LucideIcons.shield, label: 'Audit', arLabel: 'التدقيق', route: '/principal/audit'),
];
