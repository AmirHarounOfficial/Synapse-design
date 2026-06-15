import { Link } from 'react-router';
import {
  Activity,
  AlertTriangle,
  ArrowRight,
  Baby,
  BarChart3,
  Bell,
  Bot,
  Bus,
  ChefHat,
  ClipboardCheck,
  FileCheck2,
  FileText,
  HeartPulse,
  Home,
  IdCard,
  KeyRound,
  Lock,
  Map,
  MessageSquare,
  Microscope,
  Pill,
  QrCode,
  Search,
  Settings,
  ShieldCheck,
  Signature,
  Smartphone,
  Sparkles,
  Stethoscope,
  UploadCloud,
  UserCheck,
  UserCog,
  Users,
  Moon,
} from 'lucide-react';
import { useMemo, useState } from 'react';

type RouteItem = {
  label: string;
  path: string;
  samplePath?: string;
  type?: 'Primary' | 'Flow' | 'Utility' | 'Legacy';
};

type RouteGroup = {
  title: string;
  audience: string;
  summary: string;
  accent: string;
  icon: typeof HeartPulse;
  routes: RouteItem[];
};

const routeGroups: RouteGroup[] = [
  {
    title: 'Entry & Trust',
    audience: 'All users',
    summary: 'Authentication, verification, confidentiality, and signing screens that establish access and consent.',
    accent: 'bg-[#0F766E]',
    icon: KeyRound,
    routes: [
      { label: 'Splash', path: '/splash', type: 'Flow' },
      { label: 'Login', path: '/login', type: 'Flow' },
      { label: 'Two-factor verification', path: '/verify', type: 'Flow' },
      { label: 'Biometric prompt', path: '/biometric', type: 'Flow' },
      { label: 'Confidentiality agreement', path: '/agreement', type: 'Flow' },
      { label: 'E-signature', path: '/signature', type: 'Flow' },
    ],
  },
  {
    title: 'Principal Command Center',
    audience: 'School leadership',
    summary: 'Oversight for school health operations, staff access, reporting, weather advisories, and legal readiness.',
    accent: 'bg-[#1D4ED8]',
    icon: BarChart3,
    routes: [
      { label: 'Principal home', path: '/principal/home', type: 'Primary' },
      { label: 'Staff management', path: '/principal/staff', type: 'Primary' },
      { label: 'Health analytics & Ramadan trends', path: '/principal/analytics', type: 'Primary' },
      { label: 'Settings placeholder', path: '/principal/settings', type: 'Utility' },
      { label: 'Audit log', path: '/principal/audit', type: 'Primary' },
      { label: 'Add staff (UAE Licenses)', path: '/principal/add-staff', type: 'Flow' },
      { label: 'Edit staff', path: '/principal/edit-staff/:staffId', samplePath: '/principal/edit-staff/demo-staff', type: 'Flow' },
      { label: 'Permission matrix', path: '/principal/permission-matrix', type: 'Utility' },
      { label: 'Weather advisory (Haboob & NCM)', path: '/principal/weather-advisory', type: 'Flow' },
      { label: 'SMS wallet', path: '/principal/sms-wallet', type: 'Utility' },
      { label: 'After-hours access', path: '/principal/after-hours-access', type: 'Utility' },
      { label: 'Annual report', path: '/principal/annual-report', type: 'Flow' },
      { label: 'Student promotion', path: '/principal/student-promotion', type: 'Flow' },
      { label: 'School setup', path: '/principal/school-setup', type: 'Flow' },
      { label: 'Legal & UAE PDPL Compliance', path: '/principal/legal-documents', type: 'Utility' },
    ],
  },
  {
    title: 'School Physician Portal',
    audience: 'School physician',
    summary: 'Clinical protocols review, escalations management, reports co-signature, and weekly schedule configuration.',
    accent: 'bg-[#0D9488]',
    icon: Stethoscope,
    routes: [
      { label: 'Physician dashboard', path: '/physician/dashboard', type: 'Primary' },
      { label: 'Protocol review', path: '/physician/medication-review/:id', samplePath: '/physician/medication-review/1', type: 'Flow' },
      { label: 'Escalations inbox', path: '/physician/escalations', type: 'Primary' },
      { label: 'Report co-signature', path: '/physician/co-sign/:id', samplePath: '/physician/co-sign/1', type: 'Flow' },
      { label: 'Schedule configuration', path: '/physician/schedule', type: 'Primary' },
      { label: 'Physician settings', path: '/physician/settings', type: 'Utility' },
    ],
  },
  {
    title: 'Nurse Clinical Operations',
    audience: 'School nurse',
    summary: 'Daily medication work, clinic visits, emergency escalation, student health profiles, documents, and nurse reports.',
    accent: 'bg-[#DC2626]',
    icon: Stethoscope,
    routes: [
      { label: 'Nurse dashboard', path: '/nurse/dashboard', type: 'Primary' },
      { label: 'Daily doses', path: '/nurse/daily-doses', type: 'Primary' },
      { label: 'Medication list', path: '/nurse/medications', type: 'Primary' },
      { label: 'Medication detail', path: '/nurse/medications/:id', samplePath: '/nurse/medications/demo-medication', type: 'Flow' },
      { label: 'Add medication - step 1', path: '/nurse/medications/add/step1', type: 'Flow' },
      { label: 'Add medication - step 2', path: '/nurse/medications/add/step2', type: 'Flow' },
      { label: 'Add medication - step 3', path: '/nurse/medications/add/step3', type: 'Flow' },
      { label: 'Dose confirmation', path: '/nurse/medications/dose-confirmation', type: 'Flow' },
      { label: 'Dose conflict alert', path: '/nurse/medications/dose-conflict', type: 'Flow' },
      { label: 'Low supply alert', path: '/nurse/medications/low-supply', type: 'Flow' },
      { label: 'Clinic visits', path: '/nurse/clinic', type: 'Primary' },
      { label: 'New clinic visit', path: '/nurse/clinic/new-visit', type: 'Flow' },
      { label: 'Emergency photo upload', path: '/nurse/clinic/emergency-photo', type: 'Flow' },
      { label: 'Emergency consent request', path: '/nurse/clinic/emergency-consent', type: 'Flow' },
      { label: 'Emergency escalation', path: '/nurse/clinic/emergency-escalation', type: 'Flow' },
      { label: 'Student search', path: '/nurse/students', type: 'Primary' },
      { label: 'Student health profile', path: '/nurse/students/:id', samplePath: '/nurse/students/demo-student', type: 'Flow' },
      { label: 'Document review queue', path: '/nurse/documents/review', type: 'Primary' },
      { label: 'Document viewer', path: '/nurse/documents/review/:id', samplePath: '/nurse/documents/review/demo-document', type: 'Flow' },
      { label: 'Send cafeteria alert', path: '/nurse/cafeteria-alert', type: 'Flow' },
      { label: 'Reports', path: '/nurse/reports', type: 'Primary' },
      { label: 'Generate report', path: '/nurse/reports/generate', type: 'Flow' },
      { label: 'Report preview', path: '/nurse/reports/preview', type: 'Flow' },
      { label: 'Nurse settings', path: '/nurse/settings', type: 'Utility' },
      { label: 'Nurse notifications', path: '/nurse/notifications', type: 'Utility' },
    ],
  },
  {
    title: 'Parent Mobile App',
    audience: 'Parents and guardians',
    summary: 'A mobile-first experience for health history, medication logs, documents, chatbot help, pickups, QR codes, and bus tracking.',
    accent: 'bg-[#7C3AED]',
    icon: Baby,
    routes: [
      { label: 'Parent app home', path: '/parent/app/home', type: 'Primary' },
      { label: 'Health history', path: '/parent/app/health', type: 'Primary' },
      { label: 'Medication log', path: '/parent/app/medications', type: 'Primary' },
      { label: 'Documents tab', path: '/parent/app/docs', type: 'Primary' },
      { label: 'Chat tab', path: '/parent/app/chat', type: 'Primary' },
      { label: 'Emergency consent response', path: '/parent/app/emergency-consent', type: 'Flow' },
      { label: 'Report home dose', path: '/parent/app/report-home-dose', type: 'Flow' },
      { label: 'Suspend school dose', path: '/parent/app/suspend-school-dose', type: 'Flow' },
      { label: 'Authorized persons', path: '/parent/app/authorized-persons', type: 'Primary' },
      { label: 'Notification settings', path: '/parent/app/notifications', type: 'Utility' },
      { label: 'Chatbot assistant', path: '/parent/app/chatbot-assistant', type: 'Flow' },
      { label: 'Document upload', path: '/parent/app/document-upload', type: 'Flow' },
      { label: 'Full QR code', path: '/parent/app/full-qrcode/:personId', samplePath: '/parent/app/full-qrcode/demo-person', type: 'Flow' },
      { label: 'Document expiry alert', path: '/parent/app/document-expiry-alert', type: 'Flow' },
      { label: 'Bus live tracking', path: '/parent/app/bus-tracking', type: 'Flow' },
      { label: 'Profile settings', path: '/parent/app/profile-settings', type: 'Utility' },
    ],
  },
  {
    title: 'Parent Onboarding',
    audience: 'New parent accounts',
    summary: 'School-code connection, child confirmation, consent, privacy, documents, authorized pickup setup, and completion states.',
    accent: 'bg-[#DB2777]',
    icon: UserCheck,
    routes: [
      { label: 'School code entry', path: '/parent/onboarding/code', type: 'Flow' },
      { label: 'Confirm child', path: '/parent/onboarding/confirm-child', type: 'Flow' },
      { label: 'Emergency consent', path: '/parent/onboarding/emergency-consent', type: 'Flow' },
      { label: 'Privacy agreement', path: '/parent/onboarding/privacy-agreement', type: 'Flow' },
      { label: 'Documents', path: '/parent/onboarding/documents', type: 'Flow' },
      { label: 'Authorized pickups', path: '/parent/onboarding/authorized-pickups', type: 'Flow' },
      { label: 'Setup complete', path: '/parent/onboarding/complete', type: 'Flow' },
      { label: 'Profile not active', path: '/parent/onboarding/not-active', type: 'Flow' },
    ],
  },
  {
    title: 'Teacher Classroom View',
    audience: 'Teachers',
    summary: 'Classroom awareness for attendance, health considerations, clinic referrals, release notices, weather restrictions, and exemptions.',
    accent: 'bg-[#0891B2]',
    icon: Users,
    routes: [
      { label: 'Teacher home', path: '/teacher/home', type: 'Primary' },
      { label: 'Attendance', path: '/teacher/attendance', type: 'Primary' },
      { label: 'Health considerations', path: '/teacher/health-considerations', type: 'Primary' },
      { label: 'Clinic referral', path: '/teacher/clinic-referral', type: 'Flow' },
      { label: 'Student release notification', path: '/teacher/student-release', type: 'Flow' },
      { label: 'Weather restriction', path: '/teacher/weather-restriction', type: 'Flow' },
      { label: 'Activity exemptions', path: '/teacher/activity-exemptions', type: 'Primary' },
      { label: 'Notification history', path: '/teacher/notifications', type: 'Utility' },
      { label: 'Teacher settings', path: '/teacher/settings', type: 'Utility' },
    ],
  },
  {
    title: 'Cafeteria Alerts',
    audience: 'Cafeteria staff',
    summary: 'Allergen and cafeteria safety workflow with active alerts, detail review, real-time alerting, delivery history, and empty states.',
    accent: 'bg-[#EA580C]',
    icon: ChefHat,
    routes: [
      { label: 'Alert dashboard', path: '/cafeteria/alerts', type: 'Primary' },
      { label: 'Allergen detail', path: '/cafeteria/detail/:id', samplePath: '/cafeteria/detail/demo-alert', type: 'Flow' },
      { label: 'Realtime alert', path: '/cafeteria/realtime-alert', type: 'Flow' },
      { label: 'Delivery history', path: '/cafeteria/history', type: 'Primary' },
      { label: 'Empty state', path: '/cafeteria/empty', type: 'Utility' },
      { label: 'Cafeteria settings', path: '/cafeteria/settings', type: 'Utility' },
    ],
  },
  {
    title: 'Security Pickup Flow',
    audience: 'Security guards',
    summary: 'Pickup queue, QR scanning, manual verification, authorization confirmation, history, and guard settings.',
    accent: 'bg-[#475569]',
    icon: ShieldCheck,
    routes: [
      { label: 'Pickup queue', path: '/security/pickups', type: 'Primary' },
      { label: 'QR scanner', path: '/security/scanner', type: 'Flow' },
      { label: 'Manual verification', path: '/security/manual-verification', type: 'Flow' },
      { label: 'Authorized confirmation', path: '/security/authorized-confirmation', type: 'Flow' },
      { label: 'Pickup history', path: '/security/history', type: 'Primary' },
      { label: 'Security settings', path: '/security/settings', type: 'Utility' },
    ],
  },
  {
    title: 'Bus Driver Operations',
    audience: 'Bus drivers',
    summary: 'Route overview, boarding, deboarding, early dismissal handoffs, route history, and driver settings.',
    accent: 'bg-[#CA8A04]',
    icon: Bus,
    routes: [
      { label: 'Route overview', path: '/bus/route', type: 'Primary' },
      { label: 'Student boarding', path: '/bus/boarding/:id', samplePath: '/bus/boarding/demo-student', type: 'Flow' },
      { label: 'Student deboarding', path: '/bus/deboarding/:id', samplePath: '/bus/deboarding/demo-student', type: 'Flow' },
      { label: 'Early dismissal', path: '/bus/early-dismissal', type: 'Flow' },
      { label: 'Route history', path: '/bus/history', type: 'Primary' },
      { label: 'Bus settings', path: '/bus/settings', type: 'Utility' },
    ],
  },
  {
    title: 'Counselor Support',
    audience: 'Student counselor',
    summary: 'Student support dashboard, tagging, tag history, report generation, previews, student list, report list, and settings.',
    accent: 'bg-[#059669]',
    icon: ClipboardCheck,
    routes: [
      { label: 'Counselor home', path: '/counselor/home', type: 'Primary' },
      { label: 'Students list', path: '/counselor/students', type: 'Primary' },
      { label: 'Reports list', path: '/counselor/reports', type: 'Primary' },
      { label: 'Counselor settings', path: '/counselor/settings', type: 'Utility' },
      { label: 'Tag entry (Ramadan fatigue)', path: '/counselor/tag-entry', type: 'Flow' },
      { label: 'Student tag history', path: '/counselor/student-tags/:id', samplePath: '/counselor/student-tags/demo-student', type: 'Flow' },
      { label: 'Generate report', path: '/counselor/generate-report', type: 'Flow' },
      { label: 'Report preview', path: '/counselor/report-preview', type: 'Flow' },
    ],
  },
  {
    title: 'Secretary Desk',
    audience: 'School secretary',
    summary: 'Student records, bulk import, messaging, chatbot queue triage, composition, and secretary settings.',
    accent: 'bg-[#2563EB]',
    icon: MessageSquare,
    routes: [
      { label: 'Secretary home (HASANA Sync)', path: '/secretary/home', type: 'Primary' },
      { label: 'Student list', path: '/secretary/students', type: 'Primary' },
      { label: 'Messages inbox', path: '/secretary/messages', type: 'Primary' },
      { label: 'Chatbot queue', path: '/secretary/chatbot', type: 'Primary' },
      { label: 'Secretary settings', path: '/secretary/settings', type: 'Utility' },
      { label: 'Import students (UAE Emirates ID)', path: '/secretary/import-students', type: 'Flow' },
      { label: 'Compose message', path: '/secretary/compose-message', type: 'Flow' },
    ],
  },
  {
    title: 'Vice Principal Oversight',
    audience: 'Vice principal',
    summary: 'Readiness and operations view for analytics, clinic readiness, equipment checks, permissions, messages, and settings.',
    accent: 'bg-[#4F46E5]',
    icon: UserCog,
    routes: [
      { label: 'Vice principal home', path: '/vice-principal/home', type: 'Primary' },
      { label: 'Analytics', path: '/vice-principal/analytics', type: 'Primary' },
      { label: 'Clinic readiness', path: '/vice-principal/clinic-readiness', type: 'Primary' },
      { label: 'Messages', path: '/vice-principal/messages', type: 'Primary' },
      { label: 'Settings', path: '/vice-principal/settings', type: 'Utility' },
      { label: 'Permissions', path: '/vice-principal/permissions', type: 'Utility' },
      { label: 'Equipment checklist', path: '/vice-principal/equipment-checklist', type: 'Flow' },
    ],
  },
  {
    title: 'System States & Simulator',
    audience: 'Product Presentation & QA',
    summary: 'High-fidelity overlays and critical warning gates, including an interactive iPhone 16 Pro simulator showcase.',
    accent: 'bg-[#6366F1]',
    icon: Smartphone,
    routes: [
      { label: 'System state simulator', path: '/system/simulator', type: 'Primary' },
      { label: 'SYS-01 — After-hours lock', path: '/system/after-hours', type: 'Flow' },
      { label: 'SYS-02 — AQI weather banner', path: '/system/weather-advisory', type: 'Flow' },
      { label: 'SYS-03 — Onboarding pending gate', path: '/system/consent-pending', type: 'Flow' },
      { label: 'SYS-04 — Session expiry timeout', path: '/system/session-expiry', type: 'Flow' },
      { label: 'SYS-05 — Ramadan Mode Screen', path: '/system/ramadan', type: 'Flow' },
    ],
  },
  {
    title: 'Legacy Parent Portal',
    audience: 'Legacy parent view',
    summary: 'Older parent route set kept in the prototype for comparison with the newer mobile app experience.',
    accent: 'bg-[#64748B]',
    icon: Home,
    routes: [
      { label: 'Legacy dashboard', path: '/parent/dashboard', type: 'Legacy' },
      { label: 'Legacy medications', path: '/parent/medications', type: 'Legacy' },
      { label: 'Legacy notifications', path: '/parent/notifications', type: 'Legacy' },
    ],
  },
];

const analysisCards = [
  {
    label: 'Route groups',
    value: routeGroups.length,
    detail: 'Role, onboarding, and utility clusters',
    icon: Map,
  },
  {
    label: 'Screens mapped',
    value: routeGroups.reduce((sum, group) => sum + group.routes.length, 0),
    detail: 'Every declared route is linked',
    icon: FileText,
  },
  {
    label: 'Primary portals',
    value: routeGroups.filter((group) => group.routes.some((route) => route.type === 'Primary')).length,
    detail: 'Operational dashboards and tabs',
    icon: Activity,
  },
  {
    label: 'High-risk flows',
    value: 6,
    detail: 'Consent, emergency, medication, pickup, bus, and permissions',
    icon: AlertTriangle,
  },
];

const prototypeHighlights = [
  {
    title: 'Strong multi-role coverage',
    body: 'The prototype covers the full school health network: leadership, nurse, parent, teacher, cafeteria, security, bus, counselor, secretary, and vice principal.',
    icon: Users,
  },
  {
    title: 'Clear operational backbone',
    body: 'Most roles have a home screen plus focused task flows, which makes the demo easy to present by role or by scenario.',
    icon: Microscope,
  },
  {
    title: 'Safety-critical flows are visible',
    body: 'Medication conflicts, emergency consent, document review, allergen alerts, pickup verification, and bus handoffs are all reachable from this map.',
    icon: ShieldCheck,
  },
  {
    title: 'Legacy parent area is separated',
    body: 'The older parent portal remains available but is clearly marked so stakeholders can compare it against the newer parent app.',
    icon: FileCheck2,
  },
];

const scenarioLinks = [
  { label: 'iPhone 16 Pro Simulator', icon: Smartphone, path: '/system/simulator' },
  { label: 'Ramadan Mode Screen', icon: Moon, path: '/system/ramadan' },
  { label: 'UAE Legal & PDPL Compliance', icon: FileCheck2, path: '/principal/legal-documents' },
  { label: 'Secretary Dashboard (HASANA)', icon: MessageSquare, path: '/secretary/home' },
  { label: 'Import Students (Emirates ID)', icon: UploadCloud, path: '/secretary/import-students' },
  { label: 'Physician Dashboard', icon: Stethoscope, path: '/physician/dashboard' },
  { label: 'Physician Protocol Review', icon: ShieldCheck, path: '/physician/medication-review/1' },
  { label: 'Medication administration', icon: Pill, path: '/nurse/daily-doses' },
  { label: 'Emergency escalation', icon: AlertTriangle, path: '/nurse/clinic/emergency-escalation' },
  { label: 'Parent document upload', icon: UploadCloud, path: '/parent/app/document-upload' },
  { label: 'Pickup QR verification', icon: QrCode, path: '/security/scanner' },
  { label: 'Cafeteria allergen alert', icon: ChefHat, path: '/cafeteria/alerts' },
  { label: 'Bus live tracking', icon: Bus, path: '/parent/app/bus-tracking' },
  { label: 'School-wide advisory', icon: Bell, path: '/principal/weather-advisory' },
  { label: 'Counselor report', icon: Signature, path: '/counselor/generate-report' },
  { label: 'Secretary chatbot queue', icon: Bot, path: '/secretary/chatbot' },
  { label: 'Permission governance', icon: Lock, path: '/principal/permission-matrix' },
  { label: 'Vice principal readiness', icon: ClipboardCheck, path: '/vice-principal/clinic-readiness' },
  { label: 'Staff setup', icon: IdCard, path: '/principal/add-staff' },
];

const typeStyles = {
  Primary: 'bg-[#DBEAFE] text-[#1D4ED8]',
  Flow: 'bg-[#CCFBF1] text-[#0F766E]',
  Utility: 'bg-[#F1F5F9] text-[#475569]',
  Legacy: 'bg-[#FEF3C7] text-[#92400E]',
};

export function SynapseNavigationMap() {
  const [query, setQuery] = useState('');

  const normalizedQuery = query.trim().toLowerCase();
  const filteredGroups = useMemo(() => {
    if (!normalizedQuery) return routeGroups;

    return routeGroups
      .map((group) => ({
        ...group,
        routes: group.routes.filter((route) => {
          const searchable = `${group.title} ${group.audience} ${group.summary} ${route.label} ${route.path}`;
          return searchable.toLowerCase().includes(normalizedQuery);
        }),
      }))
      .filter((group) => group.routes.length > 0);
  }, [normalizedQuery]);

  return (
    <main className="fixed inset-0 z-50 overflow-y-auto bg-[#F8FAFC] text-[#0F172A]">
      <section className="bg-white border-b border-[#E2E8F0]">
        <div className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8">
          <div className="flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
            <div className="max-w-3xl">
              <div className="mb-3 inline-flex items-center gap-2 rounded-full bg-[#ECFDF5] px-3 py-1 text-[13px] font-medium text-[#047857]">
                <Sparkles className="h-4 w-4" />
                Main prototype navigation
              </div>
              <h1 className="text-[34px] font-semibold leading-tight tracking-normal text-[#0F172A] sm:text-[44px]">
                Synapse Navigation Map
              </h1>
              <p className="mt-3 max-w-2xl text-[15px] leading-6 text-[#475569] sm:text-[16px]">
                A clickable, presentation-ready route map for the full school health prototype. Use it to explain the product architecture, jump into every screen, and demo the user journeys by role.
              </p>
            </div>

            <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 lg:min-w-[520px]">
              {analysisCards.map((card) => {
                const Icon = card.icon;
                return (
                  <div key={card.label} className="rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] p-3 shadow-sm">
                    <div className="mb-3 flex h-9 w-9 items-center justify-center rounded-md bg-[#EEF2FF] text-[#4F46E5]">
                      <Icon className="h-5 w-5" />
                    </div>
                    <div className="text-[24px] font-semibold leading-none text-[#0F172A]">{card.value}</div>
                    <div className="mt-1 text-[12px] font-medium text-[#334155]">{card.label}</div>
                    <div className="mt-1 text-[11px] leading-4 text-[#64748B]">{card.detail}</div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="relative">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[#64748B]" />
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search by role, flow, screen, or route"
              className="h-12 w-full rounded-lg border border-[#CBD5E1] bg-white pl-10 pr-4 text-[15px] outline-none transition focus:border-[#2563EB] focus:ring-4 focus:ring-[#DBEAFE]"
            />
          </div>
        </div>
      </section>

      <section className="mx-auto grid w-full max-w-7xl gap-4 px-4 py-5 sm:px-6 lg:grid-cols-4 lg:px-8">
        {prototypeHighlights.map((item) => {
          const Icon = item.icon;
          return (
            <article key={item.title} className="rounded-lg border border-[#E2E8F0] bg-white p-4 shadow-sm">
              <div className="mb-3 flex h-10 w-10 items-center justify-center rounded-md bg-[#F0FDFA] text-[#0F766E]">
                <Icon className="h-5 w-5" />
              </div>
              <h2 className="text-[15px] font-semibold text-[#0F172A]">{item.title}</h2>
              <p className="mt-2 text-[13px] leading-5 text-[#64748B]">{item.body}</p>
            </article>
          );
        })}
      </section>

      <section className="mx-auto w-full max-w-7xl px-4 pb-5 sm:px-6 lg:px-8">
        <div className="rounded-lg border border-[#E2E8F0] bg-white p-4 shadow-sm">
          <div className="mb-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h2 className="text-[18px] font-semibold text-[#0F172A]">Presentation Jump Points</h2>
              <p className="text-[13px] text-[#64748B]">Fast links for the prototype’s most important stakeholder scenarios.</p>
            </div>
            <div className="flex flex-wrap gap-2 text-[12px]">
              {Object.entries(typeStyles).map(([type, className]) => (
                <span key={type} className={`rounded-full px-2.5 py-1 font-medium ${className}`}>
                  {type}
                </span>
              ))}
            </div>
          </div>
          <div className="grid gap-2 sm:grid-cols-2 lg:grid-cols-4">
            {scenarioLinks.map((scenario) => {
              const Icon = scenario.icon;
              return (
                <Link
                  key={scenario.label}
                  to={scenario.path}
                  className="group flex min-h-[54px] items-center justify-between gap-3 rounded-lg border border-[#E2E8F0] bg-[#F8FAFC] px-3 py-2 transition hover:border-[#2563EB] hover:bg-[#EFF6FF] focus:outline-none focus:ring-4 focus:ring-[#DBEAFE]"
                >
                  <span className="flex min-w-0 items-center gap-3">
                    <span className="flex h-9 w-9 flex-none items-center justify-center rounded-md bg-white text-[#2563EB] shadow-sm">
                      <Icon className="h-4 w-4" />
                    </span>
                    <span className="text-[13px] font-medium text-[#0F172A]">{scenario.label}</span>
                  </span>
                  <ArrowRight className="h-4 w-4 flex-none text-[#64748B] transition group-hover:translate-x-0.5 group-hover:text-[#2563EB]" />
                </Link>
              );
            })}
          </div>
        </div>
      </section>

      <section className="mx-auto grid w-full max-w-7xl gap-4 px-4 pb-8 sm:px-6 lg:grid-cols-2 lg:px-8 xl:grid-cols-3">
        {filteredGroups.map((group) => {
          const Icon = group.icon;
          return (
            <article key={group.title} className="overflow-hidden rounded-lg border border-[#E2E8F0] bg-white shadow-sm">
              <div className="border-b border-[#E2E8F0] p-4">
                <div className="flex items-start gap-3">
                  <div className={`flex h-11 w-11 flex-none items-center justify-center rounded-lg text-white ${group.accent}`}>
                    <Icon className="h-5 w-5" />
                  </div>
                  <div className="min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <h2 className="text-[17px] font-semibold text-[#0F172A]">{group.title}</h2>
                      <span className="rounded-full bg-[#F1F5F9] px-2 py-0.5 text-[11px] font-medium text-[#475569]">
                        {group.routes.length} screens
                      </span>
                    </div>
                    <p className="mt-1 text-[12px] font-medium uppercase tracking-normal text-[#64748B]">{group.audience}</p>
                    <p className="mt-2 text-[13px] leading-5 text-[#64748B]">{group.summary}</p>
                  </div>
                </div>
              </div>

              <div className="divide-y divide-[#E2E8F0]">
                {group.routes.map((route) => (
                  <Link
                    key={route.path}
                    to={route.samplePath ?? route.path}
                    className="group flex items-center justify-between gap-3 px-4 py-3 transition hover:bg-[#F8FAFC] focus:outline-none focus:ring-4 focus:ring-inset focus:ring-[#DBEAFE]"
                  >
                    <span className="min-w-0">
                      <span className="flex flex-wrap items-center gap-2">
                        <span className="text-[14px] font-medium text-[#0F172A]">{route.label}</span>
                        <span className={`rounded-full px-2 py-0.5 text-[11px] font-medium ${typeStyles[route.type ?? 'Primary']}`}>
                          {route.type ?? 'Primary'}
                        </span>
                      </span>
                      <span className="mt-1 block break-all text-[12px] text-[#64748B]">{route.path}</span>
                    </span>
                    <ArrowRight className="h-4 w-4 flex-none text-[#94A3B8] transition group-hover:translate-x-0.5 group-hover:text-[#2563EB]" />
                  </Link>
                ))}
              </div>
            </article>
          );
        })}
      </section>
    </main>
  );
}
