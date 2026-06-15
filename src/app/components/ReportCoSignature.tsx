// src/app/components/ReportCoSignature.tsx
import React, { useState, useRef, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ChevronLeft, FileText, Check, Lock, Download, Send, CheckCircle } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { UAEPassSignOption } from './UAEPassSignOption';
import { toast } from 'sonner';

export function ReportCoSignature() {
  const navigate = useNavigate();
  const { id } = useParams();
  const { isRTL } = useLanguage();

  // Mock data
  const report = {
    title: 'Monthly Clinical Immunization Summary',
    dateRange: '01/05/2026 - 31/05/2026',
    nurseName: 'Emily Smith',
    nurseLicense: 'RN-4521',
    signedDate: '10/06/2026',
    schoolName: 'Lincoln Elementary School',
    stats: {
      totalVisits: 142,
      medsAdministered: 98,
      referralsSent: 12,
      emergencies: 1
    }
  };

  // State
  const [reviewNotes, setReviewNotes] = useState('');
  const [isSigned, setIsSigned] = useState(false);
  const [showPinPrompt, setShowPinPrompt] = useState(false);
  const [pinCode, setPinCode] = useState('');
  const [pinError, setPinError] = useState(false);
  const [signatureDate, setSignatureDate] = useState('');

  // Interactive Signature Canvas Ref
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const [isDrawing, setIsDrawing] = useState(false);

  useEffect(() => {
    // Initialize canvas default style
    const canvas = canvasRef.current;
    if (canvas) {
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.strokeStyle = '#0F172A';
        ctx.lineWidth = 2.5;
        ctx.lineCap = 'round';
      }
    }
  }, [isSigned]);

  const startDrawing = (e: React.MouseEvent<HTMLCanvasElement> | React.TouchEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let clientX, clientY;
    if ('touches' in e) {
      clientX = e.touches[0].clientX;
      clientY = e.touches[0].clientY;
    } else {
      clientX = e.clientX;
      clientY = e.clientY;
    }

    const rect = canvas.getBoundingClientRect();
    ctx.beginPath();
    ctx.moveTo(clientX - rect.left, clientY - rect.top);
    setIsDrawing(true);
  };

  const draw = (e: React.MouseEvent<HTMLCanvasElement> | React.TouchEvent<HTMLCanvasElement>) => {
    if (!isDrawing) return;
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let clientX, clientY;
    if ('touches' in e) {
      clientX = e.touches[0].clientX;
      clientY = e.touches[0].clientY;
    } else {
      clientX = e.clientX;
      clientY = e.clientY;
    }

    const rect = canvas.getBoundingClientRect();
    ctx.lineTo(clientX - rect.left, clientY - rect.top);
    ctx.stroke();
  };

  const stopDrawing = () => {
    setIsDrawing(false);
  };

  const clearCanvas = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
  };

  const handleCoSign = () => {
    setShowPinPrompt(true);
  };

  const verifyPin = () => {
    if (pinCode === '1234' || pinCode === '9999') {
      setPinError(false);
      setShowPinPrompt(false);
      setIsSigned(true);
      const now = new Date();
      const timeStr = now.toTimeString().split(' ')[0];
      setSignatureDate(`${String(now.getDate()).padStart(2, '0')}/${String(now.getMonth() + 1).padStart(2, '0')}/${now.getFullYear()} at ${timeStr}`);
      toast.success(isRTL ? "تم التوقيع بنجاح" : "Co-signature added successfully!");
    } else {
      setPinError(true);
      setPinCode('');
      toast.error(isRTL ? "رمز PIN غير صحيح" : "Incorrect verification PIN.");
    }
  };

  const handleSubmitToPrincipal = () => {
    toast.success(isRTL ? "تم إرسال التقرير بنجاح للمدير" : "Report submitted to Principal successfully!");
    setTimeout(() => {
      navigate('/physician/dashboard');
    }, 1500);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[120px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* iOS status bar spacer */}
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
            {isRTL ? 'التوقيع المشترك للتقرير' : 'Report Co-Signature'}
          </h1>
          <p className="text-[11px] text-[#64748B]">
            {isRTL ? 'مراجعة وتوقيع' : 'Review & Sign'}
          </p>
        </div>
      </header>

      {/* Main Content */}
      <div className="px-4 py-4 space-y-4">
        
        {/* Report Metadata Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3 text-left">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-lg bg-[#EFF6FF] text-[#2563EB] flex items-center justify-center flex-shrink-0">
              <FileText className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-[15px] font-bold text-gray-900">{report.title}</h2>
              <p className="text-xs text-[#64748B] mt-0.5">{isRTL ? 'النطاق الزمني:' : 'Period:'} {report.dateRange}</p>
            </div>
          </div>
          <div className="pt-2.5 border-t border-gray-100 flex items-center justify-between text-xs text-[#64748B]">
            <span>{isRTL ? `الممرضة: ${report.nurseName}` : `Nurse: ${report.nurseName}`}</span>
            <span>{isRTL ? `ترخيص: ${report.nurseLicense}` : `License: ${report.nurseLicense}`}</span>
          </div>
        </div>

        {/* Scrollable Document Preview Sheet */}
        <div>
          <span className="block text-[13px] font-bold text-[#64748B] uppercase tracking-wider mb-2 text-left">
            {isRTL ? 'معاينة التقرير الطبي' : 'Report Document Preview'}
          </span>
          <div className="bg-white rounded-xl border border-gray-300 p-6 shadow-inner max-h-[300px] overflow-y-auto text-left space-y-4 select-none relative font-serif">
            {/* Sheet header */}
            <div className="text-center space-y-1 pb-4 border-b border-gray-200 font-sans">
              <h3 className="text-sm font-bold uppercase tracking-wide text-gray-900">{report.schoolName}</h3>
              <h4 className="text-xs font-bold text-gray-600">SCHOOL HEALTH CLINIC CLINICAL SUMMARY</h4>
              <p className="text-[10px] text-[#64748B]">Compliance Ref: DHA/HRS/HPSD/ST-22</p>
            </div>

            {/* Simulated content paragraphs */}
            <div className="space-y-3 text-xs leading-relaxed text-gray-800">
              <p>
                This report summarizes clinical activity at the {report.schoolName} health center for the period {report.dateRange}. All activities were conducted under standard DHA clinical protocols.
              </p>
              
              {/* Stats table */}
              <div className="bg-slate-50 p-3 rounded-lg border border-gray-200 space-y-1 font-sans">
                <div className="flex justify-between text-[11px] font-bold border-b border-gray-100 pb-1">
                  <span>Metric Indicator</span>
                  <span>Value</span>
                </div>
                <div className="flex justify-between text-[11px]">
                  <span>Total Student Clinic Visits</span>
                  <span>{report.stats.totalVisits}</span>
                </div>
                <div className="flex justify-between text-[11px]">
                  <span>Medication Administrations</span>
                  <span>{report.stats.medsAdministered}</span>
                </div>
                <div className="flex justify-between text-[11px]">
                  <span>Escalated Hospital Referrals</span>
                  <span>{report.stats.referralsSent}</span>
                </div>
                <div className="flex justify-between text-[11px]">
                  <span>Critical Emergency Transport</span>
                  <span>{report.stats.emergencies}</span>
                </div>
              </div>

              <p>
                All student medication administrations were executed pursuant to approved parent consent configurations. No adverse incidents occurred.
              </p>
            </div>

            {/* Nurse Signature block */}
            <div className="pt-4 border-t border-gray-200 text-xs flex justify-between items-end font-sans">
              <div className="space-y-0.5">
                <span className="block text-[10px] text-[#64748B] uppercase">Submitted By:</span>
                <span className="font-bold text-gray-900">{report.nurseName}</span>
                <span className="block text-[9px] text-emerald-600 font-semibold bg-emerald-50 px-1.5 py-0.5 rounded inline-block border border-emerald-200">
                  Signed: {report.signedDate}
                </span>
              </div>
              <div className="font-serif italic text-lg text-slate-500 pr-4">
                Emily Smith
              </div>
            </div>

            {/* Physician Co-Signature print if signed */}
            {isSigned && (
              <div className="pt-4 border-t border-gray-200 text-xs flex justify-between items-end font-sans animate-scale-in">
                <div className="space-y-0.5">
                  <span className="block text-[10px] text-[#64748B] uppercase">Co-Signed By:</span>
                  <span className="font-bold text-gray-900">Dr. Amina Al-Hashimi</span>
                  <span className="block text-[9px] text-[#0D9488] font-semibold bg-teal-50 px-1.5 py-0.5 rounded inline-block border border-teal-200">
                    Approved: {signatureDate}
                  </span>
                </div>
                <div className="font-serif italic text-lg text-[#0D9488] pr-4">
                  Dr. Amina H.
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Review Notes Input */}
        <div className="text-left">
          <label className="block text-[13px] font-bold text-[#64748B] uppercase tracking-wider mb-1">
            {isRTL ? 'ملاحظات الطبيب (اختياري)' : 'Physician Review Notes'}
          </label>
          <textarea
            disabled={isSigned}
            value={reviewNotes}
            onChange={(e) => setReviewNotes(e.target.value)}
            placeholder={isRTL ? "أدخل أي ملاحظات مرافقة للتقرير هنا..." : "Enter any review notes or caveats to submit with the signed document..."}
            rows={3}
            className="w-full p-3 border border-gray-200 rounded-lg text-sm bg-white text-[#0f172a] focus:outline-none focus:border-[#0D9488] focus:ring-1 focus:ring-[#0D9488] disabled:bg-slate-50"
          />
        </div>

        {/* Interactive Signature Area */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
          <div className="flex items-center justify-between">
            <span className="text-[13px] font-bold text-[#0F172A] text-left block">
              {isRTL ? 'توقيع الطبيب المعتمد' : 'Physician Approval Signature'}
            </span>
            {!isSigned && (
              <button 
                type="button"
                onClick={clearCanvas}
                className="text-xs text-[#64748B] hover:text-[#0D9488] font-semibold"
              >
                {isRTL ? 'مسح التوقيع' : 'Clear Pad'}
              </button>
            )}
          </div>

          {!isSigned ? (
            <div className="space-y-4">
              {/* signature drawing canvas pad */}
              <div className="w-full h-[120px] bg-slate-50 rounded-lg border-2 border-dashed border-gray-300 relative overflow-hidden flex items-center justify-center">
                <canvas
                  ref={canvasRef}
                  width={345}
                  height={120}
                  onMouseDown={startDrawing}
                  onMouseMove={draw}
                  onMouseUp={stopDrawing}
                  onMouseLeave={stopDrawing}
                  onTouchStart={startDrawing}
                  onTouchMove={draw}
                  onTouchEnd={stopDrawing}
                  className="w-full h-full cursor-crosshair relative z-10"
                />
                <div className="absolute inset-0 flex items-center justify-center pointer-events-none select-none text-[11px] text-[#94A3B8]">
                  {isRTL ? 'ارسم توقيعك هنا' : 'Draw your signature here'}
                </div>
              </div>

              {/* UAE Pass alternative button */}
              <UAEPassSignOption />
            </div>
          ) : (
            <div className="bg-[#E6F4EA] border border-[#A3E635] rounded-lg p-3 flex items-center gap-2 text-left">
              <CheckCircle className="w-5 h-5 text-emerald-600 flex-shrink-0" />
              <div>
                <span className="text-xs font-bold text-[#137333] block">
                  {isRTL ? 'تم التوقيع المشترك وتأمين الملف' : 'Dual-Authentication Co-Signed'}
                </span>
                <span className="text-[10px] text-[#137333] block">
                  {isRTL ? `المستند محمي تشفيرياً · ${signatureDate}` : `Cryptographically secured · ${signatureDate}`}
                </span>
              </div>
            </div>
          )}
        </div>

        {/* Primary Screen CTAs */}
        {isSigned ? (
          <div className="grid grid-cols-2 gap-3 pt-2">
            <button
              onClick={() => toast.success(isRTL ? "بدء تحميل ملف PDF..." : "Exporting signed report PDF...")}
              className="h-[52px] bg-white border-2 border-[#0D9488] text-[#0D9488] rounded-xl font-bold text-xs flex items-center justify-center gap-1.5 cursor-pointer"
            >
              <Download className="w-4 h-4" />
              {isRTL ? 'تصدير بصيغة PDF' : 'Export PDF'}
            </button>
            <button
              onClick={handleSubmitToPrincipal}
              className="h-[52px] bg-[#0D9488] hover:bg-[#0B7A70] text-white rounded-xl font-bold text-xs flex items-center justify-center gap-1.5 cursor-pointer shadow-md"
            >
              <Send className="w-4 h-4" />
              {isRTL ? 'إرسال لمدير المدرسة' : 'Submit to Principal'}
            </button>
          </div>
        ) : (
          <button
            onClick={handleCoSign}
            className="w-full h-[52px] bg-[#0D9488] hover:bg-[#0B7A70] text-white rounded-xl font-bold text-[15px] flex items-center justify-center gap-2 cursor-pointer shadow-md"
          >
            <Lock className="w-4 h-4" />
            {isRTL ? 'إضافة توقيعي المشترك' : 'Add Co-Signature'}
          </button>
        )}
      </div>

      {/* Signature Authorization PIN Modal */}
      {showPinPrompt && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full border border-gray-100 shadow-xl space-y-4">
            <div className="text-center space-y-1">
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'رمز أمان التوقيع' : 'Verification PIN Required'}
              </h3>
              <p className="text-xs text-[#64748B]">
                {isRTL 
                  ? 'أدخل رمز PIN الخاص بملفك الطبي لإقرار التوقيع المشترك.'
                  : 'Enter your 4-digit verification PIN to confirm report co-signature.'}
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
                {isRTL ? 'تأكيد التوقيع' : 'Confirm'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
export default ReportCoSignature;
