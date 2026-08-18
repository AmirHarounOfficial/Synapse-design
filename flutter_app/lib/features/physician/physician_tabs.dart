import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Physician role (ported from `PhysicianLayout.tsx`).
const physicianTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', arLabel: 'الرئيسية', route: '/physician/dashboard'),
  SchooKeepTab(icon: LucideIcons.pill, label: 'Protocols', arLabel: 'البروتوكولات', route: '/physician/protocols'),
  SchooKeepTab(icon: LucideIcons.alertTriangle, label: 'Escalations', arLabel: 'التصعيدات', route: '/physician/escalations'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', arLabel: 'الإعدادات', route: '/physician/settings'),
];
