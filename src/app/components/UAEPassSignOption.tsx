// src/app/components/UAEPassSignOption.tsx
import React from 'react';
import { toast } from 'sonner';
import { useLanguage } from '../../context/LanguageContext';

export function UAEPassSignOption() {
  const { isRTL } = useLanguage();

  const handleUAEPassSign = () => {
    toast.info(
      isRTL 
        ? "تكامل الهوية الرقمية (UAE Pass) قيد التطوير وسيتم تفعيله قريباً."
        : "UAE Pass integration is in progress and will be available soon.",
      {
        description: isRTL ? "مرحلة الامتثال القانوني" : "Phase 2 Compliance Integration",
        position: 'top-center',
      }
    );
  };

  return (
    <div className="w-full flex flex-col items-center py-4 border-t border-[#E2E8F0] mt-4 space-y-3">
      <div className="flex items-center gap-2 w-full">
        <div className="h-[1px] bg-[#E2E8F0] flex-1" />
        <span className="text-xs font-semibold text-[#64748B] uppercase tracking-wider">
          {isRTL ? 'أو التوقيع بواسطة' : 'Or sign with'}
        </span>
        <div className="h-[1px] bg-[#E2E8F0] flex-1" />
      </div>

      <button
        onClick={handleUAEPassSign}
        type="button"
        className="w-full h-[52px] border-2 border-[#2563EB] rounded-xl flex items-center justify-center gap-2 hover:bg-blue-50 transition-colors cursor-pointer min-h-[44px]"
      >
        {/* Stylized UAE Pass logo placeholder */}
        <div className="flex items-center gap-1.5 bg-[#0F172A] text-white px-2 py-0.5 rounded text-[10px] font-bold tracking-tight">
          <span className="text-[#06B6D4]">UAE</span>
          <span className="text-[#10B981]">PASS</span>
        </div>
        <span className="text-[14px] font-bold text-[#2563EB]">
          {isRTL ? 'التوقيع الرقمي بالهوية الرقمية' : 'Sign with UAE Pass'}
        </span>
      </button>
    </div>
  );
}
