import { SlidersHorizontal, Search, Plus, CheckCircle, X, Clock, Calendar, AlertCircle, RefreshCw, Pill } from 'lucide-react';
import { useState } from 'react';
import { Link, useNavigate } from 'react-router';

export function NurseMedications() {
  const navigate = useNavigate();
  const [activeFilter, setActiveFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const filters = [
    { id: 'all', label: 'All' },
    { id: 'due-soon', label: 'Due Soon' },
    { id: 'permanent', label: 'Permanent' },
    { id: 'temporary', label: 'Temporary' }
  ];

  const medications = [
    {
      id: 1,
      studentName: 'Emma Rodriguez',
      studentInitials: 'ER',
      medication: 'Adderall XR 10mg',
      nextDose: '10:30 AM',
      status: 'due-soon',
      statusLabel: 'Due in 12min',
      statusColor: 'amber',
      lowSupply: '5 days left'
    },
    {
      id: 2,
      studentName: 'Marcus Chen',
      studentInitials: 'MC',
      medication: 'Albuterol Inhaler 2 puffs',
      nextDose: '11:00 AM',
      status: 'administered',
      statusLabel: 'Administered',
      statusColor: 'green',
      lowSupply: null
    },
    {
      id: 3,
      studentName: 'Sophia Williams',
      studentInitials: 'SW',
      medication: 'Insulin Lispro 5 units',
      nextDose: '8:00 AM',
      status: 'missed',
      statusLabel: 'Missed',
      statusColor: 'red',
      lowSupply: null
    },
    {
      id: 4,
      studentName: 'Maya Chen',
      studentInitials: 'MC',
      medication: 'Methylphenidate 20mg',
      nextDose: '11:00 AM',
      status: 'scheduled',
      statusLabel: 'Due in 45min',
      statusColor: 'blue',
      lowSupply: '3 days left'
    }
  ];

  const getStatusStyle = (color: string) => {
    switch (color) {
      case 'amber':
        return 'bg-[#FEF3C7] text-[#92400E]';
      case 'green':
        return 'bg-[#D1FAE5] text-[#065F46]';
      case 'red':
        return 'bg-[#FEE2E2] text-[#991B1B]';
      case 'blue':
        return 'bg-[#DBEAFE] text-[#1E40AF]';
      default:
        return 'bg-[#E2E8F0] text-[#64748B]';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'administered':
        return <CheckCircle className="w-3 h-3" />;
      case 'missed':
        return <X className="w-3 h-3" />;
      case 'due-soon':
      case 'scheduled':
        return <Clock className="w-3 h-3" />;
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <h1 className="text-[17px] font-medium text-[#0F172A] flex-1 text-center" style={{ fontWeight: 500 }}>
          Medications
        </h1>
        <button className="p-2 min-w-[44px] min-h-[44px] flex items-center justify-center">
          <SlidersHorizontal className="w-6 h-6 text-[#64748B]" />
        </button>
      </div>

      {/* Search Bar */}
      <div className="bg-[#FFFFFF] px-4 py-3 border-b border-[#E2E8F0]">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search student or medication…"
            className="w-full h-[44px] pl-10 pr-4 rounded-lg border border-[#E2E8F0] bg-[#F8FAFC] text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
            style={{ fontWeight: 400 }}
          />
        </div>
      </div>

      {/* Filter Chips */}
      <div className="bg-[#FFFFFF] px-4 py-3 border-b border-[#E2E8F0]">
        <div className="flex gap-2 overflow-x-auto scrollbar-hide mb-3">
          {filters.map((filter) => (
            <button
              key={filter.id}
              onClick={() => setActiveFilter(filter.id)}
              className={`px-4 py-2 rounded-full text-[13px] font-semibold whitespace-nowrap transition-colors ${
                activeFilter === filter.id
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
              }`}
              style={{ fontWeight: 600 }}
            >
              {filter.label}
            </button>
          ))}
        </div>

        <button
          onClick={() => navigate('/nurse/daily-doses')}
          className="w-full flex items-center justify-center gap-2 py-2 text-[13px] text-[#2563EB] font-medium min-h-[44px]"
          style={{ fontWeight: 500 }}
        >
          <Calendar className="w-4 h-4" />
          View Today's Dose Schedule
        </button>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="mx-4 mt-4 bg-[#FEE2E2] border border-[#DC2626] rounded-xl p-3">
          <div className="flex items-start gap-2">
            <AlertCircle className="w-5 h-5 text-[#DC2626] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-[13px] text-[#DC2626] font-medium mb-2">
                {error}
              </p>
              <button
                onClick={() => {
                  setError(null);
                  setIsLoading(true);
                  // Simulate retry
                  setTimeout(() => setIsLoading(false), 1000);
                }}
                className="flex items-center gap-1 text-[13px] text-[#DC2626] font-medium min-h-[44px] px-2 -ml-2"
              >
                <RefreshCw className="w-4 h-4" />
                Retry
              </button>
            </div>
            <button
              onClick={() => setError(null)}
              className="w-6 h-6 flex items-center justify-center"
              aria-label="Dismiss"
            >
              <X className="w-4 h-4 text-[#DC2626]" />
            </button>
          </div>
        </div>
      )}

      {/* Medication List */}
      <div className="px-4 py-4 space-y-3">
        {/* Loading State */}
        {isLoading && (
          <>
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="bg-white rounded-xl p-3 border border-gray-200 animate-pulse">
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#E2E8F0]" />
                  <div className="flex-1">
                    <div className="h-4 bg-[#E2E8F0] rounded w-32 mb-2" />
                    <div className="h-3 bg-[#E2E8F0] rounded w-48 mb-2" />
                    <div className="h-3 bg-[#E2E8F0] rounded w-24" />
                  </div>
                  <div className="w-20 h-6 bg-[#E2E8F0] rounded-full" />
                </div>
              </div>
            ))}
          </>
        )}

        {/* Empty State */}
        {!isLoading && medications.length === 0 && !error && (
          <div className="flex flex-col items-center justify-center py-16 px-8">
            <div className="w-16 h-16 rounded-full bg-[#EFF6FF] flex items-center justify-center mb-4">
              <Pill className="w-8 h-8 text-[#2563EB]" />
            </div>
            <h3 className="text-[17px] font-medium text-gray-900 mb-2">
              No Medications Yet
            </h3>
            <p className="text-[14px] text-[#64748B] text-center mb-6">
              Add your first medication to get started tracking doses for students.
            </p>
            <Link
              to="/nurse/medications/add/step1"
              className="px-6 py-3 bg-[#2563EB] text-white rounded-lg text-[14px] font-medium min-h-[44px] flex items-center gap-2"
            >
              <Plus className="w-5 h-5" />
              Add Medication
            </Link>
          </div>
        )}

        {/* Medication List Items */}
        {!isLoading && medications.length > 0 && (
          <>
            {medications.map((med) => (
              <Link
                key={med.id}
                to={`/nurse/medications/${med.id}`}
                className="block bg-[#FFFFFF] rounded-xl p-3 border border-[#E2E8F0]"
              >
                <div className="flex items-start gap-3">
                  {/* Avatar */}
                  <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-sm font-semibold flex-shrink-0">
                    {med.studentInitials}
                  </div>

                  {/* Center Column */}
                  <div className="flex-1 min-w-0">
                    <p className="text-[14px] font-medium text-[#0F172A] mb-0.5" style={{ fontWeight: 500 }}>
                      {med.studentName}
                    </p>
                    <p className="text-[13px] text-[#64748B] mb-1" style={{ fontWeight: 400 }}>
                      {med.medication}
                    </p>
                    {med.lowSupply && (
                      <div className="inline-flex items-center gap-1 bg-[#FEF3C7] text-[#92400E] text-[11px] px-2 py-0.5 rounded-full mb-1">
                        <span className="font-semibold" style={{ fontWeight: 600 }}>
                          {med.lowSupply}
                        </span>
                      </div>
                    )}
                    <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
                      Next dose: {med.nextDose}
                    </p>
                  </div>

                  {/* Status Badge */}
                  <div className={`flex items-center gap-1 px-2.5 py-1.5 rounded-full flex-shrink-0 ${getStatusStyle(med.statusColor)}`}>
                    {getStatusIcon(med.status)}
                    <span className="text-[11px] font-semibold whitespace-nowrap" style={{ fontWeight: 600 }}>
                      {med.statusLabel}
                    </span>
                  </div>
                </div>
              </Link>
            ))}
          </>
        )}
      </div>

      {/* FAB Button */}
      <Link
        to="/nurse/medications/add/step1"
        className="fixed bottom-[100px] right-6 w-14 h-14 bg-[#2563EB] rounded-full shadow-lg flex items-center justify-center"
      >
        <Plus className="w-6 h-6 text-white" />
      </Link>
    </div>
  );
}
