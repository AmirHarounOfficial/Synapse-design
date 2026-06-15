// src/app/components/HijriDateChip.tsx
import { toHijri } from '../../utils/dateFormatter';
import { useLanguage } from '../../context/LanguageContext';

interface HijriDateChipProps {
  date: Date | string;
}

export function HijriDateChip({ date }: HijriDateChipProps) {
  const { language } = useLanguage();
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  
  if (!date || isNaN(dateObj.getTime())) {
    return null;
  }
  
  const hijriStr = toHijri(dateObj, language);
  
  return (
    <span 
      className="inline-flex items-center px-2 py-1 rounded bg-[#F8FAFC] border border-[#E2E8F0] text-[#64748B] text-[11px] font-medium"
      style={{ borderRadius: '100px' }}
    >
      {hijriStr}
    </span>
  );
}
