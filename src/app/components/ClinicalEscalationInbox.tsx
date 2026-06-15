// src/app/components/ClinicalEscalationInbox.tsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronLeft, AlertTriangle, AlertCircle, Clock, Truck, ShieldAlert, CheckCircle, ChevronDown, ChevronUp } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { toast } from 'sonner';

interface EscalationItem {
  id: string;
  studentName: string;
  severity: 'Moderate' | 'Severe' | 'Critical';
  nurseDescription: string;
  timeElapsedMinutes: number; // to check if > 8 min turns red
  photoUrl?: string;
}

export function ClinicalEscalationInbox() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();

  const [isOnCall, setIsOnCall] = useState(true); // Simulated: physician is off-site, thus on-call
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  const [activeAction, setActiveAction] = useState<{ type: string; descEn: string; descAr: string; studentName: string } | null>(null);

  // Active items list
  const [escalations, setEscalations] = useState<EscalationItem[]>([
    {
      id: '1',
      studentName: 'Sarah Williams',
      severity: 'Critical',
      nurseDescription: 'Student is experiencing a severe allergic reaction (anaphylaxis) following recess. Epinephrine administered at 10:14 AM. Breathing is shallow, wheezing continues.',
      timeElapsedMinutes: 9, // turns red (> 8)
      photoUrl: 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&q=80&w=200' // mock photo
    },
    {
      id: '2',
      studentName: 'Ethan Williams',
      severity: 'Moderate',
      nurseDescription: 'Suspected fracture of left wrist after falling off playground structures. High swelling, pain level 7/10. Wrist splinted.',
      timeElapsedMinutes: 5,
      photoUrl: 'https://images.unsplash.com/photo-1579684389782-64d84b5e901a?auto=format&fit=crop&q=80&w=200'
    }
  ]);

  const [resolvedToday, setResolvedToday] = useState([
    { id: '10', studentName: 'Maya Chen', action: 'Authorized first aid at clinic', time: '09:12 AM' }
  ]);
  const [showResolved, setShowResolved] = useState(false);

  const handleAction = (studentName: string, actionType: string, descEn: string, descAr: string) => {
    setActiveAction({
      type: actionType,
      descEn,
      descAr,
      studentName
    });
    setShowConfirmDialog(true);
  };

  const confirmAction = () => {
    if (!activeAction) return;

    toast.success(
      isRTL 
        ? `تم التصريح بـ: ${activeAction.descAr}`
        : `Authorized: ${activeAction.descEn}`,
      {
        description: isRTL ? "تم التسجيل بموجب ترخيص DHA الخاص بك" : "Logged permanently under DHA MD-4029 license",
        position: 'top-center'
      }
    );

    // Remove from active list
    setEscalations(prev => prev.filter(e => e.studentName !== activeAction.studentName));
    
    // Add to resolved
    setResolvedToday(prev => [
      {
        id: String(Date.now()),
        studentName: activeAction.studentName,
        action: activeAction.descEn,
        time: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
      },
      ...prev
    ]);

    setShowConfirmDialog(false);
    setActiveAction(null);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[120px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200 sticky top-0 z-40">
        <button
          onClick={() => navigate('/physician/dashboard')}
          className="flex items-center justify-center w-11 h-11 -ml-2 text-gray-900 animate-slide-up"
          aria-label="Go back"
        >
          <ChevronLeft className={`w-6 h-6 ${isRTL ? 'rotate-180' : ''}`} />
        </button>

        <div className="absolute left-1/2 -translate-x-1/2 flex items-center gap-1.5">
          <ShieldAlert className="w-5 h-5 text-[#DC2626]" />
          <h1 className="font-semibold text-[17px] text-gray-900">
            {isRTL ? 'التصعيدات الطبية' : 'Escalations'}
          </h1>
          <span className="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full font-bold ml-1">
            {escalations.length}
          </span>
        </div>
      </header>

      {/* Main Container */}
      <div className="px-4 py-4 space-y-4">
        
        {/* On-Call Amber Banner */}
        {isOnCall && (
          <div className="bg-[#FFFBEB] border border-[#FDE68A] rounded-xl p-3 flex gap-2.5 text-left animate-slide-down">
            <Clock className="w-5 h-5 text-[#D97706] flex-shrink-0 mt-0.5 animate-pulse" />
            <div className="text-left">
              <span className="text-xs font-bold text-[#92400E] block">
                {isRTL ? 'تنبيه: أنت في وضع الاستعداد خارج المدرسة' : 'Attention: You are currently on-call'}
              </span>
              <span className="text-[11px] text-[#B45309] mt-0.5 block leading-normal">
                {isRTL 
                  ? 'بموجب شروط هيئة الصحة (DHA)، يرجى الاستجابة للتصعيدات الطبية الطارئة خلال 10 دقائق.'
                  : 'DHA mandate requires responding to emergency escalations within 10 minutes SLA.'}
              </span>
            </div>
          </div>
        )}

        {/* Active Escalations List */}
        <div className="space-y-4">
          {escalations.map((esc) => {
            const isOverTime = esc.timeElapsedMinutes >= 8;
            return (
              <div 
                key={esc.id}
                className="bg-white border-2 border-red-500 rounded-2xl p-4 shadow-sm space-y-4 text-left animate-scale-in"
              >
                {/* Header info */}
                <div className="flex items-start justify-between">
                  <div className="space-y-0.5">
                    <div className="flex items-center gap-2">
                      <span className="text-[16px] font-bold text-gray-900">{esc.studentName}</span>
                      <span className={`text-[10px] px-2.5 py-0.5 rounded-full font-bold ${
                        esc.severity === 'Critical' 
                          ? 'bg-red-100 text-red-600' 
                          : 'bg-amber-100 text-amber-600'
                      }`}>
                        {esc.severity === 'Critical' 
                          ? (isRTL ? 'حالة حرجة جداً' : 'CRITICAL')
                          : (isRTL ? 'حالة متوسطة' : 'MODERATE')}
                      </span>
                    </div>
                    <span className="text-xs text-[#64748B] block">{esc.grade}</span>
                  </div>

                  {/* Timer widget */}
                  <div className={`flex items-center gap-1 px-2.5 py-1 rounded-lg border text-[11px] font-bold ${
                    isOverTime 
                      ? 'bg-red-50 border-red-200 text-red-600 animate-pulse' 
                      : 'bg-slate-50 border-slate-200 text-[#64748B]'
                  }`}>
                    <Clock className="w-3.5 h-3.5" />
                    <span>{esc.timeElapsedMinutes} {isRTL ? 'دقائق' : 'min ago'}</span>
                  </div>
                </div>

                {/* Nurse Description text */}
                <p className="text-xs text-gray-700 bg-slate-50 p-3 rounded-xl border border-gray-100 leading-relaxed font-medium">
                  {esc.nurseDescription}
                </p>

                {/* Incident Photo Expanded */}
                {esc.photoUrl && (
                  <div className="relative w-full h-[140px] bg-slate-100 rounded-xl overflow-hidden border border-gray-200">
                    <img 
                      src={esc.photoUrl} 
                      alt="Incident Thumbnail" 
                      className="w-full h-full object-cover"
                    />
                    <div className="absolute bottom-2 left-2 bg-black/60 text-white text-[9px] px-2 py-0.5 rounded font-bold">
                      {isRTL ? 'معاينة الصورة المرفقة' : 'Clinical Image Attachment'}
                    </div>
                  </div>
                )}

                {/* Actions Triage Section */}
                <div className="space-y-2.5 pt-2 border-t border-gray-100">
                  <button
                    onClick={() => handleAction(
                      esc.studentName,
                      'transport',
                      'Emergency Ambulance Transport (998)',
                      'نقل إسعاف طوارئ (998)'
                    )}
                    className="w-full h-[46px] bg-[#DC2626] hover:bg-[#B91C1C] text-white rounded-xl font-bold text-xs flex items-center justify-center gap-2 cursor-pointer min-h-[44px]"
                  >
                    <Truck className="w-4 h-4" />
                    {isRTL ? 'ترخيص النقل بالإسعاف (998)' : 'Authorize Emergency Transport'}
                  </button>

                  <div className="grid grid-cols-2 gap-2.5">
                    <button
                      onClick={() => handleAction(
                        esc.studentName,
                        'first-aid',
                        'First Aid Treatment at Clinic',
                        'إسعافات أولية في عيادة المدرسة'
                      )}
                      className="h-[44px] bg-white border border-[#D97706] text-[#D97706] rounded-xl text-xs font-bold flex items-center justify-center cursor-pointer hover:bg-amber-50/25"
                    >
                      {isRTL ? 'ترخيص إسعافات بالعيادة' : 'Authorize First Aid'}
                    </button>
                    <button
                      onClick={() => {
                        toast.info(isRTL ? "تم إرسال طلب تواصل للممرضة مع الوالدين" : "Nurse advised to contact parent first.");
                        // Simulate delay
                        setEscalations(prev => prev.filter(e => e.studentName !== esc.studentName));
                      }}
                      className="h-[44px] bg-white border border-gray-300 text-gray-700 rounded-xl text-xs font-bold flex items-center justify-center cursor-pointer hover:bg-slate-50"
                    >
                      {isRTL ? 'الاتصال بالوالدين أولاً' : 'Advise Parent Call First'}
                    </button>
                  </div>
                </div>
              </div>
            );
          })}

          {escalations.length === 0 && (
            <div className="bg-white rounded-2xl border border-gray-200 p-8 text-center space-y-2">
              <div className="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 mx-auto">
                <CheckCircle className="w-6 h-6" />
              </div>
              <h3 className="font-bold text-gray-900">{isRTL ? 'لوحة تحكم خالية' : 'All Clear'}</h3>
              <p className="text-xs text-[#64748B] max-w-[240px] mx-auto">
                {isRTL 
                  ? 'لا توجد أي تصعيدات نشطة حالياً. تم معالجة كافة الحالات.'
                  : 'No active medical escalations. All cases resolved.'}
              </p>
            </div>
          )}
        </div>

        {/* Resolved Today Collapsible section */}
        <div className="pt-2">
          <button
            onClick={() => setShowResolved(!showResolved)}
            className="w-full flex items-center justify-between py-2 text-xs font-bold text-[#64748B] uppercase tracking-wider"
          >
            <span>{isRTL ? 'تم حلها اليوم' : 'Resolved Today'}</span>
            {showResolved ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
          </button>
          
          {showResolved && (
            <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100 mt-2 overflow-hidden animate-slide-up">
              {resolvedToday.map((res) => (
                <div key={res.id} className="p-3.5 flex justify-between items-center text-left">
                  <div>
                    <span className="text-xs font-bold text-gray-900 block">{res.studentName}</span>
                    <span className="text-[11px] text-emerald-600 font-semibold">{res.action}</span>
                  </div>
                  <span className="text-[10px] text-[#64748B]">{res.time}</span>
                </div>
              ))}
              {resolvedToday.length === 0 && (
                <div className="p-4 text-center text-xs text-[#64748B]">
                  {isRTL ? 'لم يتم حل أي حالات بعد' : 'No resolved cases today.'}
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Confirmation modal */}
      {showConfirmDialog && activeAction && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full border border-gray-100 shadow-xl space-y-4">
            <div className="text-center space-y-1">
              <h3 className="text-[17px] font-bold text-[#DC2626]">
                {isRTL ? 'تأكيد تصريح الطوارئ' : 'Authorize Emergency Action'}
              </h3>
              <p className="text-xs text-gray-900 leading-normal font-semibold">
                {isRTL
                  ? `أنت تصرح بـ: [${activeAction.descAr}] للطالب ${activeAction.studentName}`
                  : `You are authorizing: [${activeAction.descEn}] for ${activeAction.studentName}`}
              </p>
              <p className="text-[11px] text-[#64748B] pt-2">
                {isRTL
                  ? 'سيتم تسجيل هذا الإجراء بشكل دائم وغير قابل للتعديل بموجب ترخيص DHA الخاص بك.'
                  : 'This action is logged permanently under your DHA MD-4029 license.'}
              </p>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => {
                  setShowConfirmDialog(false);
                  setActiveAction(null);
                }}
                className="flex-1 h-11 border border-gray-200 text-gray-500 rounded-xl text-xs font-bold cursor-pointer bg-white"
              >
                {isRTL ? 'إلغاء' : 'Cancel'}
              </button>
              <button
                onClick={confirmAction}
                className="flex-1 h-11 bg-[#DC2626] text-white rounded-xl text-xs font-bold cursor-pointer"
              >
                {isRTL ? 'تصريح واعتماد' : 'Authorize'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
export default ClinicalEscalationInbox;
