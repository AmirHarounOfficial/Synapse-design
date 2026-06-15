import { Check, ScanLine } from 'lucide-react';

interface PickupRecord {
  id: string;
  time: string;
  studentName: string;
  releasedTo: string;
  relationship: string;
  method: 'QR' | 'Manual';
  guardName: string;
}

export function SecurityPickupHistory() {
  const todaysDate = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  });

  const pickupRecords: PickupRecord[] = [
    {
      id: '1',
      time: '2:45 PM',
      studentName: 'Maya Chen',
      releasedTo: 'Dr. Jennifer Chen',
      relationship: 'Mother',
      method: 'Manual',
      guardName: 'M. Johnson #042'
    },
    {
      id: '2',
      time: '2:38 PM',
      studentName: 'Lucas Martinez',
      releasedTo: 'Carlos Martinez',
      relationship: 'Father',
      method: 'QR',
      guardName: 'M. Johnson #042'
    },
    {
      id: '3',
      time: '2:15 PM',
      studentName: 'Sophia Williams',
      releasedTo: 'Emma Williams',
      relationship: 'Guardian',
      method: 'QR',
      guardName: 'M. Johnson #042'
    },
    {
      id: '4',
      time: '1:52 PM',
      studentName: 'Ethan Brown',
      releasedTo: 'Michael Brown',
      relationship: 'Father',
      method: 'QR',
      guardName: 'M. Johnson #042'
    },
    {
      id: '5',
      time: '12:30 PM',
      studentName: 'Olivia Davis',
      releasedTo: 'Sarah Davis',
      relationship: 'Mother',
      method: 'Manual',
      guardName: 'K. Williams #038'
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="px-4 py-3">
          <h1 className="text-[17px] font-medium text-gray-900">
            Pickup History
          </h1>
          <p className="text-[13px] text-[#64748B]">
            {todaysDate}
          </p>
        </div>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Summary Stats */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="text-center">
              <div className="text-[28px] font-bold text-gray-900">
                {pickupRecords.length}
              </div>
              <div className="text-[12px] text-[#64748B]">
                Total Pickups
              </div>
            </div>
            <div className="text-center border-l border-gray-200">
              <div className="text-[28px] font-bold text-[#10B981]">
                {pickupRecords.filter(r => r.method === 'QR').length}
              </div>
              <div className="text-[12px] text-[#64748B]">
                QR Verified
              </div>
            </div>
          </div>
        </div>

        {/* Records List */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            PICKUP RECORDS ({pickupRecords.length})
          </h2>

          <div className="space-y-2">
            {pickupRecords.map((record) => (
              <div
                key={record.id}
                className="bg-white rounded-xl border border-gray-200 p-4"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="text-[16px] font-medium text-gray-900 mb-1">
                      {record.studentName}
                    </div>
                    <div className="text-[13px] text-[#64748B]">
                      Released to {record.releasedTo}
                    </div>
                    <div className="text-[12px] text-[#94A3B8]">
                      {record.relationship}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-[15px] font-semibold text-gray-900 mb-1">
                      {record.time}
                    </div>
                    <div className={`inline-flex items-center gap-1.5 px-2 py-1 rounded-md ${
                      record.method === 'QR' 
                        ? 'bg-[#D1FAE5] text-[#065F46]' 
                        : 'bg-[#DBEAFE] text-[#1E40AF]'
                    }`}>
                      {record.method === 'QR' ? (
                        <ScanLine className="w-3.5 h-3.5" />
                      ) : (
                        <Check className="w-3.5 h-3.5" />
                      )}
                      <span className="text-[11px] font-semibold">
                        {record.method}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="pt-3 border-t border-gray-100 flex items-center justify-between">
                  <div className="text-[12px] text-[#94A3B8]">
                    Verified by {record.guardName}
                  </div>
                  <div className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-[#D1FAE5] text-[#065F46] text-[11px] font-medium">
                    <div className="w-1.5 h-1.5 rounded-full bg-[#10B981]" />
                    Released
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Info Notice */}
        <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4">
          <p className="text-[12px] text-[#64748B] leading-relaxed text-center">
            All pickup records are permanently logged for security and compliance. Historical records available in the administration portal.
          </p>
        </div>
      </div>
    </div>
  );
}
