import { Phone } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function EmergencyEscalation() {
  const navigate = useNavigate();
  const [callStatus, setCallStatus] = useState<'calling' | 'ended'>('calling');
  const [decisionLog, setDecisionLog] = useState('');

  const handleLogDecision = () => {
    // Submit decision and return to clinic
    setTimeout(() => {
      navigate('/nurse/clinic');
    }, 500);
  };

  return (
    <div className="min-h-screen bg-[#DC2626] flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px]" />

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
        {/* Phone Icon with Pulse Rings */}
        <div className="relative mb-8">
          {callStatus === 'calling' && (
            <>
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-[120px] h-[120px] rounded-full bg-white/20 animate-ping" style={{ animationDuration: '2s' }} />
              </div>
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-[100px] h-[100px] rounded-full bg-white/30 animate-ping" style={{ animationDuration: '2s', animationDelay: '0.5s' }} />
              </div>
            </>
          )}
          <div className="relative w-20 h-20 rounded-full bg-white flex items-center justify-center">
            <Phone className="w-10 h-10 text-[#DC2626]" />
          </div>
        </div>

        {/* Heading */}
        <h1 className="text-[24px] font-semibold text-white text-center mb-3" style={{ fontWeight: 600 }}>
          {callStatus === 'calling' ? 'Calling Parent' : 'Call Ended'}
        </h1>

        {/* Subtitle */}
        <p className="text-[16px] text-white/90 text-center mb-2" style={{ fontWeight: 400 }}>
          {callStatus === 'calling' ? 'No Response Received' : 'Parent did not respond'}
        </p>

        {/* Details */}
        <p className="text-[14px] text-white/80 text-center px-4" style={{ fontWeight: 400 }}>
          Automatic emergency call initiated at 10:32 AM · Maya Chen · Playground incident
        </p>

        {/* Calling Indicator */}
        {callStatus === 'calling' && (
          <div className="mt-8">
            <div className="flex gap-2">
              <div className="w-3 h-3 rounded-full bg-white animate-bounce" style={{ animationDelay: '0ms' }} />
              <div className="w-3 h-3 rounded-full bg-white animate-bounce" style={{ animationDelay: '150ms' }} />
              <div className="w-3 h-3 rounded-full bg-white animate-bounce" style={{ animationDelay: '300ms' }} />
            </div>
          </div>
        )}

        {/* End Call Button (if calling) */}
        {callStatus === 'calling' && (
          <button
            onClick={() => setCallStatus('ended')}
            className="mt-12 w-full max-w-[280px] h-[52px] bg-white text-[#DC2626] rounded-xl font-semibold"
            style={{ fontWeight: 600 }}
          >
            End Call
          </button>
        )}
      </div>

      {/* Action Taken Section (appears after call ends) */}
      {callStatus === 'ended' && (
        <div className="bg-[#F8FAFC] rounded-t-3xl p-6 space-y-6">
          <div className="bg-[#FFFBEB] border-l-4 border-[#F59E0B] rounded-xl p-4">
            <h3 className="text-[14px] font-semibold text-[#92400E] mb-2" style={{ fontWeight: 600 }}>
              Action Required
            </h3>
            <p className="text-[13px] text-[#92400E]" style={{ fontWeight: 400 }}>
              You may now proceed on your professional judgment. Document your decision below.
            </p>
          </div>

          <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
            <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
              Decision Log *
            </label>
            <textarea
              value={decisionLog}
              onChange={(e) => setDecisionLog(e.target.value)}
              placeholder="Document your professional decision and next steps..."
              rows={6}
              className="w-full px-4 py-3 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB] resize-none"
              style={{ fontWeight: 400 }}
            />
            <p className="text-[12px] text-[#64748B] mt-2" style={{ fontWeight: 400 }}>
              This decision will be permanently logged with timestamp: May 24, 2026 at 10:35:42 AM
            </p>
          </div>

          <button
            onClick={handleLogDecision}
            disabled={decisionLog.trim().length === 0}
            className="w-full h-[52px] bg-[#DC2626] text-white rounded-xl font-semibold disabled:opacity-40"
            style={{ fontWeight: 600 }}
          >
            Log Decision
          </button>
        </div>
      )}
    </div>
  );
}
