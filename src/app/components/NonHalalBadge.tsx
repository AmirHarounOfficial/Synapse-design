// src/app/components/NonHalalBadge.tsx
import { AlertTriangle } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

interface NonHalalBadgeProps {
  size?: 'small' | 'medium';
}

export function NonHalalBadge({ size = 'medium' }: NonHalalBadgeProps) {
  const { isRTL } = useLanguage();
  
  const heightClass = size === 'small' ? 'h-6 px-2 text-[10px]' : 'h-7 px-2.5 text-[12px]';
  const label = isRTL ? 'غير حلال ⚠' : 'Non-Halal ⚠';

  return (
    <div 
      className={`inline-flex items-center gap-1 rounded-full bg-[#FEF2F2] border border-[#DC2626] text-[#DC2626] font-semibold ${heightClass}`}
      style={{ borderRadius: '100px' }}
    >
      <AlertTriangle className={size === 'small' ? 'w-3 h-3' : 'w-3.5 h-3.5'} />
      <span>{label}</span>
    </div>
  );
}
