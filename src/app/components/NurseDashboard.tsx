import { Bell, Pill, Stethoscope, FileText, AlertTriangle, X, Zap, Clock, ChevronRight, Settings } from 'lucide-react';
import { useState } from 'react';
import { useNavigate } from 'react-router';
import { useLanguage } from '../../context/LanguageContext';
import { EmergencyCallButton } from './EmergencyCallButton';

export function NurseDashboard() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [showWeatherAlert, setShowWeatherAlert] = useState(true);
  const [notificationCount] = useState(3);
  const pendingPhysicianApprovals = 2; // simulated count

  const currentHour = new Date().getHours();
  let greeting = currentHour < 12 ? 'Good morning' : currentHour < 18 ? 'Good afternoon' : 'Good evening';
  if (isRTL) {
    greeting = currentHour < 12 ? 'صباح الخير' : currentHour < 18 ? 'مساء الخير' : 'مساء الخير';
  }

  const upcomingDoses = [
    {
      id: 1,
      studentName: 'Emma Rodriguez',
      studentInitials: 'ER',
      medication: 'Adderall XR 10mg',
      doseTime: '10:30 AM',
      minutesUntil: 15,
      isUrgent: true
    },
    {
      id: 2,
      studentName: 'Marcus Chen',
      studentInitials: 'MC',
      medication: 'Albuterol Inhaler 2 puffs',
      doseTime: '11:00 AM',
      minutesUntil: 45,
      isUrgent: false
    },
    {
      id: 3,
      studentName: 'Sophia Williams',
      studentInitials: 'SW',
      medication: 'Insulin Lispro 5 units',
      doseTime: '12:00 PM',
      minutesUntil: 105,
      isUrgent: false
    }
  ];

  const recentVisits = [
    {
      id: 1,
      studentName: 'James Patterson',
      reason: isRTL ? 'صداع' : 'Headache',
      time: '9:15 AM'
    },
    {
      id: 2,
      studentName: 'Olivia Martinez',
      reason: isRTL ? 'إصابة طفيفة' : 'Minor injury',
      time: '8:45 AM'
    }
  ];

  const quickActions = [
    { id: 1, label: isRTL ? 'تسجيل زيارة عيادة' : 'Log Clinic Visit', icon: Stethoscope, color: '#2563EB', bgColor: '#2563EB/10' },
    { id: 2, label: isRTL ? 'إعطاء دواء' : 'Give Medication', icon: Pill, color: '#10B981', bgColor: '#10B981/10' },
    { id: 3, label: isRTL ? 'طوارئ' : 'Emergency', icon: Zap, color: '#DC2626', bgColor: '#DC2626', textColor: '#FFFFFF', filled: true },
    { id: 4, label: isRTL ? 'إرسال تنبيه' : 'Send Alert', icon: Bell, color: '#06B6D4', bgColor: '#06B6D4/10' }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <h1 className="text-[17px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
          {greeting}, Sarah 👋
        </h1>
        <div className="flex items-center gap-1">
          <button
            onClick={() => navigate('/nurse/notifications')}
            className="relative p-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
          >
            <Bell className="w-6 h-6 text-[#64748B]" />
            {notificationCount > 0 && (
              <span className="absolute top-1 right-1 bg-[#DC2626] text-white text-[10px] font-semibold px-1.5 py-0.5 rounded-full min-w-[18px] text-center">
                {notificationCount}
              </span>
            )}
          </button>
          <button
            onClick={() => navigate('/nurse/settings')}
            className="p-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
          >
            <Settings className="w-6 h-6 text-[#64748B]" />
          </button>
        </div>
      </div>

      {/* Weather Alert Banner */}
      {showWeatherAlert && (
        <div 
          className="bg-[#FFFBEB] p-3 mx-4 mt-4 rounded-lg text-left"
          style={{
            borderLeftWidth: isRTL ? 0 : '3px',
            borderRightWidth: isRTL ? '3px' : 0,
            borderLeftColor: isRTL ? 'transparent' : '#F59E0B',
            borderRightColor: isRTL ? '#F59E0B' : 'transparent',
            borderStyle: 'solid',
          }}
        >
          <div className="flex gap-3">
            <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <p className="flex-1 text-[13px] text-[#92400E]" style={{ fontWeight: 400 }}>
              {isRTL 
                ? 'تحذير جوي (المركز الوطني للأرصاد): عاصفة رملية (هبوب) متوقعة الساعة 2 ظهراً. يرجى الاطلاع على القيود.'
                : 'AQI Advisory (UAE NCM): Haboob (dust storm) expected at 2:00 PM. See activity restrictions.'}
            </p>
            <button
              onClick={() => setShowWeatherAlert(false)}
              className="p-1 min-w-[44px] min-h-[44px] flex items-center justify-center -mr-2 -mt-2"
            >
              <X className="w-4 h-4 text-[#92400E]" />
            </button>
          </div>
        </div>
      )}

      {/* Content */}
      <div className="px-4 pt-6 pb-6">
        {/* Summary Stats Row */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          <div className="bg-[#FFFFFF] rounded-xl p-3 border border-[#E2E8F0] text-left">
            <Pill className="w-5 h-5 text-[#2563EB] mb-2" />
            <p className="text-2xl font-semibold text-[#0F172A]">8</p>
            <p className="text-[11px] text-[#F59E0B] mt-1" style={{ fontWeight: 500 }}>
              {isRTL ? '3 معلق' : '3 pending'}
            </p>
          </div>

          <div className="bg-[#FFFFFF] rounded-xl p-3 border border-[#E2E8F0] text-left">
            <Stethoscope className="w-5 h-5 text-[#2563EB] mb-2" />
            <p className="text-2xl font-semibold text-[#0F172A]">3</p>
            <p className="text-[11px] text-[#64748B] mt-1" style={{ fontWeight: 400 }}>
              {isRTL ? 'اليوم' : 'today'}
            </p>
          </div>

          <div className="bg-[#FFFFFF] rounded-xl p-3 border border-[#E2E8F0] text-left">
            <FileText className="w-5 h-5 text-[#2563EB] mb-2" />
            <p className="text-2xl font-semibold text-[#0F172A]">2</p>
            <p className="text-[11px] text-[#64748B] mt-1" style={{ fontWeight: 400 }}>
              {isRTL ? 'من الأهالي' : 'from parents'}
            </p>
          </div>
        </div>

        {/* Physician Queue Card */}
        {pendingPhysicianApprovals > 0 && (
          <div 
            className="mb-6 p-4 rounded-xl border border-[#E2E8F0] bg-white flex flex-col gap-3 text-left shadow-sm animate-pulse-warning"
            style={{
              borderLeftWidth: isRTL ? '1px' : '4px',
              borderRightWidth: isRTL ? '4px' : '1px',
              borderLeftColor: isRTL ? '#E2E8F0' : '#F59E0B',
              borderRightColor: isRTL ? '#F59E0B' : '#E2E8F0',
            }}
          >
            <div className="flex items-center gap-2 text-amber-800">
              <Clock className="w-5 h-5 text-amber-600" />
              <span className="text-sm font-semibold">
                {isRTL 
                  ? `⏳ بانتظار موافقة الطبيب: عدد ${pendingPhysicianApprovals} بروتوكول` 
                  : `⏳ Awaiting physician approval: ${pendingPhysicianApprovals} protocol(s)`}
              </span>
            </div>
            <p className="text-xs text-amber-700">
              {isRTL 
                ? 'لا يمكن إعطاء الأدوية بانتظار الموافقة حتى يعتمدها الطبيب المناوب.' 
                : 'Medications awaiting approval cannot be administered until reviewed and signed by the physician.'}
            </p>
            <button
              onClick={() => navigate('/nurse/medications')}
              className="w-full h-9 bg-white border border-[#F59E0B] text-[#92400E] rounded-lg text-xs font-bold hover:bg-amber-50 cursor-pointer"
            >
              {isRTL ? 'مراجعة مع الطبيب' : 'Review with Physician'}
            </button>
          </div>
        )}

        {/* Quick Actions */}
        <div className="mb-6">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[14px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
              {isRTL ? 'إجراءات سريعة' : 'Quick Actions'}
            </h2>
            <button className="text-[13px] text-[#2563EB] font-medium min-h-[44px] px-2" style={{ fontWeight: 500 }}>
              {isRTL ? 'عرض الكل' : 'See all'}
            </button>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {quickActions.map((action) => {
              const Icon = action.icon;
              const handleQuickAction = () => {
                switch (action.id) {
                  case 1: // Log Clinic Visit
                    navigate('/nurse/clinic/new-visit');
                    break;
                  case 2: // Give Medication
                    navigate('/nurse/medications/dose-confirmation');
                    break;
                  case 3: // Emergency
                    // handled by EmergencyCallButton
                    break;
                  case 4: // Send Alert
                    navigate('/nurse/cafeteria-alert');
                    break;
                }
              };

              if (action.id === 3) {
                return (
                  <EmergencyCallButton
                    key={action.id}
                    variant="danger"
                    className="h-auto py-4 min-h-[100px] flex flex-col items-center justify-center gap-1.5 text-center text-xs"
                  />
                );
              }

              return (
                <button
                  key={action.id}
                  onClick={handleQuickAction}
                  className="rounded-xl p-4 flex flex-col items-center justify-center gap-2 min-h-[100px] bg-[#FFFFFF] border border-[#E2E8F0]"
                >
                  <Icon
                    className="w-7 h-7"
                    style={{ color: action.color }}
                  />
                  <span
                    className="text-[13px] font-medium text-[#0F172A]"
                    style={{ fontWeight: 500 }}
                  >
                    {action.label}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Upcoming Doses */}
        <div className="mb-6">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[14px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
              {isRTL ? 'الجرعات القادمة' : 'Upcoming Doses'}
            </h2>
            <button
              onClick={() => navigate('/nurse/daily-doses')}
              className="text-[13px] text-[#2563EB] font-medium min-h-[44px] px-2"
              style={{ fontWeight: 500 }}
            >
              {isRTL ? 'عرض جميع الجرعات' : 'View all doses'}
            </button>
          </div>

          <div className="space-y-3">
            {upcomingDoses.map((dose) => (
              <div
                key={dose.id}
                className="bg-[#FFFFFF] rounded-xl p-3 border border-[#E2E8F0] flex items-center gap-3 min-h-[44px] text-left"
              >
                <div className="w-10 h-10 rounded-full bg-[#2563EB] flex items-center justify-center text-white text-sm font-semibold flex-shrink-0">
                  {dose.studentInitials}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[14px] font-semibold text-[#0F172A] truncate" style={{ fontWeight: 600 }}>
                    {dose.studentName}
                  </p>
                  <p className="text-[12px] text-[#64748B] truncate" style={{ fontWeight: 400 }}>
                    {dose.medication}
                  </p>
                </div>
                <div
                  className={`flex items-center gap-1 px-2 py-1 rounded-full flex-shrink-0 ${
                    dose.isUrgent
                      ? 'bg-[#FEF3C7] text-[#92400E]'
                      : 'bg-[#D1FAE5] text-[#065F46]'
                  }`}
                >
                  <Clock className="w-3 h-3" />
                  <span className="text-[11px] font-semibold" style={{ fontWeight: 600 }}>
                    {dose.doseTime}
                  </span>
                </div>
                <button 
                  onClick={() => navigate(`/nurse/medications/${dose.id}`)}
                  className="px-3 py-2 bg-[#2563EB] text-white rounded-lg text-[13px] font-semibold min-w-[60px] min-h-[44px] cursor-pointer" 
                  style={{ fontWeight: 600 }}
                >
                  {isRTL ? 'إعطاء' : 'Give'}
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Visits */}
        <div className="mb-6">
          <h2 className="text-[14px] font-medium text-[#0F172A] mb-3 text-left" style={{ fontWeight: 500 }}>
            {isRTL ? 'الزيارات الأخيرة' : 'Recent Visits'}
          </h2>

          <div className="space-y-2">
            {recentVisits.map((visit) => (
              <button
                key={visit.id}
                onClick={() => navigate('/nurse/clinic')}
                className="w-full bg-[#FFFFFF] rounded-xl p-3 border border-[#E2E8F0] flex items-center gap-3 min-h-[44px]"
              >
                <div className="flex-1 text-left">
                  <p className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
                    {visit.studentName}
                  </p>
                  <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
                    {visit.reason} • {visit.time}
                  </p>
                </div>
                <ChevronRight className={`w-5 h-5 text-[#64748B] flex-shrink-0 ${isRTL ? 'rotate-180' : ''}`} />
              </button>
            ))}
          </div>
        </div>
      </div>

    </div>
  );
}
export default NurseDashboard;