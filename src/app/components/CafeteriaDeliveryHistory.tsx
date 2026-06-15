import { useNavigate } from 'react-router';
import { Download, FileText } from 'lucide-react';
import { useState } from 'react';

interface DeliveryRecord {
  id: string;
  date: string;
  studentInitial: string;
  mealType: string;
  confirmedBy: string;
  time: string;
}

export function CafeteriaDeliveryHistory() {
  const navigate = useNavigate();
  const [isExporting, setIsExporting] = useState(false);

  const deliveryRecords: DeliveryRecord[] = [
    {
      id: '1',
      date: 'Today',
      studentInitial: 'Emma R.',
      mealType: 'Nut-free lunch pack',
      confirmedBy: 'Staff Member #204',
      time: '11:45 AM'
    },
    {
      id: '2',
      date: 'Today',
      studentInitial: 'Marcus C.',
      mealType: 'Dairy-free meal',
      confirmedBy: 'Staff Member #204',
      time: '11:42 AM'
    },
    {
      id: '3',
      date: 'Today',
      studentInitial: 'Sarah W.',
      mealType: 'Seafood-free tray',
      confirmedBy: 'Staff Member #204',
      time: '11:40 AM'
    },
    {
      id: '4',
      date: 'Yesterday',
      studentInitial: 'Emma R.',
      mealType: 'Nut-free lunch pack',
      confirmedBy: 'Staff Member #204',
      time: '12:05 PM'
    },
    {
      id: '5',
      date: 'Yesterday',
      studentInitial: 'Jordan L.',
      mealType: 'Gluten-free meal',
      confirmedBy: 'Staff Member #204',
      time: '11:58 AM'
    },
    {
      id: '6',
      date: 'May 23, 2026',
      studentInitial: 'Marcus C.',
      mealType: 'Dairy-free meal',
      confirmedBy: 'Staff Member #204',
      time: '11:52 AM'
    }
  ];

  const handleExport = () => {
    setIsExporting(true);
    // Simulate export process
    setTimeout(() => {
      setIsExporting(false);
      // In real app, would generate and download PDF
    }, 1500);
  };

  const groupedRecords = deliveryRecords.reduce((groups, record) => {
    const date = record.date;
    if (!groups[date]) {
      groups[date] = [];
    }
    groups[date].push(record);
    return groups;
  }, {} as Record<string, DeliveryRecord[]>);

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="font-medium text-gray-900">
          Delivery History
        </h1>

        <button
          onClick={handleExport}
          disabled={isExporting}
          className="flex items-center gap-2 px-3 py-2 text-[14px] text-[#2563EB] font-medium min-h-[44px]"
        >
          {isExporting ? (
            <>
              <div className="w-4 h-4 border-2 border-[#2563EB] border-t-transparent rounded-full animate-spin" />
              Exporting...
            </>
          ) : (
            <>
              <Download className="w-5 h-5" />
              Export
            </>
          )}
        </button>
      </header>

      <div className="px-4 py-4 space-y-6">
        {/* Info Banner */}
        <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-xl p-3">
          <div className="flex gap-2">
            <FileText className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-[13px] text-[#1E40AF] leading-relaxed">
                This log is maintained for Section 504 documentation and compliance purposes.
              </p>
            </div>
          </div>
        </div>

        {/* Grouped Records */}
        {Object.entries(groupedRecords).map(([date, records]) => (
          <div key={date}>
            <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
              {date}
            </h2>

            <div className="space-y-2">
              {records.map((record) => (
                <div
                  key={record.id}
                  className="bg-white rounded-xl border border-gray-200 p-3"
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-900 mb-1">
                        {record.studentInitial}
                      </div>
                      <div className="text-[13px] text-[#64748B]">
                        {record.mealType}
                      </div>
                    </div>
                    <div className="text-[13px] text-[#64748B] text-right">
                      {record.time}
                    </div>
                  </div>

                  <div className="flex items-center justify-between pt-2 border-t border-gray-100">
                    <div className="text-[12px] text-[#94A3B8]">
                      Confirmed by {record.confirmedBy}
                    </div>
                    <div className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-[#D1FAE5] text-[#065F46] text-[11px] font-medium">
                      <div className="w-1.5 h-1.5 rounded-full bg-[#10B981]" />
                      Delivered
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
