import { useNavigate } from 'react-router';
import { Check, Lock } from 'lucide-react';
import { useEffect, useState } from 'react';

export function SecurityAuthorizedConfirmation() {
  const navigate = useNavigate();
  const [currentTime] = useState(
    new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
  );

  // Auto-redirect after 3 seconds
  useEffect(() => {
    const timer = setTimeout(() => {
      navigate('/security/pickups');
    }, 3000);

    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className="min-h-screen bg-[#10B981] flex items-center justify-center p-4 pb-[83px]">
      {/* Status Bar */}
      <div className="fixed top-0 left-0 right-0 h-[44px] bg-[#10B981]" />

      <div className="text-center max-w-sm w-full">
        {/* Animated Checkmark */}
        <div className="relative mb-8">
          <div className="w-32 h-32 rounded-full bg-white/20 flex items-center justify-center mx-auto animate-pulse">
            <div className="w-28 h-28 rounded-full bg-white/30 flex items-center justify-center">
              <Check className="w-20 h-20 text-white" strokeWidth={3} />
            </div>
          </div>
        </div>

        <h1 className="text-[32px] font-bold text-white mb-4">
          Student Released
        </h1>

        {/* Release Details */}
        <div className="bg-white/10 backdrop-blur rounded-2xl p-6 mb-6 text-left">
          <div className="mb-4 pb-4 border-b border-white/20">
            <div className="text-white/70 text-[12px] mb-1">
              STUDENT
            </div>
            <div className="text-white text-[17px] font-semibold">
              Maya Chen
            </div>
          </div>

          <div className="mb-4 pb-4 border-b border-white/20">
            <div className="text-white/70 text-[12px] mb-1">
              RELEASED TO
            </div>
            <div className="text-white text-[17px] font-semibold">
              Dr. Jennifer Chen
            </div>
            <div className="text-white/80 text-[13px]">
              Mother
            </div>
          </div>

          <div className="mb-4 pb-4 border-b border-white/20">
            <div className="text-white/70 text-[12px] mb-1">
              TIME
            </div>
            <div className="text-white text-[17px] font-semibold">
              {currentTime}
            </div>
          </div>

          <div>
            <div className="text-white/70 text-[12px] mb-1">
              VERIFIED BY
            </div>
            <div className="text-white text-[17px] font-semibold">
              Security Officer M. Johnson #042
            </div>
          </div>
        </div>

        {/* Locked Record Notice */}
        <div className="bg-white/10 backdrop-blur rounded-xl p-4 mb-6">
          <div className="flex items-start gap-3">
            <Lock className="w-5 h-5 text-white flex-shrink-0 mt-0.5" />
            <div className="flex-1 text-left">
              <div className="text-white text-[14px] font-semibold mb-1">
                This release has been logged
              </div>
              <div className="text-white/80 text-[12px] leading-relaxed">
                Permanent record created for security and compliance purposes. Cannot be modified.
              </div>
            </div>
          </div>
        </div>

        <button
          onClick={() => navigate('/security/pickups')}
          className="w-full px-4 py-4 bg-white text-[#10B981] rounded-lg text-[17px] font-semibold min-h-[52px] shadow-lg"
        >
          Return to Pickups
        </button>

        <p className="text-white/70 text-[13px] mt-4">
          Redirecting automatically in 3 seconds...
        </p>
      </div>
    </div>
  );
}
