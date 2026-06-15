// src/app/components/MedicationProtocolReview.tsx
import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ChevronLeft, Info, Lock, ShieldCheck, FileText, CheckCircle, AlertTriangle } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { toast } from 'sonner';

export function MedicationProtocolReview() {
  const navigate = useNavigate();
  const { id } = useParams();
  const { isRTL } = useLanguage();

  // Mock data details
  const student = {
    name: id === '2' ? 'Marcus Chen' : 'Emma Rodriguez',
    initials: id === '2' ? 'MC' : 'ER',
    grade: id === '2' ? '5th Grade' : '3rd Grade',
    school: 'Lincoln Elementary School',
    medication: id === '2' ? 'Ritalin 10mg' : 'Albuterol Inhaler 90mcg',
    dose: id === '2' ? '1 tablet' : '2 puffs',
    times: id === '2' ? ['08:30 AM'] : ['02:00 PM', 'As needed'],
    proposedBy: 'Nurse Emily Smith',
    license: 'RN-4521',
    date: '15/06/2026'
  };

  // State management
  const [showModifications, setShowModifications] = useState(false);
  const [modDose, setModDose] = useState(student.dose);
  const [modTimes, setModTimes] = useState(student.times.join(', '));
  const [declineReason, setDeclineReason] = useState('');
  const [showDeclineReason, setShowDeclineReason] = useState(false);
  
  const [showPinPrompt, setShowPinPrompt] = useState(false);
  const [pinCode, setPinCode] = useState('');
  const [pinError, setPinError] = useState(false);
  const [isApproved, setIsApproved] = useState(false);
  const [approvedRecord, setApprovedRecord] = useState<string | null>(null);

  const handleApprove = () => {
    setShowDeclineReason(false);
    setShowPinPrompt(true);
  };

  const handleDeclineSubmit = () => {
    if (!declineReason.trim()) {
      toast.error(isRTL ? "يرجى تحديد سبب الرفض" : "Please provide a reason for declining.");
      return;
    }
    toast.success(isRTL ? "تم رفض البروتوكول وإعادته للممرضة" : "Protocol declined and returned to clinic.");
    setTimeout(() => {
      navigate('/physician/dashboard');
    }, 1200);
  };

  const verifyPin = () => {
    if (pinCode === '1234' || pinCode === '9999') {
      setPinError(false);
      setShowPinPrompt(false);
      setIsApproved(true);
      
      const now = new Date();
      const timeStr = now.toTimeString().split(' ')[0];
      const dateStr = `${String(now.getDate()).padStart(2, '0')}/${String(now.getMonth() + 1).padStart(2, '0')}/${now.getFullYear()}`;
      
      const stamp = isRTL 
        ? `✓ معتمد من د. أمينة الهاشمي · ترخيص DHA MD-4029 · بتاريخ ${dateStr} الساعة ${timeStr}`
        : `✓ Approved by Dr. Amina Al-Hashimi · DHA MD-4029 · ${dateStr} at ${timeStr}`;
      
      setApprovedRecord(stamp);
      toast.success(isRTL ? "تم توقيع واعتماد البروتوكول" : "Protocol approved and signed!");

      // Simulate API callback delay to redirect
      setTimeout(() => {
        navigate('/physician/dashboard');
      }, 2000);
    } else {
      setPinError(true);
      setPinCode('');
      toast.error(isRTL ? "رمز PIN غير صحيح" : "Incorrect verification PIN.");
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[120px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* iOS Status Bar Spacer */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200 sticky top-0 z-40">
        <button
          onClick={() => navigate('/physician/dashboard')}
          className="flex items-center justify-center w-11 h-11 -ml-2 text-gray-900"
          aria-label="Go back"
        >
          <ChevronLeft className={`w-6 h-6 ${isRTL ? 'rotate-180' : ''}`} />
        </button>

        <div className="absolute left-1/2 -translate-x-1/2 text-center">
          <h1 className="font-semibold text-[17px] text-gray-900 leading-tight">
            {isRTL ? 'مراجعة البروتوكول' : 'Protocol Review'}
          </h1>
          <p className="text-[11px] text-[#64748B]">
            {student.name}
          </p>
        </div>
      </header>

      {/* Main Form Area */}
      <div className="px-4 py-4 space-y-4">
        
        {/* PDPL / DHA Notice Banner */}
        <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-xl p-3 flex gap-2.5 text-left">
          <Info className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
          <p className="text-[12px] text-[#1E40AF] leading-relaxed">
            {isRTL 
              ? 'موافقة الطبيب إلزامية قبل إعطاء هذا الدواء بالمدرسة بموجب لوائح هيئة الصحة ST-22 وقانون حماية البيانات الشخصية الإماراتي.'
              : 'Physician approval is required before this medication can be administered per DHA/HRS/HPSD/ST-22 and UAE PDPL compliance.'}
          </p>
        </div>

        {/* Student card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3">
          <div className="w-12 h-12 rounded-full bg-[#0D9488]/10 flex items-center justify-center text-[#0D9488] font-bold text-lg">
            {student.initials}
          </div>
          <div className="text-left">
            <h3 className="text-[15px] font-bold text-gray-900">{student.name}</h3>
            <p className="text-xs text-[#64748B]">{student.grade} · {student.school}</p>
          </div>
        </div>

        {/* Nurse's Proposal Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
          <div className="text-left space-y-1">
            <span className="text-[11px] font-bold text-[#64748B] uppercase tracking-wide">
              {isRTL ? 'الدواء المقترح' : 'Proposed Medication Protocol'}
            </span>
            <h2 className="text-[20px] font-bold text-[#0F172A] leading-tight">
              {student.medication}
            </h2>
          </div>

          <div className="grid grid-cols-2 gap-3 pt-3 border-t border-gray-100 text-left">
            <div>
              <span className="text-[11px] text-[#64748B] block">{isRTL ? 'الجرعة المقترحة' : 'Proposed Dose'}</span>
              <span className="text-[14px] font-bold text-gray-900">{student.dose}</span>
            </div>
            <div>
              <span className="text-[11px] text-[#64748B] block">{isRTL ? 'أوقات الإعطاء' : 'Scheduled Times'}</span>
              <div className="flex flex-wrap gap-1 mt-0.5">
                {student.times.map((t, idx) => (
                  <span key={idx} className="inline-flex px-2 py-0.5 bg-slate-100 text-[#475569] text-[11px] font-semibold rounded">
                    {t}
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* Doc Attachment */}
          <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0] flex items-center justify-between">
            <div className="flex items-center gap-2">
              <FileText className="w-5 h-5 text-[#64748B]" />
              <div className="text-left">
                <span className="text-xs font-semibold text-gray-900 block truncate max-w-[180px]">
                  {isRTL ? 'تقرير تشخيص الطبيب المعالج.pdf' : 'Physician_Diagnosis_Report.pdf'}
                </span>
                <span className="text-[10px] text-[#64748B] block">PDF · 1.4 MB</span>
              </div>
            </div>
            <button 
              onClick={() => toast.info(isRTL ? "جاري تحميل الملف..." : "Downloading document preview...")}
              className="text-xs text-[#0D9488] font-bold hover:underline"
            >
              {isRTL ? 'عرض الملف' : 'View Document'}
            </button>
          </div>

          {/* Proposal Footer Lock */}
          <div className="flex items-center gap-1.5 pt-3 border-t border-gray-100 text-[11px] text-[#64748B] font-medium justify-between">
            <div className="flex items-center gap-1">
              <Lock className="w-3.5 h-3.5" />
              <span>{isRTL ? `مقدم من: ${student.proposedBy} (${student.license})` : `Proposed by: ${student.proposedBy} (${student.license})`}</span>
            </div>
            <span>{student.date}</span>
          </div>
        </div>

        {/* Immutable Approved stamp */}
        {isApproved && approvedRecord && (
          <div className="bg-[#F0FDF4] border-2 border-[#15803D] rounded-xl p-4 space-y-2 text-left animate-pulse-success">
            <div className="flex items-center gap-2 text-[#15803D] font-bold text-sm">
              <CheckCircle className="w-5 h-5" />
              <span>{isRTL ? 'تم اعتماد البروتوكول بنجاح' : 'Protocol Approved & Locked'}</span>
            </div>
            <p className="text-xs text-[#166534] leading-relaxed font-semibold">
              {approvedRecord}
            </p>
          </div>
        )}

        {/* Action Buttons Section */}
        {!isApproved && (
          <div className="space-y-3 pt-2">
            
            {/* Standard actions */}
            {!showModifications && !showDeclineReason && (
              <div className="space-y-3">
                <button
                  onClick={handleApprove}
                  className="w-full h-[52px] bg-[#0D9488] hover:bg-[#0B7A70] text-white rounded-xl font-bold text-[15px] flex items-center justify-center gap-2 cursor-pointer shadow-md"
                >
                  <ShieldCheck className="w-5 h-5" />
                  {isRTL ? 'اعتماد البروتوكول كما هو مقترح' : 'Approve as Proposed'}
                </button>
                
                <button
                  onClick={() => setShowModifications(true)}
                  className="w-full h-[52px] bg-white border-2 border-[#0D9488] text-[#0D9488] rounded-xl font-bold text-[15px] flex items-center justify-center cursor-pointer hover:bg-teal-50/30"
                >
                  {isRTL ? 'اعتماد مع تعديل المقترح' : 'Approve with Modification'}
                </button>

                <div className="grid grid-cols-2 gap-3">
                  <button
                    onClick={() => {
                      toast.success(isRTL ? "تم إرسال طلب التوضيح للممرضة" : "Clarification request sent to clinic nurse.");
                      navigate('/physician/dashboard');
                    }}
                    className="h-[48px] bg-white border border-[#E2E8F0] text-gray-900 rounded-xl text-xs font-bold flex items-center justify-center cursor-pointer"
                  >
                    {isRTL ? 'طلب معلومات إضافية' : 'Request More Info'}
                  </button>
                  <button
                    onClick={() => setShowDeclineReason(true)}
                    className="h-[48px] bg-white border border-[#DC2626] text-[#DC2626] rounded-xl text-xs font-bold flex items-center justify-center cursor-pointer hover:bg-red-50/20"
                  >
                    {isRTL ? 'رفض البروتوكول' : 'Decline Protocol'}
                  </button>
                </div>
              </div>
            )}

            {/* Approve with Modification inputs */}
            {showModifications && (
              <div className="bg-white rounded-xl border border-teal-200 p-4 space-y-4 text-left animate-slide-up">
                <h3 className="font-bold text-[15px] text-[#0D9488]">
                  {isRTL ? 'تعديل جرعات وأوقات البروتوكول' : 'Clinical Modification Fields'}
                </h3>
                
                <div className="space-y-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#64748B] mb-1">{isRTL ? 'تعديل الجرعة' : 'Modify Dose'}</label>
                    <input 
                      type="text" 
                      value={modDose}
                      onChange={(e) => setModDose(e.target.value)}
                      className="w-full h-11 px-3 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a]"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#64748B] mb-1">{isRTL ? 'تعديل الأوقات' : 'Modify Times'}</label>
                    <input 
                      type="text" 
                      value={modTimes}
                      onChange={(e) => setModTimes(e.target.value)}
                      className="w-full h-11 px-3 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a]"
                    />
                  </div>
                </div>

                <div className="flex gap-3 pt-2">
                  <button
                    onClick={() => setShowModifications(false)}
                    className="flex-1 h-11 border border-gray-200 text-gray-500 rounded-xl text-xs font-bold cursor-pointer bg-white"
                  >
                    {isRTL ? 'إلغاء' : 'Cancel'}
                  </button>
                  <button
                    onClick={handleApprove}
                    className="flex-1 h-11 bg-[#0D9488] text-white rounded-xl text-xs font-bold cursor-pointer"
                  >
                    {isRTL ? 'توقيع واعتماد التعديل' : 'Sign & Approve Mod'}
                  </button>
                </div>
              </div>
            )}

            {/* Decline reason flow */}
            {showDeclineReason && (
              <div className="bg-white rounded-xl border border-red-200 p-4 space-y-4 text-left animate-slide-up">
                <h3 className="font-bold text-[15px] text-[#DC2626]">
                  {isRTL ? 'سبب رفض البروتوكول الطبي' : 'Protocol Declination Reason'}
                </h3>
                
                <div>
                  <label className="block text-xs font-semibold text-[#64748B] mb-1.5">{isRTL ? 'سبب الرفض (إلزامي)' : 'Reason (Mandatory)'}</label>
                  <textarea 
                    value={declineReason}
                    onChange={(e) => setDeclineReason(e.target.value)}
                    placeholder={isRTL ? "مثال: التشخيص غير واضح، جرعة غير مطابقة..." : "e.g., Clinical report unclear, dosage exceeds guidelines..."}
                    rows={3}
                    className="w-full p-3 border border-gray-200 rounded-lg text-sm resize-none bg-white text-[#0f172a]"
                  />
                </div>

                <div className="flex gap-3 pt-2">
                  <button
                    onClick={() => setShowDeclineReason(false)}
                    className="flex-1 h-11 border border-gray-200 text-gray-500 rounded-xl text-xs font-bold cursor-pointer bg-white"
                  >
                    {isRTL ? 'إلغاء' : 'Cancel'}
                  </button>
                  <button
                    onClick={handleDeclineSubmit}
                    className="flex-1 h-11 bg-[#DC2626] text-white rounded-xl text-xs font-bold cursor-pointer"
                  >
                    {isRTL ? 'تأكيد الرفض والرفض' : 'Confirm Decline'}
                  </button>
                </div>
              </div>
            )}

          </div>
        )}
      </div>

      {/* Security Signature PIN Prompt Modal */}
      {showPinPrompt && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full border border-gray-100 shadow-xl space-y-4">
            <div className="text-center space-y-1">
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'تأكيد التوقيع الرقمي' : 'Verify Clinical Signature'}
              </h3>
              <p className="text-xs text-[#64748B]">
                {isRTL 
                  ? 'أدخل رمز PIN الخاص بالطبيب للموافقة على السجل الطبي وإقفاله.'
                  : 'Enter your 4-digit signature PIN to authorize and stamp this record.'}
              </p>
            </div>

            <div className="space-y-1">
              <input
                type="password"
                maxLength={4}
                value={pinCode}
                onChange={(e) => setPinCode(e.target.value)}
                placeholder="••••"
                className={`w-full h-12 text-center text-xl tracking-widest border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0D9488] bg-white text-[#0f172a] ${
                  pinError ? 'border-red-500 focus:ring-red-500' : 'border-gray-200'
                }`}
              />
              <p className="text-[10px] text-center text-[#64748B]">
                {isRTL ? '(رمز الدخول التجريبي: 1234 أو 9999)' : '(Demo code: 1234 or 9999)'}
              </p>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => {
                  setShowPinPrompt(false);
                  setPinCode('');
                  setPinError(false);
                }}
                className="flex-1 h-11 border border-gray-200 text-gray-500 rounded-xl text-xs font-bold cursor-pointer bg-white"
              >
                {isRTL ? 'إلغاء' : 'Cancel'}
              </button>
              <button
                onClick={verifyPin}
                className="flex-1 h-11 bg-[#0D9488] text-white rounded-xl text-xs font-bold cursor-pointer"
              >
                {isRTL ? 'توقيع السجل' : 'Sign Record'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
export default MedicationProtocolReview;
