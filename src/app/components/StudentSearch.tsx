import { useNavigate } from 'react-router';
import { ChevronLeft, Search, X } from 'lucide-react';
import { useState } from 'react';

interface Student {
  id: string;
  name: string;
  initials: string;
  grade: string;
  room: string;
  schoolId: string;
  gradeLevel: number;
  alerts?: Array<{
    label: string;
    color: 'red' | 'amber' | 'blue';
  }>;
  flaggedToday?: boolean;
}

export function StudentSearch() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeGrade, setActiveGrade] = useState('all');
  const [hasEpipen, setHasEpipen] = useState(false);
  const [hasAllergies, setHasAllergies] = useState(false);
  const [hasPendingDocs, setHasPendingDocs] = useState(false);

  const gradeFilters = [
    { id: 'all', label: 'All Grades' },
    { id: '1', label: 'Grade 1' },
    { id: '2', label: 'Grade 2' },
    { id: '3', label: 'Grade 3' },
    { id: '4', label: 'Grade 4' },
    { id: '5', label: 'Grade 5' },
    { id: '6', label: 'Grade 6' }
  ];

  const recentStudents: Student[] = [
    {
      id: '1',
      name: 'Emma Johnson',
      initials: 'EJ',
      grade: '3rd Grade',
      room: 'Room 204',
      schoolId: 'ST-2024-0342',
      gradeLevel: 3,
      alerts: [
        { label: 'Asthma', color: 'red' },
        { label: 'Medications: 2', color: 'blue' }
      ]
    },
    {
      id: '2',
      name: 'Marcus Chen',
      initials: 'MC',
      grade: '5th Grade',
      room: 'Room 312',
      schoolId: 'ST-2024-0521',
      gradeLevel: 5,
      alerts: [
        { label: 'Peanut', color: 'amber' }
      ]
    },
    {
      id: '3',
      name: 'Sarah Williams',
      initials: 'SW',
      grade: '2nd Grade',
      room: 'Room 108',
      schoolId: 'ST-2024-0198',
      gradeLevel: 2
    },
    {
      id: '4',
      name: 'Alex Martinez',
      initials: 'AM',
      grade: '4th Grade',
      room: 'Room 215',
      schoolId: 'ST-2024-0405',
      gradeLevel: 4,
      alerts: [
        { label: 'Medications: 1', color: 'blue' }
      ]
    },
    {
      id: '5',
      name: 'Olivia Brown',
      initials: 'OB',
      grade: '1st Grade',
      room: 'Room 102',
      schoolId: 'ST-2024-0087',
      gradeLevel: 1
    }
  ];

  const flaggedStudents: Student[] = [
    {
      id: '6',
      name: 'James Taylor',
      initials: 'JT',
      grade: '6th Grade',
      room: 'Room 401',
      schoolId: 'ST-2024-0634',
      gradeLevel: 6,
      flaggedToday: true,
      alerts: [
        { label: 'Medications: 3', color: 'blue' }
      ]
    },
    {
      id: '7',
      name: 'Sophia Davis',
      initials: 'SD',
      grade: '3rd Grade',
      room: 'Room 210',
      schoolId: 'ST-2024-0356',
      gradeLevel: 3,
      flaggedToday: true,
      alerts: [
        { label: 'Asthma', color: 'red' }
      ]
    }
  ];

  const allStudents: Student[] = [
    ...recentStudents,
    ...flaggedStudents,
    {
      id: '8',
      name: 'Liam Anderson',
      initials: 'LA',
      grade: '5th Grade',
      room: 'Room 308',
      schoolId: 'ST-2024-0512',
      gradeLevel: 5,
      alerts: [
        { label: 'Peanut', color: 'amber' },
        { label: 'Medications: 1', color: 'blue' }
      ]
    },
    {
      id: '9',
      name: 'Ava Garcia',
      initials: 'AG',
      grade: '2nd Grade',
      room: 'Room 105',
      schoolId: 'ST-2024-0203',
      gradeLevel: 2,
      alerts: [
        { label: 'Asthma', color: 'red' }
      ]
    },
    {
      id: '10',
      name: 'Noah Wilson',
      initials: 'NW',
      grade: '4th Grade',
      room: 'Room 220',
      schoolId: 'ST-2024-0418',
      gradeLevel: 4
    }
  ];

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

  const getAlertStyle = (color: 'red' | 'amber' | 'blue') => {
    switch (color) {
      case 'red':
        return 'bg-[#FEE2E2] text-[#DC2626]';
      case 'amber':
        return 'bg-[#FEF3C7] text-[#92400E]';
      case 'blue':
        return 'bg-[#DBEAFE] text-[#1E40AF]';
      default:
        return 'bg-[#E2E8F0] text-[#64748B]';
    }
  };

  const handleStudentClick = (studentId: string) => {
    navigate(`/nurse/students/${studentId}`);
  };

  const clearSearch = () => {
    setSearchQuery('');
  };

  const filteredStudents = allStudents.filter(student => {
    const matchesSearch = searchQuery === '' ||
      student.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      student.schoolId.toLowerCase().includes(searchQuery.toLowerCase()) ||
      student.grade.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesGrade = activeGrade === 'all' || student.gradeLevel.toString() === activeGrade;

    return matchesSearch && matchesGrade;
  });

  const isSearching = searchQuery.length > 0;

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2"
          aria-label="Go back"
        >
          <ChevronLeft className="w-6 h-6 text-gray-900" />
        </button>

        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900">
          Students
        </h1>
      </header>

      {/* Search Bar */}
      <div className="bg-white px-4 pt-3 pb-2 border-b border-gray-200">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by name, ID, or class…"
            className="w-full h-12 pl-10 pr-10 rounded-lg border border-[#E2E8F0] bg-[#F8FAFC] text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
          />
          {searchQuery && (
            <button
              onClick={clearSearch}
              className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 flex items-center justify-center"
              aria-label="Clear search"
            >
              <X className="w-5 h-5 text-[#64748B]" />
            </button>
          )}
        </div>
      </div>

      {/* Grade Filter Row */}
      <div className="bg-white px-4 py-3 border-b border-gray-200">
        <div className="flex gap-2 overflow-x-auto scrollbar-hide">
          {gradeFilters.map((filter) => (
            <button
              key={filter.id}
              onClick={() => setActiveGrade(filter.id)}
              className={`px-4 py-2 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors min-h-[44px] ${
                activeGrade === filter.id
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
              }`}
            >
              {filter.label}
            </button>
          ))}
        </div>
      </div>

      {/* Quick Filters */}
      <div className="bg-white px-4 py-3 border-b border-gray-200">
        <div className="flex gap-2 overflow-x-auto scrollbar-hide">
          <button
            onClick={() => setHasEpipen(!hasEpipen)}
            className={`px-4 py-2 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors min-h-[44px] ${
              hasEpipen
                ? 'bg-[#2563EB] text-white'
                : 'bg-[#EFF6FF] text-[#64748B] border border-[#DBEAFE]'
            }`}
          >
            Has Medications
          </button>
          <button
            onClick={() => setHasAllergies(!hasAllergies)}
            className={`px-4 py-2 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors min-h-[44px] ${
              hasAllergies
                ? 'bg-[#2563EB] text-white'
                : 'bg-[#EFF6FF] text-[#64748B] border border-[#DBEAFE]'
            }`}
          >
            Has Allergies
          </button>
          <button
            onClick={() => setHasPendingDocs(!hasPendingDocs)}
            className={`px-4 py-2 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors min-h-[44px] ${
              hasPendingDocs
                ? 'bg-[#2563EB] text-white'
                : 'bg-[#EFF6FF] text-[#64748B] border border-[#DBEAFE]'
            }`}
          >
            Pending Docs
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="px-4 py-4">
        {isSearching ? (
          /* Search Results */
          <div>
            <div className="mb-3">
              <p className="text-[13px] text-[#64748B]">
                {filteredStudents.length} {filteredStudents.length === 1 ? 'student' : 'students'} found
              </p>
            </div>

            <div className="space-y-2">
              {filteredStudents.map((student) => (
                <button
                  key={student.id}
                  onClick={() => handleStudentClick(student.id)}
                  className={`
                    w-full text-left bg-white rounded-xl p-3 border border-gray-200
                    ${student.flaggedToday ? 'border-l-[3px] border-l-[#F59E0B]' : ''}
                  `}
                >
                  <div className="flex items-center gap-3">
                    {/* Avatar */}
                    <div
                      className="w-10 h-10 rounded-full flex items-center justify-center text-white text-[14px] font-medium flex-shrink-0"
                      style={{ backgroundColor: getAvatarColor(student.gradeLevel) }}
                    >
                      {student.initials}
                    </div>

                    {/* Student Info */}
                    <div className="flex-1 min-w-0">
                      <div className="text-[14px] font-medium text-gray-900">
                        {student.name}
                      </div>
                      <div className="text-[12px] text-[#64748B]">
                        {student.grade} • {student.room} • {student.schoolId}
                      </div>
                    </div>

                    {/* Medical Alerts */}
                    {student.alerts && student.alerts.length > 0 && (
                      <div className="flex items-center gap-1 flex-shrink-0">
                        {student.alerts.slice(0, 3).map((alert, index) => (
                          <span
                            key={index}
                            className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium ${getAlertStyle(
                              alert.color
                            )}`}
                          >
                            {alert.label}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                </button>
              ))}
            </div>
          </div>
        ) : (
          /* Pre-Search State */
          <>
            {/* Recent Section */}
            <div className="mb-6">
              <h2 className="text-[14px] font-medium text-gray-900 mb-3">
                Recent
              </h2>
              <div className="space-y-2">
                {recentStudents.map((student) => (
                  <button
                    key={student.id}
                    onClick={() => handleStudentClick(student.id)}
                    className="w-full text-left bg-white rounded-xl p-3 border border-gray-200"
                  >
                    <div className="flex items-center gap-3">
                      {/* Avatar */}
                      <div
                        className="w-10 h-10 rounded-full flex items-center justify-center text-white text-[14px] font-medium flex-shrink-0"
                        style={{ backgroundColor: getAvatarColor(student.gradeLevel) }}
                      >
                        {student.initials}
                      </div>

                      {/* Student Info */}
                      <div className="flex-1 min-w-0">
                        <div className="text-[14px] font-medium text-gray-900">
                          {student.name}
                        </div>
                        <div className="text-[12px] text-[#64748B]">
                          {student.grade} • {student.room} • {student.schoolId}
                        </div>
                      </div>

                      {/* Medical Alerts */}
                      {student.alerts && student.alerts.length > 0 && (
                        <div className="flex items-center gap-1 flex-shrink-0">
                          {student.alerts.slice(0, 3).map((alert, index) => (
                            <span
                              key={index}
                              className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium ${getAlertStyle(
                                alert.color
                              )}`}
                            >
                              {alert.label}
                            </span>
                          ))}
                        </div>
                      )}
                    </div>
                  </button>
                ))}
              </div>
            </div>

            {/* Flagged Today Section */}
            <div>
              <h2 className="text-[14px] font-medium text-gray-900 mb-3">
                Flagged Today
              </h2>
              <div className="space-y-2">
                {flaggedStudents.map((student) => (
                  <button
                    key={student.id}
                    onClick={() => handleStudentClick(student.id)}
                    className="w-full text-left bg-white rounded-xl p-3 border border-gray-200 border-l-[3px] border-l-[#F59E0B]"
                  >
                    <div className="flex items-center gap-3">
                      {/* Avatar */}
                      <div
                        className="w-10 h-10 rounded-full flex items-center justify-center text-white text-[14px] font-medium flex-shrink-0"
                        style={{ backgroundColor: getAvatarColor(student.gradeLevel) }}
                      >
                        {student.initials}
                      </div>

                      {/* Student Info */}
                      <div className="flex-1 min-w-0">
                        <div className="text-[14px] font-medium text-gray-900">
                          {student.name}
                        </div>
                        <div className="text-[12px] text-[#64748B]">
                          {student.grade} • {student.room} • {student.schoolId}
                        </div>
                      </div>

                      {/* Medical Alerts */}
                      {student.alerts && student.alerts.length > 0 && (
                        <div className="flex items-center gap-1 flex-shrink-0">
                          {student.alerts.slice(0, 3).map((alert, index) => (
                            <span
                              key={index}
                              className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium ${getAlertStyle(
                                alert.color
                              )}`}
                            >
                              {alert.label}
                            </span>
                          ))}
                        </div>
                      )}
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
