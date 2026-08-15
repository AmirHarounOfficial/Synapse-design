import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Parent App (ported from `ParentAppLayout.tsx`).
const parentAppTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', route: '/parent/app/home'),
  SchooKeepTab(icon: LucideIcons.heart, label: 'Health', route: '/parent/app/health'),
  SchooKeepTab(icon: LucideIcons.pill, label: 'Meds', route: '/parent/app/medications'),
  SchooKeepTab(icon: LucideIcons.fileText, label: 'Docs', route: '/parent/app/docs'),
  SchooKeepTab(icon: LucideIcons.messageCircle, label: 'Chat', route: '/parent/app/chat'),
];
