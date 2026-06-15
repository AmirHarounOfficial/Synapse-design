// src/app/components/PhysicianApprovalCard.tsx
import React, { useState } from 'react';
import { Lock, Clock, Check, ShieldCheck, Mail } from 'lucide-react';
import { toast } from 'sonner';
import { useLanguage } from '../../context/LanguageContext';

interface PhysicianApprovalCardProps {
  status: 'approved' | 'pending';
  approvedBy?: string;
  licenseNumber?: string;
  approvedAt?: string;
  onNotify?: () => void;
}

export function PhysicianApprovalCard({
  status,
  approvedBy = "Dr. Amina Al-Hashimi",
  licenseNumber = "DHA MD-4029",
  approvedAt = "15/06/2026 at 09:45:12",
  onNotify
}: PhysicianApprovalCardProps) {
  const { isRTL } = useLanguage();
  const [notified, setNotified] = useState(false);

  const handleNotify = () => {
    setNotified(true);
    toast.success(
      isRTL 
        ? "تم إرسال إشعار فوري إلى الطبيب المناوب."
        : "Incident dispatch sent to on-duty physician.",
      {
        description: isRTL ? "عبر الواتساب والرسائل النصية" : "Notified via SMS & WhatsApp",
        position: 'top-center'
      }
    );
    if (onNotify) onNotify();
  };

  if (status === 'approved') {
    return (
      <div className="bg-[#F0FDF4] border-2 border-[#15803D] rounded-xl p-4 space-y-3 shadow-sm animate-scale-in">
        <div className="flex items-start gap-2.5">
          <div className="w-8 h-8 rounded-full bg-[#D1FAE5] flex items-center justify-center text-[#15803D] flex-shrink-0">
            <Check className="w-5 h-5" />
          </div>
          <div className="flex-1">
            <h4 className="text-[14px] font-bold text-[#14532D]">
              {isRTL ? 'معتمد من طبيب المدرسة' : 'Medication Approved'}
            </h4>
            <p className="text-[11px] text-[#166534] mt-0.5 leading-normal">
              {isRTL 
                ? `تم الاعتماد بواسطة: د. ${approvedBy} · ترخيص رَقَم: ${licenseNumber} · في ${approvedAt}`
                : `Approved by ${approvedBy} · License: ${licenseNumber} · On ${approvedAt}`}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-1.5 pt-2 border-t border-[#D1FAE5] text-[11px] text-[#15803D] font-medium">
          <Lock className="w-3.5 h-3.5" />
          <span>
            {isRTL 
              ? 'هذا السجل دائم ومقفل قانونياً ولا يمكن تعديله.'
              : 'This record is permanent and locked against modification.'}
          </span>
        </div>
      </div>
    );
  }

  // PENDING state
  return (
    <div className="bg-[#FFFBEB] border-2 border-[#F59E0B] rounded-xl p-4 space-y-3 shadow-sm">
      <div className="flex items-start gap-2.5">
        <div className="w-8 h-8 rounded-full bg-[#FEF3C7] flex items-center justify-center text-[#B45309] flex-shrink-0">
          <Clock className="w-5 h-5 animate-pulse" />
        </div>
        <div className="flex-1">
          <h4 className="text-[14px] font-bold text-[#78350F]">
            {isRTL ? '⏳ بانتظار موافقة الطبيب' : '⏳ Awaiting Physician Approval'}
          </h4>
          <p className="text-[11px] text-[#B45309] mt-0.5 leading-normal">
            {isRTL
              ? 'لا يمكن إعطاء هذا الدواء للطالب قبل الحصول على موافقة الطبيب المناوب.'
              : 'Medication cannot be administered until approved by the school physician.'}
          </p>
        </div>
      </div>
      
      <div className="flex pt-1">
        <button
          onClick={handleNotify}
          disabled={notified}
          className={`w-full h-[40px] border border-[#F59E0B] rounded-lg font-bold text-[12px] flex items-center justify-center gap-1.5 transition-colors cursor-pointer min-h-[44px] ${
            notified 
              ? 'bg-[#FEF3C7] text-[#B45309] border-transparent cursor-not-allowed'
              : 'bg-white hover:bg-[#FFFBEB] text-[#B45309]'
          }`}
        >
          <Mail className="w-4 h-4" />
          <span>
            {notified 
              ? (isRTL ? 'تم إرسال الإشعار بالطوارئ' : 'Physician Notified')
              : (isRTL ? 'إرسال إشعار عاجل للطبيب المناوب' : 'Notify On-Duty Physician')}
          </span>
        </button>
      </div>
    </div>
  );
}
