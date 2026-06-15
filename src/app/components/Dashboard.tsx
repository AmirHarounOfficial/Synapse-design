import { Clock, CheckCircle, AlertTriangle } from 'lucide-react';

export function Dashboard() {
  const currentDate = new Date();
  const formattedDate = currentDate.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric'
  });

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center border-b border-[#E2E8F0]">
        <h1 className="text-xl font-semibold text-[#0F172A]">Dashboard</h1>
      </div>

      {/* Content */}
      <div className="px-4 pt-6 pb-6">
        {/* Date Header */}
        <p className="text-sm text-[#64748B] mb-4">{formattedDate}</p>

        {/* Alert Banner - Consent Pending */}
        <div className="mb-6 bg-[#FFFFFF] rounded-xl p-4 border-l-8 border-[#F59E0B]">
          <div className="flex gap-3">
            <AlertTriangle className="w-6 h-6 text-[#F59E0B] flex-shrink-0" />
            <div>
              <h3 className="font-semibold text-[#0F172A] mb-1">Consent Pending</h3>
              <p className="text-sm text-[#64748B]">3 students require parent medication consent</p>
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-4 mb-6">
          <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
            <div className="flex items-center gap-2 mb-2">
              <CheckCircle className="w-5 h-5 text-[#10B981]" />
              <span className="text-sm text-[#64748B]">Administered</span>
            </div>
            <p className="text-2xl font-semibold text-[#0F172A]">12</p>
            <p className="text-xs text-[#64748B] mt-1">Today</p>
          </div>

          <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
            <div className="flex items-center gap-2 mb-2">
              <Clock className="w-5 h-5 text-[#2563EB]" />
              <span className="text-sm text-[#64748B]">Upcoming</span>
            </div>
            <p className="text-2xl font-semibold text-[#0F172A]">8</p>
            <p className="text-xs text-[#64748B] mt-1">Next 2 hours</p>
          </div>
        </div>

        {/* Upcoming Medications */}
        <div className="mb-4">
          <h2 className="font-semibold text-[#0F172A] mb-3">Upcoming Medications</h2>

          <div className="space-y-3">
            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h3 className="font-semibold text-[#0F172A]">Emma Rodriguez</h3>
                  <p className="text-sm text-[#64748B]">Grade 4</p>
                </div>
                <span className="bg-[#2563EB] text-white text-sm px-3 py-1 rounded-full">10:30 AM</span>
              </div>
              <div className="flex items-center gap-2 mt-3">
                <div className="flex items-center gap-1.5">
                  <div className="w-2 h-2 rounded-full bg-[#2563EB]" />
                  <span className="text-sm text-[#0F172A]">Adderall XR 10mg</span>
                </div>
              </div>
            </div>

            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h3 className="font-semibold text-[#0F172A]">Marcus Chen</h3>
                  <p className="text-sm text-[#64748B]">Grade 7</p>
                </div>
                <span className="bg-[#2563EB] text-white text-sm px-3 py-1 rounded-full">11:00 AM</span>
              </div>
              <div className="flex items-center gap-2 mt-3">
                <div className="flex items-center gap-1.5">
                  <div className="w-2 h-2 rounded-full bg-[#2563EB]" />
                  <span className="text-sm text-[#0F172A]">Albuterol Inhaler 2 puffs</span>
                </div>
              </div>
            </div>

            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h3 className="font-semibold text-[#0F172A]">Sophia Williams</h3>
                  <p className="text-sm text-[#64748B]">Grade 10</p>
                </div>
                <span className="bg-[#2563EB] text-white text-sm px-3 py-1 rounded-full">12:00 PM</span>
              </div>
              <div className="flex items-center gap-2 mt-3">
                <div className="flex items-center gap-1.5">
                  <div className="w-2 h-2 rounded-full bg-[#2563EB]" />
                  <span className="text-sm text-[#0F172A]">Insulin Lispro 5 units</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mt-6">
          <button className="w-full bg-[#2563EB] text-white rounded-xl h-[52px] font-semibold">
            Administer Medication
          </button>
        </div>
      </div>
    </div>
  );
}
