import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import 'counselor_tabs.dart';
import 'view/counselor_bias_incident_detail_screen.dart';
import 'view/counselor_bias_incidents_list_screen.dart';
import 'view/counselor_dashboard_screen.dart';
import 'view/counselor_generate_report_screen.dart';
import 'view/counselor_report_preview_screen.dart';
import 'view/counselor_reports_list_screen.dart';
import 'view/counselor_settings_screen.dart';
import 'view/counselor_student_tags_history_screen.dart';
import 'view/counselor_students_list_screen.dart';
import 'view/counselor_tag_entry_screen.dart';

/// Counselor role active color (`#7C3AED`) — not a shared token.
const Color _counselorPurple = Color(0xFF7C3AED);

/// All Student Counselor routes. The 4 bottom-nav tab screens live inside the
/// role shell; the full-screen flows are top-level routes outside the shell.
/// Paths mirror `src/app/routes.tsx` exactly.
final List<RouteBase> counselorRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: counselorTabs, activeColor: _counselorPurple, child: child),
    routes: [
      GoRoute(path: '/counselor/home', builder: (c, s) => const CounselorDashboardScreen()),
      GoRoute(path: '/counselor/students', builder: (c, s) => const CounselorStudentsListScreen()),
      GoRoute(path: '/counselor/reports', builder: (c, s) => const CounselorReportsListScreen()),
      GoRoute(path: '/counselor/settings', builder: (c, s) => const CounselorSettingsScreen()),
    ],
  ),
  GoRoute(path: '/counselor/tag-entry', builder: (c, s) => const CounselorTagEntryScreen()),
  GoRoute(path: '/counselor/bias-incidents', builder: (c, s) => const CounselorBiasIncidentsListScreen()),
  GoRoute(
    path: '/counselor/bias-incidents/:id',
    builder: (c, s) => CounselorBiasIncidentDetailScreen(id: s.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: '/counselor/student-tags/:id',
    builder: (c, s) => CounselorStudentTagsHistoryScreen(id: s.pathParameters['id'] ?? ''),
  ),
  GoRoute(path: '/counselor/generate-report', builder: (c, s) => const CounselorGenerateReportScreen()),
  GoRoute(path: '/counselor/report-preview', builder: (c, s) => const CounselorReportPreviewScreen()),
];
