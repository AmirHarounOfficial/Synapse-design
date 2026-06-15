import { createBrowserRouter, Navigate } from 'react-router';
import { SynapseNavigationMap } from './components/SynapseNavigationMap';

// Auth screens
import { Splash } from './components/Splash';
import { Login } from './components/Login';
import { TwoFactorAuth } from './components/TwoFactorAuth';
import { BiometricPrompt } from './components/BiometricPrompt';
import { ConfidentialityAgreement } from './components/ConfidentialityAgreement';
import { ESignature } from './components/ESignature';

// Layouts
import { NurseLayout } from './components/NurseLayout';
import { ParentLayout } from './components/ParentLayout';
import { TeacherLayout } from './components/TeacherLayout';
import { CafeteriaLayout } from './components/CafeteriaLayout';

// Nurse screens
import { NurseDashboard } from './components/NurseDashboard';
import { NurseMedications } from './components/NurseMedications';
import { NurseMedicationDetail } from './components/NurseMedicationDetail';
import { AddMedicationStep1 } from './components/AddMedicationStep1';
import { AddMedicationStep2 } from './components/AddMedicationStep2';
import { AddMedicationStep3 } from './components/AddMedicationStep3';
import { DoseConfirmation } from './components/DoseConfirmation';
import { DoseConflictAlert } from './components/DoseConflictAlert';
import { LowSupplyAlert } from './components/LowSupplyAlert';
import { NewClinicVisit } from './components/NewClinicVisit';
import { EmergencyPhotoUpload } from './components/EmergencyPhotoUpload';
import { EmergencyConsentRequest } from './components/EmergencyConsentRequest';
import { EmergencyEscalation } from './components/EmergencyEscalation';
import { NurseClinic } from './components/NurseClinic';
import { NurseStudents } from './components/NurseStudents';
import { NurseReports } from './components/NurseReports';
import { NurseNotifications } from './components/NurseNotifications';
import { DailyDoseView } from './components/DailyDoseView';
import { ClinicVisitList } from './components/ClinicVisitList';
import { StudentSearch } from './components/StudentSearch';
import { StudentHealthProfile } from './components/StudentHealthProfile';
import { DocumentReviewQueue } from './components/DocumentReviewQueue';
import { DocumentViewer } from './components/DocumentViewer';
import { SendCafeteriaAlert } from './components/SendCafeteriaAlert';
import { GenerateReport } from './components/GenerateReport';
import { ReportPreview } from './components/ReportPreview';
import { NurseSettings } from './components/NurseSettings';

// Parent onboarding screens
import { ParentSchoolCodeEntry } from './components/ParentSchoolCodeEntry';
import { ParentChildConfirmation } from './components/ParentChildConfirmation';
import { ParentEmergencyConsent } from './components/ParentEmergencyConsent';
import { ParentPrivacyAgreement } from './components/ParentPrivacyAgreement';
import { ParentDocumentUpload } from './components/ParentDocumentUpload';
import { ParentAuthorizedPickups } from './components/ParentAuthorizedPickups';
import { ParentSetupComplete } from './components/ParentSetupComplete';
import { ParentProfileNotActive } from './components/ParentProfileNotActive';

// Parent App with Layout
import { ParentAppLayout } from './components/ParentAppLayout';
import { ParentHomeDashboard } from './components/ParentHomeDashboard';
import { ParentEmergencyConsentResponse } from './components/ParentEmergencyConsentResponse';
import { ParentClinicHistory } from './components/ParentClinicHistory';
import { ParentMedicationLog } from './components/ParentMedicationLog';
import { ParentReportHomeDose } from './components/ParentReportHomeDose';
import { ParentSuspendSchoolDose } from './components/ParentSuspendSchoolDose';
import { ParentAuthorizedPersonsManager } from './components/ParentAuthorizedPersonsManager';
import { ParentNotificationSettings } from './components/ParentNotificationSettings';
import { ParentDocsTab } from './components/ParentDocsTab';
import { ParentChatTab } from './components/ParentChatTab';
import { ParentChatbotAssistant } from './components/ParentChatbotAssistant';
import { ParentDocumentUploadScreen } from './components/ParentDocumentUpload';
import { ParentFullQRCode } from './components/ParentFullQRCode';
import { ParentDocumentExpiryAlert } from './components/ParentDocumentExpiryAlert';
import { ParentBusLiveTracking } from './components/ParentBusLiveTracking';
import { ParentProfileSettings } from './components/ParentProfileSettings';

// Old Parent Portal (legacy)
import { ParentDashboard } from './components/ParentDashboard';
import { ParentMedications } from './components/ParentMedications';
import { ParentNotifications } from './components/ParentNotifications';

// Teacher screens
import { TeacherDashboard } from './components/TeacherDashboard';
import { TeacherAttendance } from './components/TeacherAttendance';
import { TeacherHealthConsiderations } from './components/TeacherHealthConsiderations';
import { TeacherClinicReferral } from './components/TeacherClinicReferral';
import { TeacherStudentReleaseNotification } from './components/TeacherStudentReleaseNotification';
import { TeacherWeatherRestriction } from './components/TeacherWeatherRestriction';
import { TeacherActivityExemptions } from './components/TeacherActivityExemptions';
import { TeacherNotificationHistory } from './components/TeacherNotificationHistory';
import { TeacherSettings } from './components/TeacherSettings';

// Cafeteria screens
import { CafeteriaAlertDashboard } from './components/CafeteriaAlertDashboard';
import { CafeteriaAllergenDetail } from './components/CafeteriaAllergenDetail';
import { CafeteriaRealtimeAlert } from './components/CafeteriaRealtimeAlert';
import { CafeteriaDeliveryHistory } from './components/CafeteriaDeliveryHistory';
import { CafeteriaEmptyState } from './components/CafeteriaEmptyState';
import { CafeteriaSettings } from './components/CafeteriaSettings';

// Security Guard screens
import { SecurityGuardLayout } from './components/SecurityGuardLayout';
import { SecurityPickupQueue } from './components/SecurityPickupQueue';
import { SecurityQRScanner } from './components/SecurityQRScanner';
import { SecurityManualVerification } from './components/SecurityManualVerification';
import { SecurityAuthorizedConfirmation } from './components/SecurityAuthorizedConfirmation';
import { SecurityPickupHistory } from './components/SecurityPickupHistory';
import { SecuritySettings } from './components/SecuritySettings';

// Bus Driver screens
import { BusDriverLayout } from './components/BusDriverLayout';
import { BusRouteOverview } from './components/BusRouteOverview';
import { BusStudentBoarding } from './components/BusStudentBoarding';
import { BusStudentDeboarding } from './components/BusStudentDeboarding';
import { BusEarlyDismissal } from './components/BusEarlyDismissal';
import { BusRouteHistory } from './components/BusRouteHistory';
import { BusDriverSettings } from './components/BusDriverSettings';

// Student Counselor screens
import { CounselorLayout } from './components/CounselorLayout';
import { CounselorDashboard } from './components/CounselorDashboard';
import { CounselorTagEntry } from './components/CounselorTagEntry';
import { CounselorStudentTagsHistory } from './components/CounselorStudentTagsHistory';
import { CounselorGenerateReport } from './components/CounselorGenerateReport';
import { CounselorReportPreview } from './components/CounselorReportPreview';
import { CounselorStudentsList } from './components/CounselorStudentsList';
import { CounselorReportsList } from './components/CounselorReportsList';
import { CounselorSettings } from './components/CounselorSettings';

// Secretary screens
import { SecretaryLayout } from './components/SecretaryLayout';
import { SecretaryDashboard } from './components/SecretaryDashboard';
import { SecretaryStudentList } from './components/SecretaryStudentList';
import { SecretaryImportStudents } from './components/SecretaryImportStudents';
import { SecretaryMessagesInbox } from './components/SecretaryMessagesInbox';
import { SecretaryChatbotQueue } from './components/SecretaryChatbotQueue';
import { SecretaryComposeMessage } from './components/SecretaryComposeMessage';
import { SecretarySettings } from './components/SecretarySettings';

// Principal screens
import { PrincipalLayout } from './components/PrincipalLayout';
import { PrincipalDashboard } from './components/PrincipalDashboard';
import { PrincipalStaffManagement } from './components/PrincipalStaffManagement';
import { PrincipalAddEditStaff } from './components/PrincipalAddEditStaff';
import { PrincipalPermissionMatrix } from './components/PrincipalPermissionMatrix';
import { PrincipalHealthAnalytics } from './components/PrincipalHealthAnalytics';
import { PrincipalWeatherAdvisory } from './components/PrincipalWeatherAdvisory';
import { PrincipalAuditLog } from './components/PrincipalAuditLog';
import { PrincipalSMSWallet } from './components/PrincipalSMSWallet';
import { PrincipalAfterHoursAccess } from './components/PrincipalAfterHoursAccess';
import { PrincipalAnnualReport } from './components/PrincipalAnnualReport';
import { PrincipalStudentPromotion } from './components/PrincipalStudentPromotion';
import { PrincipalSchoolSetup } from './components/PrincipalSchoolSetup';
import { PrincipalLegalDocuments } from './components/PrincipalLegalDocuments';

// Physician screens
import { PhysicianLayout } from './components/PhysicianLayout';
import { PhysicianDashboard } from './components/PhysicianDashboard';
import { MedicationProtocolReview } from './components/MedicationProtocolReview';
import { ClinicalEscalationInbox } from './components/ClinicalEscalationInbox';
import { ReportCoSignature } from './components/ReportCoSignature';
import { PhysicianScheduleConfig } from './components/PhysicianScheduleConfig';
import { PhysicianSettings } from './components/PhysicianSettings';

// Vice Principal screens
import { VicePrincipalLayout } from './components/VicePrincipalLayout';
import { VicePrincipalDashboard } from './components/VicePrincipalDashboard';
import { VicePrincipalPermissions } from './components/VicePrincipalPermissions';
import { VicePrincipalClinicReadiness } from './components/VicePrincipalClinicReadiness';
import { VicePrincipalEquipmentChecklist } from './components/VicePrincipalEquipmentChecklist';
import { VicePrincipalAnalytics } from './components/VicePrincipalAnalytics';
import { VicePrincipalMessages } from './components/VicePrincipalMessages';
import { VicePrincipalSettings } from './components/VicePrincipalSettings';

// Special System States (iPhone 16 Pro overlays)
import { SysAfterHoursLock } from './components/SysAfterHoursLock';
import { SysWeatherAdvisory } from './components/SysWeatherAdvisory';
import { SysConsentPending } from './components/SysConsentPending';
import { SysSessionExpiry } from './components/SysSessionExpiry';
import { SystemStateShowcase } from './components/SystemStateShowcase';
import { RamadanModeScreen } from './components/RamadanModeScreen';


export const router = createBrowserRouter([
  // Default redirect
  {
    path: '/',
    Component: SynapseNavigationMap
  },


  // Auth Flow
  {
    path: '/splash',
    Component: Splash
  },
  {
    path: '/login',
    Component: Login
  },
  {
    path: '/verify',
    Component: TwoFactorAuth
  },
  {
    path: '/biometric',
    Component: BiometricPrompt
  },
  {
    path: '/agreement',
    Component: ConfidentialityAgreement
  },
  {
    path: '/signature',
    Component: ESignature
  },

  // Nurse Portal
  {
    path: '/nurse',
    Component: NurseLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/nurse/dashboard" replace />
      },
      {
        path: 'dashboard',
        Component: NurseDashboard
      },
      {
        path: 'daily-doses',
        Component: DailyDoseView
      },
      {
        path: 'medications',
        Component: NurseMedications
      },
      {
        path: 'medications/:id',
        Component: NurseMedicationDetail
      },
      {
        path: 'medications/add/step1',
        Component: AddMedicationStep1
      },
      {
        path: 'medications/add/step2',
        Component: AddMedicationStep2
      },
      {
        path: 'medications/add/step3',
        Component: AddMedicationStep3
      },
      {
        path: 'medications/dose-confirmation',
        Component: DoseConfirmation
      },
      {
        path: 'medications/dose-conflict',
        Component: DoseConflictAlert
      },
      {
        path: 'medications/low-supply',
        Component: LowSupplyAlert
      },
      {
        path: 'clinic',
        Component: ClinicVisitList
      },
      {
        path: 'clinic/new-visit',
        Component: NewClinicVisit
      },
      {
        path: 'clinic/emergency-photo',
        Component: EmergencyPhotoUpload
      },
      {
        path: 'clinic/emergency-consent',
        Component: EmergencyConsentRequest
      },
      {
        path: 'clinic/emergency-escalation',
        Component: EmergencyEscalation
      },
      {
        path: 'students',
        Component: StudentSearch
      },
      {
        path: 'students/:id',
        Component: StudentHealthProfile
      },
      {
        path: 'documents/review',
        Component: DocumentReviewQueue
      },
      {
        path: 'documents/review/:id',
        Component: DocumentViewer
      },
      {
        path: 'cafeteria-alert',
        Component: SendCafeteriaAlert
      },
      {
        path: 'reports',
        Component: NurseReports
      },
      {
        path: 'reports/generate',
        Component: GenerateReport
      },
      {
        path: 'reports/preview',
        Component: ReportPreview
      },
      {
        path: 'settings',
        Component: NurseSettings
      },
      {
        path: 'notifications',
        Component: NurseNotifications
      }
    ]
  },

  // Parent App with Layout
  {
    path: '/parent/app',
    Component: ParentAppLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/parent/app/home" replace />
      },
      {
        path: 'home',
        Component: ParentHomeDashboard
      },
      {
        path: 'health',
        Component: ParentClinicHistory
      },
      {
        path: 'medications',
        Component: ParentMedicationLog
      },
      {
        path: 'docs',
        Component: ParentDocsTab
      },
      {
        path: 'chat',
        Component: ParentChatTab
      },
      {
        path: 'emergency-consent',
        Component: ParentEmergencyConsentResponse
      },
      {
        path: 'report-home-dose',
        Component: ParentReportHomeDose
      },
      {
        path: 'suspend-school-dose',
        Component: ParentSuspendSchoolDose
      },
      {
        path: 'authorized-persons',
        Component: ParentAuthorizedPersonsManager
      },
      {
        path: 'notifications',
        Component: ParentNotificationSettings
      }
    ]
  },

  // Parent App - Full Screen Screens (no bottom nav)
  {
    path: '/parent/app/chatbot-assistant',
    Component: ParentChatbotAssistant
  },
  {
    path: '/parent/app/document-upload',
    Component: ParentDocumentUploadScreen
  },
  {
    path: '/parent/app/full-qrcode/:personId',
    Component: ParentFullQRCode
  },
  {
    path: '/parent/app/document-expiry-alert',
    Component: ParentDocumentExpiryAlert
  },
  {
    path: '/parent/app/bus-tracking',
    Component: ParentBusLiveTracking
  },
  {
    path: '/parent/app/profile-settings',
    Component: ParentProfileSettings
  },

  // Old Parent Portal (legacy)
  {
    path: '/parent',
    Component: ParentLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/parent/dashboard" replace />
      },
      {
        path: 'dashboard',
        Component: ParentDashboard
      },
      {
        path: 'medications',
        Component: ParentMedications
      },
      {
        path: 'notifications',
        Component: ParentNotifications
      }
    ]
  },

  // Parent Onboarding Flow (no layout)
  {
    path: '/parent/onboarding/code',
    Component: ParentSchoolCodeEntry
  },
  {
    path: '/parent/onboarding/confirm-child',
    Component: ParentChildConfirmation
  },
  {
    path: '/parent/onboarding/emergency-consent',
    Component: ParentEmergencyConsent
  },
  {
    path: '/parent/onboarding/privacy-agreement',
    Component: ParentPrivacyAgreement
  },
  {
    path: '/parent/onboarding/documents',
    Component: ParentDocumentUpload
  },
  {
    path: '/parent/onboarding/authorized-pickups',
    Component: ParentAuthorizedPickups
  },
  {
    path: '/parent/onboarding/complete',
    Component: ParentSetupComplete
  },
  {
    path: '/parent/onboarding/not-active',
    Component: ParentProfileNotActive
  },

  // Teacher Portal
  {
    path: '/teacher',
    Component: TeacherLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/teacher/home" replace />
      },
      {
        path: 'home',
        Component: TeacherDashboard
      },
      {
        path: 'attendance',
        Component: TeacherAttendance
      },
      {
        path: 'health-considerations',
        Component: TeacherHealthConsiderations
      },
      {
        path: 'clinic-referral',
        Component: TeacherClinicReferral
      },
      {
        path: 'student-release',
        Component: TeacherStudentReleaseNotification
      },
      {
        path: 'weather-restriction',
        Component: TeacherWeatherRestriction
      },
      {
        path: 'activity-exemptions',
        Component: TeacherActivityExemptions
      },
      {
        path: 'notifications',
        Component: TeacherNotificationHistory
      },
      {
        path: 'settings',
        Component: TeacherSettings
      }
    ]
  },

  // Cafeteria Portal
  {
    path: '/cafeteria',
    Component: CafeteriaLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/cafeteria/alerts" replace />
      },
      {
        path: 'alerts',
        Component: CafeteriaAlertDashboard
      },
      {
        path: 'detail/:id',
        Component: CafeteriaAllergenDetail
      },
      {
        path: 'realtime-alert',
        Component: CafeteriaRealtimeAlert
      },
      {
        path: 'history',
        Component: CafeteriaDeliveryHistory
      },
      {
        path: 'empty',
        Component: CafeteriaEmptyState
      },
      {
        path: 'settings',
        Component: CafeteriaSettings
      }
    ]
  },

  // Security Guard Portal
  {
    path: '/security',
    Component: SecurityGuardLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/security/pickups" replace />
      },
      {
        path: 'pickups',
        Component: SecurityPickupQueue
      },
      {
        path: 'scanner',
        Component: SecurityQRScanner
      },
      {
        path: 'manual-verification',
        Component: SecurityManualVerification
      },
      {
        path: 'authorized-confirmation',
        Component: SecurityAuthorizedConfirmation
      },
      {
        path: 'history',
        Component: SecurityPickupHistory
      },
      {
        path: 'settings',
        Component: SecuritySettings
      }
    ]
  },

  // Bus Driver Portal
  {
    path: '/bus',
    Component: BusDriverLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/bus/route" replace />
      },
      {
        path: 'route',
        Component: BusRouteOverview
      },
      {
        path: 'boarding/:id',
        Component: BusStudentBoarding
      },
      {
        path: 'deboarding/:id',
        Component: BusStudentDeboarding
      },
      {
        path: 'early-dismissal',
        Component: BusEarlyDismissal
      },
      {
        path: 'history',
        Component: BusRouteHistory
      },
      {
        path: 'settings',
        Component: BusDriverSettings
      }
    ]
  },

  // Student Counselor Portal
  {
    path: '/counselor',
    Component: CounselorLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/counselor/home" replace />
      },
      {
        path: 'home',
        Component: CounselorDashboard
      },
      {
        path: 'students',
        Component: CounselorStudentsList
      },
      {
        path: 'reports',
        Component: CounselorReportsList
      },
      {
        path: 'settings',
        Component: CounselorSettings
      }
    ]
  },

  // Counselor Full Screen Screens (no bottom nav)
  {
    path: '/counselor/tag-entry',
    Component: CounselorTagEntry
  },
  {
    path: '/counselor/student-tags/:id',
    Component: CounselorStudentTagsHistory
  },
  {
    path: '/counselor/generate-report',
    Component: CounselorGenerateReport
  },
  {
    path: '/counselor/report-preview',
    Component: CounselorReportPreview
  },

  // Secretary Portal
  {
    path: '/secretary',
    Component: SecretaryLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/secretary/home" replace />
      },
      {
        path: 'home',
        Component: SecretaryDashboard
      },
      {
        path: 'students',
        Component: SecretaryStudentList
      },
      {
        path: 'messages',
        Component: SecretaryMessagesInbox
      },
      {
        path: 'chatbot',
        Component: SecretaryChatbotQueue
      },
      {
        path: 'settings',
        Component: SecretarySettings
      }
    ]
  },

  // Secretary Full Screen Screens (no bottom nav)
  {
    path: '/secretary/import-students',
    Component: SecretaryImportStudents
  },
  {
    path: '/secretary/compose-message',
    Component: SecretaryComposeMessage
  },

  // Principal Portal
  {
    path: '/principal',
    Component: PrincipalLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/principal/home" replace />
      },
      {
        path: 'home',
        Component: PrincipalDashboard
      },
      {
        path: 'staff',
        Component: PrincipalStaffManagement
      },
      {
        path: 'analytics',
        Component: PrincipalHealthAnalytics
      },
      {
        path: 'settings',
        element: <div className="min-h-screen bg-[#F8FAFC] flex items-center justify-center pb-[83px]"><div className="text-center text-[#64748B]">Settings screen placeholder</div></div>
      },
      {
        path: 'audit',
        Component: PrincipalAuditLog
      }
    ]
  },

  // Principal Full Screen Screens (no bottom nav)
  {
    path: '/principal/add-staff',
    Component: PrincipalAddEditStaff
  },
  {
    path: '/principal/edit-staff/:staffId',
    Component: PrincipalAddEditStaff
  },
  {
    path: '/principal/permission-matrix',
    Component: PrincipalPermissionMatrix
  },
  {
    path: '/principal/weather-advisory',
    Component: PrincipalWeatherAdvisory
  },
  {
    path: '/principal/sms-wallet',
    Component: PrincipalSMSWallet
  },
  {
    path: '/principal/after-hours-access',
    Component: PrincipalAfterHoursAccess
  },
  {
    path: '/principal/annual-report',
    Component: PrincipalAnnualReport
  },
  {
    path: '/principal/student-promotion',
    Component: PrincipalStudentPromotion
  },
  {
    path: '/principal/school-setup',
    Component: PrincipalSchoolSetup
  },
  {
    path: '/principal/legal-documents',
    Component: PrincipalLegalDocuments
  },

  // Physician Portal
  {
    path: '/physician',
    Component: PhysicianLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/physician/dashboard" replace />
      },
      {
        path: 'dashboard',
        Component: PhysicianDashboard
      },
      {
        path: 'protocols',
        Component: MedicationProtocolReview
      },
      {
        path: 'protocols/:id',
        Component: MedicationProtocolReview
      },
      {
        path: 'escalations',
        Component: ClinicalEscalationInbox
      },
      {
        path: 'co-sign/:id',
        Component: ReportCoSignature
      },
      {
        path: 'schedule',
        Component: PhysicianScheduleConfig
      },
      {
        path: 'settings',
        Component: PhysicianSettings
      }
    ]
  },

  // Vice Principal Portal
  {
    path: '/vice-principal',
    Component: VicePrincipalLayout,
    children: [
      {
        index: true,
        element: <Navigate to="/vice-principal/home" replace />
      },
      {
        path: 'home',
        Component: VicePrincipalDashboard
      },
      {
        path: 'analytics',
        Component: VicePrincipalAnalytics
      },
      {
        path: 'clinic-readiness',
        Component: VicePrincipalClinicReadiness
      },
      {
        path: 'messages',
        Component: VicePrincipalMessages
      },
      {
        path: 'settings',
        Component: VicePrincipalSettings
      }
    ]
  },

  // Vice Principal Full Screen Screens (no bottom nav)
  {
    path: '/vice-principal/permissions',
    Component: VicePrincipalPermissions
  },
  {
    path: '/vice-principal/equipment-checklist',
    Component: VicePrincipalEquipmentChecklist
  },

  // Special System States (iPhone 16 Pro Overlays)
  {
    path: '/system/after-hours',
    Component: SysAfterHoursLock
  },
  {
    path: '/system/weather-advisory',
    Component: SysWeatherAdvisory
  },
  {
    path: '/system/consent-pending',
    Component: SysConsentPending
  },
  {
    path: '/system/session-expiry',
    Component: SysSessionExpiry
  },
  {
    path: '/system/simulator',
    Component: SystemStateShowcase
  },
  {
    path: '/system/ramadan',
    Component: RamadanModeScreen
  },


  // Catch all
  {
    path: '*',
    element: <Navigate to="/" replace />
  }
]);
