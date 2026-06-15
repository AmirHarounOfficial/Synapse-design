import { useNavigate } from 'react-router';
import { ChevronLeft, Info, AlertCircle } from 'lucide-react';
import { useState } from 'react';

interface HealthConsideration {
  id: string;
  studentName: string;
  initials: string;
  restriction: string;
  type: 'activity' | 'dietary' | 'environmental';
}

export function TeacherHealthConsiderations() {
  const navigate = useNavigate();
  const [showFerpaInfo, setShowFerpaInfo] = useState(false);

  const considerations: HealthConsideration[] = [
    {
      id: '1',
      studentName: 'Emma Rodriguez',
      initials: 'ER',
      restriction: 'No vigorous outdoor activity',
      type: 'activity'
    },
    {
      id: '2',
      studentName: 'Marcus Chen',
      initials: 'MC',
      restriction: 'Peanut-free environment required',
      type: 'dietary'
    },
    {
      id: '3',
      studentName: 'Sarah Williams',
      initials: 'SW',
      restriction: 'Indoor activities during dust advisories',
      type: 'environmental'
    }
  ];

  const weatherRestrictedStudents = [
    {
      id: '3',
      studentName: 'Sarah Williams',
      initials: 'SW',
      restriction: 'Must remain indoors during dust advisory'
    }
  ];

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'activity':
        return 'bg-[#DBEAFE] text-[#1E40AF]';
      case 'dietary':
        return 'bg-[#FEF3C7] text-[#92400E]';
      case 'environmental':
        return 'bg-[#F3E8FF] text-[#6B21A8]';
      default:
        return 'bg-[#E2E8F0] text-[#64748B]';
    }
  };

  const getTypeLabel = (type: string) => {
    switch (type) {
      case 'activity':
        return 'Activity';
      case 'dietary':
        return 'Dietary';
      case 'environmental':
        return 'Environmental';
      default:
        return 'Other';
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
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

        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900">
          Health Considerations
        </h1>

        <button
          onClick={() => setShowFerpaInfo(!showFerpaInfo)}
          className="flex items-center justify-center w-11 h-11"
          aria-label="FERPA information"
        >
          <Info className="w-6 h-6 text-[#64748B]" />
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* FERPA Notice Banner */}
        <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-xl p-3">
          <div className="flex gap-2">
            <Info className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-[13px] text-[#1E40AF] leading-relaxed">
                You are viewing activity restrictions only. Medical details are confidential per FERPA regulations.
              </p>
            </div>
          </div>
        </div>

        {/* Weather Restricted Today Section */}
        {weatherRestrictedStudents.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-3">
              <div className="h-px flex-1 bg-[#F59E0B]" />
              <h2 className="text-[13px] font-medium text-[#F59E0B] uppercase tracking-wide">
                Restricted from Outdoor Activities Today
              </h2>
              <div className="h-px flex-1 bg-[#F59E0B]" />
            </div>

            <div className="space-y-2">
              {weatherRestrictedStudents.map((student) => (
                <div
                  key={student.id}
                  className="bg-white rounded-xl border border-gray-200 border-l-[3px] border-l-[#F59E0B] p-3"
                >
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-[#FEF3C7] flex items-center justify-center text-[#F59E0B] text-[14px] font-medium flex-shrink-0">
                      {student.initials}
                    </div>
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-900 mb-1">
                        {student.studentName}
                      </div>
                      <div className="flex items-start gap-1">
                        <AlertCircle className="w-4 h-4 text-[#F59E0B] flex-shrink-0 mt-0.5" />
                        <p className="text-[13px] text-[#64748B]">
                          {student.restriction}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* All Health Considerations */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            All Health Considerations
          </h2>

          <div className="space-y-2">
            {considerations.map((consideration) => (
              <div
                key={consideration.id}
                className="bg-white rounded-xl border border-gray-200 p-3 pointer-events-none"
              >
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[14px] font-medium flex-shrink-0">
                    {consideration.initials}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <div className="text-[14px] font-medium text-gray-900">
                        {consideration.studentName}
                      </div>
                      <span
                        className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium ${getTypeColor(
                          consideration.type
                        )}`}
                      >
                        {getTypeLabel(consideration.type)}
                      </span>
                    </div>
                    <div className="text-[13px] text-[#64748B]">
                      {consideration.restriction}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* FERPA Disclaimer */}
        <div className="bg-[#F8FAFC] rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-2">
            <Info className="w-4 h-4 text-[#64748B] flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-[12px] text-[#64748B] leading-relaxed mb-2">
                <span className="font-medium">Privacy Notice:</span> You cannot access full medical records. These restrictions are provided to support safe classroom activities only.
              </p>
              <p className="text-[12px] text-[#64748B] leading-relaxed">
                For medical emergencies, contact the school nurse immediately at ext. 4521.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* FERPA Info Modal */}
      {showFerpaInfo && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full">
            <h3 className="text-[17px] font-semibold text-gray-900 mb-2">
              FERPA Privacy Protection
            </h3>
            <p className="text-[14px] text-[#64748B] mb-4">
              Under the Family Educational Rights and Privacy Act (FERPA), detailed medical information is confidential. You can only view activity restrictions necessary for safe classroom management.
            </p>
            <p className="text-[14px] text-[#64748B] mb-6">
              Full medical records are maintained by the school nurse and accessible only to authorized healthcare personnel.
            </p>
            <button
              onClick={() => setShowFerpaInfo(false)}
              className="w-full px-4 py-2.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-medium min-h-[44px]"
            >
              Understood
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
