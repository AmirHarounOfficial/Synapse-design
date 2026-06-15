import { useNavigate } from 'react-router';
import { ChevronLeft, Search, Check } from 'lucide-react';
import { useState } from 'react';

interface Student {
  id: string;
  name: string;
  initials: string;
  room: string;
  status: 'present' | 'late' | 'absent' | null;
}

export function TeacherAttendance() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [showSuccess, setShowSuccess] = useState(false);

  const [students, setStudents] = useState<Student[]>([
    { id: '1', name: 'Alex Anderson', initials: 'AA', room: '204', status: 'present' },
    { id: '2', name: 'Emma Rodriguez', initials: 'ER', room: '204', status: 'present' },
    { id: '3', name: 'Marcus Chen', initials: 'MC', room: '204', status: null },
    { id: '4', name: 'Sarah Williams', initials: 'SW', room: '204', status: 'late' },
    { id: '5', name: 'James Taylor', initials: 'JT', room: '204', status: null },
    { id: '6', name: 'Olivia Brown', initials: 'OB', room: '204', status: null },
    { id: '7', name: 'Sophia Davis', initials: 'SD', room: '204', status: null },
    { id: '8', name: 'Liam Anderson', initials: 'LA', room: '204', status: 'present' },
    { id: '9', name: 'Ava Garcia', initials: 'AG', room: '204', status: 'present' },
    { id: '10', name: 'Noah Wilson', initials: 'NW', room: '204', status: 'present' },
  ]);

  const filteredStudents = students.filter(student =>
    student.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const markedCount = students.filter(s => s.status !== null).length;
  const totalCount = students.length;
  const allMarked = markedCount === totalCount;

  const handleStatusChange = (studentId: string, status: 'present' | 'late' | 'absent') => {
    setStudents(prev =>
      prev.map(s => s.id === studentId ? { ...s, status } : s)
    );
  };

  const handleSubmit = () => {
    if (allMarked) {
      setShowSuccess(true);
      setTimeout(() => {
        navigate('/teacher/home');
      }, 2000);
    }
  };

  const getStatusButtonClass = (student: Student, statusType: 'present' | 'late' | 'absent') => {
    const isSelected = student.status === statusType;
    const baseClass = 'flex-1 py-2 rounded-lg text-[14px] font-medium min-h-[44px] transition-colors';

    if (statusType === 'present') {
      return `${baseClass} ${isSelected ? 'bg-[#10B981] text-white' : 'bg-white border border-[#E2E8F0] text-[#64748B]'}`;
    } else if (statusType === 'late') {
      return `${baseClass} ${isSelected ? 'bg-[#F59E0B] text-white' : 'bg-white border border-[#E2E8F0] text-[#64748B]'}`;
    } else {
      return `${baseClass} ${isSelected ? 'bg-[#DC2626] text-white' : 'bg-white border border-[#E2E8F0] text-[#64748B]'}`;
    }
  };

  if (showSuccess) {
    return (
      <div className="min-h-screen bg-[#F8FAFC] pb-[83px] flex items-center justify-center">
        <div className="text-center px-8">
          <div className="w-16 h-16 bg-[#D1FAE5] rounded-full flex items-center justify-center mx-auto mb-4">
            <Check className="w-8 h-8 text-[#10B981]" strokeWidth={2.5} />
          </div>
          <h2 className="text-[20px] font-medium text-gray-900 mb-2">
            Attendance Submitted
          </h2>
          <p className="text-[14px] text-[#64748B]">
            {markedCount} students marked for {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric' })}
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[180px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2"
          aria-label="Go back"
        >
          <ChevronLeft className="w-6 h-6 text-gray-900" />
        </button>

        <div className="absolute left-1/2 -translate-x-1/2 text-center">
          <h1 className="font-medium text-gray-900">
            Attendance
          </h1>
          <p className="text-[12px] text-[#64748B]">
            {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
          </p>
        </div>

        <button
          onClick={handleSubmit}
          disabled={!allMarked}
          className={`px-4 py-2 rounded-lg text-[14px] font-medium min-h-[44px] ${
            allMarked
              ? 'text-[#2563EB]'
              : 'text-[#94A3B8] cursor-not-allowed'
          }`}
        >
          Submit
        </button>
      </header>

      {/* Search Bar */}
      <div className="bg-white px-4 py-3 border-b border-gray-200">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by name..."
            className="w-full h-12 pl-10 pr-4 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
          />
        </div>
      </div>

      {/* Student List */}
      <div className="px-4 py-4 space-y-3">
        {filteredStudents.map((student) => (
          <div
            key={student.id}
            className="bg-white rounded-xl border border-gray-200 p-3"
          >
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[14px] font-medium flex-shrink-0">
                {student.initials}
              </div>
              <div className="flex-1">
                <div className="text-[14px] font-medium text-gray-900">
                  {student.name}
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Room {student.room}
                </div>
              </div>
            </div>

            <div className="grid grid-cols-3 gap-2">
              <button
                onClick={() => handleStatusChange(student.id, 'present')}
                className={getStatusButtonClass(student, 'present')}
              >
                P
              </button>
              <button
                onClick={() => handleStatusChange(student.id, 'late')}
                className={getStatusButtonClass(student, 'late')}
              >
                L
              </button>
              <button
                onClick={() => handleStatusChange(student.id, 'absent')}
                className={getStatusButtonClass(student, 'absent')}
              >
                A
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Progress Footer */}
      <div className="fixed bottom-[83px] left-0 right-0 bg-white border-t border-gray-200 p-4">
        <div className="mb-3">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[13px] text-[#64748B]">
              {markedCount} of {totalCount} marked
            </span>
            <span className="text-[13px] font-medium text-gray-900">
              {Math.round((markedCount / totalCount) * 100)}%
            </span>
          </div>
          <div className="h-2 bg-[#E2E8F0] rounded-full overflow-hidden">
            <div
              className="h-full bg-[#2563EB] transition-all duration-300"
              style={{ width: `${(markedCount / totalCount) * 100}%` }}
            />
          </div>
        </div>

        <button
          onClick={handleSubmit}
          disabled={!allMarked}
          className={`w-full px-4 py-3.5 rounded-lg text-[15px] font-medium min-h-[52px] transition-colors ${
            allMarked
              ? 'bg-[#2563EB] text-white'
              : 'bg-[#E2E8F0] text-[#94A3B8] cursor-not-allowed'
          }`}
        >
          Submit Attendance
        </button>
      </div>
    </div>
  );
}
