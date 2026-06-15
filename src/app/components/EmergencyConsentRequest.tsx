import { Phone, AlertTriangle, Clock, Eye, Camera } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState, useEffect } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { EmergencyCallButton } from './EmergencyCallButton';

export function EmergencyConsentRequest() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [timeRemaining, setTimeRemaining] = useState(572); // 9:32 in seconds

  useEffect(() => {
    const timer = setInterval(() => {
      setTimeRemaining((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          // Auto-escalate after 10 minutes
          setTimeout(() => {
            navigate('/nurse/clinic/emergency-escalation');
          }, 1000);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [navigate]);

  const minutes = Math.floor(timeRemaining / 60);
  const seconds = timeRemaining % 60;
  const displayTime = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  const progressPercentage = (timeRemaining / 600) * 100;

  return (
    <div className="min-h-screen bg-[#F8FAFC]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center border-b border-[#E2E8F0]">
        <h1 className="flex-1 text-[17px] font-semibold text-[#DC2626] text-center animate-pulse" style={{ fontWeight: 600 }}>
          {isRTL ? 'تفويض الحالات الطارئة' : 'Emergency Authorization'}
        </h1>
      </div>

      {/* Content */}
      <div className="px-4 py-8 space-y-6">
        {/* Countdown Timer */}
        <div className="flex flex-col items-center">
          <div className="relative w-[120px] h-[120px]">
            {/* Background circle */}
            <svg className="w-full h-full transform -rotate-90">
              <circle
                cx="60"
                cy="60"
                r="54"
                fill="none"
                stroke="#E2E8F0"
                strokeWidth="8"
              />
              {/* Progress circle */}
              <circle
                cx="60"
                cy="60"
                r="54"
                fill="none"
                stroke="#DC2626"
                strokeWidth="8"
                strokeDasharray={`${2 * Math.PI * 54}`}
                strokeDashoffset={`${2 * Math.PI * 54 * (1 - progressPercentage / 100)}`}
                className="transition-all duration-1000"
              />
            </svg>
            {/* Time display */}
            <div className="absolute inset-0 flex items-center justify-center">
              <span className="text-[32px] font-semibold text-[#DC2626]" style={{ fontWeight: 600 }}>
                {displayTime}
              </span>
            </div>
          </div>

          <p className="text-[14px] text-[#64748B] mt-4 text-center" style={{ fontWeight: 400 }}>
            {isRTL ? 'بانتظار موافقة ولي الأمر...' : 'Waiting for parent response...'}
          </p>
        </div>

        {/* Incident Summary */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] text-left">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3" style={{ fontWeight: 600 }}>
            {isRTL ? 'ملخص الحادثة' : 'Incident Summary'}
          </h3>

          {/* Photo Thumbnail */}
          <div className="w-full h-[120px] bg-[#1F2937] rounded-lg flex items-center justify-center mb-3">
            <Camera className="w-12 h-12 text-[#64748B]" />
          </div>

          <div className="space-y-2">
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>{isRTL ? 'الطالب' : 'Student'}</span>
              <span className="text-[13px] text-[#0F172A] font-semibold" style={{ fontWeight: 600 }}>Maya Chen</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>{isRTL ? 'الموقع' : 'Location'}</span>
              <span className="text-[13px] text-[#0F172A] font-semibold" style={{ fontWeight: 600 }}>{isRTL ? 'الملعب المدرسي' : 'Playground'}</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>{isRTL ? 'درجة الخطورة' : 'Severity'}</span>
              <span className="inline-flex items-center gap-1 bg-[#FEE2E2] text-[#991B1B] text-[12px] px-2.5 py-1 rounded-full font-semibold" style={{ fontWeight: 600 }}>
                {isRTL ? 'حرجة جداً' : 'Severe'}
              </span>
            </div>
            <div className="py-2">
              <p className="text-[13px] text-[#64748B] mb-1" style={{ fontWeight: 400 }}>{isRTL ? 'الوصف بالتفصيل' : 'Description'}</p>
              <p className="text-[13px] text-[#0F172A] leading-relaxed" style={{ fontWeight: 400 }}>
                {isRTL 
                  ? 'سقوط الطالبة من ألعاب ساحة المدرسة. إصابة ظاهرة في الذراع الأيسر وتشتكي الطالبة من ألم شديد وصعوبة في تحريكها.'
                  : 'Student fell from playground equipment. Visible injury to left arm. Student reports pain and difficulty moving arm.'}
              </p>
            </div>
          </div>
        </div>

        {/* Required Action */}
        <div 
          className="bg-[#FEE2E2] rounded-xl p-4 text-left border"
          style={{
            borderStyle: 'solid',
            borderLeftWidth: isRTL ? 0 : '4px',
            borderRightWidth: isRTL ? '4px' : 0,
            borderLeftColor: isRTL ? 'transparent' : '#DC2626',
            borderRightColor: isRTL ? '#DC2626' : 'transparent',
          }}
        >
          <h3 className="text-[14px] font-semibold text-[#991B1B] mb-2" style={{ fontWeight: 600 }}>
            {isRTL ? 'بانتظار تفويض ولي الأمر' : 'Awaiting Parent Authorization'}
          </h3>
          <p className="text-[13px] text-[#991B1B]" style={{ fontWeight: 400 }}>
            {isRTL 
              ? 'نقل إسعافي طارئ إلى مستشفى الجليلة التخصصي للأطفال'
              : 'Emergency transport to Al Jalila Children\'s Specialty Hospital'}
          </p>
        </div>

        {/* Escalation Notice */}
        <div 
          className="bg-[#FFFBEB] rounded-xl p-4 text-left border"
          style={{
            borderStyle: 'solid',
            borderLeftWidth: isRTL ? 0 : '4px',
            borderRightWidth: isRTL ? '4px' : 0,
            borderLeftColor: isRTL ? 'transparent' : '#F59E0B',
            borderRightColor: isRTL ? '#F59E0B' : 'transparent',
          }}
        >
          <div className="flex gap-3">
            <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <p className="text-[13px] text-[#92400E] leading-relaxed" style={{ fontWeight: 400 }}>
              {isRTL 
                ? 'إذا لم يتم الرد خلال 10 دقائق، سيتم طلب الإسعاف وتصعيد الحالة تلقائياً.'
                : 'If no response within 10 minutes, an emergency call (998) will be placed automatically.'}
            </p>
          </div>
        </div>

        {/* Status Log */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] text-left">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-4" style={{ fontWeight: 600 }}>
            {isRTL ? 'سجل الحالة الطارئة' : 'Status Log'}
          </h3>

          <div className="space-y-4">
            <div className="flex gap-3">
              <div className="flex flex-col items-center">
                <div className="w-8 h-8 rounded-full bg-[#10B981] flex items-center justify-center flex-shrink-0">
                  <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                </div>
                <div className="w-0.5 h-full bg-[#E2E8F0] mt-2" />
              </div>
              <div className="flex-1 pb-4">
                <p className="text-[13px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
                  {isRTL ? 'تم إرسال الطلب للموقع' : 'Request sent'}
                </p>
                <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
                  10:22 AM
                </p>
              </div>
            </div>

            <div className="flex gap-3">
              <div className="flex flex-col items-center">
                <div className="w-8 h-8 rounded-full bg-[#2563EB] flex items-center justify-center flex-shrink-0">
                  <Eye className="w-5 h-5 text-white" />
                </div>
                <div className="w-0.5 h-full bg-[#E2E8F0] mt-2" />
              </div>
              <div className="flex-1 pb-4">
                <p className="text-[13px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
                  {isRTL ? 'تم الاطلاع من ولي الأمر' : 'Parent viewed'}
                </p>
                <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
                  10:24 AM
                </p>
              </div>
            </div>

            <div className="flex gap-3">
              <div className="flex flex-col items-center">
                <div className="w-8 h-8 rounded-full bg-[#F59E0B] flex items-center justify-center flex-shrink-0">
                  <Clock className="w-5 h-5 text-white animate-pulse" />
                </div>
              </div>
              <div className="flex-1">
                <p className="text-[13px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
                  {isRTL ? 'بانتظار الرد...' : 'Awaiting response...'}
                </p>
                <div className="flex gap-1 mt-2">
                  <div className="w-2 h-2 rounded-full bg-[#F59E0B] animate-bounce" style={{ animationDelay: '0ms' }} />
                  <div className="w-2 h-2 rounded-full bg-[#F59E0B] animate-bounce" style={{ animationDelay: '150ms' }} />
                  <div className="w-2 h-2 rounded-full bg-[#F59E0B] animate-bounce" style={{ animationDelay: '300ms' }} />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Action Buttons Stack */}
        <div className="space-y-3 pt-2">
          {/* Emergency Ambulance 998 Button */}
          <EmergencyCallButton variant="danger" />

          {/* Contact On-Call Physician Button */}
          <button
            onClick={() => alert(isRTL ? "اتصال بالطبيب المناوب: د. أمينة الهاشمي على الرقم +971 50 123 4567..." : "Dialing on-call physician Dr. Amina Al-Hashimi at +971 50 123 4567...")}
            className="w-full h-[52px] bg-white text-[#0D9488] border-2 border-[#0D9488] rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 cursor-pointer transition-all active:scale-[0.98] min-h-[44px]"
          >
            <Phone className="w-5 h-5 flex-shrink-0" />
            <span>{isRTL ? "الاتصال بالطبيب المناوب" : "Contact on-call physician"}</span>
          </button>

          {/* Original Call Parent Button */}
          <button
            onClick={() => navigate('/nurse/clinic/emergency-escalation')}
            className="w-full h-[52px] bg-[#FFFFFF] text-[#2563EB] border-2 border-[#2563EB] rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 cursor-pointer transition-all active:scale-[0.98] min-h-[44px]"
          >
            <Phone className="w-5 h-5 flex-shrink-0" />
            <span>{isRTL ? "الاتصال بولي الأمر الآن" : "Call Parent Now"}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
export default EmergencyConsentRequest;
