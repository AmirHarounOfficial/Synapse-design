import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Nurse role (ported from `NurseLayout.tsx`).
const nurseTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', arLabel: 'الرئيسية', route: '/nurse/dashboard'),
  SchooKeepTab(icon: LucideIcons.pill, label: 'Medications', arLabel: 'الأدوية', route: '/nurse/medications'),
  SchooKeepTab(icon: LucideIcons.clipboardList, label: 'Clinic', arLabel: 'العيادة', route: '/nurse/clinic'),
  SchooKeepTab(icon: LucideIcons.users, label: 'Students', arLabel: 'الطلاب', route: '/nurse/students'),
  SchooKeepTab(icon: LucideIcons.barChart3, label: 'Reports', arLabel: 'التقارير', route: '/nurse/reports'),
];
