import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Bus Driver role (ported from `BusDriverLayout.tsx`).
const busTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.bus, label: 'Route', arLabel: 'المسار', route: '/bus/route'),
  SchooKeepTab(icon: LucideIcons.clock, label: 'History', arLabel: 'السجل', route: '/bus/history'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', arLabel: 'الإعدادات', route: '/bus/settings'),
];
