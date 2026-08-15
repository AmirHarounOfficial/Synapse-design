import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Cafeteria role (ported from `CafeteriaLayout.tsx`).
const cafeteriaTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.alertTriangle, label: 'Alerts', route: '/cafeteria/alerts'),
  SchooKeepTab(icon: LucideIcons.clock, label: 'History', route: '/cafeteria/history'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', route: '/cafeteria/settings'),
];
