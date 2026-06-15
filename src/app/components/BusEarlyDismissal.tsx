import { useNavigate } from 'react-router';
import { AlertTriangle, Check } from 'lucide-react';
import { useState } from 'react';

export function BusEarlyDismissal() {
  const navigate = useNavigate();
  const [isAcknowledged, setIsAcknowledged] = useState(false);

  const student = {
    name: 'Maya Chen',
    grade: '3rd Grade',
    stopNumber: 4,
    reason: 'Medical appointment',
    dismissedAt: '1:45 PM'
  };

  const handleAcknowledge = () => {
    setIsAcknowledged(true);
    // Log acknowledgment
    setTimeout(() => {
      navigate('/bus/route');
    }, 1500);
  };

  return (
    <div className="min-h-screen bg-[#FEF3C7] flex items-center justify-center p-4 pb-[83px]">
      {/* Status Bar */}
      <div className="fixed top-0 left-0 right-0 h-[44px] bg-[#FEF3C7]" />

      <div className="max-w-sm w-full">
        {!isAcknowledged ? (
          <>
            {/* Alert Icon */}
            <div className="w-24 h-24 rounded-full bg-white/50 flex items-center justify-center mx-auto mb-6">
              <AlertTriangle className="w-16 h-16 text-[#F59E0B]" />
            </div>

            <h1 className="text-[28px] font-bold text-[#92400E] mb-4 text-center">
              Early Dismissal Alert
            </h1>

            {/* Student Info Card */}
            <div className="bg-white rounded-2xl p-6 mb-6 shadow-lg">
              <div className="text-center mb-4">
                <div className="text-[20px] font-bold text-gray-900 mb-2">
                  {student.name}
                </div>
                <div className="text-[14px] text-[#64748B] mb-1">
                  {student.grade}
                </div>
                <div className="inline-flex items-center px-3 py-1.5 rounded-lg bg-[#F8FAFC] text-[#64748B] text-[13px] font-medium">
                  Usually at Stop {student.stopNumber}
                </div>
              </div>

              <div className="pt-4 border-t border-gray-200 space-y-3">
                <div>
                  <div className="text-[12px] text-[#64748B] mb-1">
                    DISMISSAL TIME
                  </div>
                  <div className="text-[15px] font-semibold text-gray-900">
                    {student.dismissedAt}
                  </div>
                </div>
                <div>
                  <div className="text-[12px] text-[#64748B] mb-1">
                    REASON
                  </div>
                  <div className="text-[15px] font-semibold text-gray-900">
                    {student.reason}
                  </div>
                </div>
              </div>
            </div>

            {/* Warning Message */}
            <div className="bg-[#F59E0B] text-white rounded-xl p-4 mb-6">
              <p className="text-[15px] font-semibold text-center leading-relaxed">
                {student.name} will NOT be on the afternoon bus.
              </p>
              <p className="text-[14px] text-center mt-2">
                Do not wait at Stop {student.stopNumber} this afternoon.
              </p>
            </div>

            {/* Acknowledge Button */}
            <button
              onClick={handleAcknowledge}
              className="w-full px-4 py-4 bg-white text-[#F59E0B] rounded-lg text-[17px] font-semibold min-h-[52px] shadow-lg border-2 border-[#F59E0B]"
            >
              Acknowledge Alert
            </button>

            <p className="text-[12px] text-[#92400E] text-center mt-4">
              This acknowledgment will be logged for compliance purposes.
            </p>
          </>
        ) : (
          <>
            {/* Success State */}
            <div className="w-24 h-24 rounded-full bg-white/50 flex items-center justify-center mx-auto mb-6 animate-pulse">
              <Check className="w-16 h-16 text-[#10B981]" />
            </div>

            <h2 className="text-[24px] font-bold text-[#065F46] mb-4 text-center">
              Alert Acknowledged
            </h2>

            <div className="bg-white rounded-2xl p-6 mb-6 shadow-lg">
              <p className="text-[14px] text-[#64748B] text-center leading-relaxed">
                You have acknowledged the early dismissal for <strong className="text-gray-900">{student.name}</strong>.
              </p>
              <p className="text-[13px] text-[#64748B] text-center mt-3">
                This has been recorded at {new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
              </p>
            </div>

            <p className="text-[13px] text-[#92400E] text-center">
              Returning to route overview...
            </p>
          </>
        )}
      </div>
    </div>
  );
}
