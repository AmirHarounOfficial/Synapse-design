import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import 'nurse_tabs.dart';
import 'view/add_medication_step1_screen.dart';
import 'view/add_medication_step2_screen.dart';
import 'view/add_medication_step3_screen.dart';
import 'view/clinic_visit_detail_screen.dart';
import 'view/clinic_visit_list_screen.dart';
import 'view/daily_dose_view_screen.dart';
import 'view/document_review_queue_screen.dart';
import 'view/document_viewer_screen.dart';
import 'view/dose_confirmation_screen.dart';
import 'view/dose_conflict_alert_screen.dart';
import 'view/emergency_consent_request_screen.dart';
import 'view/emergency_escalation_screen.dart';
import 'view/emergency_photo_upload_screen.dart';
import 'view/generate_report_screen.dart';
import 'view/low_supply_alert_screen.dart';
import 'view/new_clinic_visit_screen.dart';
import 'view/nurse_dashboard_screen.dart';
import 'view/nurse_medication_detail_screen.dart';
import 'view/nurse_medications_screen.dart';
import 'view/nurse_pharmacy_inventory_screen.dart';
import 'view/nurse_notifications_screen.dart';
import 'view/nurse_reports_screen.dart';
import 'view/nurse_settings_screen.dart';
import 'view/report_preview_screen.dart';
import 'view/send_cafeteria_alert_screen.dart';
import 'view/student_health_profile_screen.dart';
import 'view/student_search_screen.dart';

/// All Nurse routes. The 5 tab roots + their sub-screens live inside the role
/// shell (bottom nav). Each route maps to its ported screen, with the exact
/// paths from `src/app/routes.tsx`.
final List<RouteBase> nurseRoutes = [
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: nurseTabs, child: child),
    routes: [
      GoRoute(path: '/nurse/dashboard', builder: (c, s) => const NurseDashboardScreen()),
      GoRoute(path: '/nurse/daily-doses', builder: (c, s) => const DailyDoseViewScreen()),
      GoRoute(path: '/nurse/medications', builder: (c, s) => const NurseMedicationsScreen()),
      GoRoute(path: '/nurse/medications/inventory', builder: (c, s) => const NursePharmacyInventoryScreen()),
      GoRoute(path: '/nurse/medications/add/step1', builder: (c, s) => const AddMedicationStep1Screen()),
      GoRoute(path: '/nurse/medications/add/step2', builder: (c, s) => const AddMedicationStep2Screen()),
      GoRoute(path: '/nurse/medications/add/step3', builder: (c, s) => const AddMedicationStep3Screen()),
      GoRoute(
        path: '/nurse/medications/dose-confirmation',
        builder: (c, s) => DoseConfirmationScreen(
          medicationId: int.tryParse(s.uri.queryParameters['medication_id'] ?? ''),
          studentId: int.tryParse(s.uri.queryParameters['student_id'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/nurse/medications/dose-conflict',
        builder: (c, s) => DoseConflictAlertScreen(
          medicationId: int.tryParse(s.uri.queryParameters['medication_id'] ?? ''),
          studentId: int.tryParse(s.uri.queryParameters['student_id'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/nurse/medications/low-supply',
        builder: (c, s) => LowSupplyAlertScreen(
          medicationId: int.tryParse(s.uri.queryParameters['medication_id'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/nurse/medications/:id',
        builder: (c, s) => NurseMedicationDetailScreen(id: s.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/nurse/clinic', builder: (c, s) => const ClinicVisitListScreen()),
      GoRoute(
        path: '/nurse/clinic/visit/:id',
        builder: (c, s) => ClinicVisitDetailScreen(id: s.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/nurse/clinic/new-visit', builder: (c, s) => const NewClinicVisitScreen()),
      GoRoute(path: '/nurse/clinic/emergency-photo', builder: (c, s) => const EmergencyPhotoUploadScreen()),
      GoRoute(path: '/nurse/clinic/emergency-consent', builder: (c, s) => const EmergencyConsentRequestScreen()),
      GoRoute(path: '/nurse/clinic/emergency-escalation', builder: (c, s) => const EmergencyEscalationScreen()),
      GoRoute(path: '/nurse/students', builder: (c, s) => const StudentSearchScreen()),
      GoRoute(
        path: '/nurse/students/:id',
        builder: (c, s) => StudentHealthProfileScreen(id: s.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/nurse/documents/review', builder: (c, s) => const DocumentReviewQueueScreen()),
      GoRoute(
        path: '/nurse/documents/review/:id',
        builder: (c, s) => DocumentViewerScreen(id: s.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/nurse/cafeteria-alert', builder: (c, s) => const SendCafeteriaAlertScreen()),
      GoRoute(path: '/nurse/reports', builder: (c, s) => const NurseReportsScreen()),
      GoRoute(path: '/nurse/reports/generate', builder: (c, s) => const GenerateReportScreen()),
      GoRoute(path: '/nurse/reports/preview', builder: (c, s) => const ReportPreviewScreen()),
      GoRoute(path: '/nurse/settings', builder: (c, s) => const NurseSettingsScreen()),
      GoRoute(path: '/nurse/notifications', builder: (c, s) => const NurseNotificationsScreen()),
    ],
  ),
];
