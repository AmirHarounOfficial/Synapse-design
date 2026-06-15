// src/app/components/EmirateSelector.tsx
import React from 'react';
import { uaeTokens } from '../../tokens/uae';
import { useLanguage } from '../../context/LanguageContext';

interface EmirateSelectorProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  value: string;
  onChangeValue: (value: string) => void;
  label?: string;
}

export function EmirateSelector({ 
  value, 
  onChangeValue, 
  label, 
  className = '', 
  ...props 
}: EmirateSelectorProps) {
  const { isRTL } = useLanguage();
  
  const defaultLabel = label || (isRTL ? 'الإمارة' : 'Emirate');

  return (
    <div className="flex flex-col gap-1 w-full text-left">
      <label className="text-[13px] font-medium text-[#64748B] w-full block">
        {defaultLabel}
      </label>
      <div className="relative w-full">
        <select
          value={value}
          onChange={(e) => onChangeValue(e.target.value)}
          className={`w-full h-[52px] px-4 pr-10 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB] appearance-none transition-all cursor-pointer ${className}`}
          style={{ direction: isRTL ? 'rtl' : 'ltr' }}
          {...props}
        >
          <option value="" className="text-gray-400">
            {isRTL ? '-- اختر الإمارة --' : '-- Select Emirate --'}
          </option>
          {uaeTokens.emirates.map((item) => (
            <option key={item.en} value={item.en}>
              {item.en} · {item.ar}
            </option>
          ))}
        </select>
        {/* Dropdown Chevron arrow indicator */}
        <div className={`absolute top-1/2 -translate-y-1/2 pointer-events-none flex items-center justify-center text-[#64748B] ${
          isRTL ? 'left-4' : 'right-4'
        }`}>
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
          </svg>
        </div>
      </div>
    </div>
  );
}
