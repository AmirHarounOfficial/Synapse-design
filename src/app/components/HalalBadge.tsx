// src/app/components/HalalBadge.tsx
import { Check } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

interface HalalBadgeProps {
  size?: 'small' | 'medium';
}

export function HalalBadge({ size = 'medium' }: HalalBadgeProps) {
  const { isRTL } = useLanguage();
  
  const heightClass = size === 'small' ? 'h-6 px-2 text-[10px]' : 'h-7 px-2.5 text-[12px]';
  const label = isRTL ? 'حلال ✓' : 'Halal ✓';

  return (
    <div 
      className={`inline-flex items-center gap-1 rounded-full bg-[#F0FDF4] border border-[#15803D] text-[#15803D] font-semibold ${heightClass}`}
      style={{ borderRadius: '100px' }}
    >
      <Check className={size === 'small' ? 'w-3 h-3' : 'w-3.5 h-3.5'} />
      <span>{label}</span>
    </div>
  );
}
