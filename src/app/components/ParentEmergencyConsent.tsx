import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, AlertTriangle, CheckCircle } from 'lucide-react';

export function ParentEmergencyConsent() {
  const navigate = useNavigate();
  const [scrolledToBottom, setScrolledToBottom] = useState(false);
  const [isSigning, setIsSigning] = useState(false);
  const [signature, setSignature] = useState<string | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [isDrawing, setIsDrawing] = useState(false);

  const handleScroll = () => {
    if (scrollRef.current) {
      const { scrollTop, scrollHeight, clientHeight } = scrollRef.current;
      const isAtBottom = scrollTop + clientHeight >= scrollHeight - 10;
      if (isAtBottom && !scrolledToBottom) {
        setScrolledToBottom(true);
      }
    }
  };

  const startDrawing = (e: React.TouchEvent<HTMLCanvasElement> | React.MouseEvent<HTMLCanvasElement>) => {
    setIsDrawing(true);
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const rect = canvas.getBoundingClientRect();
    const x = 'touches' in e ? e.touches[0].clientX - rect.left : e.clientX - rect.left;
    const y = 'touches' in e ? e.touches[0].clientY - rect.top : e.clientY - rect.top;

    ctx.beginPath();
    ctx.moveTo(x, y);
  };

  const draw = (e: React.TouchEvent<HTMLCanvasElement> | React.MouseEvent<HTMLCanvasElement>) => {
    if (!isDrawing) return;
    
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const rect = canvas.getBoundingClientRect();
    const x = 'touches' in e ? e.touches[0].clientX - rect.left : e.clientX - rect.left;
    const y = 'touches' in e ? e.touches[0].clientY - rect.top : e.clientY - rect.top;

    ctx.lineTo(x, y);
    ctx.strokeStyle = '#1F2937';
    ctx.lineWidth = 2;
    ctx.lineCap = 'round';
    ctx.stroke();
  };

  const stopDrawing = () => {
    setIsDrawing(false);
    const canvas = canvasRef.current;
    if (canvas) {
      const dataUrl = canvas.toDataURL();
      setSignature(dataUrl);
    }
  };

  const clearSignature = () => {
    const canvas = canvasRef.current;
    if (canvas) {
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        setSignature(null);
      }
    }
  };

  const handleContinue = () => {
    if (signature) {
      navigate('/parent/onboarding/privacy-agreement');
    }
  };

  useEffect(() => {
    const canvas = canvasRef.current;
    if (canvas) {
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.fillStyle = '#FFFFFF';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
      }
    }
  }, [isSigning]);

  return (
    <div className="min-h-screen bg-white flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Progress Bar */}
      <div className="h-1 bg-gray-100">
        <div className="h-full bg-[#2563EB]" style={{ width: '37.5%' }} />
      </div>

      {/* App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 -ml-2 flex items-center justify-center"
        >
          <ArrowLeft className="w-6 h-6 text-gray-900" />
        </button>
        <h1 className="flex-1 text-center font-medium text-gray-900 pr-10">
          Step 1 of 4 — Emergency Care Consent
        </h1>
      </header>

      {!isSigning ? (
        <>
          {/* Amber Notice */}
          <div className="mx-4 mt-4 p-4 bg-[#FEF3C7] border border-[#F59E0B] rounded-xl flex gap-3">
            <AlertTriangle className="w-5 h-5 text-[#D97706] flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-[13px] font-semibold text-[#92400E] mb-1">
                Required Legal Document
              </p>
              <p className="text-[12px] text-[#92400E]">
                This document cannot be pre-filled. Please read carefully before signing.
              </p>
            </div>
          </div>

          {/* Scrollable Content */}
          <div
            ref={scrollRef}
            onScroll={handleScroll}
            className="flex-1 overflow-y-auto px-4 py-4"
          >
            <div className="prose prose-sm max-w-none">
              <h2 className="text-[17px] font-semibold text-gray-900 mb-4">
                Emergency Medical Care Authorization
              </h2>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                1. Emergency Transport Authorization
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                I hereby authorize school officials to seek emergency medical care for my child when I cannot be reached immediately. This includes transportation by ambulance or emergency vehicle to the nearest appropriate medical facility.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                2. First Aid Administration Consent
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                I consent to first aid treatment by trained school personnel including, but not limited to: wound care, ice pack application, CPR administration, and AED use if medically necessary.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                3. Medication Administration Rights
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                I authorize the school nurse or designated personnel to administer emergency medications including epinephrine auto-injectors (EpiPen), asthma rescue inhalers, glucose tablets for hypoglycemia, or other life-saving medications as prescribed by a physician.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                4. Medical Information Sharing
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                I authorize school health personnel to share necessary medical information with emergency medical technicians (EMTs), hospital staff, and other medical providers in emergency situations.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                5. Limitation of Liability
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                I understand that school personnel are not medical professionals (except licensed school nurses) and will act in good faith. I agree to hold the school, its employees, and volunteers harmless from liability when providing emergency care.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                6. Parent/Guardian Notification
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                I understand that school personnel will make every reasonable effort to contact me immediately in case of emergency, but that emergency care may be administered before I am reached.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                7. Duration and Revocation
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-6">
                This authorization remains in effect for the current school year and must be renewed annually. I may revoke this authorization in writing at any time, but understand that this may affect my child's ability to participate in certain school activities.
              </p>

              <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mb-4">
                <p className="text-[12px] text-[#64748B] leading-relaxed">
                  By signing below, I acknowledge that I have read, understand, and agree to all terms of this Emergency Medical Care Authorization.
                </p>
              </div>
            </div>
          </div>

          {/* Bottom Action */}
          <div className="p-4 border-t border-gray-200 bg-white">
            {!scrolledToBottom && (
              <div className="flex items-center gap-2 mb-3 text-[#F59E0B] text-[12px] font-medium">
                <AlertTriangle className="w-4 h-4" />
                Scroll to bottom to continue
              </div>
            )}
            <button
              onClick={() => setIsSigning(true)}
              disabled={!scrolledToBottom}
              className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold disabled:opacity-40 disabled:cursor-not-allowed"
            >
              Continue to Sign
            </button>
          </div>
        </>
      ) : (
        <>
          {/* Signature View */}
          <div className="flex-1 flex flex-col px-4 py-6">
            <div className="mb-4">
              <h2 className="text-[17px] font-semibold text-gray-900 mb-2">
                Sign Below
              </h2>
              <p className="text-[13px] text-[#64748B]">
                Draw your signature with your finger or stylus
              </p>
            </div>

            {/* Signature Canvas */}
            <div className="flex-1 flex items-center justify-center mb-4">
              <div className="w-full bg-white border-2 border-dashed border-gray-300 rounded-xl overflow-hidden">
                <canvas
                  ref={canvasRef}
                  width={361}
                  height={200}
                  onTouchStart={startDrawing}
                  onTouchMove={draw}
                  onTouchEnd={stopDrawing}
                  onMouseDown={startDrawing}
                  onMouseMove={draw}
                  onMouseUp={stopDrawing}
                  onMouseLeave={stopDrawing}
                  className="w-full touch-none"
                />
              </div>
            </div>

            {/* Date & Name */}
            <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mb-4">
              <div className="flex justify-between mb-2">
                <span className="text-[13px] text-[#64748B]">Date</span>
                <span className="text-[13px] font-medium text-gray-900">May 25, 2026</span>
              </div>
              <div className="flex justify-between">
                <span className="text-[13px] text-[#64748B]">Parent/Guardian</span>
                <span className="text-[13px] font-medium text-gray-900">Jennifer Thompson</span>
              </div>
            </div>

            <div className="flex gap-3">
              <button
                onClick={clearSignature}
                className="flex-1 min-h-[52px] px-4 py-3.5 bg-white text-gray-900 border border-gray-200 rounded-lg text-[15px] font-medium"
              >
                Clear
              </button>
              <button
                onClick={handleContinue}
                disabled={!signature}
                className="flex-1 min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold disabled:opacity-40 disabled:cursor-not-allowed"
              >
                Sign & Continue
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
