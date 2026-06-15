// src/app/components/EmergencyCallButton.tsx
import React from 'react';
import { PhoneCall } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { uaeTokens } from '../../tokens/uae';

interface EmergencyCallButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'danger' | 'outline';
}

export function EmergencyCallButton({ variant = 'danger', className = '', ...props }: EmergencyCallButtonProps) {
  const { isRTL } = useLanguage();

  const handleCall = () => {
    // In real app: window.location.href = `tel:${uaeTokens.ambulanceNumber}`;
    alert(
      isRTL 
        ? `اتصال بالطوارئ: جارٍ الاتصال بالإسعاف على الرقم ${uaeTokens.ambulanceNumber}...`
        : `Calling Emergency: Dialing Ambulance at ${uaeTokens.ambulanceNumber}...`
    );
  };

  const label = isRTL 
    ? `طوارئ · اتصل بالإسعاف ${uaeTokens.ambulanceNumber}`
    : `Emergency · Call Ambulance ${uaeTokens.ambulanceNumber}`;

  const buttonStyle = variant === 'danger' 
    ? 'bg-[#DC2626] hover:bg-[#B91C1C] text-white shadow-md shadow-red-200' 
    : 'bg-white hover:bg-red-50 text-[#DC2626] border-2 border-[#DC2626]';

  return (
    <button
      onClick={handleCall}
      type="button"
      className={`w-full h-[52px] rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all active:scale-[0.98] cursor-pointer min-h-[44px] ${buttonStyle} ${className}`}
      {...props}
    >
      <PhoneCall className="w-5 h-5 flex-shrink-0 animate-bounce" />
      <span>{label}</span>
    </button>
  );
}
