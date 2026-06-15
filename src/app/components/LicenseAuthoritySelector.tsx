// src/app/components/LicenseAuthoritySelector.tsx
import React, { useEffect } from 'react';
import { uaeTokens } from '../../tokens/uae';
import { useLanguage } from '../../context/LanguageContext';

interface LicenseAuthoritySelectorProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  value: string;
  onChangeValue: (value: string) => void;
  schoolEmirate?: string;
  label?: string;
}

export function LicenseAuthoritySelector({
  value,
  onChangeValue,
  schoolEmirate = 'Dubai',
  label,
  className = '',
  ...props
}: LicenseAuthoritySelectorProps) {
  const { isRTL } = useLanguage();

  // Auto-select based on school's configured emirate
  useEffect(() => {
    if (!value && schoolEmirate) {
      const formattedEmirate = schoolEmirate.trim().toLowerCase();
      if (formattedEmirate === 'dubai') {
        onChangeValue('DHA');
      } else if (formattedEmirate === 'abu dhabi') {
        onChangeValue('DoH Abu Dhabi');
      } else {
        onChangeValue('MOHAP');
      }
    }
  }, [schoolEmirate, value, onChangeValue]);

  const defaultLabel = label || (isRTL ? 'هيئة الترخيص الطبي' : 'Medical License Authority');

  // Compliance message mapping
  const getComplianceNote = (authority: string) => {
    if (isRTL) {
      return `يجب أن يحمل هذا الموظف ترخيصًا ساريًا من [${authority}] لإجراء الفحوصات والإجراءات الطبية في المدارس.`;
    }
    return `This staff member must hold a valid [${authority}] license to perform clinical actions in schools.`;
  };

  return (
    <div className="flex flex-col gap-1.5 w-full text-left">
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
          {uaeTokens.licenseAuthorities.map((auth) => (
            <option key={auth} value={auth}>
              {auth}
            </option>
          ))}
        </select>
        <div className={`absolute top-1/2 -translate-y-1/2 pointer-events-none flex items-center justify-center text-[#64748B] ${
          isRTL ? 'left-4' : 'right-4'
        }`}>
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
          </svg>
        </div>
      </div>
      {value && (
        <span className="text-[11px] font-medium text-[#B45309] bg-[#FFFBEB] px-3 py-1.5 rounded-md border border-[#FDE68A] mt-1 block">
          {getComplianceNote(value)}
        </span>
      )}
    </div>
  );
}
