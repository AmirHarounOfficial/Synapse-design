import { useNavigate } from 'react-router';
import { SlidersHorizontal, Calendar, ChevronRight, Lock, Plus, Paperclip, AlertCircle, RefreshCw, Clipboard } from 'lucide-react';
import { useState } from 'react';

interface ClinicVisit {
  id: string;
  studentName: string;
  studentInitials: string;
  grade: string;
  room: string;
  category: 'Injury' | 'Illness' | 'Medication' | 'Routine' | 'Emergency';
  time: string;
  nurse: string;
  nurseCredential: string;
  hasNote?: boolean;
  gradeLevel: number;
}

export function ClinicVisitList() {
  const navigate = useNavigate();
  const [activeFilter, setActiveFilter] = useState('today');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const filters = [
    { id: 'today', label: 'Today' },
    { id: 'week', label: 'This Week' },
    { id: 'emergency', label: 'Emergency' },
    { id: 'routine', label: 'Routine' },
    { id: 'pending', label: 'Pending Documents' }
  ];

  const [visits] = useState<ClinicVisit[]>([
    {
      id: '1',
      studentName: 'Emma Johnson',
      studentInitials: 'EJ',
      grade: '3rd Grade',
      room: 'Room 204',
      category: 'Emergency',
      time: '09:14 AM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 3
    },
    {
      id: '2',
      studentName: 'Marcus Chen',
      studentInitials: 'MC',
      grade: '5th Grade',
      room: 'Room 312',
      category: 'Injury',
      time: '09:28 AM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      hasNote: true,
      gradeLevel: 5
    },
    {
      id: '3',
      studentName: 'Sarah Williams',
      studentInitials: 'SW',
      grade: '2nd Grade',
      room: 'Room 108',
      category: 'Illness',
      time: '09:45 AM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 2
    },
    {
      id: '4',
      studentName: 'Alex Martinez',
      studentInitials: 'AM',
      grade: '4th Grade',
      room: 'Room 215',
      category: 'Medication',
      time: '10:12 AM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 4
    },
    {
      id: '5',
      studentName: 'Olivia Brown',
      studentInitials: 'OB',
      grade: '1st Grade',
      room: 'Room 102',
      category: 'Routine',
      time: '10:30 AM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 1
    },
    {
      id: '6',
      studentName: 'James Taylor',
      studentInitials: 'JT',
      grade: '6th Grade',
      room: 'Room 401',
      category: 'Illness',
      time: '10:52 AM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 6
    },
    {
      id: '7',
      studentName: 'Sophia Davis',
      studentInitials: 'SD',
      grade: '3rd Grade',
      room: 'Room 210',
      category: 'Injury',
      time: '11:15 AM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 3
    },
    {
      id: '8',
      studentName: 'Liam Anderson',
      studentInitials: 'LA',
      grade: '5th Grade',
      room: 'Room 308',
      category: 'Emergency',
      time: '11:42 AM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 5
    },
    {
      id: '9',
      studentName: 'Ava Garcia',
      studentInitials: 'AG',
      grade: '2nd Grade',
      room: 'Room 105',
      category: 'Illness',
      time: '12:08 PM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 2
    },
    {
      id: '10',
      studentName: 'Noah Wilson',
      studentInitials: 'NW',
      grade: '4th Grade',
      room: 'Room 220',
      category: 'Routine',
      time: '01:30 PM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 4
    },
    {
      id: '11',
      studentName: 'Isabella Lee',
      studentInitials: 'IL',
      grade: '1st Grade',
      room: 'Room 101',
      category: 'Injury',
      time: '01:55 PM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 1
    },
    {
      id: '12',
      studentName: 'Ethan Thomas',
      studentInitials: 'ET',
      grade: '6th Grade',
      room: 'Room 405',
      category: 'Medication',
      time: '02:22 PM',
      nurse: 'Nurse Smith',
      nurseCredential: 'RN-4521',
      gradeLevel: 6
    }
  ]);

  const getAvatarColor = (gradeLevel: number): string => {
    const colors = [
      '#2563EB', // Grade 1 - Blue
      '#10B981', // Grade 2 - Green
      '#F59E0B', // Grade 3 - Amber
      '#8B5CF6', // Grade 4 - Purple
      '#EC4899', // Grade 5 - Pink
      '#06B6D4', // Grade 6 - Cyan
    ];
    return colors[(gradeLevel - 1) % colors.length];
  };

  const getCategoryStyle = (category: string) => {
    switch (category) {
      case 'Emergency':
        return 'bg-[#FEE2E2] text-[#DC2626]';
      case 'Injury':
        return 'bg-[#FEF3C7] text-[#92400E]';
      case 'Illness':
        return 'bg-[#DBEAFE] text-[#1E40AF]';
      case 'Medication':
        return 'bg-[#E0E7FF] text-[#4338CA]';
      case 'Routine':
        return 'bg-[#D1FAE5] text-[#065F46]';
      default:
        return 'bg-[#E2E8F0] text-[#64748B]';
    }
  };

  const handleVisitClick = (visitId: string) => {
    // Navigate to visit detail screen
    navigate(`/nurse/clinic/visit/${visitId}`);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="font-medium text-gray-900">
          Clinic Visits
        </h1>

        <div className="flex items-center gap-2">
          <button
            className="flex items-center justify-center w-11 h-11"
            aria-label="Calendar"
          >
            <Calendar className="w-6 h-6 text-[#64748B]" />
          </button>
          <button
            className="flex items-center justify-center w-11 h-11"
            aria-label="Filter"
          >
            <SlidersHorizontal className="w-6 h-6 text-[#64748B]" />
          </button>
        </div>
      </header>

      {/* Filter Bar */}
        <div className="bg-white px-4 py-3 border-b border-gray-200">
          <div className="flex gap-2 overflow-x-auto scrollbar-hide">
            {filters.map((filter) => (
              <button
                key={filter.id}
                onClick={() => setActiveFilter(filter.id)}
                className={`px-4 py-2 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors min-h-[44px] ${
                  activeFilter === filter.id
                    ? 'bg-[#2563EB] text-white'
                    : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
                }`}
              >
                {filter.label}
              </button>
            ))}
          </div>
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
                    setTimeout(() => setIsLoading(false), 1000);
                  }}
                  className="flex items-center gap-1 text-[13px] text-[#DC2626] font-medium min-h-[44px] px-2 -ml-2"
                >
                  <RefreshCw className="w-4 h-4" />
                  Retry
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Visit Count */}
        {!isLoading && visits.length > 0 && !error && (
          <div className="px-4 pt-3 pb-2">
            <p className="text-[13px] text-[#64748B]">
              {visits.length} visits today
            </p>
          </div>
        )}

        {/* Visit List */}
        <div className="px-4 space-y-3">
          {/* Loading Skeleton */}
          {isLoading && (
            <>
              {[1, 2, 3].map((i) => (
                <div key={i} className="bg-white rounded-xl p-3 border border-gray-200 animate-pulse">
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-[#E2E8F0]" />
                    <div className="flex-1">
                      <div className="h-4 bg-[#E2E8F0] rounded w-32 mb-2" />
                      <div className="h-3 bg-[#E2E8F0] rounded w-40 mb-2" />
                      <div className="h-6 bg-[#E2E8F0] rounded w-16 mb-2" />
                      <div className="h-3 bg-[#E2E8F0] rounded w-24" />
                    </div>
                  </div>
                </div>
              ))}
            </>
          )}

          {/* Empty State */}
          {!isLoading && visits.length === 0 && !error && (
            <div className="flex flex-col items-center justify-center py-16 px-8">
              <div className="w-16 h-16 rounded-full bg-[#EFF6FF] flex items-center justify-center mb-4">
                <Clipboard className="w-8 h-8 text-[#2563EB]" />
              </div>
              <h3 className="text-[17px] font-medium text-gray-900 mb-2">
                No Clinic Visits Today
              </h3>
              <p className="text-[14px] text-[#64748B] text-center mb-6">
                When students visit the clinic, their records will appear here.
              </p>
              <button
                onClick={() => navigate('/nurse/clinic/new-visit')}
                className="px-6 py-3 bg-[#2563EB] text-white rounded-lg text-[14px] font-medium min-h-[44px] flex items-center gap-2"
              >
                <Plus className="w-5 h-5" />
                Log New Visit
              </button>
            </div>
          )}

          {/* Visit List Items */}
          {!isLoading && visits.length > 0 && visits.map((visit) => (
            <button
              key={visit.id}
              onClick={() => handleVisitClick(visit.id)}
              className={`
                w-full text-left bg-white rounded-xl p-3 border
                ${visit.category === 'Emergency'
                  ? 'border-l-[3px] border-l-[#DC2626] border-t border-r border-b border-gray-200'
                  : 'border-gray-200'
                }
              `}
            >
              <div className="flex items-start gap-3">
                {/* Avatar */}
                <div
                  className="w-10 h-10 rounded-full flex items-center justify-center text-white text-[14px] font-medium flex-shrink-0"
                  style={{ backgroundColor: getAvatarColor(visit.gradeLevel) }}
                >
                  {visit.studentInitials}
                </div>

                {/* Center Content */}
                <div className="flex-1 min-w-0">
                  {/* Student Info */}
                  <div className="mb-1">
                    <div className="text-[14px] font-medium text-gray-900">
                      {visit.studentName}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      {visit.grade} • {visit.room}
                    </div>
                  </div>

                  {/* Category Chip */}
                  <div className="mb-2">
                    <span
                      className={`inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium ${getCategoryStyle(
                        visit.category
                      )}`}
                    >
                      {visit.category}
                    </span>
                  </div>

                  {/* Time and Nurse */}
                  <div className="text-[12px] text-[#64748B] mb-1">
                    {visit.time}
                  </div>
                  <div className="text-[11px] text-[#64748B]">
                    Logged by {visit.nurse} {visit.nurseCredential}
                  </div>

                  {/* Corrective Note */}
                  {visit.hasNote && (
                    <div className="flex items-center gap-1 mt-2 text-[12px] text-[#F59E0B]">
                      <Paperclip className="w-3 h-3" />
                      <span className="font-medium">1 note</span>
                    </div>
                  )}
                </div>

                {/* Right Icons */}
                <div className="flex flex-col items-center gap-2 flex-shrink-0">
                  <Lock className="w-4 h-4 text-[#64748B]" />
                  <ChevronRight className="w-5 h-5 text-[#64748B]" />
                </div>
              </div>
            </button>
          ))}
        </div>

      {/* FAB */}
      <button
        onClick={() => navigate('/nurse/clinic/new-visit')}
        className="fixed bottom-24 right-4 w-14 h-14 bg-[#2563EB] rounded-full shadow-lg flex items-center justify-center"
        aria-label="New clinic visit"
      >
        <Plus className="w-7 h-7 text-white" strokeWidth={2.5} />
      </button>
    </div>
  );
}
