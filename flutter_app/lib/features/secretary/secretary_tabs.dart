import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/schookeep_bottom_nav.dart';

/// Bottom-nav tabs for the Secretary role (ported from `SecretaryLayout.tsx`).
const secretaryTabs = <SchooKeepTab>[
  SchooKeepTab(icon: LucideIcons.home, label: 'Home', arLabel: 'الرئيسية', route: '/secretary/home'),
  SchooKeepTab(icon: LucideIcons.users, label: 'Students', arLabel: 'الطلاب', route: '/secretary/students'),
  SchooKeepTab(icon: LucideIcons.messageCircle, label: 'Messages', arLabel: 'الرسائل', route: '/secretary/messages'),
  SchooKeepTab(icon: LucideIcons.bot, label: 'Chatbot', arLabel: 'المساعد الذكي', route: '/secretary/chatbot'),
  SchooKeepTab(icon: LucideIcons.settings, label: 'Settings', arLabel: 'الإعدادات', route: '/secretary/settings'),
];
