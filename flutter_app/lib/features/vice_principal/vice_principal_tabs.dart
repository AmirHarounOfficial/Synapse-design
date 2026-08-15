import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Vice Principal role (ported from `VicePrincipalLayout.tsx`).
const vicePrincipalTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', route: '/vice-principal/home'),
  SchooKeepTab(icon: LucideIcons.barChart3, label: 'Analytics', route: '/vice-principal/analytics'),
  SchooKeepTab(icon: LucideIcons.clipboard, label: 'Clinic Readiness', route: '/vice-principal/clinic-readiness'),
  SchooKeepTab(icon: LucideIcons.messageCircle, label: 'Messages', route: '/vice-principal/messages'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', route: '/vice-principal/settings'),
];
