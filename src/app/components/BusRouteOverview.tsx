import { useNavigate } from 'react-router';
import { AlertTriangle, Check, Clock } from 'lucide-react';
import { useState } from 'react';

interface Student {
  id: string;
  name: string;
  stopNumber: number;
  status: 'pending' | 'boarded' | 'absent';
  earlyDismissal?: boolean;
}

export function BusRouteOverview() {
  const navigate = useNavigate();
  const [students, setStudents] = useState<Student[]>([
    {
      id: '1',
      name: 'Emma Rodriguez',
      stopNumber: 1,
      status: 'boarded'
    },
    {
      id: '2',
      name: 'Liam Thompson',
      stopNumber: 1,
      status: 'boarded'
    },
    {
      id: '3',
      name: 'Ava Johnson',
      stopNumber: 2,
      status: 'boarded'
    },
    {
      id: '4',
      name: 'Maya Chen',
      stopNumber: 4,
      status: 'pending',
      earlyDismissal: true
    },
    {
      id: '5',
      name: 'Noah Williams',
      stopNumber: 5,
      status: 'pending'
    },
    {
      id: '6',
      name: 'Olivia Martinez',
      stopNumber: 5,
      status: 'pending'
    },
    {
      id: '7',
      name: 'Ethan Davis',
      stopNumber: 6,
      status: 'pending'
    }
  ]);

  const currentTime = new Date().toLocaleTimeString('en-US', { 
    hour: '2-digit', 
    minute: '2-digit' 
  });

  const totalStudents = students.length;
  const boardedCount = students.filter(s => s.status === 'boarded').length;
  const progressPercent = (boardedCount / totalStudents) * 100;

  const earlyDismissalStudent = students.find(s => s.earlyDismissal);

  const handleStudentTap = (student: Student) => {
    if (student.status === 'pending' && !student.earlyDismissal) {
      navigate(`/bus/boarding/${student.id}`);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="px-4 py-3">
          <div className="flex items-center justify-between mb-1">
            <h1 className="text-[17px] font-medium text-gray-900">
              Route 12 — Morning
            </h1>
            <div className="flex items-center gap-2 text-[#64748B]">
              <Clock className="w-4 h-4" />
              <span className="text-[15px] font-medium">{currentTime}</span>
            </div>
          </div>
        </div>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Route Status */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide">
              ROUTE STATUS
            </h2>
            <div className="text-[14px] font-semibold text-gray-900">
              {boardedCount} of {totalStudents}
            </div>
          </div>
          
          {/* Progress Bar */}
          <div className="w-full h-3 bg-gray-100 rounded-full overflow-hidden">
            <div 
              className="h-full bg-[#10B981] transition-all duration-300 rounded-full"
              style={{ width: `${progressPercent}%` }}
            />
          </div>
          
          <div className="text-[12px] text-[#64748B] mt-2 text-center">
            {progressPercent.toFixed(0)}% Complete
          </div>
        </div>

        {/* Early Dismissal Notice */}
        {earlyDismissalStudent && (
          <div className="bg-[#FEF3C7] border-2 border-[#F59E0B] rounded-xl p-4">
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-6 h-6 text-[#F59E0B] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[14px] text-[#92400E] font-semibold mb-1">
                  Early Dismissal Alert
                </div>
                <p className="text-[13px] text-[#92400E] leading-relaxed">
                  <strong>{earlyDismissalStudent.name}</strong> will NOT be on the afternoon bus — early dismissal confirmed. Do not wait at Stop {earlyDismissalStudent.stopNumber}.
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Student Manifest */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            STUDENT MANIFEST ({totalStudents})
          </h2>

          <div className="space-y-2">
            {students.map((student) => (
              <button
                key={student.id}
                onClick={() => handleStudentTap(student)}
                disabled={student.status === 'boarded' || student.earlyDismissal}
                className={`w-full text-left bg-white rounded-xl border p-4 transition-all ${
                  student.status === 'boarded'
                    ? 'border-[#10B981] bg-[#F0FDF4]'
                    : student.earlyDismissal
                    ? 'border-[#F59E0B] bg-[#FFFBEB] opacity-60'
                    : 'border-gray-200 active:bg-gray-50'
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <div className="text-[16px] font-medium text-gray-900">
                        {student.name}
                      </div>
                      {student.earlyDismissal && (
                        <div className="inline-flex items-center px-2 py-0.5 rounded-md bg-[#FEF3C7] text-[#92400E] text-[11px] font-semibold">
                          EARLY DISMISSAL
                        </div>
                      )}
                    </div>
                    <div className="text-[13px] text-[#64748B]">
                      Stop {student.stopNumber}
                    </div>
                  </div>
                  
                  <div>
                    {student.status === 'boarded' && (
                      <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#D1FAE5] text-[#065F46]">
                        <Check className="w-4 h-4" />
                        <span className="text-[12px] font-semibold">Boarded</span>
                      </div>
                    )}
                    {student.status === 'pending' && !student.earlyDismissal && (
                      <div className="inline-flex items-center px-3 py-1.5 rounded-lg bg-gray-100 text-[#64748B]">
                        <span className="text-[12px] font-semibold">Pending</span>
                      </div>
                    )}
                    {student.earlyDismissal && (
                      <div className="inline-flex items-center px-3 py-1.5 rounded-lg bg-[#FEF3C7] text-[#92400E]">
                        <span className="text-[12px] font-semibold">N/A</span>
                      </div>
                    )}
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Info Notice */}
        <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-xl p-3">
          <p className="text-[12px] text-[#1E40AF] leading-relaxed text-center">
            Tap any pending student to confirm boarding. Parents will receive automatic notifications.
          </p>
        </div>
      </div>
    </div>
  );
}
