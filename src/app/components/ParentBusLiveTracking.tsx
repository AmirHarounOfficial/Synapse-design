import { ArrowLeft, MapPin, Navigation, RefreshCw, Home, School, Bus } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function ParentBusLiveTracking() {
  const navigate = useNavigate();
  const [busStatus] = useState<'en-route-school' | 'arrived-school' | 'en-route-home' | 'approaching-stop' | 'arrived-home'>('approaching-stop');

  const statusConfig = {
    'en-route-school': { label: 'En route to school', color: 'bg-[#DBEAFE] text-[#2563EB]' },
    'arrived-school': { label: 'Arrived at school', color: 'bg-[#D1FAE5] text-[#10B981]' },
    'en-route-home': { label: 'En route home', color: 'bg-[#CFFAFE] text-[#0891B2]' },
    'approaching-stop': { label: 'Approaching your stop', color: 'bg-[#FEF3C7] text-[#F59E0B]' },
    'arrived-home': { label: 'Arrived home', color: 'bg-[#D1FAE5] text-[#10B981]' }
  };

  const currentStatus = statusConfig[busStatus];

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col" style={{ width: '393px', height: '852px' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
          aria-label="Go back"
        >
          <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
        </button>
        <div className="flex-1">
          <h1 className="text-[17px] font-medium text-[#0F172A]">Bus Tracking</h1>
          <p className="text-[13px] text-[#64748B]">Route 12</p>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto">
        {/* Map View - 55% of screen height */}
        <div className="relative bg-[#F1F5F9] overflow-hidden" style={{ height: '468px' }}>
          {/* Map placeholder with roads */}
          <div className="absolute inset-0 bg-[#F1F5F9]">
            {/* Road lines */}
            <svg className="absolute inset-0 w-full h-full" xmlns="http://www.w3.org/2000/svg">
              {/* Horizontal road */}
              <line x1="0" y1="240" x2="393" y2="240" stroke="white" strokeWidth="24" />
              {/* Vertical road */}
              <line x1="196" y1="0" x2="196" y2="468" stroke="white" strokeWidth="24" />
              {/* Diagonal road */}
              <line x1="50" y1="50" x2="343" y2="418" stroke="white" strokeWidth="20" opacity="0.8" />
            </svg>

            {/* Home Pin */}
            <div className="absolute" style={{ left: '60px', top: '100px' }}>
              <div className="flex flex-col items-center">
                <div className="bg-[#F59E0B] p-2 rounded-full shadow-lg">
                  <Home className="w-5 h-5 text-white" />
                </div>
                <div className="mt-1 bg-white px-2 py-1 rounded text-xs font-medium text-[#0F172A] shadow-sm">
                  Home
                </div>
              </div>
            </div>

            {/* Bus Pin (with direction arrow and animated pulse) */}
            <div className="absolute" style={{ left: '160px', top: '200px' }}>
              <div className="flex flex-col items-center">
                <div className="relative">
                  {/* Animated pulse ring */}
                  <div className="absolute inset-0 bg-[#10B981] rounded-full animate-ping opacity-30" />
                  <div className="relative bg-[#10B981] p-2.5 rounded-full shadow-lg">
                    <Bus className="w-6 h-6 text-white" />
                  </div>
                  {/* Direction arrow */}
                  <div className="absolute -top-2 -right-2 bg-[#059669] p-1 rounded-full">
                    <Navigation className="w-3 h-3 text-white" style={{ transform: 'rotate(45deg)' }} />
                  </div>
                </div>
                <div className="mt-1 bg-white px-2 py-1 rounded text-xs font-medium text-[#0F172A] shadow-sm">
                  Bus 12
                </div>
              </div>
            </div>

            {/* School Pin */}
            <div className="absolute" style={{ left: '280px', top: '320px' }}>
              <div className="flex flex-col items-center">
                <div className="bg-[#2563EB] p-2 rounded-full shadow-lg">
                  <School className="w-5 h-5 text-white" />
                </div>
                <div className="mt-1 bg-white px-2 py-1 rounded text-xs font-medium text-[#0F172A] shadow-sm">
                  Lincoln ES
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Status Card */}
        <div className="px-4 pt-4">
          <div className="bg-white rounded-xl p-4 shadow-sm border border-gray-200">
            {/* Status Chip */}
            <div className="mb-3">
              <span className={`inline-flex items-center px-3 py-1.5 rounded-full text-[13px] font-medium ${currentStatus.color}`}>
                {currentStatus.label}
              </span>
            </div>

            {/* ETA */}
            <div className="mb-1">
              <p className="text-[20px] font-medium text-[#0F172A]">
                Estimated arrival at school: 7:52 AM
              </p>
            </div>
            <div className="flex items-center gap-1.5 mb-4">
              <RefreshCw className="w-3 h-3 text-[#64748B]" />
              <span className="text-xs text-[#64748B]">Updated 1 min ago</span>
            </div>

            {/* Route Progress */}
            <div className="mb-4">
              <div className="flex items-center justify-between">
                {/* Home */}
                <div className="flex flex-col items-center flex-1">
                  <div className="w-8 h-8 rounded-full bg-[#10B981] flex items-center justify-center mb-1">
                    <Home className="w-4 h-4 text-white" />
                  </div>
                  <span className="text-xs text-[#0F172A] font-medium">Home</span>
                </div>

                {/* Connector line */}
                <div className="flex-1 h-1 bg-[#10B981] -mx-2" />

                {/* Stop 3 (current - animated pulse) */}
                <div className="flex flex-col items-center flex-1">
                  <div className="relative">
                    <div className="absolute inset-0 bg-[#F59E0B] rounded-full animate-ping opacity-40" style={{ width: '32px', height: '32px' }} />
                    <div className="relative w-8 h-8 rounded-full bg-[#F59E0B] flex items-center justify-center mb-1">
                      <MapPin className="w-4 h-4 text-white" />
                    </div>
                  </div>
                  <span className="text-xs text-[#0F172A] font-medium">Stop 3</span>
                </div>

                {/* Connector line */}
                <div className="flex-1 h-1 bg-[#E2E8F0] -mx-2" />

                {/* Stop 5 */}
                <div className="flex flex-col items-center flex-1">
                  <div className="w-8 h-8 rounded-full bg-[#E2E8F0] flex items-center justify-center mb-1">
                    <MapPin className="w-4 h-4 text-[#94A3B8]" />
                  </div>
                  <span className="text-xs text-[#64748B]">Stop 5</span>
                </div>

                {/* Connector line */}
                <div className="flex-1 h-1 bg-[#E2E8F0] -mx-2" />

                {/* School */}
                <div className="flex flex-col items-center flex-1">
                  <div className="w-8 h-8 rounded-full bg-[#E2E8F0] flex items-center justify-center mb-1">
                    <School className="w-4 h-4 text-[#94A3B8]" />
                  </div>
                  <span className="text-xs text-[#64748B]">School</span>
                </div>
              </div>
            </div>

            {/* Student Status */}
            <div className="pt-3 border-t border-gray-200">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#EDE9FE] flex items-center justify-center flex-shrink-0">
                  <span className="text-sm font-medium text-[#7C3AED]">MJ</span>
                </div>
                <div className="flex-1">
                  <p className="text-[14px] text-[#0F172A]">
                    <span className="font-medium">Maya</span> boarded at Stop 3 at 07:41 AM
                  </p>
                </div>
                <div className="flex items-center justify-center w-6 h-6 rounded-full bg-[#D1FAE5]">
                  <span className="text-[#10B981] text-lg leading-none">✓</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Privacy Notice */}
        <div className="px-4 py-6">
          <div className="bg-[#EFF6FF] rounded-lg px-4 py-3 border border-[#BFDBFE]">
            <p className="text-[11px] leading-relaxed text-[#64748B]">
              Live location is only available during active bus hours (6:30 AM – 5:00 PM).
              Location data is deleted after 24 hours.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
