// src/context/LanguageContext.tsx
import React, { createContext, useContext, useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';

interface LanguageContextType {
  language: 'ar' | 'en';
  isRTL: boolean;
  toggleLanguage: () => void;
  isRebooting: boolean;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const { i18n } = useTranslation();
  const [language, setLanguage] = useState<'ar' | 'en'>(
    (localStorage.getItem('schookeep_lang') as 'ar' | 'en') ||
    (localStorage.getItem('synapse_lang') as 'ar' | 'en') || 'en'
  );
  const [isRebooting, setIsRebooting] = useState(false);

  const isRTL = language === 'ar';

  useEffect(() => {
    i18n.changeLanguage(language);
    document.documentElement.dir = isRTL ? 'rtl' : 'ltr';
    document.documentElement.lang = language;
  }, [language, isRTL, i18n]);

  const toggleLanguage = () => {
    const nextLang = language === 'en' ? 'ar' : 'en';
    setIsRebooting(true);
    
    setTimeout(() => {
      setLanguage(nextLang);
      localStorage.setItem('schookeep_lang', nextLang);
      setIsRebooting(false);
    }, 900);
  };

  return (
    <LanguageContext.Provider value={{ language, isRTL, toggleLanguage, isRebooting }}>
      {children}
      
      {/* Premium simulated device reboot overlay */}
      {isRebooting && (
        <div className="fixed inset-0 z-[9999] bg-[#0F172A] flex flex-col items-center justify-center text-white select-none animate-fade-in animate-duration-200">
          <div className="flex flex-col items-center gap-4">
            {/* Pulsing app icon */}
            <div className="w-16 h-16 bg-[#2563EB] rounded-2xl flex items-center justify-center shadow-lg shadow-[#2563EB]/40 animate-pulse">
              <span className="text-2xl font-bold tracking-wider">S</span>
            </div>
            <div className="text-center">
              <p className="text-sm font-semibold tracking-wide">
                {language === 'en' ? 'Changing language to العربية...' : 'جاري تغيير اللغة إلى الإنجليزية...'}
              </p>
              <p className="text-xs text-[#64748B] mt-1 font-medium">
                {language === 'en' ? 'Applying RTL layout configuration' : 'جاري تطبيق اتجاه التصميم'}
              </p>
            </div>
            {/* Small loading indicator */}
            <div className="w-6 h-6 border-2 border-[#64748B]/50 border-t-[#2563EB] rounded-full animate-spin mt-2" />
          </div>
        </div>
      )}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}
