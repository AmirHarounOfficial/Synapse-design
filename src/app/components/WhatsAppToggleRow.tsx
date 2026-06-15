// src/app/components/WhatsAppToggleRow.tsx
import React from 'react';
import { useLanguage } from '../../context/LanguageContext';

interface WhatsAppToggleRowProps {
  label?: string;
  checked: boolean;
  onChange: (checked: boolean) => void;
  disabled?: boolean;
}

export function WhatsAppToggleRow({ 
  label = "WhatsApp", 
  checked, 
  onChange, 
  disabled = false 
}: WhatsAppToggleRowProps) {
  const { isRTL } = useLanguage();

  return (
    <div className={`flex items-center justify-between py-3 ${disabled ? 'opacity-60' : ''}`}>
      <div className="flex items-center gap-3">
        {/* WhatsApp Green SVG Logo */}
        <div className="w-[24px] h-[24px] flex items-center justify-center bg-[#25D366] rounded-full flex-shrink-0 text-white p-[4px]">
          <svg viewBox="0 0 24 24" className="w-full h-full fill-current">
            <path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946C.06 5.348 5.397.01 12.008.01c3.202.001 6.212 1.246 8.477 3.514 2.266 2.268 3.507 5.28 3.505 8.484-.004 6.657-5.34 11.997-11.953 11.997-2.005-.001-3.973-.502-5.717-1.458L0 24zm6.59-4.846c1.6.95 3.188 1.449 4.825 1.451 5.436 0 9.86-4.413 9.863-9.847.001-2.63-1.02-5.101-2.877-6.958C16.6 1.983 14.129 1.012 11.5 1.01c-5.437 0-9.863 4.414-9.866 9.849-.001 2.03.535 4.022 1.554 5.761l-.993 3.628 3.725-.976.137.082zM17.65 14.39c-.31-.154-1.834-.903-2.119-1.006-.285-.102-.492-.154-.699.155-.207.31-.8.1.9-.155-.1.207-.31.31-.62.155-.31-.154-1.314-.484-2.502-1.543-.925-.824-1.55-1.841-1.732-2.148-.182-.31-.02-.477.136-.631.14-.14.31-.36.465-.54.156-.182.207-.31.31-.518.104-.207.052-.389-.026-.543-.078-.154-.7-.1-.958-1.102-.25-.615-.496-1.5-.68-1.56-.162-.054-.347-.059-.533-.059-.187 0-.492.07-.75.36-.258.282-.984.962-.984 2.346 0 1.383 1.007 2.72 1.147 2.91.14.19 1.98 3.027 4.8 4.242.671.29 1.196.463 1.603.593.675.215 1.29.185 1.774.113.54-.08 1.835-.75 2.09-1.472.257-.721.257-1.341.182-1.472-.076-.13-.286-.207-.597-.361z" />
          </svg>
        </div>
        
        <div className="flex flex-col">
          <span className="text-[14px] font-semibold text-[#0F172A]">{label}</span>
          {/* UAE recommended badge */}
          <div className="flex mt-1">
            <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded bg-[#ECFEFF] text-[10px] font-semibold text-[#0E7490]">
              <span>🇦🇪</span> {isRTL ? 'موصى به للإمارات' : 'Recommended for UAE'}
            </span>
          </div>
        </div>
      </div>

      <button
        onClick={() => !disabled && onChange(!checked)}
        disabled={disabled}
        className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
          checked ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
        } ${disabled ? 'cursor-not-allowed opacity-50' : 'cursor-pointer'}`}
      >
        <div 
          className={`w-4 h-4 bg-white rounded-full transition-transform ${
            checked ? (isRTL ? '-translate-x-5' : 'translate-x-5') : ''
          }`} 
        />
      </button>
    </div>
  );
}
