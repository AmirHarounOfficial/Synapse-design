import { FileText, CheckCircle } from 'lucide-react';
import { useRef, useState, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { useLanguage } from '../../context/LanguageContext';

export function ESignature() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [hasSignature, setHasSignature] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [signatureTime, setSignatureTime] = useState('');

  useEffect(() => {
    const now = new Date();
    const formatted = now.toLocaleDateString(isRTL ? 'ar-AE' : 'en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric'
    }) + ' ' + now.toLocaleTimeString(isRTL ? 'ar-AE' : 'en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });
    setSignatureTime(formatted);

    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    canvas.width = canvas.offsetWidth * 2;
    canvas.height = canvas.offsetHeight * 2;
    ctx.scale(2, 2);

    ctx.strokeStyle = '#0F172A';
    ctx.lineWidth = 2;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
  }, [isRTL]);

  const startDrawing = (e: React.MouseEvent | React.TouchEvent) => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    setIsDrawing(true);
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const rect = canvas.getBoundingClientRect();
    const x = 'touches' in e ? e.touches[0].clientX - rect.left : e.clientX - rect.left;
    const y = 'touches' in e ? e.touches[0].clientY - rect.top : e.clientY - rect.top;

    ctx.beginPath();
    ctx.moveTo(x, y);
  };

  const draw = (e: React.MouseEvent | React.TouchEvent) => {
    if (!isDrawing) return;

    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const rect = canvas.getBoundingClientRect();
    const x = 'touches' in e ? e.touches[0].clientX - rect.left : e.clientX - rect.left;
    const y = 'touches' in e ? e.touches[0].clientY - rect.top : e.clientY - rect.top;

    ctx.lineTo(x, y);
    ctx.stroke();

    setHasSignature(true);
  };

  const stopDrawing = () => {
    setIsDrawing(false);
  };

  const clearSignature = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    setHasSignature(false);
  };

  const handleSubmit = () => {
    if (!hasSignature) return;

    setIsSubmitting(true);

    setTimeout(() => {
      setIsSubmitting(false);
      setShowSuccess(true);

      setTimeout(() => {
        navigate('/principal/home');
      }, 1500);
    }, 1500);
  };

  return (
    <div className="w-full h-screen bg-[#F8FAFC] flex flex-col" dir={isRTL ? 'rtl' : 'ltr'}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <h1 className="text-[17px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
          {isRTL ? 'التوقيع والتأكيد' : 'Sign & Confirm'}
        </h1>
        <span className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
          {isRTL ? 'الخطوة 2 من 2' : 'Step 2 of 2'}
        </span>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-4 py-6">
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] mb-6">
          <div className="flex gap-3 items-center">
            <div className="w-10 h-10 rounded-full bg-[#2563EB]/10 flex items-center justify-center flex-shrink-0">
              <FileText className="w-5 h-5 text-[#2563EB]" />
            </div>
            <p className="text-[14px] text-[#64748B]" style={{ fontWeight: 400 }}>
              {isRTL
                ? 'بالتوقيع أدناه، فإنك توافق على الالتزام بالسرية التامة لجميع البيانات الصحية الطلابية المسجلة.'
                : 'By signing, you agree to maintain confidentiality of all student health data in your care.'}
            </p>
          </div>
        </div>

        {/* Signature pad */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] mb-4">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
              {isRTL ? 'التوقيع الإلكتروني' : 'Your Signature'}
            </span>
            <button
              onClick={clearSignature}
              className="text-[13px] text-[#2563EB] font-medium min-h-[44px] px-3 cursor-pointer"
              style={{ fontWeight: 500 }}
            >
              {isRTL ? 'مسح' : 'Clear'}
            </button>
          </div>

          <div className="relative">
            <canvas
              ref={canvasRef}
              onMouseDown={startDrawing}
              onMouseMove={draw}
              onMouseUp={stopDrawing}
              onMouseLeave={stopDrawing}
              onTouchStart={startDrawing}
              onTouchMove={draw}
              onTouchEnd={stopDrawing}
              className="w-full h-[200px] border-2 border-dashed border-[#E2E8F0] rounded-lg bg-[#FFFFFF] cursor-crosshair touch-none"
            />
            {!hasSignature && (
              <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                <span className="text-[#E2E8F0] text-[16px]" style={{ fontWeight: 400 }}>
                  {isRTL ? 'وقع هنا' : 'Sign here'}
                </span>
              </div>
            )}
          </div>

          <div className="mt-3">
            <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
              {isRTL ? `تاريخ التوقيع: ${signatureTime}` : `Signed: ${signatureTime}`}
            </p>
          </div>
        </div>

        <button
          onClick={handleSubmit}
          disabled={!hasSignature || isSubmitting}
          className={`w-full h-[52px] rounded-xl font-semibold transition-all cursor-pointer ${
            hasSignature && !isSubmitting
              ? 'bg-[#2563EB] text-white'
              : 'bg-[#2563EB] text-white opacity-40 cursor-not-allowed'
          }`}
          style={{ fontWeight: 600 }}
        >
          {isSubmitting ? (
            <span className="flex items-center justify-center gap-2">
              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              {isRTL ? 'جاري إرسال التوقيع...' : 'Submitting...'}
            </span>
          ) : (
            isRTL ? 'إرسال التوقيع' : 'Submit Signature'
          )}
        </button>
      </div>

      {showSuccess && (
        <div className="absolute inset-0 bg-[#FFFFFF] flex items-center justify-center z-50">
          <div className="text-center animate-scale-in">
            <div className="w-20 h-20 rounded-full bg-[#10B981] flex items-center justify-center mx-auto mb-4">
              <CheckCircle className="w-12 h-12 text-white" />
            </div>
            <h2 className="text-[20px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
              {isRTL ? 'تمت الموافقة والتوقيع بنجاح' : 'Agreement Complete'}
            </h2>
            <p className="text-[14px] text-[#64748B] mt-2" style={{ fontWeight: 400 }}>
              {isRTL ? 'جاري توجيهك إلى لوحة التحكم...' : 'Redirecting to dashboard...'}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
