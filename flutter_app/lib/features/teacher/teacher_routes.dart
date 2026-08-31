import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import 'teacher_tabs.dart';
import 'view/teacher_activity_exemptions_screen.dart';
import 'view/teacher_attendance_screen.dart';
import 'view/teacher_bias_report_screen.dart';
import 'view/teacher_clinic_referral_screen.dart';
import 'view/teacher_dashboard_screen.dart';
import 'view/teacher_health_considerations_screen.dart';
import 'view/teacher_notification_history_screen.dart';
import 'view/teacher_settings_screen.dart';
import 'view/teacher_student_release_notification_screen.dart';
import 'view/teacher_weather_restriction_screen.dart';

/// All Teacher routes. Every screen lives inside the role shell (bottom nav),
/// matching `TeacherLayout.tsx` which wraps all `/teacher/*` children with the
/// fixed tab bar. Exact paths come from `src/app/routes.tsx`.
final List<RouteBase> teacherRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: teacherTabs, child: child),
    routes: [
      GoRoute(path: '/teacher/home', builder: (c, s) => const TeacherDashboardScreen()),
      GoRoute(path: '/teacher/attendance', builder: (c, s) => const TeacherAttendanceScreen()),
      GoRoute(
        path: '/teacher/health-considerations',
        builder: (c, s) => const TeacherHealthConsiderationsScreen(),
      ),
      GoRoute(path: '/teacher/clinic-referral', builder: (c, s) => const TeacherClinicReferralScreen()),
      GoRoute(path: '/teacher/report-bias', builder: (c, s) => const TeacherBiasReportScreen()),
      GoRoute(
        path: '/teacher/student-release',
        builder: (c, s) => const TeacherStudentReleaseNotificationScreen(),
      ),
      GoRoute(
        path: '/teacher/weather-restriction',
        builder: (c, s) => const TeacherWeatherRestrictionScreen(),
      ),
      GoRoute(
        path: '/teacher/activity-exemptions',
        builder: (c, s) => const TeacherActivityExemptionsScreen(),
      ),
      GoRoute(path: '/teacher/notifications', builder: (c, s) => const TeacherNotificationHistoryScreen()),
      GoRoute(path: '/teacher/settings', builder: (c, s) => const TeacherSettingsScreen()),
    ],
  ),
];
