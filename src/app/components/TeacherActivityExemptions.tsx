import { useNavigate } from 'react-router';
import { ChevronLeft, Info, AlertTriangle, CheckCircle } from 'lucide-react';

interface Student {
  id: string;
  name: string;
  initials: string;
  grade: string;
  restriction: string;
  weatherLinked?: boolean;
}

export function TeacherActivityExemptions() {
  const navigate = useNavigate();

  const hasWeatherAdvisory = true;
  const todaysDate = new Date().toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  });

  const activeExemptions: Student[] = [
    {
      id: '1',
      name: 'Emma Rodriguez',
      initials: 'ER',
      grade: '5th Grade',
      restriction: 'No vigorous physical activity'
    },
    {
      id: '2',
      name: 'Marcus Chen',
      initials: 'MC',
      grade: '5th Grade',
      restriction: 'Light activity only'
    },
    {
      id: '3',
      name: 'James Taylor',
      initials: 'JT',
      grade: '5th Grade',
      restriction: 'No swimming'
    }
  ];

  const weatherLinkedExemptions: Student[] = [
    {
      id: '4',
      name: 'Sarah Williams',
      initials: 'SW',
      grade: '5th Grade',
      restriction: 'Indoor only today — weather advisory',
      weatherLinked: true
    },
    {
      id: '5',
      name: 'Alex Martinez',
      initials: 'AM',
      grade: '5th Grade',
      restriction: 'Indoor only today — weather advisory',
      weatherLinked: true
    },
    {
      id: '6',
      name: 'Jordan Lee',
      initials: 'JL',
      grade: '5th Grade',
      restriction: 'Indoor only today — weather advisory',
      weatherLinked: true
    }
  ];

  const hasExemptions = activeExemptions.length > 0 || weatherLinkedExemptions.length > 0;

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="flex items-center px-4 h-14">
          <button
            onClick={() => navigate(-1)}
            className="flex items-center justify-center w-11 h-11 -ml-2"
            aria-label="Go back"
          >
            <ChevronLeft className="w-6 h-6 text-gray-900" />
          </button>

          <div className="absolute left-1/2 -translate-x-1/2 text-center">
            <h1 className="font-medium text-gray-900">
              Activity Exemptions
            </h1>
            <p className="text-[12px] text-[#64748B]">
              {todaysDate}
            </p>
          </div>
        </div>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* FERPA Banner */}
        <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-xl p-3">
          <div className="flex gap-2">
            <Info className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-[13px] text-[#1E40AF] leading-relaxed">
                You are viewing activity restrictions only. Medical conditions are confidential.
              </p>
            </div>
          </div>
        </div>

        {hasExemptions ? (
          <>
            {/* Weather-Linked Exemptions */}
            {hasWeatherAdvisory && weatherLinkedExemptions.length > 0 && (
              <div>
                <div className="flex items-center gap-2 mb-3">
                  <div className="h-px flex-1 bg-[#F59E0B]" />
                  <h2 className="text-[13px] font-medium text-[#F59E0B] uppercase tracking-wide flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4" />
                    During Current AQI Advisory
                  </h2>
                  <div className="h-px flex-1 bg-[#F59E0B]" />
                </div>

                <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-3 mb-3">
                  <p className="text-[13px] text-[#92400E] font-medium">
                    {weatherLinkedExemptions.length} students must remain fully sedentary
                  </p>
                </div>

                <div className="space-y-2">
                  {weatherLinkedExemptions.map((student) => (
                    <div
                      key={student.id}
                      className="bg-white rounded-xl border border-gray-200 border-l-[3px] border-l-[#F59E0B] p-3 min-h-[64px] flex items-center pointer-events-none"
                    >
                      <div className="flex items-center gap-3 flex-1">
                        <div className="w-10 h-10 rounded-full bg-[#FEF3C7] flex items-center justify-center text-[#F59E0B] text-[14px] font-medium flex-shrink-0">
                          {student.initials}
                        </div>
                        <div className="flex-1">
                          <div className="flex items-center gap-2 mb-1">
                            <div className="text-[14px] font-medium text-gray-900">
                              {student.name}
                            </div>
                            <span className="text-[12px] text-[#64748B]">
                              {student.grade}
                            </span>
                          </div>
                          <div className="text-[13px] text-[#64748B]">
                            {student.restriction}
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Active Exemptions */}
            {activeExemptions.length > 0 && (
              <div>
                <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
                  Active Exemptions
                </h2>

                <div className="space-y-2">
                  {activeExemptions.map((student) => (
                    <div
                      key={student.id}
                      className="bg-white rounded-xl border border-gray-200 p-3 min-h-[64px] flex items-center pointer-events-none"
                    >
                      <div className="flex items-center gap-3 flex-1">
                        <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[14px] font-medium flex-shrink-0">
                          {student.initials}
                        </div>
                        <div className="flex-1">
                          <div className="flex items-center gap-2 mb-1">
                            <div className="text-[14px] font-medium text-gray-900">
                              {student.name}
                            </div>
                            <span className="text-[12px] text-[#64748B]">
                              {student.grade}
                            </span>
                          </div>
                          <div className="text-[13px] text-[#64748B]">
                            {student.restriction}
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* PE Teacher Note */}
            <div className="bg-[#F8FAFC] rounded-xl border border-gray-200 p-4">
              <div className="flex items-start gap-2">
                <Info className="w-4 h-4 text-[#64748B] flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-[12px] text-[#64748B] leading-relaxed">
                    <span className="font-medium">Students excused from today's class:</span> {activeExemptions.length + weatherLinkedExemptions.length}
                  </p>
                </div>
              </div>
            </div>
          </>
        ) : (
          /* Empty State */
          <div className="bg-white rounded-xl border border-gray-200 p-8 text-center mt-8">
            <div className="w-16 h-16 rounded-full bg-[#D1FAE5] flex items-center justify-center mx-auto mb-4">
              <CheckCircle className="w-8 h-8 text-[#10B981]" />
            </div>
            <h3 className="text-[17px] font-medium text-gray-900 mb-2">
              No Activity Restrictions Today
            </h3>
            <p className="text-[14px] text-[#64748B]">
              All students are cleared for regular physical activity
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
