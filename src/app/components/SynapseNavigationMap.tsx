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
import { useLanguage } from '../../context/LanguageContext';

type RouteItem = {
  label: string;
  labelAr?: string;
  path: string;
  samplePath?: string;
  type?: 'Primary' | 'Flow' | 'Utility' | 'Legacy';
};

type RouteGroup = {
  title: string;
  titleAr: string;
  audience: string;
  audienceAr: string;
  summary: string;
  summaryAr: string;
  accent: string;
  icon: typeof HeartPulse;
  routes: RouteItem[];
};

const routeGroups: RouteGroup[] = [
  {
    title: 'Entry & Trust',
    titleAr: 'الدخول والتحقق والأمان',
    audience: 'All users',
    audienceAr: 'جميع المستخدمين',
    summary: 'Authentication, verification, confidentiality, and signing screens that establish access and consent.',
    summaryAr: 'شاشات تسجيل الدخول والتحقق والتوقيع الإلكتروني وتأكيد السرية.',
    accent: 'bg-[#0F766E]',
    icon: KeyRound,
    routes: [
      { label: 'Splash', labelAr: 'الشاشة الافتتاحية', path: '/splash', type: 'Flow' },
      { label: 'Login', labelAr: 'تسجيل الدخول', path: '/login', type: 'Flow' },
      { label: 'Two-factor verification', labelAr: 'التحقق بخطوتين', path: '/verify', type: 'Flow' },
      { label: 'Biometric prompt', labelAr: 'التعرف على الوجه (Biometric)', path: '/biometric', type: 'Flow' },
      { label: 'Confidentiality agreement', labelAr: 'اتفاقية السرية', path: '/agreement', type: 'Flow' },
      { label: 'E-signature', labelAr: 'التوقيع الإلكتروني', path: '/signature', type: 'Flow' },
    ],
  },
  {
    title: 'Principal Command Center',
    titleAr: 'مركز قيادة مدير المدرسة',
    audience: 'School leadership',
    audienceAr: 'إدارة المدرسة والقيادة',
    summary: 'Oversight for school health operations, staff access, reporting, weather advisories, and legal readiness.',
    summaryAr: 'متابعة العمليات الصحية، صلاحيات الموظفين، التنبيهات الجوية، والتقارير التنفيذية.',
    accent: 'bg-[#1D4ED8]',
    icon: BarChart3,
    routes: [
      { label: 'Principal home', labelAr: 'الرئيسية للمدير', path: '/principal/home', type: 'Primary' },
      { label: 'Staff management', labelAr: 'إدارة الكادر المدرسي', path: '/principal/staff', type: 'Primary' },
      { label: 'Health analytics & Ramadan trends', labelAr: 'التحليلات الصحية واتجاهات رمضان', path: '/principal/analytics', type: 'Primary' },
      { label: 'Settings placeholder', labelAr: 'الإعدادات', path: '/principal/settings', type: 'Utility' },
      { label: 'Audit log', labelAr: 'سجل التدقيق والسجلات', path: '/principal/audit', type: 'Primary' },
      { label: 'Add staff (UAE Licenses)', labelAr: 'إضافة موظف (تراخيص الإمارات)', path: '/principal/add-staff', type: 'Flow' },
      { label: 'Edit staff', labelAr: 'تعديل بيانات موظف', path: '/principal/edit-staff/:staffId', samplePath: '/principal/edit-staff/demo-staff', type: 'Flow' },
      { label: 'Permission matrix', labelAr: 'مصفوفة الصلاحيات', path: '/principal/permission-matrix', type: 'Utility' },
      { label: 'Weather advisory (Haboob & NCM)', labelAr: 'تنبيه الأحوال الجوية (المركز الوطني)', path: '/principal/weather-advisory', type: 'Flow' },
      { label: 'SMS wallet', labelAr: 'محفظة الرسائل النصية', path: '/principal/sms-wallet', type: 'Utility' },
      { label: 'After-hours access', labelAr: 'دخول خارج أوقات الدوام', path: '/principal/after-hours-access', type: 'Utility' },
      { label: 'Annual report', labelAr: 'التقرير السنوي', path: '/principal/annual-report', type: 'Flow' },
      { label: 'Student promotion', labelAr: 'ترقية سجلات الطلاب', path: '/principal/student-promotion', type: 'Flow' },
      { label: 'School setup', labelAr: 'إعدادات المدرسة', path: '/principal/school-setup', type: 'Flow' },
      { label: 'Legal & UAE PDPL Compliance', labelAr: 'الامتثال لقانون حماية البيانات الإماراتي', path: '/principal/legal-documents', type: 'Utility' },
    ],
  },
  {
    title: 'School Physician Portal',
    titleAr: 'بوابة طبيب المدرسة',
    audience: 'School physician',
    audienceAr: 'طبيب المدرسة',
    summary: 'Clinical protocols review, escalations management, reports co-signature, and weekly schedule configuration.',
    summaryAr: 'اعتماد البروتوكولات الطبية، إدارة الحالات المرفوعة، والمصادقة على التقارير.',
    accent: 'bg-[#0D9488]',
    icon: Stethoscope,
    routes: [
      { label: 'Physician dashboard', labelAr: 'لوحة التحكم للطبيب', path: '/physician/dashboard', type: 'Primary' },
      { label: 'Protocol review', labelAr: 'مراجعة البروتوكول الطبي', path: '/physician/protocols/:id', samplePath: '/physician/protocols/1', type: 'Flow' },
      { label: 'Escalations inbox', labelAr: 'صندوق الحالات الطارئة المرفوعة', path: '/physician/escalations', type: 'Primary' },
      { label: 'Report co-signature', labelAr: 'التوقيع المشترك على التقارير', path: '/physician/co-sign/:id', samplePath: '/physician/co-sign/1', type: 'Flow' },
      { label: 'Schedule configuration', labelAr: 'جدول التواجد والزيارات', path: '/physician/schedule', type: 'Primary' },
      { label: 'Physician settings', labelAr: 'إعدادات الطبيب', path: '/physician/settings', type: 'Utility' },
    ],
  },
  {
    title: 'Nurse Clinical Operations',
    titleAr: 'عمليات ممرض المدرسة',
    audience: 'School nurse',
    audienceAr: 'ممرض/ممرضة المدرسة',
    summary: 'Daily medication work, clinic visits, emergency escalation, student health profiles, documents, and nurse reports.',
    summaryAr: 'إعطاء الأدوية اليومية، زيارات العيادة، إدارة المخزون، والتعامل مع الطوارئ.',
    accent: 'bg-[#DC2626]',
    icon: Stethoscope,
    routes: [
      { label: 'Nurse dashboard', labelAr: 'لوحة التحكم للممرض', path: '/nurse/dashboard', type: 'Primary' },
      { label: 'Daily doses', labelAr: 'جرعات اليوم', path: '/nurse/daily-doses', type: 'Primary' },
      { label: 'Medication list', labelAr: 'قائمة الأدوية', path: '/nurse/medications', type: 'Primary' },
      { label: 'Pharmacy Inventory', labelAr: 'مخزون الصيدلية (CRUD)', path: '/nurse/medications/inventory', type: 'Primary' },
      { label: 'Clinic visits', labelAr: 'زيارات العيادة', path: '/nurse/clinic', type: 'Primary' },
      { label: 'New clinic visit', labelAr: 'تسجيل زيارة عيادة جديدة', path: '/nurse/clinic/new-visit', type: 'Flow' },
      { label: 'Emergency escalation', labelAr: 'تصعيد طارئ', path: '/nurse/clinic/emergency-escalation', type: 'Flow' },
      { label: 'Student health profile', labelAr: 'الملف الصحي للطالب', path: '/nurse/students/:id', samplePath: '/nurse/students/demo-student', type: 'Flow' },
    ],
  },
  {
    title: 'Parent Mobile App',
    titleAr: 'تطبيق ولي الأمر للموبايل',
    audience: 'Parents and guardians',
    audienceAr: 'أولياء الأمور والأوصياء',
    summary: 'A mobile-first experience for health history, medication logs, documents, chatbot help, pickups, QR codes, and bus tracking.',
    summaryAr: 'متابعة التاريخ الصحي، الأدوية، التتبع المباشر للحافلة، ورموز الاستلام QR.',
    accent: 'bg-[#7C3AED]',
    icon: Baby,
    routes: [
      { label: 'Parent app home', labelAr: 'الرئيسية لولي الأمر', path: '/parent/app/home', type: 'Primary' },
      { label: 'Health history', labelAr: 'السجل الصحي', path: '/parent/app/health', type: 'Primary' },
      { label: 'Medication log', labelAr: 'سجل الأدوية', path: '/parent/app/medications', type: 'Primary' },
      { label: 'Documents tab', labelAr: 'الوثائق والمستندات', path: '/parent/app/docs', type: 'Primary' },
      { label: 'Chat tab', labelAr: 'المحادثات والدعم', path: '/parent/app/chat', type: 'Primary' },
      { label: 'Bus live tracking', labelAr: 'تتبع الحافلة المباشر', path: '/parent/app/bus-tracking', type: 'Flow' },
    ],
  },
  {
    title: 'Teacher Classroom View',
    titleAr: 'واجهة المعلم للفصل',
    audience: 'Teachers',
    audienceAr: 'المعلمون والكادر التعليمي',
    summary: 'Classroom awareness for attendance, health considerations, clinic referrals, release notices, weather restrictions, and exemptions.',
    summaryAr: 'متابعة حضور الطلاب، الحالات الصحية في الفصل، والإحالة إلى العيادة.',
    accent: 'bg-[#0891B2]',
    icon: Users,
    routes: [
      { label: 'Teacher home', labelAr: 'الرئيسية للمعلم', path: '/teacher/home', type: 'Primary' },
      { label: 'Attendance', labelAr: 'سجل الحضور والغياب', path: '/teacher/attendance', type: 'Primary' },
      { label: 'Health considerations', labelAr: 'الحالات الصحية الخاصة', path: '/teacher/health-considerations', type: 'Primary' },
      { label: 'Clinic referral', labelAr: 'إحالة إلى العيادة', path: '/teacher/clinic-referral', type: 'Flow' },
    ],
  },
  {
    title: 'Secretary Desk',
    titleAr: 'مكتب السكرتير والسجلات',
    audience: 'School secretary',
    audienceAr: 'السكرتارية والاستقبال',
    summary: 'Student records, bulk import, messaging, chatbot queue triage, composition, and secretary settings.',
    summaryAr: 'سجلات الطلاب، الاستيراد الجماعي للبطاقات، مراسلة أولياء الأمور، ومزامنة حتمية.',
    accent: 'bg-[#2563EB]',
    icon: MessageSquare,
    routes: [
      { label: 'Secretary home (HASANA Sync)', labelAr: 'الرئيسية ومزامنة حصانة', path: '/secretary/home', type: 'Primary' },
      { label: 'Student list', labelAr: 'قائمة الطلاب', path: '/secretary/students', type: 'Primary' },
      { label: 'Messages inbox', labelAr: 'صندوق الرسائل', path: '/secretary/messages', type: 'Primary' },
      { label: 'Import students (UAE Emirates ID)', labelAr: 'استيراد الطلاب (الهوية الإماراتية)', path: '/secretary/import-students', type: 'Flow' },
      { label: 'Compose message', labelAr: 'كتابة رسالة جديدة', path: '/secretary/compose-message', type: 'Flow' },
    ],
  },
  {
    title: 'Cafeteria Alerts',
    titleAr: 'تنبيهات المقصف المدرسي',
    audience: 'Cafeteria staff',
    audienceAr: 'كادر المقصف والتغذية',
    summary: 'Allergen and cafeteria safety workflow with active alerts, detail review, real-time alerting, delivery history, and empty states.',
    summaryAr: 'متابعة الحساسية الغذائية وتنبيهات وجبات الطلاب المباشرة.',
    accent: 'bg-[#EA580C]',
    icon: ChefHat,
    routes: [
      { label: 'Alert dashboard', labelAr: 'لوحة تنبيهات المقصف', path: '/cafeteria/alerts', type: 'Primary' },
      { label: 'Delivery history', labelAr: 'سجل الوجبات والتسليم', path: '/cafeteria/history', type: 'Primary' },
    ],
  },
  {
    title: 'Security Pickup Flow',
    titleAr: 'عمليات الأمن واستلام الطلاب',
    audience: 'Security guards',
    audienceAr: 'حراس الأمن والاستقبال',
    summary: 'Pickup queue, QR scanning, manual verification, authorization confirmation, history, and guard settings.',
    summaryAr: 'قائمة انتظام الانصراف، مسح رمز QR، والتحقق من هوية المستلم.',
    accent: 'bg-[#475569]',
    icon: ShieldCheck,
    routes: [
      { label: 'Pickup queue', labelAr: 'قائمة طابور الاستلام', path: '/security/pickups', type: 'Primary' },
      { label: 'QR scanner', labelAr: 'ماسح رمز QR', path: '/security/scanner', type: 'Flow' },
      { label: 'Pickup history', labelAr: 'سجل انصراف الطلاب', path: '/security/history', type: 'Primary' },
    ],
  },
  {
    title: 'Bus Driver Operations',
    titleAr: 'عمليات سائق الحافلة',
    audience: 'Bus drivers',
    audienceAr: 'سائقو الحافلات والمشرفون',
    summary: 'Route overview, boarding, deboarding, early dismissal handoffs, route history, and driver settings.',
    summaryAr: 'خط سير الحافلة، تسجيل صعود وهبوط الطلاب، والتنبيهات المباشرة.',
    accent: 'bg-[#CA8A04]',
    icon: Bus,
    routes: [
      { label: 'Route overview', labelAr: 'نظرة عامة على المسار', path: '/bus/route', type: 'Primary' },
      { label: 'Route history', labelAr: 'سجل الرحلات', path: '/bus/history', type: 'Primary' },
    ],
  },
];

const typeStyles = {
  Primary: 'bg-[#DBEAFE] text-[#1D4ED8]',
  Flow: 'bg-[#CCFBF1] text-[#0F766E]',
  Utility: 'bg-[#F1F5F9] text-[#475569]',
  Legacy: 'bg-[#FEF3C7] text-[#92400E]',
};

export function SynapseNavigationMap() {
  const { isRTL, toggleLanguage } = useLanguage();
  const [query, setQuery] = useState('');

  const normalizedQuery = query.trim().toLowerCase();
  const filteredGroups = useMemo(() => {
    if (!normalizedQuery) return routeGroups;

    return routeGroups
      .map((group) => ({
        ...group,
        routes: group.routes.filter((route) => {
          const searchable = `${group.title} ${group.titleAr} ${group.audience} ${group.summary} ${route.label} ${route.labelAr ?? ''} ${route.path}`;
          return searchable.toLowerCase().includes(normalizedQuery);
        }),
      }))
      .filter((group) => group.routes.length > 0);
  }, [normalizedQuery]);

  return (
    <main className="fixed inset-0 z-50 overflow-y-auto bg-[#F8FAFC] text-[#0F172A]" dir={isRTL ? 'rtl' : 'ltr'}>
      <section className="bg-white border-b border-[#E2E8F0]">
        <div className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8">
          <div className="flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
            <div className="max-w-3xl">
              <div className="mb-3 flex flex-wrap items-center gap-2">
                <div className="inline-flex items-center gap-2 rounded-full bg-[#ECFDF5] px-3 py-1 text-[13px] font-medium text-[#047857]">
                  <Sparkles className="h-4 w-4" />
                  {isRTL ? 'تنقل النماذج الأساسية' : 'Main prototype navigation'}
                </div>

                <button
                  type="button"
                  onClick={toggleLanguage}
                  className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F1F5F9] border border-[#E2E8F0] hover:border-[#CBD5E1] text-[12px] font-semibold text-[#475569] transition-all cursor-pointer"
                >
                  <span>{isRTL ? 'Switch to English' : 'التحويل إلى العربية'}</span>
                </button>
              </div>
              <h1 className="text-[34px] font-semibold leading-tight tracking-normal text-[#0F172A] sm:text-[44px]">
                {isRTL ? 'خريطة التنقل في SchooKeep' : 'SchooKeep Navigation Map'}
              </h1>
              <p className="mt-3 max-w-2xl text-[15px] leading-6 text-[#475569] sm:text-[16px]">
                {isRTL
                  ? 'خريطة مسارات كاملة وجاهزة للعرض التفاعلي والشرح لجميع شاشات وأدوار النظام الصحي المدرسي.'
                  : 'A clickable, presentation-ready route map for the full school health prototype. Use it to explain the product architecture, jump into every screen, and demo the user journeys by role.'}
              </p>
            </div>
          </div>

          <div className="relative">
            <Search className={`pointer-events-none absolute top-1/2 h-4 w-4 -translate-y-1/2 text-[#64748B] ${isRTL ? 'right-3' : 'left-3'}`} />
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder={isRTL ? 'ابحث حسب الدور، الشاشة، أو المسار...' : 'Search by role, flow, screen, or route'}
              className={`h-12 w-full rounded-lg border border-[#CBD5E1] bg-white text-[15px] outline-none transition focus:border-[#2563EB] focus:ring-4 focus:ring-[#DBEAFE] ${
                isRTL ? 'pr-10 pl-4 text-right' : 'pl-10 pr-4 text-left'
              }`}
            />
          </div>
        </div>
      </section>

      <section className="mx-auto grid w-full max-w-7xl gap-4 px-4 py-8 sm:px-6 lg:grid-cols-2 lg:px-8 xl:grid-cols-3">
        {filteredGroups.map((group) => {
          const Icon = group.icon;
          return (
            <article key={group.title} className="overflow-hidden rounded-lg border border-[#E2E8F0] bg-white shadow-sm hover:border-[#2563EB]/40 transition-all">
              <div className="border-b border-[#E2E8F0] p-4">
                <div className="flex items-start gap-3">
                  <div className={`flex h-11 w-11 flex-none items-center justify-center rounded-lg text-white ${group.accent}`}>
                    <Icon className="h-5 w-5" />
                  </div>
                  <div className="min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <h2 className="text-[17px] font-semibold text-[#0F172A]">
                        {isRTL ? group.titleAr : group.title}
                      </h2>
                      <span className="rounded-full bg-[#F1F5F9] px-2 py-0.5 text-[11px] font-medium text-[#475569]">
                        {group.routes.length} {isRTL ? 'شاشات' : 'screens'}
                      </span>
                    </div>
                    <p className="mt-1 text-[12px] font-medium uppercase tracking-normal text-[#64748B]">
                      {isRTL ? group.audienceAr : group.audience}
                    </p>
                    <p className="mt-2 text-[13px] leading-5 text-[#64748B]">
                      {isRTL ? group.summaryAr : group.summary}
                    </p>
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
                        <span className="text-[14px] font-medium text-[#0F172A]">
                          {isRTL && route.labelAr ? route.labelAr : route.label}
                        </span>
                        <span className={`rounded-full px-2 py-0.5 text-[11px] font-medium ${typeStyles[route.type ?? 'Primary']}`}>
                          {route.type ?? 'Primary'}
                        </span>
                      </span>
                      <span className="mt-1 block break-all text-[12px] text-[#64748B]" dir="ltr">{route.path}</span>
                    </span>
                    <ArrowRight className={`h-4 w-4 flex-none text-[#94A3B8] transition group-hover:text-[#2563EB] ${isRTL ? 'rotate-180 group-hover:-translate-x-0.5' : 'group-hover:translate-x-0.5'}`} />
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
