import { useNavigate } from 'react-router';
import { Search, Bell, Filter } from 'lucide-react';
import { useState } from 'react';

export function SecretaryStudentList() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [filterGrade, setFilterGrade] = useState('all');

  const students = [
    {
      id: '1',
      name: 'Maya Thompson',
      initials: 'MT',
      grade: '4th Grade',
      class: 'Ms. Johnson',
      consentStatus: 'Complete',
      consentColor: 'bg-[#D1FAE5] text-[#10B981]',
      documentStatus: 'Up to date',
      documentColor: 'bg-[#D1FAE5] text-[#10B981]'
    },
    {
      id: '2',
      name: 'Ethan Williams',
      initials: 'EW',
      grade: '5th Grade',
      class: 'Mr. Davis',
      consentStatus: 'Complete',
      consentColor: 'bg-[#D1FAE5] text-[#10B981]',
      documentStatus: 'Expiring soon',
      documentColor: 'bg-[#FEF3C7] text-[#F59E0B]'
    },
    {
      id: '3',
      name: 'Sophia Martinez',
      initials: 'SM',
      grade: '4th Grade',
      class: 'Ms. Johnson',
      consentStatus: 'Pending',
      consentColor: 'bg-[#FEF3C7] text-[#F59E0B]',
      documentStatus: 'Missing',
      documentColor: 'bg-[#FEE2E2] text-[#DC2626]'
    },
    {
      id: '4',
      name: 'Liam Chen',
      initials: 'LC',
      grade: '3rd Grade',
      class: 'Mrs. Anderson',
      consentStatus: 'Complete',
      consentColor: 'bg-[#D1FAE5] text-[#10B981]',
      documentStatus: 'Up to date',
      documentColor: 'bg-[#D1FAE5] text-[#10B981]'
    }
  ];

  const filteredStudents = students.filter(s => {
    const matchesSearch = s.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesGrade = filterGrade === 'all' || s.grade === filterGrade;
    return matchesSearch && matchesGrade;
  });

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
              className="w-full h-[44px] pl-10 pr-4 bg-[#F1F5F9] border border-transparent rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:bg-white focus:border-transparent"
            />
          </div>
        </div>

        {/* Filter */}
        <div className="px-4 pb-3">
          <select
            value={filterGrade}
            onChange={(e) => setFilterGrade(e.target.value)}
            className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[14px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent appearance-none"
            style={{
              backgroundImage: `url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1.5L6 6.5L11 1.5' stroke='%2364748B' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E")`,
              backgroundRepeat: 'no-repeat',
              backgroundPosition: 'right 16px center'
            }}
          >
            <option value="all">All Grades</option>
            <option value="3rd Grade">3rd Grade</option>
            <option value="4th Grade">4th Grade</option>
            <option value="5th Grade">5th Grade</option>
          </select>
        </div>
      </header>

      <div className="px-4 py-4">
        <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
          {filteredStudents.map((student) => (
            <button
              key={student.id}
              onClick={() => navigate(`/secretary/student/${student.id}`)}
              className="w-full p-4 flex items-start gap-3 text-left active:bg-gray-50"
            >
              <div className="w-12 h-12 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <span className="text-[15px] font-medium text-[#2563EB]">
                  {student.initials}
                </span>
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-[15px] font-medium text-[#0F172A] mb-0.5">
                  {student.name}
                </div>
                <div className="text-[13px] text-[#64748B] mb-2">
                  {student.grade} • {student.class}
                </div>
                <div className="flex items-center gap-2 flex-wrap">
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium ${student.consentColor}`}>
                    {student.consentStatus}
                  </span>
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium ${student.documentColor}`}>
                    {student.documentStatus}
                  </span>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
