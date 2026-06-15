// src/app/components/RamadanBanner.tsx
import React, { useState, useEffect } from 'react';
import { Moon, X } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { router } from '../routes';

export function RamadanBanner() {
  const { isRTL } = useLanguage();
  const [isActive, setIsActive] = useState(false);
  const [isDismissed, setIsDismissed] = useState(false);
  const [currentPath, setCurrentPath] = useState(router.state.location.pathname);

  useEffect(() => {
    // Check if Ramadan Mode is enabled in localStorage (controlled by the simulator)
    const checkRamadan = () => {
      const active = localStorage.getItem('sys_ramadan_active') === 'true';
      setIsActive(active);
    };

    checkRamadan();

    // Subscribe to router state changes to track the current pathname
    const unsubscribe = router.subscribe((state) => {
      setCurrentPath(state.location.pathname);
    });

    // Listen for storage changes or context update
    window.addEventListener('storage', checkRamadan);
    window.addEventListener('ramadan_state_change', checkRamadan);

    return () => {
      unsubscribe();
      window.removeEventListener('storage', checkRamadan);
      window.removeEventListener('ramadan_state_change', checkRamadan);
    };
  }, []);

  // Don't show anything if Ramadan mode is not active globally
  if (!isActive) return null;

  // Don't show the banner on login, verify, biometric, splash, or simulator dashboard itself
  const hiddenPaths = ['/login', '/verify', '/biometric', '/splash', '/system/simulator', '/', '/system/ramadan'];
  if (hiddenPaths.includes(currentPath)) return null;

  if (isDismissed) {
    // Collapsed crescent moon pill in the corner (bottom-left or bottom-right based on RTL)
    return (
      <button
        onClick={() => setIsDismissed(false)}
        className={`fixed bottom-24 z-50 w-10 h-10 bg-amber-500 hover:bg-amber-600 text-white rounded-full flex items-center justify-center shadow-lg cursor-pointer transition-transform hover:scale-105 active:scale-95 ${
          isRTL ? 'left-4' : 'right-4'
        }`}
        aria-label="Expand Ramadan Info"
      >
        <Moon className="w-5 h-5 fill-current" />
      </button>
    );
  }

  return (
    <div 
      className={`fixed top-14 left-1/2 -translate-x-1/2 z-[999] w-[calc(100%-32px)] max-w-[361px] bg-[#FFFBEB] border border-[#F59E0B] rounded-xl p-3 shadow-md flex items-center justify-between text-left animate-slide-down`}
      style={{ direction: isRTL ? 'rtl' : 'ltr' }}
    >
      <div className="flex items-start gap-2.5 min-w-0 flex-1">
        {/* Moon Icon */}
        <div className="w-8 h-8 rounded-full bg-[#FEF3C7] flex items-center justify-center text-amber-600 flex-shrink-0 mt-0.5">
          <Moon className="w-4.5 h-4.5 fill-current" />
        </div>

        {/* Content Column */}
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
          <button
            onClick={() => router.navigate('/nurse/daily-doses')}
            className="text-[11px] text-[#2563EB] font-bold hover:underline block cursor-pointer pt-0.5 text-left bg-transparent border-none p-0"
          >
            {isRTL ? 'تحقق من مواقيت جرعات الأدوية' : 'Check medication dose timings'}
          </button>
        </div>
      </div>

      {/* Dismiss Button */}
      <button
        onClick={() => setIsDismissed(true)}
        className="w-[44px] h-[44px] flex items-center justify-center -mr-2 text-slate-400 hover:text-slate-600 transition-colors cursor-pointer"
        aria-label="Dismiss banner"
      >
        <X className="w-4 h-4" />
      </button>
    </div>
  );
}

