import { useNavigate } from 'react-router';
import { CheckCircle, Bell, Clock, FileText } from 'lucide-react';

export function ParentSetupComplete() {
  const navigate = useNavigate();

  const handleGoToDashboard = () => {
    navigate('/parent/app/home');
  };

  return (
    <div className="min-h-screen bg-white flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Progress Bar - Complete */}
      <div className="h-1 bg-[#10B981]" />

      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
        {/* Success Animation */}
        <div className="w-24 h-24 rounded-full bg-[#D1FAE5] flex items-center justify-center mb-8 animate-scale-in">
          <CheckCircle className="w-14 h-14 text-[#10B981]" />
        </div>

        {/* Success Message */}
        <h1 className="text-[24px] font-semibold text-gray-900 mb-3 text-center">
          You're all set!
        </h1>
        <p className="text-[15px] text-[#64748B] mb-12 text-center">
          Maya's health profile is now active.
        </p>

        {/* What's Next Section */}
        <div className="w-full max-w-sm">
          <h2 className="text-[15px] font-semibold text-gray-900 mb-4">
            What's next
          </h2>

          <div className="space-y-4">
            {/* Clinic Alerts */}
            <div className="flex gap-3">
              <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <Bell className="w-5 h-5 text-[#2563EB]" />
              </div>
              <div className="flex-1 pt-1">
                <p className="text-[14px] text-gray-900 leading-relaxed">
                  You'll get alerts when Maya visits the clinic
                </p>
              </div>
            </div>

            {/* Medication Times */}
            <div className="flex gap-3">
              <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <Clock className="w-5 h-5 text-[#2563EB]" />
              </div>
              <div className="flex-1 pt-1">
                <p className="text-[14px] text-gray-900 leading-relaxed">
                  Report medication times here
                </p>
              </div>
            </div>

            {/* Health Records */}
            <div className="flex gap-3">
              <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <FileText className="w-5 h-5 text-[#2563EB]" />
              </div>
              <div className="flex-1 pt-1">
                <p className="text-[14px] text-gray-900 leading-relaxed">
                  View health records anytime
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Action */}
      <div className="p-6 border-t border-gray-200 bg-white">
        <button
          onClick={handleGoToDashboard}
          className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold"
        >
          Go to Dashboard
        </button>
      </div>

      <style>{`
        @keyframes scale-in {
          from {
            transform: scale(0);
            opacity: 0;
          }
          to {
            transform: scale(1);
            opacity: 1;
          }
        }
        .animate-scale-in {
          animation: scale-in 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
      `}</style>
    </div>
  );
}