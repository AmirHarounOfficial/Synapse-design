import { CheckCircle, Check } from 'lucide-react';
import { useState } from 'react';

export function CafeteriaEmptyState() {
  const [isAcknowledged, setIsAcknowledged] = useState(false);
  const [acknowledgedAt, setAcknowledgedAt] = useState<string | null>(null);

  const todaysDate = new Date().toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  });

  const handleAcknowledge = () => {
    const time = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    setAcknowledgedAt(time);
    setIsAcknowledged(true);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="px-4 py-3">
          <h1 className="text-[17px] font-medium text-gray-900">
            Today's Meal Restrictions
          </h1>
          <p className="text-[13px] text-[#64748B]">
            {todaysDate}
          </p>
        </div>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Acknowledgment Required */}
        {!isAcknowledged ? (
          <div className="bg-[#FEF3C7] border-2 border-[#F59E0B] rounded-xl p-4">
            <p className="text-[14px] text-[#92400E] font-medium mb-3">
              Please confirm you have checked today's restriction list
            </p>
            <button
              onClick={handleAcknowledge}
              className="w-full px-4 py-3 bg-[#F59E0B] text-white rounded-lg text-[15px] font-medium min-h-[52px]"
            >
              Acknowledge
            </button>
          </div>
        ) : (
          <div className="bg-[#D1FAE5] border border-[#10B981] rounded-xl p-3">
            <div className="flex items-center gap-2">
              <Check className="w-5 h-5 text-[#10B981] flex-shrink-0" />
              <p className="text-[14px] text-[#065F46] font-medium">
                List checked at {acknowledgedAt} ✓
              </p>
            </div>
          </div>
        )}

        {/* Empty State */}
        <div className="bg-white rounded-xl border border-gray-200 p-8 text-center mt-8">
          <div className="w-20 h-20 rounded-full bg-[#D1FAE5] flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-10 h-10 text-[#10B981]" />
          </div>

          <h2 className="text-[20px] font-medium text-gray-900 mb-2">
            No Meal Restrictions Today
          </h2>

          <p className="text-[15px] text-[#64748B] mb-4">
            All students can eat from the standard menu
          </p>

          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#F0FDF4] text-[#065F46] text-[13px] font-medium">
            <div className="w-2 h-2 rounded-full bg-[#10B981]" />
            All clear for today's service
          </div>
        </div>

        {/* Info Card */}
        <div className="bg-[#F8FAFC] rounded-xl border border-gray-200 p-4">
          <p className="text-[12px] text-[#64748B] leading-relaxed">
            <span className="font-medium">Note:</span> If any restrictions are added during the day, you will receive an immediate alert notification.
          </p>
        </div>
      </div>
    </div>
  );
}
