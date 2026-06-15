import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { CheckCircle, Phone } from 'lucide-react';

export function ParentEmergencyConsentResponse() {
  const navigate = useNavigate();
  const [timeRemaining, setTimeRemaining] = useState(503); // 8:23 in seconds
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [responseType, setResponseType] = useState<'authorize' | 'decline' | null>(null);

  useEffect(() => {
    const interval = setInterval(() => {
      setTimeRemaining((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const calculateProgress = () => {
    // Assuming 30 minutes total (1800 seconds)
    const total = 1800;
    return (timeRemaining / total) * 100;
  };

  const handleAuthorize = () => {
    setResponseType('authorize');
    setShowConfirmation(true);
  };

  const handleDecline = () => {
    setResponseType('decline');
    setShowConfirmation(true);
  };

  const handleDone = () => {
    navigate('/parent/app/home');
  };

  if (showConfirmation) {
    return (
      <div className="min-h-screen bg-white flex flex-col">
        {/* Status Bar */}
        <div className="h-[44px] bg-white" />

        <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
          {/* Success Icon */}
          <div className={`w-24 h-24 rounded-full ${responseType === 'authorize' ? 'bg-[#D1FAE5]' : 'bg-[#FEE2E2]'} flex items-center justify-center mb-8`}>
            {responseType === 'authorize' ? (
              <CheckCircle className="w-14 h-14 text-[#10B981]" />
            ) : (
              <Phone className="w-14 h-14 text-[#DC2626]" />
            )}
          </div>

          {/* Message */}
          <h1 className="text-[24px] font-semibold text-gray-900 mb-3 text-center">
            {responseType === 'authorize' ? 'Transport Authorized' : 'Request Declined'}
          </h1>
          <p className="text-[15px] text-[#64748B] mb-8 text-center max-w-sm">
            {responseType === 'authorize' 
              ? 'School nurse has been notified and will proceed with emergency transport to Lakewood Medical Center.'
              : 'School nurse has been notified and will call you immediately to discuss next steps.'}
          </p>

          {/* Timestamp */}
          <div className="w-full max-w-sm bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mb-8">
            <div className="flex justify-between items-center mb-2">
              <span className="text-[13px] text-[#64748B]">Response logged at</span>
              <span className="text-[13px] font-medium text-gray-900">2:45 PM</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-[13px] text-[#64748B]">Parent/Guardian</span>
              <span className="text-[13px] font-medium text-gray-900">James Thompson</span>
            </div>
          </div>

          {/* Info */}
          <div className="w-full max-w-sm bg-[#EFF6FF] border border-[#2563EB] rounded-xl p-3 mb-8">
            <p className="text-[12px] text-[#1E40AF] leading-relaxed text-center">
              This response has been permanently logged for compliance and cannot be modified.
            </p>
          </div>
        </div>

        {/* Bottom Action */}
        <div className="p-4 border-t border-gray-200 bg-white">
          <button
            onClick={handleDone}
            className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold"
          >
            Done
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Red Header */}
      <div className="h-[120px] bg-[#DC2626] flex items-center justify-center px-6">
        <h1 className="text-[20px] font-semibold text-white text-center">
          🚨 Emergency Authorization Required
        </h1>
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-6">
        {/* Countdown Timer */}
        <div className="flex flex-col items-center mb-6">
          <div className="relative w-[90px] h-[90px] mb-3">
            <svg className="w-full h-full -rotate-90">
              <circle
                cx="45"
                cy="45"
                r="40"
                fill="none"
                stroke="#FEE2E2"
                strokeWidth="8"
              />
              <circle
                cx="45"
                cy="45"
                r="40"
                fill="none"
                stroke="#DC2626"
                strokeWidth="8"
                strokeDasharray={`${2 * Math.PI * 40}`}
                strokeDashoffset={`${2 * Math.PI * 40 * (1 - calculateProgress() / 100)}`}
                strokeLinecap="round"
              />
            </svg>
            <div className="absolute inset-0 flex items-center justify-center">
              <span className="text-[24px] font-semibold text-gray-900">
                {formatTime(timeRemaining)}
              </span>
            </div>
          </div>
          <p className="text-[13px] text-[#DC2626] font-medium">
            Request expires in {formatTime(timeRemaining)}
          </p>
        </div>

        {/* Incident Summary */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 mb-6">
          <h2 className="text-[15px] font-semibold text-gray-900 mb-3">
            Incident Summary
          </h2>

          {/* Photo */}
          <div className="w-full h-48 bg-gray-100 rounded-lg mb-3 flex items-center justify-center">
            <span className="text-[13px] text-[#64748B]">Photo uploaded by nurse</span>
          </div>

          <div className="space-y-2">
            <div className="flex justify-between">
              <span className="text-[13px] text-[#64748B]">Location</span>
              <span className="text-[13px] font-medium text-gray-900">School Clinic</span>
            </div>
            <div className="flex justify-between">
              <span className="text-[13px] text-[#64748B]">Severity</span>
              <span className="inline-flex items-center px-2 py-0.5 rounded bg-[#FEE2E2] text-[#DC2626] text-[11px] font-semibold">
                HIGH
              </span>
            </div>
            <div className="pt-2">
              <span className="text-[13px] text-[#64748B] block mb-1">Description</span>
              <p className="text-[14px] text-gray-900 leading-relaxed">
                Student experiencing severe allergic reaction. EpiPen administered at 2:38 PM. Symptoms improving but requires immediate medical evaluation.
              </p>
            </div>
          </div>
        </div>

        {/* Requested Action */}
        <div className="bg-[#F8FAFC] border-2 border-[#2563EB] rounded-xl p-4 mb-6">
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-2">
            REQUESTED ACTION
          </h2>
          <p className="text-[17px] font-medium text-gray-900">
            Authorize transport to Lakewood Medical Center
          </p>
        </div>

        {/* Warning */}
        <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-3 mb-6">
          <p className="text-[12px] text-[#92400E] leading-relaxed">
            Your response will be permanently logged and cannot be changed. School nurse will proceed based on your authorization.
          </p>
        </div>
      </div>

      {/* Bottom Actions */}
      <div className="p-4 border-t border-gray-200 bg-white space-y-3">
        <button
          onClick={handleAuthorize}
          className="w-full min-h-[56px] px-4 py-3.5 bg-[#10B981] text-white rounded-lg text-[15px] font-semibold flex items-center justify-center gap-2"
        >
          <CheckCircle className="w-5 h-5" />
          Authorize
        </button>

        <button
          onClick={handleDecline}
          className="w-full min-h-[56px] px-4 py-3.5 bg-white text-[#DC2626] border-2 border-[#DC2626] rounded-lg text-[15px] font-semibold flex items-center justify-center gap-2"
        >
          <Phone className="w-5 h-5" />
          Decline / Call me
        </button>
      </div>
    </div>
  );
}
