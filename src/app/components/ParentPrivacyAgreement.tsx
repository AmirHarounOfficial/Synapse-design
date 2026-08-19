import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, AlertTriangle } from 'lucide-react';

export function ParentPrivacyAgreement() {
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
      navigate('/parent/onboarding/documents');
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
        <div className="h-full bg-[#2563EB]" style={{ width: '50%' }} />
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
          Step 2 of 4 — Privacy & Data Agreement
        </h1>
      </header>

      {!isSigning ? (
        <>
          {/* Scrollable Content */}
          <div
            ref={scrollRef}
            onScroll={handleScroll}
            className="flex-1 overflow-y-auto px-4 py-4"
          >
            <div className="prose prose-sm max-w-none">
              <h2 className="text-[17px] font-semibold text-gray-900 mb-4">
                Privacy & Data Usage Agreement
              </h2>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                1. Digital Health Record Storage
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                I consent to the digital storage of my child's health records within the SchooKeep platform. Records are encrypted at rest and in transit using AES-256 encryption and stored on HIPAA-compliant servers located in the United States.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                2. Data Access and Sharing
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                Health records will only be accessible to authorized school personnel with a legitimate educational interest, including: school nurses, administrators, and designated teachers for students with accommodation plans. No data will be shared with third parties without explicit written consent, except as required by law.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                3. FERPA Compliance
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                All data handling complies with the Family Educational Rights and Privacy Act (FERPA). You have the right to inspect and review your child's health records, request corrections, and control the disclosure of personally identifiable information.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                4. Anonymized Research Data Use
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                De-identified, aggregated data may be used for research purposes to improve health outcomes for K-12 students. All personally identifiable information is removed before data is used for research. Individual students cannot be identified from research data.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                5. Data Retention and Deletion
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                Health records are retained for seven years after the student graduates or withdraws from the district, as required by state law. You may request deletion of non-legally required data at any time by submitting a written request to the school nurse.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                6. Parent/Guardian Access Rights
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                You have 24/7 access to your child's health records through the SchooKeep parent portal. You will receive real-time notifications for: clinic visits, medication administration, health alerts, and document updates. You may export all records in PDF format at any time.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                7. Security Breach Notification
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                In the unlikely event of a data breach affecting your child's information, you will be notified within 72 hours via email and push notification. The notification will include details about what data was affected and steps being taken to protect your child's information.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                8. Third-Party Service Providers
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                SchooKeep uses HIPAA-compliant third-party services for: cloud hosting (AWS), authentication (Auth0), and analytics (privacy-focused, no personal data shared). All vendors have signed Business Associate Agreements (BAAs).
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                9. Communication Preferences
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-4">
                You consent to receive health-related notifications via: push notifications, SMS text messages, and email. You may update notification preferences at any time in app settings. Critical emergency notifications cannot be disabled.
              </p>

              <h3 className="text-[15px] font-semibold text-gray-900 mb-2 mt-6">
                10. Agreement Duration and Revocation
              </h3>
              <p className="text-[14px] text-[#64748B] leading-relaxed mb-6">
                This agreement remains in effect until revoked in writing or until your child is no longer enrolled in the school district. Revocation of consent may affect your child's ability to participate in certain school health services and activities.
              </p>

              <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mb-4">
                <p className="text-[12px] text-[#64748B] leading-relaxed">
                  By signing below, I acknowledge that I have read, understand, and agree to all terms of this Privacy & Data Usage Agreement.
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
