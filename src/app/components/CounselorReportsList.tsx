import { useNavigate } from 'react-router';
import { Bell, Plus, FileText } from 'lucide-react';

export function CounselorReportsList() {
  const navigate = useNavigate();

  const reports = [
    {
      id: '1',
      title: 'Maya Thompson - Individual Report',
      date: '2026-05-31',
      status: 'Sent to parent',
      statusColor: 'bg-[#D1FAE5] text-[#10B981]'
    },
    {
      id: '2',
      title: '4th Grade - Class Summary',
      date: '2026-05-28',
      status: 'With secretary',
      statusColor: 'bg-[#DBEAFE] text-[#2563EB]'
    },
    {
      id: '3',
      title: 'Olivia Brown - Individual Report',
      date: '2026-05-25',
      status: 'Draft',
      statusColor: 'bg-[#F1F5F9] text-[#64748B]'
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Reports
        </h1>
        <button className="w-10 h-10 -mr-2 flex items-center justify-center relative">
          <Bell className="w-6 h-6 text-[#0F172A]" />
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Generate New Report Button */}
        <button
          onClick={() => navigate('/counselor/generate-report')}
          className="w-full bg-[#7C3AED] text-white rounded-xl p-4 flex items-center justify-center gap-2 active:bg-[#6D28D9]"
        >
          <Plus className="w-5 h-5" />
          <span className="text-[15px] font-medium">Generate New Report</span>
        </button>

        {/* Recent Reports */}
        <div>
          <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
            Recent Reports
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {reports.map((report) => (
              <button
                key={report.id}
                onClick={() => navigate('/counselor/report-preview')}
                className="w-full p-4 flex items-start gap-3 text-left active:bg-gray-50"
              >
                <div className="w-10 h-10 rounded-full bg-[#F3F0FF] flex items-center justify-center flex-shrink-0 mt-0.5">
                  <FileText className="w-5 h-5 text-[#7C3AED]" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-1">
                    {report.title}
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-[12px] text-[#64748B]">
                      {new Date(report.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                    </span>
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium ${report.statusColor}`}>
                      {report.status}
                    </span>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
