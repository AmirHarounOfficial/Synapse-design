import { CheckCircle, Clock, Lock } from 'lucide-react';
import { useState } from 'react';

export function MedicationTracking() {
  const [activeTab, setActiveTab] = useState<'today' | 'history'>('today');

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center border-b border-[#E2E8F0]">
        <h1 className="text-xl font-semibold text-[#0F172A]">Medications</h1>
      </div>

      {/* Content */}
      <div className="pt-6">
        {/* Tabs */}
        <div className="px-4 mb-6">
          <div className="flex gap-2 bg-[#FFFFFF] p-1 rounded-xl border border-[#E2E8F0]">
            <button
              onClick={() => setActiveTab('today')}
              className={`flex-1 h-[44px] rounded-lg font-semibold transition-colors ${
                activeTab === 'today'
                  ? 'bg-[#2563EB] text-white'
                  : 'text-[#64748B]'
              }`}
            >
              Today
            </button>
            <button
              onClick={() => setActiveTab('history')}
              className={`flex-1 h-[44px] rounded-lg font-semibold transition-colors ${
                activeTab === 'history'
                  ? 'bg-[#2563EB] text-white'
                  : 'text-[#64748B]'
              }`}
            >
              History
            </button>
          </div>
        </div>

        {activeTab === 'today' ? (
          <div className="px-4 space-y-4">
            {/* Completed Section */}
            <div>
              <h2 className="text-sm font-semibold text-[#64748B] mb-3 flex items-center gap-2">
                <CheckCircle className="w-4 h-4" />
                COMPLETED
              </h2>

              <div className="space-y-3">
                <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="font-semibold text-[#0F172A]">Emma Rodriguez</h3>
                      <p className="text-sm text-[#64748B]">Grade 4 • Student ID: 45892</p>
                    </div>
                    <div className="flex items-center gap-1.5 bg-[#10B981] text-white text-xs px-3 py-1.5 rounded-full">
                      <CheckCircle className="w-3.5 h-3.5" />
                      <span className="font-semibold">Given</span>
                    </div>
                  </div>
                  <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0]">
                    <p className="font-semibold text-[#0F172A] mb-1">Adderall XR 10mg</p>
                    <p className="text-sm text-[#64748B]">Administered at 8:30 AM by Nurse Johnson</p>
                  </div>
                </div>

                <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="font-semibold text-[#0F172A]">James Patterson</h3>
                      <p className="text-sm text-[#64748B]">Grade 6 • Student ID: 45123</p>
                    </div>
                    <div className="flex items-center gap-1.5 bg-[#10B981] text-white text-xs px-3 py-1.5 rounded-full">
                      <CheckCircle className="w-3.5 h-3.5" />
                      <span className="font-semibold">Given</span>
                    </div>
                  </div>
                  <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0]">
                    <p className="font-semibold text-[#0F172A] mb-1">Methylphenidate 20mg</p>
                    <p className="text-sm text-[#64748B]">Administered at 9:00 AM by Nurse Johnson</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Pending Section */}
            <div className="pt-4">
              <h2 className="text-sm font-semibold text-[#64748B] mb-3 flex items-center gap-2">
                <Clock className="w-4 h-4" />
                PENDING
              </h2>

              <div className="space-y-3">
                <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="font-semibold text-[#0F172A]">Marcus Chen</h3>
                      <p className="text-sm text-[#64748B]">Grade 7 • Student ID: 45678</p>
                    </div>
                    <span className="bg-[#2563EB] text-white text-sm px-3 py-1.5 rounded-full font-semibold">11:00 AM</span>
                  </div>
                  <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0] mb-3">
                    <p className="font-semibold text-[#0F172A] mb-1">Albuterol Inhaler</p>
                    <p className="text-sm text-[#64748B]">2 puffs as needed for asthma</p>
                  </div>
                  <button className="w-full bg-[#2563EB] text-white rounded-lg h-[44px] font-semibold">
                    Administer Now
                  </button>
                </div>

                <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="font-semibold text-[#0F172A]">Sophia Williams</h3>
                      <p className="text-sm text-[#64748B]">Grade 10 • Student ID: 45234</p>
                    </div>
                    <span className="bg-[#2563EB] text-white text-sm px-3 py-1.5 rounded-full font-semibold">12:00 PM</span>
                  </div>
                  <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0] mb-3">
                    <p className="font-semibold text-[#0F172A] mb-1">Insulin Lispro 5 units</p>
                    <p className="text-sm text-[#64748B]">Before lunch</p>
                  </div>
                  <button className="w-full bg-[#FFFFFF] text-[#2563EB] border-2 border-[#2563EB] rounded-lg h-[44px] font-semibold">
                    View Details
                  </button>
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="px-4 space-y-3">
            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="font-semibold text-[#0F172A]">Emma Rodriguez</h3>
                  <p className="text-sm text-[#64748B]">May 23, 2026 • 8:30 AM</p>
                </div>
                <div className="flex items-center gap-1.5 text-[#64748B]">
                  <Lock className="w-4 h-4" />
                  <span className="text-xs font-semibold">Locked</span>
                </div>
              </div>
              <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0]">
                <p className="font-semibold text-[#0F172A] mb-1">Adderall XR 10mg</p>
                <p className="text-sm text-[#64748B]">Administered by Nurse Johnson</p>
              </div>
            </div>

            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="font-semibold text-[#0F172A]">Marcus Chen</h3>
                  <p className="text-sm text-[#64748B]">May 23, 2026 • 11:15 AM</p>
                </div>
                <div className="flex items-center gap-1.5 text-[#64748B]">
                  <Lock className="w-4 h-4" />
                  <span className="text-xs font-semibold">Locked</span>
                </div>
              </div>
              <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0]">
                <p className="font-semibold text-[#0F172A] mb-1">Albuterol Inhaler 2 puffs</p>
                <p className="text-sm text-[#64748B]">Administered by Nurse Martinez</p>
              </div>
            </div>

            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="font-semibold text-[#0F172A]">Sophia Williams</h3>
                  <p className="text-sm text-[#64748B]">May 22, 2026 • 12:00 PM</p>
                </div>
                <div className="flex items-center gap-1.5 text-[#64748B]">
                  <Lock className="w-4 h-4" />
                  <span className="text-xs font-semibold">Locked</span>
                </div>
              </div>
              <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0]">
                <p className="font-semibold text-[#0F172A] mb-1">Insulin Lispro 5 units</p>
                <p className="text-sm text-[#64748B]">Administered by Nurse Johnson</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
