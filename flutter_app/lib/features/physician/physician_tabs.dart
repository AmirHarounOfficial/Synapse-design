import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Physician role (ported from `PhysicianLayout.tsx`).
const physicianTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', route: '/physician/dashboard'),
  SchooKeepTab(icon: LucideIcons.pill, label: 'Protocols', route: '/physician/protocols'),
  SchooKeepTab(icon: LucideIcons.alertTriangle, label: 'Escalations', route: '/physician/escalations'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', route: '/physician/settings'),
];
