import { useNavigate } from 'react-router';
import { ChevronLeft, AlertTriangle, Check, Lock } from 'lucide-react';
import { useState } from 'react';

interface RestrictedStudent {
  id: string;
  name: string;
  initials: string;
}

export function TeacherWeatherRestriction() {
  const navigate = useNavigate();
  const [isConfirmed, setIsConfirmed] = useState(false);
  const [confirmedAt, setConfirmedAt] = useState<string | null>(null);

  const restrictedStudents: RestrictedStudent[] = [
    { id: '1', name: 'Sarah Williams', initials: 'SW' },
    { id: '2', name: 'Alex Martinez', initials: 'AM' },
    { id: '3', name: 'Jordan Lee', initials: 'JL' }
  ];

  const advisoryReason = 'AQI Advisory — respiratory sensitivity';

  const handleConfirm = () => {
    const time = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    setConfirmedAt(time);
    setIsConfirmed(true);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[120px]">
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
          Weather Restriction
        </h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Alert Banner */}
        <div className="bg-[#FEF3C7] border-2 border-[#F59E0B] rounded-xl p-4">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-6 h-6 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <h2 className="text-[15px] font-medium text-[#92400E] mb-1">
                Active Weather Advisory
              </h2>
              <p className="text-[13px] text-[#92400E]">
                {advisoryReason}
              </p>
            </div>
          </div>
        </div>

        {/* Instructions */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <p className="text-[14px] text-gray-900">
            The following students must remain indoors during this advisory:
          </p>
        </div>

        {/* Student List */}
        <div className="space-y-2">
          {restrictedStudents.map((student) => (
            <div
              key={student.id}
              className="bg-white rounded-xl border border-gray-200 border-l-[3px] border-l-[#F59E0B] p-3"
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#FEF3C7] flex items-center justify-center text-[#F59E0B] text-[14px] font-medium flex-shrink-0">
                  {student.initials}
                </div>
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-gray-900">
                    {student.name}
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Confirmation Section */}
        {!isConfirmed ? (
          <div className="bg-[#F8FAFC] rounded-xl border border-gray-200 p-4">
            <p className="text-[13px] text-[#64748B] mb-1">
              Required acknowledgment:
            </p>
            <p className="text-[14px] text-gray-900 font-medium">
              I have ensured the above students remain indoors
            </p>
          </div>
        ) : (
          <div className="bg-[#D1FAE5] rounded-xl border border-[#10B981] p-4">
            <div className="flex items-start gap-3">
              <Lock className="w-5 h-5 text-[#10B981] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <p className="text-[14px] text-[#065F46] font-medium mb-1">
                  Confirmed at {confirmedAt}
                </p>
                <p className="text-[13px] text-[#065F46]">
                  Acknowledgment has been logged and locked
                </p>
              </div>
              <Check className="w-5 h-5 text-[#10B981] flex-shrink-0" />
            </div>
          </div>
        )}
      </div>

      {/* Confirmation Button */}
      <div className="fixed bottom-[83px] left-0 right-0 bg-white border-t border-gray-200 p-4">
        <button
          onClick={handleConfirm}
          disabled={isConfirmed}
          className={`w-full px-4 py-3.5 rounded-lg text-[15px] font-medium min-h-[52px] transition-colors ${
            isConfirmed
              ? 'bg-[#E2E8F0] text-[#94A3B8] cursor-not-allowed'
              : 'bg-[#F59E0B] text-white'
          }`}
        >
          {isConfirmed ? 'Confirmed' : 'Confirm Acknowledgment'}
        </button>
      </div>
    </div>
  );
}
