import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Teacher role (ported from `TeacherLayout.tsx`).
const teacherTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', arLabel: 'الرئيسية', route: '/teacher/home'),
  SchooKeepTab(icon: LucideIcons.users, label: 'Attendance', arLabel: 'الحضور', route: '/teacher/attendance'),
  SchooKeepTab(icon: LucideIcons.bell, label: 'Alerts', arLabel: 'التنبيهات', route: '/teacher/weather-restriction'),
  SchooKeepTab(icon: LucideIcons.stethoscope, label: 'Referrals', arLabel: 'الإحالات', route: '/teacher/clinic-referral'),
];
