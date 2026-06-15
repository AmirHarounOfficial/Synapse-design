import { useNavigate } from 'react-router';
import { Search, Bell } from 'lucide-react';
import { useState } from 'react';

export function CounselorStudentsList() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');

  const students = [
    {
      id: '1',
      name: 'Maya Thompson',
      initials: 'MT',
      grade: '4th Grade',
      recentTags: 3,
      lastTagDate: '2026-05-31',
      hasTrend: true
    },
    {
      id: '2',
      name: 'Ethan Williams',
      initials: 'EW',
      grade: '5th Grade',
      recentTags: 2,
      lastTagDate: '2026-05-31',
      hasTrend: false
    },
    {
      id: '3',
      name: 'Sophia Martinez',
      initials: 'SM',
      grade: '4th Grade',
      recentTags: 1,
      lastTagDate: '2026-05-31',
      hasTrend: false
    },
    {
      id: '4',
      name: 'Liam Chen',
      initials: 'LC',
      grade: '3rd Grade',
      recentTags: 1,
      lastTagDate: '2026-05-31',
      hasTrend: false
    },
    {
      id: '5',
      name: 'Olivia Brown',
      initials: 'OB',
      grade: '5th Grade',
      recentTags: 4,
      lastTagDate: '2026-05-30',
      hasTrend: true
    }
  ];

  const filteredStudents = students.filter(s =>
    s.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="flex items-center justify-between px-4 h-14">
          <h1 className="text-[17px] font-medium text-[#0F172A]">
            Students
          </h1>
          <button className="w-10 h-10 -mr-2 flex items-center justify-center relative">
            <Bell className="w-6 h-6 text-[#0F172A]" />
          </button>
        </div>

        {/* Search Bar */}
        <div className="px-4 pb-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
            <input
              type="text"
              placeholder="Search students..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full h-[44px] pl-10 pr-4 bg-[#F1F5F9] border border-transparent rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#7C3AED] focus:bg-white focus:border-transparent"
            />
          </div>
        </div>
      </header>

      <div className="px-4 py-4">
        <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
          {filteredStudents.map((student) => (
            <button
              key={student.id}
              onClick={() => navigate(`/counselor/student-tags/${student.id}`)}
              className="w-full p-4 flex items-center gap-3 text-left active:bg-gray-50"
            >
              <div className="w-12 h-12 rounded-full bg-[#F3F0FF] flex items-center justify-center flex-shrink-0">
                <span className="text-[15px] font-medium text-[#7C3AED]">
                  {student.initials}
                </span>
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-[15px] font-medium text-[#0F172A] mb-1">
                  {student.name}
                </div>
                <div className="text-[13px] text-[#64748B]">
                  {student.grade}
                </div>
                <div className="flex items-center gap-2 mt-1.5">
                  <span className="text-[12px] text-[#64748B]">
                    {student.recentTags} tags (30 days)
                  </span>
                  {student.hasTrend && (
                    <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium bg-[#FEF3C7] text-[#F59E0B]">
                      Trend
                    </span>
                  )}
                </div>
              </div>
              <div className="text-[12px] text-[#64748B] flex-shrink-0">
                Last: {new Date(student.lastTagDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
