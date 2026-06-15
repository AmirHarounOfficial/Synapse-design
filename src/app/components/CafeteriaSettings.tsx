import { useNavigate } from 'react-router';
import { Bell, Calendar, Volume2, Clock, FileText, Shield, Info, Headphones, Lock, ChevronRight, Award, Check, X } from 'lucide-react';
import { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { HalalBadge } from './HalalBadge';
import { toast } from 'sonner';

export function CafeteriaSettings() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [newAllergenAlerts, setNewAllergenAlerts] = useState(true); // Locked ON
  const [dailyReminder, setDailyReminder] = useState(true);
  const [reminderTime, setReminderTime] = useState('07:15 AM');
  const [soundAlerts, setSoundAlerts] = useState(true);
  const [shiftTime, setShiftTime] = useState('07:00 AM — 3:00 PM');
  const [halalReminder, setHalalReminder] = useState(true);
  
  const [showLockedSheet, setShowLockedSheet] = useState(false);
  const [showTimeSheet, setShowTimeSheet] = useState(false);
  const [showShiftSheet, setShowShiftSheet] = useState(false);
  const [showConfidentialitySheet, setShowConfidentialitySheet] = useState(false);
  const [showDataAccessSheet, setShowDataAccessSheet] = useState(false);
  const [showSignOutDialog, setShowSignOutDialog] = useState(false);
  
  const [showHalalCertificate, setShowHalalCertificate] = useState(false);
  const [showHalalLockSheet, setShowHalalLockSheet] = useState(false);

  const handleSignOut = () => {
    toast.success(isRTL ? "تم تسجيل الخروج بنجاح" : "Signed out successfully.");
    setTimeout(() => {
      navigate('/');
    }, 1200);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center justify-center px-4 h-14 bg-white border-b border-gray-200 relative">
        <h1 className="font-bold text-gray-900 text-[17px]">
          {isRTL ? 'الإعدادات' : 'Settings'}
        </h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Profile Section */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 text-left shadow-sm">
          <div className="flex items-start gap-3">
            <div className="w-16 h-16 rounded-full bg-[#F0FDF4] flex items-center justify-center flex-shrink-0">
              <span className="text-[20px] font-bold text-[#15803D]">
                AM
              </span>
            </div>
            <div className="flex-1">
              <div className="text-[17px] font-bold text-gray-900 mb-1">
                Alex Martinez
              </div>
              <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-[#F0FDF4] mb-2 border border-[#A7F3D0]">
                <span className="text-[11px] font-bold text-[#15803D]">
                  {isRTL ? 'موظف الكافتيريا' : 'Cafeteria Staff'}
                </span>
              </div>
              <div className="text-[13px] text-[#64748B]">
                Lincoln Elementary School
              </div>
            </div>
          </div>
        </div>

        {/* Thin Divider */}
        <div className="h-px bg-gray-200" />

        {/* NOTIFICATIONS Section */}
        <div className="text-left">
          <h2 className="text-[12px] font-bold text-[#64748B] uppercase tracking-wide mb-3">
            {isRTL ? 'تنبيهات الإشعارات' : 'NOTIFICATIONS'}
          </h2>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100 shadow-sm">
            {/* Row 1: New allergen alerts - LOCKED */}
            <div className="p-4 min-h-[52px] flex items-center gap-3">
              <Bell className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A] mb-0.5">
                  {isRTL ? 'تنبيهات الحساسية الجديدة' : 'New allergen alerts'}
                </div>
                <div className="text-[12px] text-[#64748B] leading-relaxed">
                  {isRTL ? 'إشعارات فورية عند إضافة أو تعديل قيود الطعام للطالب' : 'Real-time alerts when a restriction is added or updated'}
                </div>
              </div>
              <button
                onClick={() => setShowLockedSheet(true)}
                className="flex items-center gap-2 flex-shrink-0 cursor-pointer"
              >
                <Lock className="w-4 h-4 text-[#64748B]" />
                <div className="w-12 h-7 rounded-full p-0.5 transition-colors bg-[#10B981]">
                  <div className="w-6 h-6 rounded-full bg-white shadow-sm transition-transform translate-x-5" />
                </div>
              </button>
            </div>

            {/* Row 2: Daily allergen list reminder */}
            <div className="p-4 min-h-[52px] flex items-center gap-3">
              <Bell className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A] mb-0.5">
                  {isRTL ? 'تذكير القائمة اليومية' : 'Daily allergen list reminder'}
                </div>
                <div className="text-[12px] text-[#64748B] leading-relaxed">
                  {isRTL ? 'تذكير لتأكيد مراجعة القائمة قبل تقديم الوجبات' : 'Reminder to acknowledge today\'s list at meal service start'}
                </div>
              </div>
              <button
                onClick={() => setDailyReminder(!dailyReminder)}
                className="flex-shrink-0 cursor-pointer"
              >
                <div className={`w-12 h-7 rounded-full p-0.5 transition-colors ${dailyReminder ? 'bg-[#10B981]' : 'bg-gray-300'}`}>
                  <div className={`w-6 h-6 rounded-full bg-white shadow-sm transition-transform ${dailyReminder ? 'translate-x-5' : 'translate-x-0'}`} />
                </div>
              </button>
            </div>

            {/* Row 3: Reminder time - Only visible when daily reminder is ON */}
            {dailyReminder && (
              <button
                onClick={() => setShowTimeSheet(true)}
                className="w-full p-4 min-h-[52px] flex items-center gap-3 text-left cursor-pointer hover:bg-slate-50/20"
              >
                <Calendar className="w-5 h-5 text-[#64748B] flex-shrink-0" />
                <div className="flex-1 min-w-0">
                  <div className="text-[14px] text-[#0F172A]">
                    {isRTL ? 'وقت التذكير اليومي' : 'Reminder time'}
                  </div>
                </div>
                <div className="text-[14px] text-[#2563EB] font-medium font-mono">
                  {reminderTime}
                </div>
              </button>
            )}

            {/* Row 4: Sound alerts for new restrictions */}
            <div className="p-4 min-h-[52px] flex items-center gap-3">
              <Volume2 className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A] mb-0.5">
                  {isRTL ? 'التنبيهات الصوتية للقيود الجديدة' : 'Sound alerts for new restrictions'}
                </div>
                <div className="text-[12px] text-[#64748B] leading-relaxed">
                  {isRTL ? 'تشغيل تنبيه صوتي عند ظهور نافذة التنبيه الفوري' : 'Audible alert when C-03 real-time modal appears'}
                </div>
              </div>
              <button
                onClick={() => setSoundAlerts(!soundAlerts)}
                className="flex-shrink-0 cursor-pointer"
              >
                <div className={`w-12 h-7 rounded-full p-0.5 transition-colors ${soundAlerts ? 'bg-[#10B981]' : 'bg-gray-300'}`}>
                  <div className={`w-6 h-6 rounded-full bg-white shadow-sm transition-transform ${soundAlerts ? 'translate-x-5' : 'translate-x-0'}`} />
                </div>
              </button>
            </div>
          </div>
        </div>

        {/* Thin Divider */}
        <div className="h-px bg-gray-200" />

        {/* HALAL COMPLIANCE Section */}
        <div className="text-left">
          <h2 className="text-[12px] font-bold text-[#64748B] uppercase tracking-wide mb-3">
            {isRTL ? 'الامتثال لمتطلبات الحلال' : 'Halal Compliance'}
          </h2>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100 shadow-sm">
            {/* Row 1: Halal certification status */}
            <button
              onClick={() => setShowHalalCertificate(true)}
              className="w-full p-4 min-h-[52px] flex items-center gap-3 text-left cursor-pointer hover:bg-slate-50/30"
            >
              <Award className="w-5 h-5 text-emerald-600 flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A]">
                  {isRTL ? 'شهادة الحلال المعتمدة' : 'Halal Certification Status'}
                </div>
                <div className="text-[12px] text-[#64748B]">
                  {isRTL ? 'الترخيص نشط وصالح للتقديم الغذائي للمدارس' : 'Official compliance certificate details'}
                </div>
              </div>
              <div className="flex items-center gap-1.5 flex-shrink-0">
                <span className="text-[11px] bg-[#D1FAE5] text-[#065F46] font-bold px-2 py-0.5 rounded-full border border-emerald-200">
                  {isRTL ? 'معتمد · 15/06/2027' : 'Certified · Exp: 15/06/2027'}
                </span>
                <ChevronRight className="w-4 h-4 text-[#64748B]" />
              </div>
            </button>

            {/* Row 2: Daily Halal acknowledgment - LOCKED */}
            <div className="p-4 min-h-[52px] flex items-center gap-3">
              <Check className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A] mb-0.5">
                  {isRTL ? 'الإقرار اليومي لشهادة الحلال' : 'Daily Halal acknowledgment'}
                </div>
                <div className="text-[12px] text-[#64748B] leading-relaxed">
                  {isRTL ? 'تأكيد مطابقة وجبات اليوم بالكامل للشريعة الإسلامية' : 'Cafeteria staff must confirm Halal compliance daily'}
                </div>
              </div>
              <button
                onClick={() => setShowHalalLockSheet(true)}
                className="flex items-center gap-2 flex-shrink-0 cursor-pointer"
              >
                <Lock className="w-4 h-4 text-[#64748B]" />
                <div className="w-12 h-7 rounded-full p-0.5 bg-[#10B981]">
                  <div className="w-6 h-6 rounded-full bg-white shadow-sm transition-transform translate-x-5" />
                </div>
              </button>
            </div>

            {/* Row 3: Certification renewal reminder */}
            <div className="p-4 min-h-[52px] flex items-center gap-3">
              <Bell className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A] mb-0.5">
                  {isRTL ? 'تنبيه انتهاء الشهادة' : 'Certification renewal reminder'}
                </div>
                <div className="text-[12px] text-[#64748B] leading-relaxed">
                  {isRTL ? 'إرسال تنبيه قبل 30 يوماً من انتهاء الشهادة' : 'Remind 30 days before certificate expiry'}
                </div>
              </div>
              <button
                onClick={() => setHalalReminder(!halalReminder)}
                className="flex-shrink-0 cursor-pointer"
              >
                <div className={`w-12 h-7 rounded-full p-0.5 transition-colors ${halalReminder ? 'bg-[#10B981]' : 'bg-gray-300'}`}>
                  <div className={`w-6 h-6 rounded-full bg-white shadow-sm transition-transform ${halalReminder ? 'translate-x-5' : 'translate-x-0'}`} />
                </div>
              </button>
            </div>
          </div>
        </div>

        {/* Thin Divider */}
        <div className="h-px bg-gray-200" />

        {/* MY SHIFT Section */}
        <div className="text-left">
          <h2 className="text-[12px] font-bold text-[#64748B] uppercase tracking-wide mb-3">
            {isRTL ? 'ساعات المناوبة' : 'MY SHIFT'}
          </h2>

          <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
            <button
              onClick={() => setShowShiftSheet(true)}
              className="w-full p-4 min-h-[52px] flex items-center gap-3 text-left cursor-pointer hover:bg-slate-50/20"
            >
              <Clock className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A] mb-0.5">
                  {isRTL ? 'بداية ونهاية المناوبة' : 'Shift start / end'}
                </div>
                <div className="text-[12px] text-[#64748B] leading-relaxed">
                  {isRTL ? 'إرسال الإشعارات إليك خلال ساعات عملك الفعلي فقط' : 'Notifications only sent during your shift window'}
                </div>
              </div>
              <div className="text-[14px] text-[#2563EB] font-medium font-mono">
                {shiftTime}
              </div>
            </button>
          </div>
        </div>

        {/* Thin Divider */}
        <div className="h-px bg-gray-200" />

        {/* DATA & PRIVACY Section */}
        <div className="text-left">
          <h2 className="text-[12px] font-bold text-[#64748B] uppercase tracking-wide mb-3">
            {isRTL ? 'البيانات والخصوصية' : 'DATA & PRIVACY'}
          </h2>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100 shadow-sm">
            {/* Confidentiality agreement */}
            <button
              onClick={() => setShowConfidentialitySheet(true)}
              className="w-full p-4 min-h-[52px] flex items-center gap-3 text-left cursor-pointer hover:bg-slate-50/20"
            >
              <FileText className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A]">
                  {isRTL ? 'اتفاقية السرية وحماية البيانات' : 'Confidentiality agreement'}
                </div>
              </div>
              <div className="flex items-center gap-2">
                <div className="text-[12px] text-[#64748B]">
                  {isRTL ? 'موقعة في 01/05/2026' : 'Signed May 1, 2026'}
                </div>
                <ChevronRight className={`w-5 h-5 text-[#64748B] flex-shrink-0 ${isRTL ? 'rotate-180' : ''}`} />
              </div>
            </button>

            {/* My data access level */}
            <button
              onClick={() => setShowDataAccessSheet(true)}
              className="w-full p-4 min-h-[52px] flex items-center gap-3 text-left cursor-pointer hover:bg-slate-50/20"
            >
              <Shield className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A]">
                  {isRTL ? 'مستوى الوصول للبيانات' : 'My data access level'}
                </div>
              </div>
              <div className="flex items-center gap-2">
                <div className="text-[11px] text-[#10B981] font-bold bg-[#EFF6FF] px-2 py-0.5 rounded-full border border-blue-100 max-w-[150px] truncate">
                  {isRTL ? 'قيود الكافتيريا فقط' : 'Allergens only'}
                </div>
                <ChevronRight className={`w-5 h-5 text-[#64748B] flex-shrink-0 ${isRTL ? 'rotate-180' : ''}`} />
              </div>
            </button>
          </div>
        </div>

        {/* Thin Divider */}
        <div className="h-px bg-gray-200" />

        {/* ABOUT Section */}
        <div className="text-left">
          <h2 className="text-[12px] font-bold text-[#64748B] uppercase tracking-wide mb-3">
            {isRTL ? 'حول التطبيق' : 'ABOUT'}
          </h2>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100 shadow-sm">
            {/* App version */}
            <div className="p-4 min-h-[52px] flex items-center gap-3">
              <Info className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A]">
                  {isRTL ? 'إصدار التطبيق' : 'App version'}
                </div>
              </div>
              <div className="text-[12px] text-[#64748B] font-mono">
                Synapse v1.0.0
              </div>
            </div>

            {/* Contact support */}
            <button className="w-full p-4 min-h-[52px] flex items-center gap-3 text-left cursor-pointer hover:bg-slate-50/20">
              <Headphones className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-semibold text-[#0F172A]">
                  {isRTL ? 'الاتصال بالدعم الفني' : 'Contact support'}
                </div>
              </div>
              <ChevronRight className={`w-5 h-5 text-[#64748B] flex-shrink-0 ${isRTL ? 'rotate-180' : ''}`} />
            </button>
          </div>
        </div>

        {/* Sign Out Button */}
        <div className="pt-4">
          <button
            onClick={() => setShowSignOutDialog(true)}
            className="w-full px-4 py-3.5 text-[#DC2626] text-[15px] font-bold min-h-[52px] rounded-lg bg-white border border-gray-200 shadow-sm cursor-pointer hover:bg-red-50/10 active:scale-[0.98] transition-all"
          >
            {isRTL ? 'تسجيل الخروج' : 'Sign out'}
          </button>
        </div>
      </div>

      {/* Required Notification Warning Modal */}
      {showLockedSheet && (
        <div className="fixed inset-0 z-50 flex items-end">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowLockedSheet(false)}
          />
          <div className="relative bg-white rounded-t-3xl w-full max-h-[70vh] overflow-y-auto max-w-[393px] mx-auto text-left">
            <div className="sticky top-0 bg-white px-4 pt-4 pb-3 border-b border-gray-200">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'إشعار تنبيه إلزامي' : 'Required Notification'}
              </h3>
            </div>
            <div className="p-4 space-y-4">
              <div className="flex items-start gap-3">
                <Lock className="w-6 h-6 text-[#DC2626] flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-[14px] text-[#0F172A] leading-relaxed font-semibold">
                    {isRTL 
                      ? 'لا يمكن إيقاف تنبيهات الحساسية الممنوعة للطلاب لضمان سلامتهم الغذائية التامة بالمدرسة.'
                      : 'This alert cannot be disabled. Cafeteria staff must receive all allergen updates for student safety.'}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setShowLockedSheet(false)}
                className="w-full px-4 py-3.5 bg-[#0D9488] text-white rounded-lg text-[15px] font-medium min-h-[52px] cursor-pointer"
              >
                {isRTL ? 'مفهوم' : 'Understood'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Time Picker Bottom Sheet */}
      {showTimeSheet && (
        <div className="fixed inset-0 z-50 flex items-end">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowTimeSheet(false)}
          />
          <div className="relative bg-white rounded-t-3xl w-full max-h-[70vh] overflow-y-auto max-w-[393px] mx-auto text-left">
            <div className="sticky top-0 bg-white px-4 pt-4 pb-3 border-b border-gray-200">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'تحديد وقت التنبيه' : 'Set Reminder Time'}
              </h3>
            </div>
            <div className="p-4 space-y-3">
              <p className="text-[13px] text-[#64748B]">
                {isRTL 
                  ? 'اختر الوقت الذي تفضله لتلقي التذكير اليومي للقيود الغذائية.'
                  : "Choose when you'd like to receive your daily allergen list reminder."}
              </p>
              <div className="space-y-2">
                {['06:30 AM', '07:00 AM', '07:15 AM', '07:30 AM', '08:00 AM'].map((time) => (
                  <button
                    key={time}
                    onClick={() => {
                      setReminderTime(time);
                      setShowTimeSheet(false);
                    }}
                    className={`w-full p-4 rounded-lg text-left border-2 transition-all cursor-pointer ${
                      reminderTime === time
                        ? 'border-[#0D9488] bg-teal-50/20'
                        : 'border-gray-200 bg-white'
                    }`}
                  >
                    <div className="text-[15px] font-bold text-gray-900">
                      {time}
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Shift Time Bottom Sheet */}
      {showShiftSheet && (
        <div className="fixed inset-0 z-50 flex items-end">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowShiftSheet(false)}
          />
          <div className="relative bg-white rounded-t-3xl w-full max-h-[70vh] overflow-y-auto max-w-[393px] mx-auto text-left">
            <div className="sticky top-0 bg-white px-4 pt-4 pb-3 border-b border-gray-200">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'تحديد ساعات المناوبة' : 'Set Shift Hours'}
              </h3>
            </div>
            <div className="p-4 space-y-3">
              <p className="text-[13px] text-[#64748B]">
                {isRTL 
                  ? 'حدد ساعات عملك لتلقي التنبيهات خلال هذه الفترة فقط.'
                  : 'Set your shift hours so you only receive notifications during your work time.'}
              </p>
              <div className="space-y-2">
                {[
                  '06:00 AM — 2:00 PM',
                  '07:00 AM — 3:00 PM',
                  '08:00 AM — 4:00 PM',
                  '09:00 AM — 5:00 PM'
                ].map((time) => (
                  <button
                    key={time}
                    onClick={() => {
                      setShiftTime(time);
                      setShowShiftSheet(false);
                    }}
                    className={`w-full p-4 rounded-lg text-left border-2 transition-all cursor-pointer ${
                      shiftTime === time
                        ? 'border-[#0D9488] bg-teal-50/20'
                        : 'border-gray-200 bg-white'
                    }`}
                  >
                    <div className="text-[15px] font-bold text-gray-900">
                      {time}
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Confidentiality Agreement Bottom Sheet */}
      {showConfidentialitySheet && (
        <div className="fixed inset-0 z-50 flex items-end">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowConfidentialitySheet(false)}
          />
          <div className="relative bg-white rounded-t-3xl w-full max-h-[70vh] overflow-y-auto max-w-[393px] mx-auto text-left">
            <div className="sticky top-0 bg-white px-4 pt-4 pb-3 border-b border-gray-200">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'اتفاقية حماية سرية البيانات' : 'Confidentiality Agreement'}
              </h3>
            </div>
            <div className="p-4 space-y-4">
              <div className="flex items-start gap-2 p-3 bg-[#F0FDF4] rounded-lg border border-[#10B981]">
                <Lock className="w-5 h-5 text-[#10B981] flex-shrink-0 mt-0.5" />
                <div>
                  <div className="text-[13px] font-bold text-[#065F46] mb-1">
                    {isRTL ? 'موقعة ونشطة' : 'Signed and Active'}
                  </div>
                  <div className="text-[12px] text-[#10B981]">
                    {isRTL ? 'وقعت في 1 مايو 2026 الساعة 9:15 ص' : 'Signed on May 1, 2026 at 9:15 AM'}
                  </div>
                </div>
              </div>
              
              <div className="space-y-3 text-[13px] text-[#64748B] leading-relaxed">
                <p className="font-bold text-[#0F172A]">
                  {isRTL 
                    ? 'اتفاقية سرية معلومات صحة الطلاب (قانون حماية البيانات الشخصية PDPL)'
                    : 'Student Health Information Confidentiality Agreement (UAE PDPL)'}
                </p>
                <p>
                  {isRTL
                    ? 'بصفتي موظفاً في كافتيريا المدرسة، أقر بأنني قد أطلع على معلومات مسببات الحساسية والقيود الغذائية للطلاب من خلال نظام Synapse.'
                    : 'As a cafeteria staff member, I understand that I may have access to student allergen and dietary restriction information through the Synapse system.'}
                </p>
                <p>
                  {isRTL ? 'أوافق على ما يلي:' : 'I agree to:'}
                </p>
                <ul className="list-disc pr-5 pl-5 space-y-2">
                  <li>{isRTL ? 'الحفاظ على السرية التامة لجميع البيانات الشخصية والصحية بموجب المرسوم بقانون رقم 45/2021.' : 'Keep all student health information strictly confidential per UAE Decree Law No. 45/2021.'}</li>
                  <li>{isRTL ? 'الوصول فقط إلى معلومات قيود الطعام الضرورية لإعداد الوجبات بسلامة.' : 'Only access information necessary to safely prepare and serve meals.'}</li>
                  <li>{isRTL ? 'عدم مناقشة قيود الطلاب الغذائية مع أي جهة غير مصرح لها.' : 'Never discuss student restrictions with unauthorized individuals.'}</li>
                  <li>{isRTL ? 'الإبلاغ فوراً عن أي خرق أو تسريب محتمل للخصوصية لـ مسؤول حماية البيانات (DPO).' : 'Report any suspected privacy breaches immediately to the DPO.'}</li>
                </ul>
                <p className="text-[11px] text-[#94A3B8] italic mt-4">
                  {isRTL 
                    ? 'توقيعك الرقمي مسجل ونشط ومحفوظ قانوناً طوال فترة العمل.'
                    : 'Your digital signature is on file and this agreement remains active under UAE Data Office regulations.'}
                </p>
              </div>

              <button
                onClick={() => setShowConfidentialitySheet(false)}
                className="w-full px-4 py-3 bg-[#0D9488] text-white rounded-lg text-[15px] font-bold min-h-[44px] cursor-pointer"
              >
                {isRTL ? 'إغلاق' : 'Close'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Data Access Level Bottom Sheet */}
      {showDataAccessSheet && (
        <div className="fixed inset-0 z-50 flex items-end">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowDataAccessSheet(false)}
          />
          <div className="relative bg-white rounded-t-3xl w-full max-h-[70vh] overflow-y-auto max-w-[393px] mx-auto text-left">
            <div className="sticky top-0 bg-white px-4 pt-4 pb-3 border-b border-gray-200">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'مستوى الوصول للبيانات المصرح بها' : 'Your Data Access Level'}
              </h3>
            </div>
            <div className="p-4 space-y-4">
              <div className="flex items-start gap-2 p-3 bg-[#F0FDF4] rounded-lg border border-[#10B981]">
                <Shield className="w-5 h-5 text-[#10B981] flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <div className="text-[13px] font-bold text-[#065F46] mb-1">
                    {isRTL ? 'وصول محدود — موظفي الكافتيريا' : 'Limited Access — Cafeteria Staff'}
                  </div>
                  <div className="text-[12px] text-[#10B981]">
                    {isRTL ? 'قيود الحساسية والأغذية فقط — بدون سجلات طبية' : 'Allergen restrictions only — no medical records'}
                  </div>
                </div>
              </div>
              
              <div className="space-y-4 text-[13px]">
                <div>
                  <div className="font-bold text-[#0F172A] mb-2">
                    {isRTL ? 'البيانات المسموح لك بالاطلاع عليها:' : 'What you can see:'}
                  </div>
                  <ul className="space-y-2 text-[#64748B] list-inside list-disc">
                    <li>{isRTL ? 'اسم الطالب (الاسم الأول والحرف الأول للجد فقط)' : 'Student name (first name + last initial only)'}</li>
                    <li>{isRTL ? 'الصف الدراسي للمدرسة' : 'Grade level'}</li>
                    <li>{isRTL ? 'قيود الطعام ومسببات الحساسية' : 'Allergen and dietary restrictions'}</li>
                    <li>{isRTL ? 'متطلبات إعداد وجبة خاصة للطلاب' : 'Special meal requirements'}</li>
                  </ul>
                </div>

                <div>
                  <div className="font-bold text-[#0F172A] mb-2">
                    {isRTL ? 'البيانات المحجوبة والسرية عنك:' : 'What you cannot see:'}
                  </div>
                  <ul className="space-y-2 text-[#64748B] list-inside list-disc">
                    <li>{isRTL ? 'التشخيصات الطبية والأمراض' : 'Medical diagnoses or conditions'}</li>
                    <li>{isRTL ? 'بيانات الأدوية الموصوفة والجرعات' : 'Medication information'}</li>
                    <li>{isRTL ? 'الأسماء الكاملة للطلاب أو أرقام التواصل' : 'Full names or contact information'}</li>
                    <li>{isRTL ? 'سجل زيارات العيادة أو الملاحظات الطبية' : 'Health visit history or clinic notes'}</li>
                  </ul>
                </div>

                <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-lg p-3">
                  <p className="text-[12px] text-[#1E40AF] leading-relaxed">
                    <strong className="font-semibold">{isRTL ? 'قانون حماية البيانات الإماراتي (PDPL):' : 'UAE PDPL Protection:'}</strong>{' '}
                    {isRTL 
                      ? 'تم تقييد نطاق وصول موظفي الكافتيريا لحماية خصوصية بيانات الطلاب الصحية مع ضمان حصولك على القيود الغذائية اللازمة فقط لتحضير الوجبات بسلامة.'
                      : 'This limited access scope is designed to protect student privacy per UAE PDPL compliance while ensuring you have dietary information needed to safely prepare meals.'}
                  </p>
                </div>
              </div>

              <button
                onClick={() => setShowDataAccessSheet(false)}
                className="w-full px-4 py-3 bg-[#0D9488] text-white rounded-lg text-[15px] font-bold min-h-[44px] cursor-pointer"
              >
                {isRTL ? 'إغلاق' : 'Close'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Sign Out Confirmation Dialog */}
      {showSignOutDialog && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full text-left space-y-4">
            <h3 className="text-[17px] font-bold text-gray-900">
              {isRTL ? 'تسجيل الخروج · Sign out?' : 'Sign out of Synapse?'}
            </h3>
            <p className="text-[14px] text-[#64748B] leading-relaxed">
              {isRTL 
                ? 'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى التطبيق.'
                : "You'll need to sign in again to access the app."}
            </p>

            <div className="flex gap-3">
              <button
                onClick={() => setShowSignOutDialog(false)}
                className="flex-1 px-4 py-3 bg-white text-gray-900 border border-gray-200 rounded-lg text-[14px] font-bold min-h-[44px] cursor-pointer"
              >
                {isRTL ? 'إلغاء · Cancel' : 'Cancel'}
              </button>
              <button
                onClick={handleSignOut}
                className="flex-1 px-4 py-3 bg-[#DC2626] text-white rounded-lg text-[14px] font-bold min-h-[44px] cursor-pointer"
              >
                {isRTL ? 'تسجيل الخروج · Sign out' : 'Sign out'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Halal Certificate Modal */}
      {showHalalCertificate && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full text-left space-y-4 relative">
            <button
              onClick={() => setShowHalalCertificate(false)}
              className="absolute top-4 right-4 p-1 rounded-full bg-slate-100 hover:bg-slate-200 cursor-pointer min-w-[32px] min-h-[32px] flex items-center justify-center"
            >
              <X className="w-4 h-4 text-slate-500" />
            </button>
            <div className="text-center space-y-3">
              <Award className="w-12 h-12 text-[#15803D] mx-auto animate-bounce" />
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'شهادة الحلال المعتمدة' : 'Official Halal Certificate'}
              </h3>
              <p className="text-xs text-[#64748B]">
                {isRTL 
                  ? 'هذه المنشأة الغذائية معتمدة بالكامل وحلال من الجهات الرسمية في دولة الإمارات العربية المتحدة.'
                  : 'This school cafeteria facility is certified Halal and compliant with UAE food safety regulations.'}
              </p>
              
              <div className="border border-dashed border-[#15803D] bg-[#F0FDF4] p-4 rounded-xl space-y-2 text-xs text-left">
                <div className="flex justify-between font-bold text-[#15803D]">
                  <span>{isRTL ? 'رقم الشهادة:' : 'Cert No:'}</span>
                  <span className="font-mono">UAE-HALAL-2026-992</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>{isRTL ? 'جهة الترخيص:' : 'Authority:'}</span>
                  <span>MOHAP / Dubai Municipality</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>{isRTL ? 'تاريخ الانتهاء:' : 'Expiry Date:'}</span>
                  <span className="font-mono">15/06/2027</span>
                </div>
              </div>
            </div>
            <button
              onClick={() => setShowHalalCertificate(false)}
              className="w-full px-4 py-2.5 bg-[#0D9488] text-white rounded-lg text-xs font-bold cursor-pointer"
            >
              {isRTL ? 'إغلاق' : 'Close Viewer'}
            </button>
          </div>
        </div>
      )}

      {/* Halal Lock Alert Sheet */}
      {showHalalLockSheet && (
        <div className="fixed inset-0 z-50 flex items-end">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowHalalLockSheet(false)}
          />
          <div className="relative bg-white rounded-t-3xl w-full max-h-[70vh] overflow-y-auto max-w-[393px] mx-auto text-left">
            <div className="sticky top-0 bg-white px-4 pt-4 pb-3 border-b border-gray-200">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'إجراء تأكيد إلزامي' : 'Mandatory Requirement'}
              </h3>
            </div>
            <div className="p-4 space-y-4">
              <div className="flex items-start gap-3">
                <Lock className="w-6 h-6 text-[#DC2626] flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-[14px] text-[#0F172A] leading-relaxed font-semibold">
                    {isRTL 
                      ? 'لا يمكن إلغاء الإقرار اليومي بالحلال. يجب على جميع موظفي الكافتيريا تأكيد الامتثال قبل بدء خدمة تقديم الطعام.'
                      : 'The daily Halal acknowledgment cannot be disabled. All cafeteria staff must confirm Halal compliance before meal service.'}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setShowHalalLockSheet(false)}
                className="w-full px-4 py-3.5 bg-[#0D9488] text-white rounded-lg text-[15px] font-medium min-h-[52px] cursor-pointer"
              >
                {isRTL ? 'حسناً، مفهوم' : 'Understood'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
export default CafeteriaSettings;
