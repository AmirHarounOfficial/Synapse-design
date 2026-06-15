// src/app/components/PhysicianScheduleConfig.tsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronLeft, Info, Check, Plus, AlertCircle, Phone, Save } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { validateUAEPhone, formatUAEPhone } from '../../utils/phoneValidator';
import { toast } from 'sonner';

interface TimeConfig {
  start: string;
  end: string;
}

export function PhysicianScheduleConfig() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();

  const daysLabels = isRTL 
    ? ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت']
    : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  const daysShort = isRTL 
    ? ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س']
    : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // State
  const [selectedDays, setSelectedDays] = useState<number[]>([1, 2, 4]); // Monday, Tuesday, Thursday
  const [times, setTimes] = useState<Record<number, TimeConfig>>({
    1: { start: '08:00 AM', end: '03:00 PM' },
    2: { start: '08:00 AM', end: '03:00 PM' },
    4: { start: '08:00 AM', end: '03:00 PM' }
  });

  const [onCallPhone, setOnCallPhone] = useState('+971 50 123 4567');
  const [onCallStart, setOnCallStart] = useState('03:00 PM');
  const [onCallEnd, setOnCallEnd] = useState('09:00 PM');

  const [backupName, setBackupName] = useState('Dr. Tariq Al-Mansoori');
  const [backupLicense, setBackupLicense] = useState('DHA MD-4982');
  const [backupPhone, setBackupPhone] = useState('+971 55 987 6543');

  const handleDayToggle = (idx: number) => {
    setSelectedDays(prev => {
      const nextDays = prev.includes(idx) 
        ? prev.filter(d => d !== idx)
        : [...prev, idx].sort((a,b) => a-b);
      
      // If adding, initialize default times
      if (!prev.includes(idx)) {
        setTimes(t => ({
          ...t,
          [idx]: { start: '08:00 AM', end: '03:00 PM' }
        }));
      }
      return nextDays;
    });
  };

  const handleTimeChange = (dayIdx: number, field: 'start' | 'end', val: string) => {
    setTimes(prev => ({
      ...prev,
      [dayIdx]: {
        ...prev[dayIdx],
        [field]: val
      }
    }));
  };

  const handlePhoneChange = (val: string, setter: (v: string) => void) => {
    setter(formatUAEPhone(val));
  };

  const handleSave = () => {
    // DHA check: Minimum 3 on-site days
    if (selectedDays.length < 3) {
      toast.error(
        isRTL
          ? "تنبيه هيئة الصحة: يجب تحديد 3 أيام دوام في الموقع كحد أدنى أسبوعياً."
          : "DHA Compliance Alert: A minimum of 3 on-site days per week is required.",
        {
          position: 'top-center',
          duration: 4000
        }
      );
      return;
    }

    // Phone checks
    if (!validateUAEPhone(onCallPhone)) {
      toast.error(isRTL ? "رقم هاتف المناوبة غير صالح" : "Invalid On-call phone format.");
      return;
    }
    if (backupPhone && !validateUAEPhone(backupPhone)) {
      toast.error(isRTL ? "رقم هاتف الطبيب البديل غير صالح" : "Invalid Backup physician phone format.");
      return;
    }

    toast.success(
      isRTL 
        ? "تم حفظ الجدول الزمني بنجاح والتحقق من الامتثال" 
        : "Schedule saved successfully! DHA compliance verified."
    );

    setTimeout(() => {
      navigate('/physician/dashboard');
    }, 1500);
  };

  const daysCount = selectedDays.length;
  const isDhaCompliant = daysCount >= 3;

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
            {isRTL ? 'جدول المواعيد والدوام' : 'My Schedule'}
          </h1>
          <p className="text-[11px] text-[#64748B]">
            {isRTL ? 'تكوين وضبط الحضور' : 'Configure Duty Settings'}
          </p>
        </div>
      </header>

      {/* Form area */}
      <div className="px-4 py-4 space-y-5 text-left">
        
        {/* On-site Day Selector Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
          <div className="space-y-1">
            <span className="block text-[13px] font-bold text-gray-900">
              {isRTL ? 'أيام التواجد في العيادة (في الموقع)' : 'On-Site Clinic Days'}
            </span>
            <p className="text-[11px] text-[#64748B]">
              {isRTL 
                ? 'حدد الأيام التي ستتواجد فيها عيادياً داخل حرم المدرسة.'
                : 'Select the weekdays you are physically present in the school clinic.'}
            </p>
          </div>

          {/* Days buttons row */}
          <div className="flex justify-between items-center gap-1.5">
            {daysShort.map((day, idx) => {
              const isSelected = selectedDays.includes(idx);
              return (
                <button
                  key={idx}
                  type="button"
                  onClick={() => handleDayToggle(idx)}
                  className={`w-10 h-10 rounded-xl font-bold text-xs transition-colors flex items-center justify-center cursor-pointer min-h-[44px] ${
                    isSelected 
                      ? 'bg-[#0D9488] text-white shadow-sm' 
                      : 'bg-[#F1F5F9] text-[#64748B] hover:bg-[#E2E8F0]'
                  }`}
                >
                  {day}
                </button>
              );
            })}
          </div>

          {/* Compliance note / count */}
          <div className="space-y-2.5">
            <div className="flex items-center justify-between">
              <span className="text-[11px] text-[#64748B]">
                {isRTL ? 'الأيام المحددة:' : 'Selected Days:'}
              </span>
              <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold ${
                isDhaCompliant 
                  ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                  : 'bg-amber-50 text-amber-700 border border-amber-200'
              }`}>
                {isDhaCompliant ? <Check className="w-3.5 h-3.5" /> : <AlertCircle className="w-3.5 h-3.5" />}
                {isRTL ? `${daysCount} من 7 أيام دوام` : `${daysCount} of 7 selected`}
              </span>
            </div>
            
            <div className="bg-[#FFFBEB] border border-[#FDE68A] p-2.5 rounded-lg text-[11px] text-[#B45309] leading-relaxed">
              {isRTL 
                ? '⚠ تشترط هيئة الصحة بدبي (DHA) وجود طبيب المدرسة في الموقع 3 أيام أسبوعياً كحد أدنى.'
                : 'DHA Compliance: School physicians must configure a minimum of 3 on-site days weekly.'}
            </div>
          </div>
        </div>

        {/* Per-day times configuration list */}
        {selectedDays.length > 0 && (
          <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
            <span className="block text-[13px] font-bold text-gray-900 mb-1">
              {isRTL ? 'ساعات دوام العيادة اليومي' : 'Daily Clinic Work Hours'}
            </span>
            
            <div className="space-y-3.5">
              {selectedDays.map((dayIdx) => {
                const config = times[dayIdx] || { start: '08:00 AM', end: '03:00 PM' };
                return (
                  <div key={dayIdx} className="flex items-center gap-4 justify-between border-b border-gray-50 pb-3 last:border-0 last:pb-0">
                    <span className="text-xs font-bold text-gray-950 w-24">
                      {daysLabels[dayIdx]}
                    </span>
                    <div className="flex items-center gap-2 flex-1 max-w-[200px]">
                      <input 
                        type="text" 
                        value={config.start}
                        onChange={(e) => handleTimeChange(dayIdx, 'start', e.target.value)}
                        className="w-full text-center h-9 px-2 border border-gray-200 rounded-lg text-xs bg-white text-[#0f172a]"
                      />
                      <span className="text-[#64748B] text-xs font-bold">{isRTL ? 'إلى' : 'to'}</span>
                      <input 
                        type="text" 
                        value={config.end}
                        onChange={(e) => handleTimeChange(dayIdx, 'end', e.target.value)}
                        className="w-full text-center h-9 px-2 border border-gray-200 rounded-lg text-xs bg-white text-[#0f172a]"
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* On-call Configuration section */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
          <span className="block text-[13px] font-bold text-gray-900">
            {isRTL ? 'ساعات التغطية تحت الطلب (الطوارئ)' : 'Emergency On-Call Details'}
          </span>

          <div className="space-y-3">
            <div>
              <label className="block text-xs font-semibold text-[#64748B] mb-1">
                {isRTL ? 'رقم هاتف الطوارئ تحت الطلب' : 'On-Call Contact Phone'}
              </label>
              <div className="relative">
                <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#64748B]" />
                <input 
                  type="text" 
                  value={onCallPhone}
                  onChange={(e) => handlePhoneChange(e.target.value, setOnCallPhone)}
                  className="w-full h-11 pl-10 pr-4 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a] focus:outline-none focus:border-[#0D9488]"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-[#64748B] mb-1">{isRTL ? 'بدء التغطية' : 'Start Time'}</label>
                <input 
                  type="text" 
                  value={onCallStart}
                  onChange={(e) => setOnCallStart(e.target.value)}
                  className="w-full h-11 px-3 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a]"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-[#64748B] mb-1">{isRTL ? 'نهاية التغطية' : 'End Time'}</label>
                <input 
                  type="text" 
                  value={onCallEnd}
                  onChange={(e) => setOnCallEnd(e.target.value)}
                  className="w-full h-11 px-3 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a]"
                />
              </div>
            </div>
            
            <div className="bg-[#FFFBEB] border border-[#FDE68A] p-2.5 rounded-lg text-[11px] text-[#B45309] flex items-start gap-1.5 leading-relaxed">
              <Info className="w-4 h-4 text-[#D97706] flex-shrink-0 mt-0.5" />
              <span>
                {isRTL 
                  ? 'يجب الرد على جميع تصعيدات الحالات الحرجة خلال 10 دقائق بموجب شروط الترخيص ولا يمكن تعديل هذه الاتفاقية.'
                  : 'Critical Response SLA: Must respond to clinical dispatches within 10 minutes (Locked DHA requirement).'}
              </span>
            </div>
          </div>
        </div>

        {/* Backup Physician credentials */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
          <span className="block text-[13px] font-bold text-gray-900">
            {isRTL ? 'الطبيب البديل (لتغطية الإجازات)' : 'Backup Coverage Physician'}
          </span>

          <div className="space-y-3">
            <div>
              <label className="block text-xs font-semibold text-[#64748B] mb-1">{isRTL ? 'اسم الطبيب البديل' : 'Physician Name'}</label>
              <input 
                type="text" 
                value={backupName}
                onChange={(e) => setBackupName(e.target.value)}
                className="w-full h-11 px-3 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a]"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-[#64748B] mb-1">{isRTL ? 'رقم الترخيص الطبي' : 'License Number'}</label>
                <input 
                  type="text" 
                  value={backupLicense}
                  onChange={(e) => setBackupLicense(e.target.value)}
                  className="w-full h-11 px-3 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a]"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-[#64748B] mb-1">{isRTL ? 'رقم الهاتف البديل' : 'Backup Phone'}</label>
                <input 
                  type="text" 
                  value={backupPhone}
                  onChange={(e) => handlePhoneChange(e.target.value, setBackupPhone)}
                  className="w-full h-11 px-3 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a]"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Primary Save CTA */}
        <button
          onClick={handleSave}
          className="w-full h-[52px] bg-[#0D9488] hover:bg-[#0B7A70] text-white rounded-xl font-bold text-[15px] flex items-center justify-center gap-2 cursor-pointer shadow-md mt-2"
        >
          <Save className="w-5 h-5" />
          {isRTL ? 'حفظ جدول الدوام والالتزام' : 'Save Duty Schedule'}
        </button>
      </div>
    </div>
  );
}
export default PhysicianScheduleConfig;
