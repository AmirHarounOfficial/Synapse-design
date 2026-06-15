// src/app/components/PhysicianDashboard.tsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { useLanguage } from '../../context/LanguageContext';
import { Calendar, AlertTriangle, FileText, CheckCircle, ChevronRight, User } from 'lucide-react';
import { formatGregorian } from '../../utils/dateFormatter';

export function PhysicianDashboard() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();

  // Mock settings (shared state simulation)
  const physicianName = isRTL ? "أحمد الأنصاري" : "Amina Al-Hashimi";
  
  // 7 days of the week schedule configuration
  const daysOfWeek = isRTL 
    ? ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س']
    : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  const activeDays = [1, 2, 4]; // Monday, Tuesday, Thursday

  const [isOnSite, setIsOnSite] = useState(true);

  // Queue counts and lists
  const pendingProtocols = [
    { id: '1', studentName: 'Emma Rodriguez', grade: '3rd Grade', room: 'Room 204', medication: 'Albuterol Inhaler 90mcg', dose: '2 puffs', proposedBy: 'Nurse Smith RN-4521', date: '15/06/2026' },
    { id: '2', studentName: 'Marcus Chen', grade: '5th Grade', room: 'Room 105', medication: 'Ritalin 10mg', dose: '1 tablet', proposedBy: 'Nurse Smith RN-4521', date: '15/06/2026' }
  ];

  const activeEscalations = [
    { id: '1', studentName: 'Sarah Williams', grade: '2nd Grade', severity: 'Critical', issue: 'Severe allergic reaction / difficulty breathing', timeElapsed: '4 min ago', urgent: true }
  ];

  const pendingReports = [
    { id: '1', title: 'Monthly Clinical Immunization Summary', dateRange: '01/05/2026 - 31/05/2026', nurse: 'Nurse Smith RN-4521' }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[100px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* iOS status bar spacer */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-[#E2E8F0] sticky top-0 z-40">
        <div className="flex items-center gap-2">
          <div 
            onClick={() => navigate('/physician/settings')}
            className="w-10 h-10 rounded-full bg-[#0D9488]/10 flex items-center justify-center text-[#0D9488] font-bold cursor-pointer"
          >
            {isRTL ? 'د' : 'DR'}
          </div>
          <div className="flex flex-col text-left">
            <span className="text-[15px] font-bold text-[#0F172A]">
              {isRTL ? `د. ${physicianName}` : `Dr. ${physicianName}`}
            </span>
            <span className="text-[11px] text-[#64748B]">
              {isRTL ? 'طبيب المدرسة المناوب' : 'School Physician on Duty'}
            </span>
          </div>
        </div>
        <button 
          onClick={() => navigate('/physician/settings')}
          className="p-1 hover:bg-gray-50 rounded-full"
        >
          <User className="w-5 h-5 text-[#64748B]" />
        </button>
      </header>

      {/* Main Content */}
      <div className="px-4 py-4 space-y-4">
        {/* On-Site Status Card */}
        <div className="bg-white rounded-2xl border border-[#E2E8F0] p-4 shadow-sm">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[13px] font-bold text-[#0F172A]">
              {isRTL ? 'جدول الدوام الأسبوعي' : 'Weekly On-Site Schedule'}
            </span>
            <button 
              onClick={() => navigate('/physician/schedule')}
              className="text-xs text-[#0D9488] font-semibold hover:underline"
            >
              {isRTL ? 'تعديل الجدول' : 'Manage Schedule'}
            </button>
          </div>

          {/* Days Grid */}
          <div className="flex justify-between items-center mb-4">
            {daysOfWeek.map((day, idx) => {
              const isActive = activeDays.includes(idx);
              const isToday = idx === 1; // Simulated "Monday"
              return (
                <div 
                  key={idx}
                  className={`w-9 h-9 rounded-xl flex items-center justify-center font-bold text-xs ${
                    isActive 
                      ? 'bg-[#0D9488] text-white' 
                      : 'bg-[#F1F5F9] text-[#64748B]'
                  } ${isToday ? 'ring-2 ring-offset-2 ring-[#0D9488]' : ''}`}
                >
                  {day}
                </div>
              );
            })}
          </div>

          {/* Status Chip Info */}
          <div className="flex items-center justify-between p-3 bg-[#F8FAFC] rounded-xl border border-[#E2E8F0]">
            <div className="flex items-center gap-2">
              <div className={`w-2.5 h-2.5 rounded-full ${isOnSite ? 'bg-emerald-500' : 'bg-amber-500'}`} />
              <span className="text-xs font-semibold text-[#0F172A]">
                {isOnSite 
                  ? (isRTL ? 'متواجد بالمدرسة · حتى 3:00 م' : 'On-site · Until 3:00 PM')
                  : (isRTL ? 'تحت الطلب: +971 50 123 4567' : 'On-call: +971 50 123 4567')}
              </span>
            </div>
            
            {/* Quick Duty Toggle */}
            <button 
              onClick={() => setIsOnSite(!isOnSite)}
              className="text-[11px] font-bold px-2.5 py-1 bg-white border border-[#E2E8F0] rounded-md text-[#0D9488]"
            >
              {isRTL ? 'تغيير الحالة' : 'Toggle State'}
            </button>
          </div>
        </div>

        {/* Emergency Escalations Queue */}
        <section className="space-y-2.5">
          <div className="flex items-center justify-between">
            <h3 className="text-[14px] font-bold text-[#DC2626] flex items-center gap-1.5">
              <AlertTriangle className="w-4 h-4" />
              <span>{isRTL ? 'الحالات الحرجة والتصعيدات' : 'Emergency Escalations'}</span>
            </h3>
            <span className="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full font-bold">
              {activeEscalations.length}
            </span>
          </div>

          <div className="space-y-3">
            {activeEscalations.map((esc) => (
              <div 
                key={esc.id}
                onClick={() => navigate('/physician/escalations')}
                className="bg-white border-2 border-[#DC2626] rounded-2xl p-4 shadow-sm hover:bg-red-50/20 transition-all cursor-pointer flex justify-between items-start"
              >
                <div className="space-y-1 text-left">
                  <div className="flex items-center gap-2">
                    <span className="text-[15px] font-bold text-[#0F172A]">{esc.studentName}</span>
                    <span className="text-[10px] bg-[#DC2626] text-white px-2 py-0.5 rounded-full font-bold">
                      {isRTL ? 'حالة حرجة' : 'CRITICAL'}
                    </span>
                  </div>
                  <p className="text-xs text-[#64748B]">{esc.grade}</p>
                  <p className="text-xs font-semibold text-[#DC2626]">{esc.issue}</p>
                </div>
                <div className="flex flex-col items-end gap-1.5">
                  <span className="text-[10px] text-red-600 bg-red-50 border border-red-200 px-2 py-0.5 rounded-md font-bold">
                    {esc.timeElapsed}
                  </span>
                  <ChevronRight className="w-5 h-5 text-[#64748B]" />
                </div>
              </div>
            ))}
            {activeEscalations.length === 0 && (
              <div className="bg-white border border-[#E2E8F0] rounded-xl p-4 text-center text-xs text-[#64748B]">
                {isRTL ? 'لا توجد تصعيدات نشطة حالياً' : 'No active clinical escalations.'}
              </div>
            )}
          </div>
        </section>

        {/* Review Queue Section */}
        <section className="space-y-2.5">
          <div className="flex items-center justify-between">
            <h3 className="text-[14px] font-bold text-[#0F172A]">
              {isRTL ? 'طلبات الموافقة على الأدوية' : 'Pending Protocol Approvals'}
            </h3>
            <span className="text-xs bg-[#0D9488]/10 text-[#0D9488] px-2 py-0.5 rounded-full font-bold">
              {pendingProtocols.length}
            </span>
          </div>

          <div className="space-y-3">
            {pendingProtocols.map((protocol) => (
              <div 
                key={protocol.id}
                onClick={() => navigate(`/physician/medication-review/${protocol.id}`)}
                className="bg-white border border-[#E2E8F0] rounded-xl p-4 shadow-sm hover:border-[#0D9488] transition-all cursor-pointer flex justify-between items-center"
              >
                <div className="space-y-1 text-left">
                  <span className="text-[14px] font-bold text-[#0F172A] block">{protocol.studentName}</span>
                  <div className="text-[12px] text-[#64748B]">
                    <span>{protocol.medication}</span> · <span className="font-semibold">{protocol.dose}</span>
                  </div>
                  <p className="text-[10px] text-[#64748B]">
                    {isRTL ? `مقدم من: ${protocol.proposedBy}` : `Proposed by: ${protocol.proposedBy}`}
                  </p>
                </div>
                <div className="flex items-center gap-1">
                  <span className="text-[11px] font-bold text-[#0D9488] bg-[#0D9488]/5 px-2.5 py-1 rounded-lg">
                    {isRTL ? 'مراجعة' : 'Review'}
                  </span>
                  <ChevronRight className="w-5 h-5 text-[#64748B]" />
                </div>
              </div>
            ))}
            {pendingProtocols.length === 0 && (
              <div className="bg-white border border-[#E2E8F0] rounded-xl p-6 text-center text-xs text-[#64748B] flex flex-col items-center gap-2">
                <CheckCircle className="w-8 h-8 text-emerald-500" />
                <span>{isRTL ? 'لا توجد بروتوكولات بانتظار المراجعة' : 'No protocols pending review.'}</span>
              </div>
            )}
          </div>
        </section>

        {/* Reports to Co-Sign Section */}
        <section className="space-y-2.5">
          <h3 className="text-[14px] font-bold text-[#0F172A] text-left">
            {isRTL ? 'تقارير بانتظار التوقيع المشترك' : 'Reports Awaiting Co-Signature'}
          </h3>

          <div className="space-y-3">
            {pendingReports.map((rep) => (
              <div 
                key={rep.id}
                onClick={() => navigate(`/physician/co-sign/${rep.id}`)}
                className="bg-white border border-[#E2E8F0] rounded-xl p-4 shadow-sm hover:border-[#0D9488] transition-all cursor-pointer flex justify-between items-center"
              >
                <div className="flex items-start gap-3 text-left">
                  <div className="w-10 h-10 rounded-lg bg-slate-100 flex items-center justify-center text-[#64748B]">
                    <FileText className="w-5 h-5" />
                  </div>
                  <div className="space-y-0.5">
                    <span className="text-[14px] font-bold text-[#0F172A] block line-clamp-1">{rep.title}</span>
                    <span className="text-[12px] text-[#64748B] block">{rep.dateRange}</span>
                    <span className="text-[10px] text-[#64748B] block">{isRTL ? `إعداد الممرضة: ${rep.nurse}` : `Nurse: ${rep.nurse}`}</span>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-[#64748B]" />
              </div>
            ))}
            {pendingReports.length === 0 && (
              <div className="bg-white border border-[#E2E8F0] rounded-xl p-4 text-center text-xs text-[#64748B]">
                {isRTL ? 'لا توجد تقارير بانتظار التوقيع' : 'No reports pending co-signature.'}
              </div>
            )}
          </div>
        </section>
      </div>
    </div>
  );
}
export default PhysicianDashboard;
