import { useNavigate } from 'react-router';
import { AlertTriangle, RefreshCw } from 'lucide-react';

export function CafeteriaRealtimeAlert() {
  const navigate = useNavigate();

  const handleRefresh = () => {
    // In real app, would fetch updated data
    navigate('/cafeteria/alerts');
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Full-Screen Modal Overlay */}
      <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
        <div className="bg-white rounded-2xl border-4 border-[#DC2626] p-6 max-w-sm w-full shadow-2xl">
          <div className="flex flex-col items-center text-center">
            {/* Alert Icon */}
            <div className="w-20 h-20 rounded-full bg-[#FEE2E2] flex items-center justify-center mb-4">
              <AlertTriangle className="w-10 h-10 text-[#DC2626]" />
            </div>

            {/* Alert Content */}
            <h2 className="text-[20px] font-bold text-[#DC2626] mb-3">
              New Allergy Alert
            </h2>

            <p className="text-[15px] text-gray-900 mb-2 leading-relaxed">
              An allergen restriction has been updated for a student in your service area.
            </p>

            <p className="text-[14px] text-[#64748B] mb-6 leading-relaxed">
              You must refresh the list to see the updated information before continuing meal service.
            </p>

            {/* Refresh Button - Cannot dismiss without tapping */}
            <button
              onClick={handleRefresh}
              className="w-full px-4 py-3.5 bg-[#DC2626] text-white rounded-lg text-[16px] font-bold min-h-[52px] flex items-center justify-center gap-2"
            >
              <RefreshCw className="w-5 h-5" />
              Refresh List Now
            </button>

            {/* Safety Notice */}
            <div className="mt-4 bg-[#FEF3C7] rounded-lg p-3 w-full">
              <p className="text-[12px] text-[#92400E] font-medium">
                For student safety, this alert cannot be dismissed without refreshing.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Background Content (blurred) */}
      <div className="opacity-30 pointer-events-none">
        <div className="bg-white border-b border-gray-200 px-4 py-3">
          <h1 className="text-[17px] font-medium text-gray-900">
            Today's Meal Restrictions
          </h1>
        </div>
      </div>
    </div>
  );
}
