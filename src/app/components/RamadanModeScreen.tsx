// src/app/components/RamadanModeScreen.tsx
import React, { useState } from 'react';
import { Moon, CheckCircle2, ChevronRight, AlertCircle, ArrowLeft, Smartphone } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useLanguage } from '../../context/LanguageContext';

export function RamadanModeScreen() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [isRamadanActive, setIsRamadanActive] = useState(true);

  // Toggle local storage and dispatch custom event
  const toggleRamadanMode = () => {
    const nextState = !isRamadanActive;
    setIsRamadanActive(nextState);
    localStorage.setItem('sys_ramadan_active', nextState ? 'true' : 'false');
    window.dispatchEvent(new Event('ramadan_state_change'));
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col items-center justify-center p-4 select-none font-sans">
      {/* Demo Controls */}
      <div className="absolute top-4 left-4 right-4 z-50 bg-slate-800/90 backdrop-blur-md rounded-xl p-3 border border-slate-700 flex flex-col sm:flex-row gap-3 items-center justify-between shadow-xl max-w-md mx-auto">
        <div className="flex items-center gap-2">
          <Smartphone className="w-5 h-5 text-indigo-400" />
          <span className="text-xs font-semibold text-slate-300">SYS-05 Ramadan Mode Demo</span>
        </div>
        <button
          onClick={toggleRamadanMode}
          className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all active:scale-95 cursor-pointer ${
            isRamadanActive 
              ? 'bg-amber-500 hover:bg-amber-600 text-white shadow'
              : 'bg-slate-700 hover:bg-slate-600 text-slate-300'
          }`}
        >
          {isRamadanActive 
            ? (isRTL ? 'إيقاف وضع رمضان' : 'Disable Ramadan Mode')
            : (isRTL ? 'تفعيل وضع رمضان' : 'Enable Ramadan Mode')
          }
        </button>
      </div>

      {/* Simulator Viewport */}
      <div className="relative w-full max-w-[393px] h-[852px] bg-slate-800 rounded-[52px] shadow-2xl border-[12px] border-slate-950 overflow-hidden flex flex-col">
        {/* iOS Dynamic Island */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[110px] h-[30px] bg-black rounded-b-[18px] z-50 flex items-center justify-center">
          <div className="w-3 h-3 rounded-full bg-slate-900/90 ml-6" />
        </div>

        {/* Mock iOS Status Bar */}
        <div className="h-[44px] flex items-center justify-between px-6 text-white text-[13px] font-semibold select-none z-40 bg-slate-950/20">
          <span>10:45 AM</span>
          <div className="flex items-center gap-1.5">
            <svg className="w-4 h-4 fill-white" viewBox="0 0 24 24"><path d="M12 3c-4.97 0-9 4.03-9 9 0 2.12.74 4.07 1.97 5.61L4.35 19.4c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l1.9-1.9C9.13 19.57 10.5 20 12 20c4.97 0 9-4.03 9-9s-4.03-9-9-9zm0 15c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/></svg>
            <span className="text-[11px]">5G</span>
            <div className="w-[20px] h-[10px] border border-white rounded-[3px] p-[1px] flex items-center">
              <div className="w-[14px] h-[6px] bg-white rounded-[1.5px]" />
            </div>
          </div>
        </div>

        {/* Background Simulated App Screen (With Persistent Banner at Top) */}
        <div className="flex-1 flex flex-col bg-slate-50 relative overflow-hidden" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
          
          {/* Header */}
          <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0] flex-shrink-0">
            <button
              onClick={() => navigate('/')}
              className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center cursor-pointer"
            >
              <ArrowLeft className={`w-5 h-5 text-[#0F172A] ${isRTL ? 'rotate-180' : ''}`} />
            </button>
            <h1 className="flex-1 text-[17px] font-bold text-[#0F172A] text-center">
              {isRTL ? 'الوضع الرمضاني النشط' : 'Active Ramadan Mode'}
            </h1>
            <div className="w-5" />
          </div>

          {/* Active Ramadan Banner Inside Mockup (Fixed positioning simulation) */}
          {isRamadanActive && (
            <div className="mx-4 mt-4 bg-[#FFFBEB] border border-[#F59E0B] rounded-xl p-3 shadow-sm flex items-start gap-2.5 text-left">
              <div className="w-8 h-8 rounded-full bg-[#FEF3C7] flex items-center justify-center text-amber-600 flex-shrink-0 mt-0.5">
                <Moon className="w-4.5 h-4.5 fill-current" />
              </div>
              <div className="flex-1 min-w-0 space-y-0.5 text-left">
                <h4 className="text-[13px] font-bold text-[#92400E] leading-tight flex items-center gap-1">
                  <span>{isRTL ? 'رمضان كريم' : 'Ramadan Mubarak'}</span>
                  <span className="text-[10px] text-amber-500 font-medium">·</span>
                  <span className="text-xs font-semibold text-[#B45309]">{isRTL ? 'رمضان مبارك' : 'Ramadan Kareem'}</span>
                </h4>
                <p className="text-[11px] text-[#64748B] font-medium leading-normal">
                  {isRTL 
                    ? 'ساعات العمل المعدلة: 08:00 ص – 1:30 م' 
                    : 'Modified school hours: 08:00 AM – 1:30 PM'}
                </p>
                <span className="text-[11px] text-[#2563EB] font-bold hover:underline block pt-0.5">
                  {isRTL ? 'تحقق من مواقيت جرعات الأدوية' : 'Check medication dose timings'}
                </span>
              </div>
            </div>
          )}

          {/* Screen Content */}
          <div className="flex-1 overflow-y-auto p-4 space-y-4">
            <div className="bg-white rounded-xl border border-gray-200 p-4 text-left space-y-3 shadow-sm">
              <h3 className="text-sm font-bold text-gray-900 flex items-center gap-1.5">
                <Moon className="w-4.5 h-4.5 text-amber-500 fill-current" />
                {isRTL ? 'تعديلات ساعات العمل المدرسي' : 'Modified School Operations'}
              </h3>
              <p className="text-xs text-[#64748B] leading-relaxed">
                {isRTL 
                  ? 'بموجب قرارات الهيئة الاتحادية للموارد البشرية وهيئة المعرفة والتنمية البشرية في دبي، يتم تعديل ساعات العمل المدرسي اليومية لتسهيل الصيام والالتزام بالأنشطة الروحية.'
                  : 'Under regulations from the UAE Federal Authority for Government Human Resources and Dubai KHDA, daily school operational timings are compressed to support fasting.'}
              </p>
              
              <div className="p-3 bg-amber-50 rounded-lg border border-amber-100 grid grid-cols-2 gap-2 text-xs">
                <div>
                  <span className="text-[#92400E] font-semibold block">{isRTL ? 'بداية الدوام' : 'School Start'}</span>
                  <span className="font-bold text-slate-800">08:00 AM</span>
                </div>
                <div>
                  <span className="text-[#92400E] font-semibold block">{isRTL ? 'نهاية الدوام' : 'School End'}</span>
                  <span className="font-bold text-slate-800">01:30 PM</span>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-xl border border-gray-200 p-4 text-left space-y-3.5 shadow-sm">
              <h3 className="text-sm font-bold text-gray-900 flex items-center gap-1.5">
                <CheckCircle2 className="w-4.5 h-4.5 text-emerald-500" />
                {isRTL ? 'مراجعة جرعات الأدوية للممرضين' : 'Clinical Dose Review Alert'}
              </h3>
              <p className="text-xs text-[#64748B] leading-relaxed">
                {isRTL
                  ? 'يجب على الممرضة مراجعة وتعديل مواقيت جرعات الطلاب لتقع ضمن فترة ساعات العمل المدرسي المخفضة.'
                  : 'Nurses are prompted to check and adjust students\' daytime medication schedules to fall within the shortened school hours.'}
              </p>
              <button 
                onClick={() => navigate('/nurse/daily-doses')}
                className="w-full h-[40px] bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-bold cursor-pointer"
              >
                {isRTL ? 'الذهاب لجدول جرعات الأدوية اليومي' : 'Go to Daily Dose View'}
              </button>
            </div>
            
            {/* Additional info badge */}
            <div className="bg-blue-50 border border-blue-100 rounded-lg p-3 flex gap-2.5 text-left text-xs">
              <AlertCircle className="w-4.5 h-4.5 text-[#2563EB] flex-shrink-0 mt-0.5" />
              <p className="text-[#1E40AF]">
                {isRTL 
                  ? 'ملاحظة الكافتيريا: يتم إيقاف وجبات الإفطار الصباحية وتعديل خدمات الطعام لتناسب الطلاب الصائمين وغير الصائمين بشكل منفصل.'
                  : 'Cafeteria Note: Morning meal service is modified. Food preparation is adapted to accommodate fasting and non-fasting children separately.'}
              </p>
            </div>
          </div>
        </div>

        {/* Mock iOS Home Indicator */}
        <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 w-[140px] h-[5px] bg-slate-900/40 rounded-full z-50" />
      </div>

      <button
        onClick={() => navigate('/')}
        className="mt-6 text-slate-400 hover:text-white text-xs font-semibold underline underline-offset-4 flex items-center gap-1.5 cursor-pointer"
      >
        Return to Navigation Map
      </button>
    </div>
  );
}
