import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Nurse role (ported from `NurseLayout.tsx`).
const nurseTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', route: '/nurse/dashboard'),
  SchooKeepTab(icon: LucideIcons.pill, label: 'Medications', route: '/nurse/medications'),
  SchooKeepTab(icon: LucideIcons.clipboardList, label: 'Clinic', route: '/nurse/clinic'),
  SchooKeepTab(icon: LucideIcons.users, label: 'Students', route: '/nurse/students'),
  SchooKeepTab(icon: LucideIcons.barChart3, label: 'Reports', route: '/nurse/reports'),
];
