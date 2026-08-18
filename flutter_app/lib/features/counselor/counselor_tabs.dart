import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Student Counselor role (ported from
/// `CounselorLayout.tsx`).
const counselorTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', arLabel: 'الرئيسية', route: '/counselor/home'),
  SchooKeepTab(icon: LucideIcons.users, label: 'Students', arLabel: 'الطلاب', route: '/counselor/students'),
  SchooKeepTab(icon: LucideIcons.fileText, label: 'Reports', arLabel: 'التقارير', route: '/counselor/reports'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', arLabel: 'الإعدادات', route: '/counselor/settings'),
];
