import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Bus Driver role (ported from `BusDriverLayout.tsx`).
const busTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.bus, label: 'Route', route: '/bus/route'),
  SchooKeepTab(icon: LucideIcons.clock, label: 'History', route: '/bus/history'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', route: '/bus/settings'),
];
