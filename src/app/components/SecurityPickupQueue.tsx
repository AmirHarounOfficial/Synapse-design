import { useNavigate } from 'react-router';
import { Check } from 'lucide-react';
import { useState } from 'react';

interface Pickup {
  id: string;
  studentName: string;
  grade: string;
  authorizedPerson: string;
  earlyDismissal: boolean;
  status: 'pending' | 'approved';
  time?: string;
}

export function SecurityPickupQueue() {
  const navigate = useNavigate();
  const [pickups, setPickups] = useState<Pickup[]>([
    {
      id: '1',
      studentName: 'Maya Chen',
      grade: '3rd Grade',
      authorizedPerson: 'Dr. Jennifer Chen (Mother)',
      earlyDismissal: true,
      status: 'approved'
    },
    {
      id: '2',
      studentName: 'Lucas Martinez',
      grade: '5th Grade',
      authorizedPerson: 'Carlos Martinez (Father)',
      earlyDismissal: false,
      status: 'approved'
    },
    {
      id: '3',
      studentName: 'Sophia Williams',
      grade: '2nd Grade',
      authorizedPerson: 'Emma Williams (Guardian)',
      earlyDismissal: true,
      status: 'pending'
    },
    {
      id: '4',
      studentName: 'Ethan Brown',
      grade: '4th Grade',
      authorizedPerson: 'Michael Brown (Father)',
      earlyDismissal: false,
      status: 'pending'
    }
  ]);

  const pendingCount = pickups.filter(p => p.status === 'pending').length;
  const approvedPickups = pickups.filter(p => p.status === 'approved');
  const pendingPickups = pickups.filter(p => p.status === 'pending');

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="font-medium text-gray-900">
          Student Pickups
        </h1>
        {pendingCount > 0 && (
          <div className="flex items-center justify-center min-w-[28px] h-[28px] px-2 rounded-full bg-[#DC2626] text-white text-[13px] font-semibold">
            {pendingCount}
          </div>
        )}
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Approved Pickups Section */}
        {approvedPickups.length > 0 && (
          <div>
            <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
              APPROVED — READY FOR PICKUP ({approvedPickups.length})
            </h2>

            <div className="space-y-3">
              {approvedPickups.map((pickup) => (
                <div
                  key={pickup.id}
                  className="bg-white rounded-xl border-2 border-[#10B981] p-4"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <div className="text-[16px] font-medium text-gray-900">
                          {pickup.studentName}
                        </div>
                        {pickup.earlyDismissal && (
                          <div className="inline-flex items-center px-2 py-0.5 rounded-md bg-[#FEF3C7] text-[#92400E] text-[11px] font-semibold">
                            EARLY DISMISSAL
                          </div>
                        )}
                      </div>
                      <div className="text-[13px] text-[#64748B]">
                        {pickup.grade}
                      </div>
                    </div>
                    <div className="flex items-center gap-2 text-[#10B981]">
                      <Check className="w-5 h-5" />
                      <span className="text-[13px] font-medium">Verified</span>
                    </div>
                  </div>

                  <div className="pt-3 border-t border-gray-100">
                    <div className="text-[12px] text-[#64748B] mb-1">
                      Expected pickup by:
                    </div>
                    <div className="text-[14px] font-medium text-gray-900">
                      {pickup.authorizedPerson}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Pending Pickups Section */}
        {pendingPickups.length > 0 && (
          <div>
            <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
              PENDING VERIFICATION ({pendingPickups.length})
            </h2>

            <div className="space-y-3">
              {pendingPickups.map((pickup) => (
                <div
                  key={pickup.id}
                  className="bg-white rounded-xl border border-gray-200 p-4"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <div className="text-[16px] font-medium text-gray-900">
                          {pickup.studentName}
                        </div>
                        {pickup.earlyDismissal && (
                          <div className="inline-flex items-center px-2 py-0.5 rounded-md bg-[#FEF3C7] text-[#92400E] text-[11px] font-semibold">
                            EARLY DISMISSAL
                          </div>
                        )}
                      </div>
                      <div className="text-[13px] text-[#64748B]">
                        {pickup.grade}
                      </div>
                    </div>
                  </div>

                  <div className="mb-4 pt-3 border-t border-gray-100">
                    <div className="text-[12px] text-[#64748B] mb-1">
                      Expected pickup by:
                    </div>
                    <div className="text-[14px] font-medium text-gray-900">
                      {pickup.authorizedPerson}
                    </div>
                  </div>

                  <button
                    onClick={() => navigate('/security/scanner')}
                    className="w-full px-4 py-3.5 bg-[#10B981] text-white rounded-lg text-[15px] font-medium min-h-[52px] flex items-center justify-center gap-2"
                  >
                    Verify Identity
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Empty State */}
        {pickups.length === 0 && (
          <div className="flex flex-col items-center justify-center py-12">
            <div className="w-16 h-16 rounded-full bg-[#F0FDF4] flex items-center justify-center mb-4">
              <Check className="w-8 h-8 text-[#10B981]" />
            </div>
            <h3 className="text-[17px] font-medium text-gray-900 mb-2">
              No Pending Pickups
            </h3>
            <p className="text-[14px] text-[#64748B] text-center max-w-[280px]">
              All students have been picked up or are in their scheduled locations.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
