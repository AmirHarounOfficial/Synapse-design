// src/app/components/PhysicianSettings.tsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronLeft, ShieldAlert, Bell, Lock, Key, FileText, LogOut, Upload, Shield } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { LicenseAuthoritySelector } from './LicenseAuthoritySelector';
import { toast } from 'sonner';

export function PhysicianSettings() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();

  // Settings State
  const [authority, setAuthority] = useState('DHA');
  const [licenseNum] = useState('MD-4029'); // Read-only in settings
  const [specialty, setSpecialty] = useState('General Pediatrics');
  const [expiryDate] = useState('24/11/2026'); // Expiry date

  const [notifications, setNotifications] = useState({
    coSignAlerts: true,
    reminders: true
  });

  const [showSignOutDialog, setShowSignOutDialog] = useState(false);
  const [showConfidentialitySheet, setShowConfidentialitySheet] = useState(false);

  const handleSignOut = () => {
    toast.success(isRTL ? "تم تسجيل الخروج بنجاح" : "Signed out successfully");
    setShowSignOutDialog(false);
    setTimeout(() => {
      navigate('/login');
    }, 1000);
  };

  const handleUpdateLicense = () => {
    toast.info(isRTL ? "جاري فتح بوابة ترخيص هيئة الصحة..." : "Opening healthcare licensing document portal...");
  };

  // Determine license status chip (expiry date is 24/11/2026, which is > 90d from June 2026)
  const licenseDaysLeft = 162; // Mock days left
  const licenseStatusColor = 'bg-[#D1FAE5] text-[#065F46] border-[#A7F3D0]';
  const licenseStatusText = isRTL ? 'ساري الصلاحية ✓' : 'Active ✓';

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[120px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* iOS status bar spacer */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200 sticky top-0 z-40">
        <button
          onClick={() => navigate('/physician/dashboard')}
          className="flex items-center justify-center w-11 h-11 -ml-2 text-gray-900"
          aria-label="Go back"
        >
          <ChevronLeft className={`w-6 h-6 ${isRTL ? 'rotate-180' : ''}`} />
        </button>

        <div className="absolute left-1/2 -translate-x-1/2 text-center">
          <h1 className="font-semibold text-[17px] text-gray-900 leading-tight">
            {isRTL ? 'إعدادات الطبيب' : 'Physician Settings'}
          </h1>
        </div>
      </header>

      {/* Main Content */}
      <div className="px-4 py-4 space-y-4">
        
        {/* Profile Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-4 text-left">
          <div className="w-16 h-16 rounded-full bg-[#0D9488]/10 flex items-center justify-center text-[#0D9488] font-bold text-2xl">
            DR
          </div>
          <div className="space-y-1">
            <h2 className="text-[17px] font-bold text-gray-900">
              {isRTL ? 'د. أمينة الهاشمي' : 'Dr. Amina Al-Hashimi'}
            </h2>
            <div className="flex flex-wrap gap-1.5">
              <span className="inline-flex px-2 py-0.5 bg-[#0D9488]/10 text-[#0D9488] text-[10px] font-bold rounded-full">
                {isRTL ? 'طبيب المدرسة المعتمد' : 'School Physician'}
              </span>
              <span className="inline-flex px-2 py-0.5 bg-slate-100 text-[#475569] text-[10px] font-semibold rounded-full">
                {specialty}
              </span>
            </div>
            <p className="text-[11px] text-[#64748B]">{isRTL ? 'مدرسة لينكولن الابتدائية' : 'Lincoln Elementary School'}</p>
          </div>
        </div>

        {/* UAE License Section */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4 text-left">
          <span className="block text-[13px] font-bold text-gray-900 uppercase tracking-wider">
            {isRTL ? 'الترخيص الطبي المهني بدولة الإمارات' : 'UAE Clinical Licensing'}
          </span>

          <div className="space-y-3">
            {/* License Authority Selector */}
            <LicenseAuthoritySelector 
              value={authority}
              onChangeValue={setAuthority}
              schoolEmirate="Dubai"
            />

            {/* License Number Input - Locked after verification */}
            <div>
              <label className="block text-xs font-semibold text-[#64748B] mb-1">{isRTL ? 'رقم الترخيص (غير قابل للتعديل)' : 'License Number (Read-only)'}</label>
              <div className="relative">
                <input 
                  type="text" 
                  value={licenseNum} 
                  disabled
                  className="w-full h-11 px-3 border border-gray-200 rounded-lg text-sm bg-slate-50 text-[#64748B] font-mono"
                />
                <Lock className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#64748B]" />
              </div>
            </div>

            {/* Expiry Date with Status Badge */}
            <div className="flex items-center justify-between pt-1">
              <div>
                <span className="block text-xs font-semibold text-[#64748B]">{isRTL ? 'تاريخ انتهاء الترخيص' : 'License Expiry Date'}</span>
                <span className="text-sm font-bold text-gray-900">{expiryDate}</span>
              </div>
              
              <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-[11px] font-semibold border ${licenseStatusColor}`}>
                {licenseStatusText}
              </span>
            </div>

            <button
              onClick={handleUpdateLicense}
              className="w-full h-11 border border-dashed border-[#0D9488] text-[#0D9488] hover:bg-teal-50/20 rounded-lg font-bold text-xs flex items-center justify-center gap-1.5 cursor-pointer mt-2"
            >
              <Upload className="w-4 h-4" />
              {isRTL ? 'تحديث ملف التراخيص أو رفع مستند' : 'Update Credentials / Upload Certificate'}
            </button>
          </div>
        </div>

        {/* Notification Preferences */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3 text-left">
          <span className="block text-[13px] font-bold text-gray-900 uppercase tracking-wider mb-1">
            {isRTL ? 'إعدادات الإشعارات والتنبيهات' : 'Notification Configurations'}
          </span>

          <div className="divide-y divide-gray-100">
            {/* Protocol review notification - LOCKED ON */}
            <div className="flex items-center justify-between py-3">
              <div className="space-y-0.5">
                <span className="block text-xs font-bold text-gray-900">{isRTL ? 'بروتوكولات الأدوية الجديدة' : 'New Medication Protocols'}</span>
                <span className="block text-[10px] text-[#64748B]">{isRTL ? 'إشعار فوري لمراجعة طلب الممرضة' : 'Instant review request from school nurse'}</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-10 h-5 bg-[#0D9488] rounded-full flex items-center px-1 cursor-not-allowed opacity-60">
                  <div className="w-3.5 h-3.5 bg-white rounded-full ml-auto" />
                </div>
                <Lock className="w-3.5 h-3.5 text-[#64748B]" />
              </div>
            </div>

            {/* Emergency Escalations - LOCKED ON */}
            <div className="flex items-center justify-between py-3">
              <div className="space-y-0.5">
                <span className="block text-xs font-bold text-gray-900">{isRTL ? 'تصعيدات الطوارئ الطارئة' : 'Emergency Escalations'}</span>
                <span className="block text-[10px] text-[#64748B]">{isRTL ? 'تنبيه فوري عند الحالات الحرجة' : 'Critical triage alarms for clinic incidents'}</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-10 h-5 bg-[#0D9488] rounded-full flex items-center px-1 cursor-not-allowed opacity-60">
                  <div className="w-3.5 h-3.5 bg-white rounded-full ml-auto" />
                </div>
                <Lock className="w-3.5 h-3.5 text-[#64748B]" />
              </div>
            </div>

            {/* Reports to co-sign - Editable */}
            <div className="flex items-center justify-between py-3">
              <div className="space-y-0.5">
                <span className="block text-xs font-bold text-gray-900">{isRTL ? 'تقارير بانتظار التوقيع المشترك' : 'Reports to Co-Sign'}</span>
                <span className="block text-[10px] text-[#64748B]">{isRTL ? 'تذكير بالتقارير الشهرية المرسلة من الممرضة' : 'Remind when monthly reports are submitted'}</span>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, coSignAlerts: !notifications.coSignAlerts })}
                className={`w-10 h-5 rounded-full flex items-center px-1 transition-colors cursor-pointer ${
                  notifications.coSignAlerts ? 'bg-[#0D9488]' : 'bg-gray-200'
                }`}
              >
                <div className={`w-3.5 h-3.5 bg-white rounded-full transition-transform ${
                  notifications.coSignAlerts ? (isRTL ? '-translate-x-4' : 'translate-x-4') : ''
                }`} />
              </button>
            </div>

            {/* Daily Schedule check reminders - Editable */}
            <div className="flex items-center justify-between py-3">
              <div className="space-y-0.5">
                <span className="block text-xs font-bold text-gray-900">{isRTL ? 'تذكير بجدول الدوام' : 'Schedule Reminders'}</span>
                <span className="block text-[10px] text-[#64748B]">{isRTL ? 'تذكير قبل الدوام بيوم واحد في الموقع' : 'Remind 24 hours before your on-site shift'}</span>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, reminders: !notifications.reminders })}
                className={`w-10 h-5 rounded-full flex items-center px-1 transition-colors cursor-pointer ${
                  notifications.reminders ? 'bg-[#0D9488]' : 'bg-gray-200'
                }`}
              >
                <div className={`w-3.5 h-3.5 bg-white rounded-full transition-transform ${
                  notifications.reminders ? (isRTL ? '-translate-x-4' : 'translate-x-4') : ''
                }`} />
              </button>
            </div>
          </div>
        </div>

        {/* Confidentiality reference section */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 flex items-center justify-between text-left">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-slate-100 flex items-center justify-center text-[#64748B]">
              <Shield className="w-5 h-5" />
            </div>
            <div>
              <span className="text-xs font-bold text-gray-900 block">{isRTL ? 'ميثاق سرية البيانات الطبية' : 'Confidentiality Agreement'}</span>
              <span className="text-[10px] text-[#64748B] block">{isRTL ? 'توقيع القانون الطبي: 15/05/2026' : 'Signed Medical Liability: 15/05/2026'}</span>
            </div>
          </div>
          <button 
            onClick={() => setShowConfidentialitySheet(true)}
            className="text-xs text-[#0D9488] font-bold hover:underline"
          >
            {isRTL ? 'عرض الميثاق' : 'View'}
          </button>
        </div>

        {/* Sign Out Trigger Button */}
        <button
          onClick={() => setShowSignOutDialog(true)}
          className="w-full h-[52px] bg-white border border-[#DC2626] text-[#DC2626] rounded-xl font-bold text-[15px] flex items-center justify-center gap-2 cursor-pointer mt-4"
        >
          <LogOut className="w-4 h-4" />
          {isRTL ? 'تسجيل الخروج من الحساب' : 'Sign out'}
        </button>
      </div>

      {/* Sign Out Confirmation Dialogue Modal */}
      {showSignOutDialog && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full border border-gray-100 shadow-xl space-y-4">
            <div className="text-center space-y-1">
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'تسجيل الخروج؟' : 'Sign out?'}
              </h3>
              <p className="text-xs text-[#64748B]">
                {isRTL 
                  ? 'هل أنت متأكد من رغبتك في تسجيل الخروج؟' 
                  : 'Are you sure you want to log out of your session?'}
              </p>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => setShowSignOutDialog(false)}
                className="flex-1 h-11 border border-gray-200 text-gray-500 rounded-xl text-xs font-bold cursor-pointer bg-white"
              >
                {isRTL ? 'إلغاء' : 'Cancel'}
              </button>
              <button
                onClick={handleSignOut}
                className="flex-1 h-11 bg-[#DC2626] text-white rounded-xl text-xs font-bold cursor-pointer"
              >
                {isRTL ? 'تسجيل الخروج' : 'Sign out'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Confidentiality Agreement full sheet mock modal */}
      {showConfidentialitySheet && (
        <div className="fixed inset-0 bg-black/60 flex items-end justify-center z-50">
          <div className="bg-white rounded-t-3xl max-w-sm w-full h-[80%] flex flex-col border border-gray-100 shadow-2xl animate-slide-up">
            <div className="p-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="text-[15px] font-bold text-gray-900 text-left">
                {isRTL ? 'ميثاق سرية البيانات الطبية' : 'Clinical Disclosure Agreement'}
              </h3>
              <button 
                onClick={() => setShowConfidentialitySheet(false)}
                className="text-xs font-bold text-[#64748B] hover:text-gray-900"
              >
                {isRTL ? 'إغلاق' : 'Close'}
              </button>
            </div>
            
            <div className="flex-1 p-4 overflow-y-auto text-xs text-gray-700 leading-relaxed text-left space-y-3.5">
              <p className="font-bold text-gray-950">
                {isRTL 
                  ? 'مستند قانوني للامتثال للمادة الطبية رَقَم 4 لسنة 2016 لدولة الإمارات وقانون حماية البيانات الشخصية الإمارتي (PDPL):' 
                  : 'UAE Legal compliance document pursuant to Medical Liability Law No. 4/2016 and UAE Personal Data Protection Law (PDPL):'}
              </p>
              <p>
                {isRTL
                  ? 'يقر المستخدم الموقّع أدناه بمسؤوليته الكاملة عن الحفاظ على سرية سجلات الطلاب الصحية وكافة التشخيصات الطبية والبروتوكولات التي يتم الاطلاع عليها أو اعتمادها عبر التطبيق.'
                  : 'The undersigned practitioner acknowledges full legal responsibility under UAE law for maintaining student record privacy. Personal health records, medication orders, and escalation details accessed herein constitute protected health files.'}
              </p>
              <p>
                {isRTL
                  ? 'يخضع هذا الترخيص لرقابة هيئة الصحة بدبي (DHA) وتطبيقات التفتيش الدورية، وأي تسريب أو مشاركة غير مرخصة للملفات الطبية يعرض صاحبها للملاحقة القانونية.'
                  : 'Access logs are monitored in compliance with DHA clinical audit policies. Unauthorized disclosure, sharing, or modification of these files violates medical ethics and Federal laws.'}
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
export default PhysicianSettings;
