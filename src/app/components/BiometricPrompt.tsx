import { Scan } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useLanguage } from '../../context/LanguageContext';

export function BiometricPrompt() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();

  return (
    <div className="w-full h-screen bg-[#F8FAFC] relative" dir={isRTL ? 'rtl' : 'ltr'}>
      {/* Overlay backdrop */}
      <div className="absolute inset-0 bg-black/30" onClick={() => navigate('/agreement')} />

      {/* Bottom sheet */}
      <div className="absolute bottom-0 left-0 right-0 bg-[#FFFFFF] rounded-t-3xl pt-2 pb-8 px-6 animate-slide-up">
        {/* Drag handle */}
        <div className="flex justify-center mb-6">
          <div className="w-10 h-1 bg-[#E2E8F0] rounded-full" />
        </div>

        {/* Face ID icon */}
        <div className="flex justify-center mb-6">
          <div className="w-[64px] h-[64px] rounded-full bg-[#2563EB]/10 flex items-center justify-center">
            <Scan className="w-10 h-10 text-[#2563EB]" />
          </div>
        </div>

        {/* Heading */}
        <h2 className="text-[20px] font-medium text-[#0F172A] text-center mb-3" style={{ fontWeight: 500 }}>
          {isRTL ? 'تفعيل التعرف على الوجه Face ID؟' : 'Enable Face ID?'}
        </h2>

        {/* Body text */}
        <p className="text-[14px] text-[#64748B] text-center mb-8" style={{ fontWeight: 400 }}>
          {isRTL ? 'سجل الدخول بشكل أسرع في المرة القادمة دون الحاجة لإدخال كلمة المرور.' : 'Sign in faster next time without entering your password.'}
        </p>

        {/* Primary CTA */}
        <button
          onClick={() => navigate('/agreement')}
          className="w-full h-[52px] bg-[#2563EB] text-white rounded-xl font-semibold mb-4 cursor-pointer"
          style={{ fontWeight: 600 }}
        >
          {isRTL ? 'تفعيل Face ID' : 'Enable Face ID'}
        </button>

        {/* Secondary link */}
        <button
          onClick={() => navigate('/agreement')}
          className="w-full text-[14px] text-[#64748B] font-medium min-h-[44px] cursor-pointer"
          style={{ fontWeight: 500 }}
        >
          {isRTL ? 'ليس الآن' : 'Not now'}
        </button>
      </div>
    </div>
  );
}
