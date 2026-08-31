import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/localization/l10n_ext.dart';
import '../../core/localization/locale_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';

typedef _NavLink = ({String labelEn, String labelAr, String route});
typedef _NavSection = ({String titleEn, String titleAr, List<_NavLink> links});

class NavigationMapScreen extends StatefulWidget {
  const NavigationMapScreen({super.key});

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<_NavSection> _sections = [
    (
      titleEn: 'Authentication & Entry',
      titleAr: 'التوثيق والدخول',
      links: [
        (labelEn: 'Splash Screen', labelAr: 'الشاشة الافتتاحية', route: '/splash'),
        (labelEn: 'Login', labelAr: 'تسجيل الدخول', route: '/login'),
        (labelEn: '2FA Verify', labelAr: 'التحقق بخطوتين', route: '/verify'),
        (labelEn: 'Biometric Verification', labelAr: 'بصمة الوجه', route: '/biometric'),
        (labelEn: 'Confidentiality Agreement', labelAr: 'اتفاقية السرية', route: '/agreement'),
        (labelEn: 'E-Signature', labelAr: 'التوقيع الإلكتروني', route: '/signature'),
      ],
    ),
    (
      titleEn: 'Principal & Leadership',
      titleAr: 'مدير المدرسة والقيادة',
      links: [
        (labelEn: 'Principal Dashboard', labelAr: 'لوحة تحكم المدير الرئيسي', route: '/principal/home'),
        (labelEn: 'Staff Management', labelAr: 'إدارة الكادر المدرسي', route: '/principal/staff'),
        (labelEn: 'Add Staff Member', labelAr: 'إضافة موظف جديد', route: '/principal/add-staff'),
        (labelEn: 'Edit Staff Member', labelAr: 'تعديل بيانات موظف', route: '/principal/edit-staff/staff-1'),
        (labelEn: 'Permission Matrix', labelAr: 'مصفوفة الصلاحيات', route: '/principal/permission-matrix'),
        (labelEn: 'Health Analytics', labelAr: 'التحليلات الصحية', route: '/principal/analytics'),
        (labelEn: 'Weather Advisory Mgmt', labelAr: 'إدارة التنبيهات الجوية', route: '/principal/weather-advisory'),
        (labelEn: 'Audit Log', labelAr: 'سجل العمليات والأنشطة', route: '/principal/audit'),
        (labelEn: 'SMS Wallet & Quota', labelAr: 'محفظة الرسائل القصيرة', route: '/principal/sms-wallet'),
        (labelEn: 'After-Hours Access', labelAr: 'صلاحيات الدخول بعد الدوام', route: '/principal/after-hours-access'),
        (labelEn: 'Annual Health Report', labelAr: 'التقرير الصحي السنوي', route: '/principal/annual-report'),
        (labelEn: 'Student Health Promotion', labelAr: 'ترقية الطلاب الصحية', route: '/principal/student-promotion'),
        (labelEn: 'School Setup Wizard', labelAr: 'إعدادات المدرسة', route: '/principal/school-setup'),
        (labelEn: 'Legal & Compliance Docs', labelAr: 'الوثائق القانونية والامتثال', route: '/principal/legal-documents'),
        (labelEn: 'Principal Settings', labelAr: 'إعدادات المدير', route: '/principal/settings'),
      ],
    ),
    (
      titleEn: 'Vice Principal Operations',
      titleAr: 'نائب المدير والعمليات',
      links: [
        (labelEn: 'Vice Principal Dashboard', labelAr: 'لوحة تحكم نائب المدير', route: '/vice-principal/home'),
        (labelEn: 'VP Health Analytics', labelAr: 'تحليلات الصحة والحضور', route: '/vice-principal/analytics'),
        (labelEn: 'Clinic Readiness Overview', labelAr: 'جاهزية العيادة المدرسية', route: '/vice-principal/clinic-readiness'),
        (labelEn: 'Messages Inbox', labelAr: 'صندوق الرسائل والمراسلات', route: '/vice-principal/messages'),
        (labelEn: 'Permissions Matrix', labelAr: 'مصفوفة الصلاحيات والإذن', route: '/vice-principal/permissions'),
        (labelEn: 'Clinic Equipment Checklist', labelAr: 'قائمة تفقد معدات العيادة', route: '/vice-principal/equipment-checklist'),
        (labelEn: 'Vice Principal Settings', labelAr: 'إعدادات نائب المدير', route: '/vice-principal/settings'),
      ],
    ),
    (
      titleEn: 'Nurse Clinical Operations',
      titleAr: 'عمليات ممرض المدرسة',
      links: [
        (labelEn: 'Nurse Dashboard', labelAr: 'لوحة تحكم الممرض', route: '/nurse/dashboard'),
        (labelEn: 'Daily Dose View', labelAr: 'جدول الجرعات اليومية', route: '/nurse/daily-doses'),
        (labelEn: 'Medications List', labelAr: 'قائمة الأدوية المعتمدة', route: '/nurse/medications'),
        (labelEn: 'Pharmacy Inventory (CRUD)', labelAr: 'مخزون الصيدلية والتدقيق', route: '/nurse/medications/inventory'),
        (labelEn: 'Add Medication (Step 1)', labelAr: 'إضافة دواء - الخطوة ١', route: '/nurse/medications/add/step1'),
        (labelEn: 'Add Medication (Step 2)', labelAr: 'إضافة دواء - الخطوة ٢', route: '/nurse/medications/add/step2'),
        (labelEn: 'Add Medication (Step 3)', labelAr: 'إضافة دواء - الخطوة ٣', route: '/nurse/medications/add/step3'),
        (labelEn: 'Dose Confirmation', labelAr: 'تأكيد تقديم الجرعة', route: '/nurse/medications/dose-confirmation'),
        (labelEn: 'Dose Conflict Alert', labelAr: 'تنبيه تعارض الجرعات', route: '/nurse/medications/dose-conflict'),
        (labelEn: 'Low Supply Alert', labelAr: 'تنبيه نقص المخزون', route: '/nurse/medications/low-supply'),
        (labelEn: 'Medication Detail View', labelAr: 'تفاصيل الدواء', route: '/nurse/medications/med-1'),
        (labelEn: 'Clinic Visits List', labelAr: 'سجل زيارات العيادة', route: '/nurse/clinic'),
        (labelEn: 'Clinic Visit Detail', labelAr: 'تفاصيل زيارة العيادة', route: '/nurse/clinic/visit/visit-1'),
        (labelEn: 'New Clinic Visit Entry', labelAr: 'تسجيل زيارة عيادة جديدة', route: '/nurse/clinic/new-visit'),
        (labelEn: 'Emergency Photo Upload', labelAr: 'رفع صورة حالة طارئة', route: '/nurse/clinic/emergency-photo'),
        (labelEn: 'Emergency Consent Request', labelAr: 'طلب موافقة طارئة', route: '/nurse/clinic/emergency-consent'),
        (labelEn: 'Emergency Escalation', labelAr: 'تصعيد حالة طوارئ', route: '/nurse/clinic/emergency-escalation'),
        (labelEn: 'Student Health Search', labelAr: 'البحث عن ملف طالب', route: '/nurse/students'),
        (labelEn: 'Student Health Profile', labelAr: 'الملف الصحي للطالب', route: '/nurse/students/stu-1'),
        (labelEn: 'Document Review Queue', labelAr: 'طابور مراجعة المستندات', route: '/nurse/documents/review'),
        (labelEn: 'Document Viewer', labelAr: 'استعراض الوثائق الطبية', route: '/nurse/documents/review/doc-1'),
        (labelEn: 'Send Cafeteria Alert', labelAr: 'إرسال تنبيه للمقصف', route: '/nurse/cafeteria-alert'),
        (labelEn: 'Clinical Reports', labelAr: 'تقارير العيادة المدرسية', route: '/nurse/reports'),
        (labelEn: 'Generate Clinical Report', labelAr: 'إنشاء تقرير طبي جديد', route: '/nurse/reports/generate'),
        (labelEn: 'Clinical Report Preview', labelAr: 'معاينة التقرير الطبي', route: '/nurse/reports/preview'),
        (labelEn: 'Nurse Settings', labelAr: 'إعدادات الممرض', route: '/nurse/settings'),
        (labelEn: 'Nurse Notifications', labelAr: 'الإشعارات والتنبيهات', route: '/nurse/notifications'),
      ],
    ),
    (
      titleEn: 'School Physician Oversight',
      titleAr: 'طبيب المدرسة الإشرافي',
      links: [
        (labelEn: 'Physician Dashboard', labelAr: 'لوحة تحكم طبيب المدرسة', route: '/physician/dashboard'),
        (labelEn: 'Protocol Review List', labelAr: 'مراجعة بروتوكولات الأدوية', route: '/physician/protocols'),
        (labelEn: 'Protocol Detail Review', labelAr: 'تفاصيل بروتوكول الدواء', route: '/physician/protocols/proto-1'),
        (labelEn: 'Clinical Escalation Inbox', labelAr: 'بريد الحالات المصعدة طبياً', route: '/physician/escalations'),
        (labelEn: 'Report Co-Signature', labelAr: 'اعتماد وتوقيع التقارير', route: '/physician/co-sign/report-1'),
        (labelEn: 'Schedule Configuration', labelAr: 'إعداد الجدول والدوام', route: '/physician/schedule'),
        (labelEn: 'Physician Settings', labelAr: 'إعدادات الطبيب', route: '/physician/settings'),
      ],
    ),
    (
      titleEn: 'Parent App (Modern)',
      titleAr: 'تطبيق ولي الأمر الحديث',
      links: [
        (labelEn: 'Parent App Home', labelAr: 'الرئيسية لولي الأمر', route: '/parent/app/home'),
        (labelEn: 'Clinic & Health History', labelAr: 'السجل الصحي والزيارات', route: '/parent/app/health'),
        (labelEn: 'Medication Log', labelAr: 'سجل الأدوية والجرعات', route: '/parent/app/medications'),
        (labelEn: 'Health Documents', labelAr: 'المستندات والشهادات الصحية', route: '/parent/app/docs'),
        (labelEn: 'Chat & Messages', labelAr: 'المحادثات والتواصل', route: '/parent/app/chat'),
        (labelEn: 'Emergency Consent Response', labelAr: 'الرد على موافقة الطوارئ', route: '/parent/app/emergency-consent'),
        (labelEn: 'Report Home Dose', labelAr: 'الإبلاغ عن جرعة منزلية', route: '/parent/app/report-home-dose'),
        (labelEn: 'Suspend School Dose', labelAr: 'إيقاف جرعة في المدرسة', route: '/parent/app/suspend-school-dose'),
        (labelEn: 'Authorized Persons Manager', labelAr: 'إدارة الأشخاص المخولين', route: '/parent/app/authorized-persons'),
        (labelEn: 'Add Authorized Person', labelAr: 'إضافة شخص مخول بالاستلام', route: '/parent/app/add-authorized-person'),
        (labelEn: 'Notification Settings', labelAr: 'إعدادات الإشعارات', route: '/parent/app/notifications'),
        (labelEn: 'AI Chatbot Assistant', labelAr: 'المساعد الذكي لولي الأمر', route: '/parent/app/chatbot-assistant'),
        (labelEn: 'Document Upload', labelAr: 'رفع المستندات والوثائق', route: '/parent/app/document-upload'),
        (labelEn: 'Full QR Code View', labelAr: 'رمز QR للاستلام', route: '/parent/app/full-qrcode/person-1'),
        (labelEn: 'Document Expiry Alert', labelAr: 'تنبيه انتهاء صلاحية وثيقة', route: '/parent/app/document-expiry-alert'),
        (labelEn: 'Bus Live Tracking', labelAr: 'التتبع المباشر للحافلة', route: '/parent/app/bus-tracking'),
        (labelEn: 'Parent Profile Settings', labelAr: 'إعدادات حساب ولي الأمر', route: '/parent/app/profile-settings'),
      ],
    ),
    (
      titleEn: 'Parent Onboarding Flow',
      titleAr: 'مسار إعداد حساب ولي الأمر',
      links: [
        (labelEn: 'School Code Entry', labelAr: 'إدخال رمز المدرسة', route: '/parent/onboarding/code'),
        (labelEn: 'Child Confirmation', labelAr: 'تأكيد بيانات الابن/الابنة', route: '/parent/onboarding/confirm-child'),
        (labelEn: 'Emergency Consent Grant', labelAr: 'منح موافقة الطوارئ', route: '/parent/onboarding/emergency-consent'),
        (labelEn: 'Privacy & Consent Agreement', labelAr: 'اتفاقية الخصوصية والبيانات', route: '/parent/onboarding/privacy-agreement'),
        (labelEn: 'Onboarding Document Upload', labelAr: 'رفع الوثائق المطلوبة', route: '/parent/onboarding/documents'),
        (labelEn: 'Authorized Pickups Setup', labelAr: 'تسجيل المفوضين بالاستلام', route: '/parent/onboarding/authorized-pickups'),
        (labelEn: 'Setup Complete', labelAr: 'اكتمل إعداد الحساب', route: '/parent/onboarding/complete'),
        (labelEn: 'Account Pending Activation', labelAr: 'الحساب قيد التفعيل', route: '/parent/onboarding/not-active'),
      ],
    ),
    (
      titleEn: 'Parent Portal (Legacy)',
      titleAr: 'بوابة ولي الأمر (القديمة)',
      links: [
        (labelEn: 'Legacy Parent Dashboard', labelAr: 'لوحة التحكم القديمة', route: '/parent/dashboard'),
        (labelEn: 'Legacy Medication Tracker', labelAr: 'متابع الأدوية القديم', route: '/parent/medications'),
        (labelEn: 'Legacy Notifications', labelAr: 'الإشعارات القديمة', route: '/parent/notifications'),
      ],
    ),
    (
      titleEn: 'Teacher Classroom Desk',
      titleAr: 'واجهة المعلم للفصل',
      links: [
        (labelEn: 'Teacher Portal', labelAr: 'بوابة المعلم الرئيسية', route: '/teacher/home'),
        (labelEn: 'Class Attendance Log', labelAr: 'سجل حضور وغياب الفصل', route: '/teacher/attendance'),
        (labelEn: 'Report Bias / Racism Incident', labelAr: 'الإبلاغ عن حادث تمييز/عنصرية', route: '/teacher/report-bias'),
        (labelEn: 'Student Health Considerations', labelAr: 'الحالات الصحية للطلاب', route: '/teacher/health-considerations'),
        (labelEn: 'Send Student to Clinic', labelAr: 'إحالة طالب إلى العيادة', route: '/teacher/clinic-referral'),
        (labelEn: 'Student Release Notice', labelAr: 'إشعار مغادرة طالب', route: '/teacher/student-release'),
        (labelEn: 'Weather Restrictions', labelAr: 'قيود الطقس والأنشطة الخارجية', route: '/teacher/weather-restriction'),
        (labelEn: 'Activity Exemptions', labelAr: 'الإعفاءات من الرياضة', route: '/teacher/activity-exemptions'),
        (labelEn: 'Teacher Notifications', labelAr: 'سجل إشعارات المعلم', route: '/teacher/notifications'),
        (labelEn: 'Teacher Settings', labelAr: 'إعدادات المعلم', route: '/teacher/settings'),
      ],
    ),
    (
      titleEn: 'Secretary Desk & Admissions',
      titleAr: 'مكتب السكرتارية والتسجيل',
      links: [
        (labelEn: 'Secretary Portal', labelAr: 'بوابة السكرتارية', route: '/secretary/home'),
        (labelEn: 'Student Directory', labelAr: 'دليل وحضور الطلاب', route: '/secretary/students'),
        (labelEn: 'Student Detail View', labelAr: 'تفاصيل ملف الطالب', route: '/secretary/student/stu-1'),
        (labelEn: 'Messages Inbox', labelAr: 'صندوق الرسائل والمراسلات', route: '/secretary/messages'),
        (labelEn: 'Message Detail View', labelAr: 'تفاصيل الرسالة', route: '/secretary/message/msg-1'),
        (labelEn: 'Chatbot Queue', labelAr: 'طابور استفسارات الذكاء الاصطناعي', route: '/secretary/chatbot'),
        (labelEn: 'Chatbot Escalation Thread', labelAr: 'محادثة استفسار مصعد', route: '/secretary/chatbot-thread/thread-1'),
        (labelEn: 'Import Students CSV', labelAr: 'استيراد قائمة الطلاب', route: '/secretary/import-students'),
        (labelEn: 'Compose Message', labelAr: 'كتابة وإرسال تعميم', route: '/secretary/compose-message'),
        (labelEn: 'Secretary Notifications', labelAr: 'إشعارات السكرتارية', route: '/secretary/notifications'),
        (labelEn: 'Secretary Settings', labelAr: 'إعدادات السكرتارية', route: '/secretary/settings'),
      ],
    ),
    (
      titleEn: 'Student Counselor',
      titleAr: 'الموجه الطلابي والأخصائي',
      links: [
        (labelEn: 'Counselor Dashboard', labelAr: 'لوحة تحكم الموجه الطلابي', route: '/counselor/home'),
        (labelEn: 'Anti-Bias Incident Hub', labelAr: 'مركز متابعة بلاغات التمييز والعنصرية', route: '/counselor/bias-incidents'),
        (labelEn: 'Bias Incident Case Detail', labelAr: 'تفاصيل تحقيق قضية التمييز', route: '/counselor/bias-incidents/101'),
        (labelEn: 'Counselor Student List', labelAr: 'قائمة الطلاب والمتابعة', route: '/counselor/students'),
        (labelEn: 'Student Tag History', labelAr: 'سجل شارات وسلوك الطالب', route: '/counselor/student-tags/stu-1'),
        (labelEn: 'Wellbeing Tag Entry', labelAr: 'تسجيل ملاحظة/شارة جديدة', route: '/counselor/tag-entry'),
        (labelEn: 'Counseling Reports List', labelAr: 'قائمة التقارير السلوكية', route: '/counselor/reports'),
        (labelEn: 'Generate Counseling Report', labelAr: 'إنشاء تقرير إرشادي', route: '/counselor/generate-report'),
        (labelEn: 'Counselor Report Preview', labelAr: 'معاينة التقرير الإرشادي', route: '/counselor/report-preview'),
        (labelEn: 'Counselor Settings', labelAr: 'إعدادات الموجه الطلابي', route: '/counselor/settings'),
      ],
    ),
    (
      titleEn: 'Cafeteria & Allergen Specialist',
      titleAr: 'أخصائي المقصف والحساسية',
      links: [
        (labelEn: 'Allergen Alert Dashboard', labelAr: 'لوحة تنبيهات الحساسية والحلال', route: '/cafeteria/alerts'),
        (labelEn: 'Allergen Incident Detail', labelAr: 'تفاصيل تنبيه الحساسية', route: '/cafeteria/detail/1'),
        (labelEn: 'Realtime Emergency Alert', labelAr: 'تنبيه طوارئ فوري بالمقصف', route: '/cafeteria/realtime-alert'),
        (labelEn: 'Daily Delivery Log', labelAr: 'سجل التوريد والوجبات اليومية', route: '/cafeteria/history'),
        (labelEn: 'No Active Alerts View', labelAr: 'حالة لا توجد تنبيهات نشطة', route: '/cafeteria/empty'),
        (labelEn: 'Cafeteria Settings', labelAr: 'إعدادات المقصف المدرسي', route: '/cafeteria/settings'),
      ],
    ),
    (
      titleEn: 'Security & Campus Pickup',
      titleAr: 'الحراسات والأمن المدرسي',
      links: [
        (labelEn: 'Pickup Queue (Dashboard)', labelAr: 'طابور استلام الطلاب', route: '/security/pickups'),
        (labelEn: 'QR Code Scanner', labelAr: 'ماسح رمز الاستلام QR', route: '/security/scanner'),
        (labelEn: 'Manual Verification', labelAr: 'التحقق اليدوي من هوية المستلم', route: '/security/manual-verification'),
        (labelEn: 'Authorized Confirmation', labelAr: 'تأكيد التسليم للشخص المخول', route: '/security/authorized-confirmation'),
        (labelEn: 'Pickup History Log', labelAr: 'سجل عمليات الاستلام والتسليم', route: '/security/history'),
        (labelEn: 'Security Settings', labelAr: 'إعدادات الأمن والحراسة', route: '/security/settings'),
      ],
    ),
    (
      titleEn: 'Bus Driver Operations',
      titleAr: 'سائق الحافلة المدرسية',
      links: [
        (labelEn: 'Bus Route Overview', labelAr: 'خريطة ومسار الحافلة', route: '/bus/route'),
        (labelEn: 'Report Transit Bias Incident', labelAr: 'الإبلاغ عن حادث تمييز في الحافلة', route: '/bus/report-bias'),
        (labelEn: 'Student Boarding Screen', labelAr: 'تسجيل صعود الطلاب للحافلة', route: '/bus/boarding/stu-1'),
        (labelEn: 'Student Deboarding Screen', labelAr: 'تسجيل نزول الطلاب من الحافلة', route: '/bus/deboarding/stu-1'),
        (labelEn: 'Early Dismissal Alerts', labelAr: 'تنبيهات المغادرة المبكرة', route: '/bus/early-dismissal'),
        (labelEn: 'Bus Route History Log', labelAr: 'سجل الرحلات والمسارات السابقة', route: '/bus/history'),
        (labelEn: 'Bus Driver Settings', labelAr: 'إعدادات سائق الحافلة', route: '/bus/settings'),
      ],
    ),
    (
      titleEn: 'System Administration & Maintenance',
      titleAr: 'إدارة وتحديثات النظام',
      links: [
        (labelEn: 'System Maintenance & Status', labelAr: 'صيانة النظام والحالة الحالية', route: '/system/maintenance'),
        (labelEn: 'Mobile App Update Required', labelAr: 'تنبيه تحديث التطبيق الإجباري', route: '/system/update'),
        (labelEn: 'Role Switcher & Debug Sandbox', labelAr: 'مبدل الأدوار وتجربة الأنظمة', route: '/dev/map'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRTL;
    final query = _searchQuery.trim().toLowerCase();

    var totalRoutes = 0;
    for (final s in _sections) {
      totalRoutes += s.links.length;
    }

    final filteredSections = <_NavSection>[];

    for (final section in _sections) {
      final matchingLinks = section.links.where((l) {
        if (query.isEmpty) return true;
        return l.labelEn.toLowerCase().contains(query) ||
            l.labelAr.toLowerCase().contains(query) ||
            l.route.toLowerCase().contains(query);
      }).toList();

      final sectionTitleMatch = query.isNotEmpty &&
          (section.titleEn.toLowerCase().contains(query) || section.titleAr.toLowerCase().contains(query));

      if (matchingLinks.isNotEmpty || sectionTitleMatch) {
        filteredSections.add((
          titleEn: section.titleEn,
          titleAr: section.titleAr,
          links: sectionTitleMatch ? section.links : matchingLinks,
        ));
      }
    }

    return SchooKeepScaffold(
      scrollable: false,
      appBar: SchooKeepAppBar(
        title: context.tr(
          en: 'SchooKeep — Map ($totalRoutes)',
          ar: 'خريطة الشاشات ($totalRoutes)',
        ),
        actions: [
          InkWell(
            onTap: () => context.read<LocaleCubit>().toggleLanguage(),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Text(
                isAr ? 'English' : 'العربية',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: isAr ? 'ابحث عن شاشة أو مسار...' : 'Search screen or route path...',
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: SchooKeepColors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: SchooKeepColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: SchooKeepColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: SchooKeepColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // List of sections and screens
          Expanded(
            child: filteredSections.isEmpty
                ? Center(
                    child: Text(
                      isAr ? 'لا توجد نتائج مطابقة لـ "$_searchQuery"' : 'No screens match "$_searchQuery"',
                      style: const TextStyle(color: SchooKeepColors.textSecondary, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredSections.length,
                    itemBuilder: (context, sectionIdx) {
                      final section = filteredSections[sectionIdx];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: SchooKeepColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isAr ? section.titleAr : section.titleEn,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: SchooKeepColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${section.links.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: SchooKeepColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SchooKeepColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                for (var i = 0; i < section.links.length; i++) ...[
                                  if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  _routeTile(context, section.links[i], isAr),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _routeTile(BuildContext context, _NavLink link, bool isAr) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(link.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? link.labelAr : link.labelEn,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      link.route,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: SchooKeepColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 18, color: SchooKeepColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
