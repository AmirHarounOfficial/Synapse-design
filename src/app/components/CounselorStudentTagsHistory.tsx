import { ArrowLeft, AlertTriangle, Cloud, Lock } from 'lucide-react';
import { useNavigate } from 'react-router';

export function CounselorStudentTagsHistory() {
  const navigate = useNavigate();

  const student = {
    name: 'Maya Thompson',
    initials: 'MT',
    grade: '4th Grade'
  };

  const tagHistory = [
    {
      id: '1',
      date: '2026-05-31',
      time: '10:45 AM',
      tags: ['Headache'],
      environmentalContext: 'AQI Advisory, Indoor only',
      notes: 'Student reported mild headache after recess. Rested in quiet area for 10 minutes.',
      counselor: 'Dr. Sarah Chen'
    },
    {
      id: '2',
      date: '2026-05-28',
      time: '2:15 PM',
      tags: ['Headache', 'Difficulty focusing'],
      environmentalContext: 'Normal air quality',
      notes: 'Second occurrence this week. Student mentioned feeling overwhelmed with math assignment.',
      counselor: 'Dr. Sarah Chen'
    },
    {
      id: '3',
      date: '2026-05-26',
      time: '11:30 AM',
      tags: ['Headache'],
      environmentalContext: 'AQI Advisory, Indoor only',
      notes: 'First report of headache. Asked to take break.',
      counselor: 'Dr. Sarah Chen'
    },
    {
      id: '4',
      date: '2026-05-24',
      time: '9:45 AM',
      tags: ['Low mood'],
      environmentalContext: 'Normal air quality',
      notes: 'Student seemed quieter than usual during morning circle.',
      counselor: 'Dr. Sarah Chen'
    }
  ];

  // Detect repeated tags
  const headacheCount = tagHistory.filter(h => h.tags.includes('Headache')).length;
  const showTrendWarning = headacheCount >= 3;

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col" style={{ width: '393px', height: '852px' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
          aria-label="Go back"
        >
          <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
        </button>
        <div className="flex-1">
          <h1 className="text-[17px] font-medium text-[#0F172A]">
            {student.name}
          </h1>
          <p className="text-[13px] text-[#64748B]">
            Wellbeing History
          </p>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto">
        {/* Student Header */}
        <div className="bg-white border-b border-gray-200 px-4 py-4">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full bg-[#F3F0FF] flex items-center justify-center flex-shrink-0">
              <span className="text-[15px] font-medium text-[#7C3AED]">
                {student.initials}
              </span>
            </div>
            <div>
              <div className="text-[17px] font-semibold text-[#0F172A]">
                {student.name}
              </div>
              <div className="text-[13px] text-[#64748B]">
                {student.grade}
              </div>
            </div>
          </div>
        </div>

        <div className="px-4 py-4 space-y-4">
          {/* Trend Warning */}
          {showTrendWarning && (
            <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4">
              <div className="flex items-start gap-3">
                <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <div className="text-[14px] font-semibold text-[#92400E] mb-1">
                    Repeated Pattern Detected
                  </div>
                  <div className="text-[13px] text-[#92400E] mb-2">
                    "Headache" tag noted {headacheCount} times in recent history — consider referral or environmental assessment.
                  </div>
                  <button className="text-[13px] text-[#2563EB] font-medium">
                    Generate referral report
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Timeline */}
          <div>
            <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
              Tag Timeline
            </h2>
            <div className="space-y-3">
              {tagHistory.map((entry, index) => (
                <div key={entry.id} className="bg-white rounded-xl border border-gray-200 p-4">
                  {/* Date & Time */}
                  <div className="flex items-center justify-between mb-3">
                    <div className="text-[14px] font-medium text-[#0F172A]">
                      {new Date(entry.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      {entry.time}
                    </div>
                  </div>

                  {/* Tags */}
                  <div className="flex flex-wrap gap-2 mb-3">
                    {entry.tags.map((tag) => (
                      <span
                        key={tag}
                        className="inline-flex items-center px-2.5 py-1 rounded-full text-[12px] font-medium bg-[#F3F0FF] text-[#7C3AED]"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>

                  {/* Environmental Context */}
                  <div className="flex items-start gap-2 mb-2 pb-3 border-b border-gray-100">
                    <Cloud className="w-4 h-4 text-[#64748B] flex-shrink-0 mt-0.5" />
                    <div className="text-[12px] text-[#64748B]">
                      {entry.environmentalContext}
                    </div>
                  </div>

                  {/* Notes */}
                  <div className="mb-3">
                    <p className="text-[13px] text-[#0F172A] leading-relaxed">
                      {entry.notes}
                    </p>
                  </div>

                  {/* Locked Record Footer */}
                  <div className="flex items-center gap-2 pt-2 border-t border-gray-100">
                    <Lock className="w-3 h-3 text-[#64748B]" />
                    <span className="text-[11px] text-[#64748B]">
                      Logged by {entry.counselor}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
