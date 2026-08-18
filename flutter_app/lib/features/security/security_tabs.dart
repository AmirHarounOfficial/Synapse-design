import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Security Guard role (ported from
/// `SecurityGuardLayout.tsx`).
const securityTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.users, label: 'Pickups', arLabel: 'الاستلام', route: '/security/pickups'),
  SchooKeepTab(icon: LucideIcons.scanLine, label: 'Scanner', arLabel: 'المسح', route: '/security/scanner'),
  SchooKeepTab(icon: LucideIcons.clock, label: 'History', arLabel: 'السجل', route: '/security/history'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', arLabel: 'الإعدادات', route: '/security/settings'),
];
