import 'package:go_router/go_router.dart';

import '../../core/widgets/role_shell.dart';
import '../../data/models/authorized_person.dart';
import 'parent_app_tabs.dart';
import 'parent_legacy_tabs.dart';
import 'view/parent_add_authorized_person_screen.dart';
import 'view/parent_authorized_persons_manager_screen.dart';
import 'view/parent_authorized_pickups_screen.dart';
import 'view/parent_bus_live_tracking_screen.dart';
import 'view/parent_chat_tab_screen.dart';
import 'view/parent_chatbot_assistant_screen.dart';
import 'view/parent_child_confirmation_screen.dart';
import 'view/parent_clinic_history_screen.dart';
import 'view/parent_dashboard_screen.dart';
import 'view/parent_docs_tab_screen.dart';
import 'view/parent_document_expiry_alert_screen.dart';
import 'view/parent_document_upload_onboarding_screen.dart';
import 'view/parent_document_upload_screen.dart';
import 'view/parent_emergency_consent_response_screen.dart';
import 'view/parent_emergency_consent_screen.dart';
import 'view/parent_full_qrcode_screen.dart';
import 'view/parent_home_dashboard_screen.dart';
import 'view/parent_medication_log_screen.dart';
import 'view/parent_medications_screen.dart';
import 'view/parent_notification_settings_screen.dart';
import 'view/parent_notifications_screen.dart';
import 'view/parent_privacy_agreement_screen.dart';
import 'view/parent_profile_not_active_screen.dart';
import 'view/parent_profile_settings_screen.dart';
import 'view/parent_report_home_dose_screen.dart';
import 'view/parent_school_code_entry_screen.dart';
import 'view/parent_setup_complete_screen.dart';
import 'view/parent_suspend_school_dose_screen.dart';

/// All Parent routes across the three flows (paths mirror `src/app/routes.tsx`):
///   A) the modern Parent App (`/parent/app/*`) — tab screens live in a
///      [RoleShell] bottom-nav shell; full-screen screens are top-level routes;
///   B) onboarding (`/parent/onboarding/*`) — top-level, no shell;
///   C) the legacy portal (`/parent/*`) — its own [RoleShell] with legacy tabs.
final List<RouteBase> parentRoutes = [
  // A) Parent App — bottom-nav tab screens + non-tab children inside the shell.
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: parentAppTabs, child: child),
    routes: [
      GoRoute(path: '/parent/app/home', builder: (c, s) => const ParentHomeDashboardScreen()),
      GoRoute(path: '/parent/app/health', builder: (c, s) => const ParentClinicHistoryScreen()),
      GoRoute(path: '/parent/app/medications', builder: (c, s) => const ParentMedicationLogScreen()),
      GoRoute(path: '/parent/app/docs', builder: (c, s) => const ParentDocsTabScreen()),
      GoRoute(path: '/parent/app/chat', builder: (c, s) => const ParentChatTabScreen()),
      GoRoute(
        path: '/parent/app/emergency-consent',
        builder: (c, s) => const ParentEmergencyConsentResponseScreen(),
      ),
      GoRoute(
        path: '/parent/app/report-home-dose',
        builder: (c, s) => const ParentReportHomeDoseScreen(),
      ),
      GoRoute(
        path: '/parent/app/suspend-school-dose',
        builder: (c, s) => const ParentSuspendSchoolDoseScreen(),
      ),
      GoRoute(
        path: '/parent/app/authorized-persons',
        builder: (c, s) => const ParentAuthorizedPersonsManagerScreen(),
      ),
      GoRoute(
        path: '/parent/app/add-authorized-person',
        builder: (c, s) => const ParentAddAuthorizedPersonScreen(),
      ),
      GoRoute(
        path: '/parent/app/notifications',
        builder: (c, s) => const ParentNotificationSettingsScreen(),
      ),
    ],
  ),

  // A) Parent App — full-screen screens (no bottom nav), top-level routes.
  GoRoute(
    path: '/parent/app/chatbot-assistant',
    builder: (c, s) => const ParentChatbotAssistantScreen(),
  ),
  GoRoute(
    path: '/parent/app/document-upload',
    builder: (c, s) => const ParentDocumentUploadScreen(),
  ),
  GoRoute(
    path: '/parent/app/full-qrcode/:personId',
    builder: (c, s) => ParentFullQrCodeScreen(
      personId: s.pathParameters['personId'] ?? '',
      person: s.extra is AuthorizedPerson ? s.extra as AuthorizedPerson : null,
    ),
  ),
  GoRoute(
    path: '/parent/app/document-expiry-alert',
    builder: (c, s) => const ParentDocumentExpiryAlertScreen(),
  ),
  GoRoute(
    path: '/parent/app/bus-tracking',
    builder: (c, s) => const ParentBusLiveTrackingScreen(),
  ),
  GoRoute(
    path: '/parent/app/profile-settings',
    builder: (c, s) => const ParentProfileSettingsScreen(),
  ),

  // C) Legacy Parent portal — its own bottom-nav shell.
  ShellRoute(
    builder: (c, s, child) => RoleShell(tabs: parentLegacyTabs, child: child),
    routes: [
      GoRoute(path: '/parent/dashboard', builder: (c, s) => const ParentDashboardScreen()),
      GoRoute(path: '/parent/medications', builder: (c, s) => const ParentMedicationsScreen()),
      GoRoute(path: '/parent/notifications', builder: (c, s) => const ParentNotificationsScreen()),
    ],
  ),

  // B) Onboarding flow — top-level, no layout.
  GoRoute(
    path: '/parent/onboarding/code',
    builder: (c, s) => const ParentSchoolCodeEntryScreen(),
  ),
  GoRoute(
    path: '/parent/onboarding/confirm-child',
    builder: (c, s) => const ParentChildConfirmationScreen(),
  ),
  GoRoute(
    path: '/parent/onboarding/emergency-consent',
    builder: (c, s) => const ParentEmergencyConsentScreen(),
  ),
  GoRoute(
    path: '/parent/onboarding/privacy-agreement',
    builder: (c, s) => const ParentPrivacyAgreementScreen(),
  ),
  GoRoute(
    path: '/parent/onboarding/documents',
    builder: (c, s) => const ParentDocumentUploadOnboardingScreen(),
  ),
  GoRoute(
    path: '/parent/onboarding/authorized-pickups',
    builder: (c, s) => const ParentAuthorizedPickupsScreen(),
  ),
  GoRoute(
    path: '/parent/onboarding/complete',
    builder: (c, s) => const ParentSetupCompleteScreen(),
  ),
  GoRoute(
    path: '/parent/onboarding/not-active',
    builder: (c, s) => const ParentProfileNotActiveScreen(),
  ),
];
