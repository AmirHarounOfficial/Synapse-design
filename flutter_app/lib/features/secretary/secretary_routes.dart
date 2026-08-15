import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import 'secretary_tabs.dart';
import 'view/secretary_chatbot_queue_screen.dart';
import 'view/secretary_chatbot_thread_screen.dart';
import 'view/secretary_compose_message_screen.dart';
import 'view/secretary_dashboard_screen.dart';
import 'view/secretary_import_students_screen.dart';
import 'view/secretary_message_detail_screen.dart';
import 'view/secretary_messages_inbox_screen.dart';
import 'view/secretary_notifications_screen.dart';
import 'view/secretary_settings_screen.dart';
import 'view/secretary_student_detail_screen.dart';
import 'view/secretary_student_list_screen.dart';

/// All Secretary routes. The 5 tab roots live inside the role shell (bottom
/// nav); the import and compose flows are full-screen top-level routes (no
/// bottom nav). Paths mirror `src/app/routes.tsx` exactly.
final List<RouteBase> secretaryRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: secretaryTabs, child: child),
    routes: [
      GoRoute(path: '/secretary/home', builder: (c, s) => const SecretaryDashboardScreen()),
      GoRoute(path: '/secretary/students', builder: (c, s) => const SecretaryStudentListScreen()),
      GoRoute(path: '/secretary/messages', builder: (c, s) => const SecretaryMessagesInboxScreen()),
      GoRoute(path: '/secretary/chatbot', builder: (c, s) => const SecretaryChatbotQueueScreen()),
      GoRoute(path: '/secretary/settings', builder: (c, s) => const SecretarySettingsScreen()),
    ],
  ),
  // Full-screen screens (no bottom nav).
  GoRoute(path: '/secretary/import-students', builder: (c, s) => const SecretaryImportStudentsScreen()),
  GoRoute(path: '/secretary/compose-message', builder: (c, s) => const SecretaryComposeMessageScreen()),
  GoRoute(path: '/secretary/notifications', builder: (c, s) => const SecretaryNotificationsScreen()),
  GoRoute(
    path: '/secretary/student/:id',
    builder: (c, s) => SecretaryStudentDetailScreen(id: s.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: '/secretary/message/:id',
    builder: (c, s) => SecretaryMessageDetailScreen(id: s.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: '/secretary/chatbot-thread/:id',
    builder: (c, s) => SecretaryChatbotThreadScreen(id: s.pathParameters['id'] ?? ''),
  ),
];
