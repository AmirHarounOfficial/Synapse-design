import { ArrowLeft, Filter, Lock, Download, Info } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function PrincipalAuditLog() {
  const navigate = useNavigate();
  const [activeFilter, setActiveFilter] = useState('all');

  const filters = [
    { id: 'all', label: 'All actions' },
    { id: 'clinical', label: 'Clinical' },
    { id: 'admin', label: 'Admin' },
    { id: 'security', label: 'Security' },
    { id: 'login', label: 'Login' }
  ];

  const logEntries = [
    {
      id: '1',
      action: 'Medication administered — Nurse Smith — Maya Chen',
      user: 'Nurse Smith',
      role: 'School Nurse',
      timestamp: '10:49:32 AM',
      type: 'clinical',
      color: 'bg-[#DC2626]'
    },
    {
      id: '2',
      action: 'Student record accessed — Secretary Jones',
      user: 'Secretary Jones',
      role: 'Secretary',
      timestamp: '09:14:01 AM',
      type: 'security',
      color: 'bg-[#F59E0B]'
    },
    {
      id: '3',
      action: 'Permission matrix edited — Principal Davis',
      user: 'Principal Davis',
      role: 'Principal',
      timestamp: '08:00:15 AM',
      type: 'admin',
      color: 'bg-[#2563EB]'
    },
    {
      id: '4',
      action: 'Failed login attempt — unknown@email.com',
      user: 'System',
      role: 'Security',
      timestamp: '07:45:22 AM',
      type: 'login',
      color: 'bg-[#64748B]'
    },
    {
      id: '5',
      action: 'Emergency consent sent — Nurse Smith — Ethan Williams',
      user: 'Nurse Smith',
      role: 'School Nurse',
      timestamp: '07:32:18 AM',
      type: 'clinical',
      color: 'bg-[#DC2626]'
    },
    {
      id: '6',
      action: 'Staff account created — Jennifer Miller (Teacher)',
      user: 'Principal Davis',
      role: 'Principal',
      timestamp: '07:15:09 AM',
      type: 'admin',
      color: 'bg-[#2563EB]'
    },
    {
      id: '7',
      action: 'Document approved — Health Insurance Card — Maya Chen',
      user: 'Nurse Smith',
      role: 'School Nurse',
      timestamp: 'Yesterday 4:22 PM',
      type: 'admin',
      color: 'bg-[#2563EB]'
    },
    {
      id: '8',
      action: 'User logged in — Counselor Park',
      user: 'Counselor Park',
      role: 'Student Counselor',
      timestamp: 'Yesterday 8:01 AM',
      type: 'login',
      color: 'bg-[#64748B]'
    }
  ];

  const filteredEntries = logEntries.filter(entry => {
    if (activeFilter === 'all') return true;
    return entry.type === activeFilter;
  });

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col" style={{ width: '393px', height: '852px' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="flex items-center justify-between px-4 h-14">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate(-1)}
              className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
              aria-label="Go back"
            >
              <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
            </button>
            <h1 className="text-[17px] font-medium text-[#0F172A]">
              Audit Log
            </h1>
          </div>
          <button className="flex items-center gap-2 text-[13px] text-[#2563EB] font-medium">
            <Download className="w-4 h-4" />
            Export CSV
          </button>
        </div>

        {/* Filter Chips */}
        <div className="flex overflow-x-auto px-4 pb-3 gap-2">
          {filters.map((filter) => (
            <button
              key={filter.id}
              onClick={() => setActiveFilter(filter.id)}
              className={`px-3 py-1.5 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors ${
                activeFilter === filter.id
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-[#F1F5F9] text-[#64748B] active:bg-[#E2E8F0]'
              }`}
            >
              {filter.label}
            </button>
          ))}
        </div>
      </header>

      {/* Immutability Notice */}
      <div className="px-4 pt-4">
        <div className="bg-[#FEF3C7] border border-[#FDE68A] rounded-lg p-3">
          <div className="flex items-start gap-2">
            <Info className="w-4 h-4 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <p className="text-[11px] text-[#92400E] leading-relaxed">
              ⚠ This log is tamper-proof. No entry can be deleted or modified by any user, including administrators.
            </p>
          </div>
        </div>
      </div>

      {/* Log Entries */}
      <div className="flex-1 overflow-y-auto px-4 py-4">
        <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
          {filteredEntries.map((entry) => (
            <div key={entry.id} className="p-4 min-h-[64px] flex items-center gap-3">
              <div className={`w-2 h-2 rounded-full flex-shrink-0 ${entry.color}`} />
              <div className="flex-1 min-w-0">
                <div className="text-[13px] font-medium text-[#0F172A] mb-1">
                  {entry.action}
                </div>
                <div className="flex items-center gap-2 text-[12px] text-[#64748B]">
                  <span>{entry.user}</span>
                  <span>•</span>
                  <span>{entry.role}</span>
                </div>
                <div className="text-[11px] text-[#64748B] mt-0.5">
                  {entry.timestamp}
                </div>
              </div>
              <Lock className="w-4 h-4 text-[#64748B] flex-shrink-0" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
