import { AlertTriangle } from 'lucide-react';
import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { useLanguage } from '../../context/LanguageContext';

export function ConfidentialityAgreement() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [scrollProgress, setScrollProgress] = useState(0);
  const [isScrolledToBottom, setIsScrolledToBottom] = useState(false);
  const [showPulse, setShowPulse] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleScroll = () => {
      if (!scrollRef.current) return;

      const { scrollTop, scrollHeight, clientHeight } = scrollRef.current;
      const totalScrollable = scrollHeight - clientHeight;
      const progress = totalScrollable > 0 ? (scrollTop / totalScrollable) * 100 : 0;

      setScrollProgress(progress);

      if (scrollTop + clientHeight >= scrollHeight - 10) {
        if (!isScrolledToBottom) {
          setIsScrolledToBottom(true);
          setShowPulse(true);
          setTimeout(() => setShowPulse(false), 600);
        }
      }
    };

    const scrollElement = scrollRef.current;
    if (scrollElement) {
      scrollElement.addEventListener('scroll', handleScroll);
      handleScroll();
    }

    return () => {
      if (scrollElement) {
        scrollElement.removeEventListener('scroll', handleScroll);
      }
    };
  }, [isScrolledToBottom]);

  return (
    <div className="w-full h-screen bg-[#F8FAFC] flex flex-col" dir={isRTL ? 'rtl' : 'ltr'}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <h1 className="text-[17px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
          {isRTL ? 'اتفاقية سرية البيانات' : 'Confidentiality Agreement'}
        </h1>
        <span className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
          {isRTL ? 'الخطوة 1 من 2' : 'Step 1 of 2'}
        </span>
      </div>

      {/* Amber info banner */}
      <div className="bg-[#FEF3C7] border-l-8 border-[#F59E0B] p-4">
        <div className="flex gap-3 items-center">
          <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0" />
          <p className="text-[12px] text-[#92400E]" style={{ fontWeight: 400 }}>
            {isRTL ? 'يرجى التمرير حتى نهاية الصفحة للمتابعة' : 'Please scroll to the bottom to continue'}
          </p>
        </div>
      </div>

      {/* Progress bar */}
      <div className="h-1 bg-[#E2E8F0]">
        <div
          className="h-full bg-[#2563EB] transition-all duration-150"
          style={{ width: `${scrollProgress}%` }}
        />
      </div>

      {/* Scrollable content */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 py-6">
        <div className="text-[14px] text-[#0F172A] space-y-4" style={{ fontWeight: 400, lineHeight: 1.7 }}>
          <h2 className="text-[16px] font-semibold text-[#0F172A] mb-4" style={{ fontWeight: 600 }}>
            {isRTL ? 'اتفاقية سرية وخصوصية المعلومات الصحية المدرسية' : 'Health Information Privacy & Confidentiality Agreement'}
          </h2>

          <p>
            {isRTL
              ? 'تم إبرام اتفاقية السرية هذه ("الاتفاقية") بين الكادر الإداري أو الطبي المصرح له ("المستخدم") والمؤسسة التعليمية ("المدرسة") التي تستخدم نظام إدارة الصحة المدرسية SchooKeep.'
              : 'This Confidentiality Agreement ("Agreement") is entered into by and between the authorized school health professional ("User") and the educational institution ("School") utilizing the SchooKeep health management system.'}
          </p>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            {isRTL ? '1. الغرض' : '1. Purpose'}
          </h3>
          <p>
            {isRTL
              ? 'يقر المستخدم بأنه أثناء أداء مهامه، سيكون لديه إمكانية الوصول إلى معلومات صحية سرية وحساسة تتعلق بالطلاب، بما في ذلك السجلات الطبية، والتشخيصات، وخطة الرعاية، وسجلات الأدوية، وغيرها من المعلومات المحمية بموجب قوانين حماية البيانات الصحية في دولة الإمارات العربية المتحدة.'
              : 'The User acknowledges that in the course of their duties, they will have access to confidential and sensitive health information regarding students, including medical histories, diagnoses, treatment plans, medication records, and other protected health information.'}
          </p>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            {isRTL ? '2. التزامات السرية' : '2. Confidentiality Obligations'}
          </h3>
          <p>{isRTL ? 'يطبق المستخدم القواعد التالية:' : 'The User agrees to:'}</p>
          <ul className="list-disc pl-6 pr-6 space-y-2">
            <li>{isRTL ? 'الحفاظ على سرية جميع السجلات الصحية الطلابية المسجلة عبر نظام SchooKeep' : 'Maintain the confidentiality of all student health information accessed through the SchooKeep system'}</li>
            <li>{isRTL ? 'استخدام المعلومات فقط لأغراض تقديم الخدمات الصحية والتعليمية المصرح بها' : 'Use such information solely for the purpose of providing authorized healthcare services to students'}</li>
            <li>{isRTL ? 'عدم مشاركة أو مناقشة بيانات الطلاب مع أي أشخاص غير مصرح لهم' : 'Not disclose, share, or discuss student health information with unauthorized individuals'}</li>
            <li>{isRTL ? 'الالتزام بقانون حماية البيانات الشخصية الإماراتي (PDPL) واللوائح الصحية في الإمارات' : 'Comply with all applicable federal and state privacy laws, including UAE PDPL'}</li>
          </ul>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            {isRTL ? '3. الإقرار والتأكيد' : '3. Acknowledgment'}
          </h3>
          <p>
            {isRTL
              ? 'بالمتابعة إلى صفحة التوقيع، يقر المستخدم بأنه قرأ وفهم ووافق على الالتزام بشروط هذه الاتفاقية ومسؤوليته تجاه سرية البيانات.'
              : 'By continuing to the signature page, the User acknowledges that they have read, understood, and agree to be bound by the terms of this Confidentiality Agreement.'}
          </p>

          <div className="h-8" />
        </div>
      </div>

      {/* Fixed bottom area */}
      <div className="border-t border-[#E2E8F0] bg-[#FFFFFF] px-4 py-4">
        <button
          onClick={() => navigate('/signature')}
          disabled={!isScrolledToBottom}
          className={`w-full h-[52px] rounded-xl font-semibold transition-all cursor-pointer ${
            isScrolledToBottom
              ? 'bg-[#2563EB] text-white'
              : 'bg-[#2563EB] text-white opacity-40 cursor-not-allowed'
          } ${showPulse ? 'animate-pulse-success' : ''}`}
          style={{ fontWeight: 600 }}
        >
          {isRTL ? 'المتابعة للتوقيع' : 'Continue to Signature'}
        </button>
      </div>
    </div>
  );
}
