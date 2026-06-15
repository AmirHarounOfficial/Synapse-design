import { useNavigate } from 'react-router';
import { ChevronLeft, Check, Clock, X, Lock } from 'lucide-react';
import { useState } from 'react';

interface DoseEntry {
  id: string;
  time: string;
  student: string;
  medication: string;
  status: 'given' | 'pending' | 'missed' | 'upcoming';
  administeredBy?: string;
  administeredAt?: string;
}

export function DailyDoseView() {
  const navigate = useNavigate();

  const today = new Date().toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });

  const [doses] = useState<DoseEntry[]>([
    {
      id: '1',
      time: '8:00 AM',
      student: 'Emma Johnson',
      medication: 'Albuterol Inhaler 90mcg',
      status: 'given',
      administeredBy: 'Nurse Smith',
      administeredAt: '08:01:44 AM'
    },
    {
      id: '2',
      time: '8:30 AM',
      student: 'Marcus Chen',
      medication: 'Methylphenidate 10mg',
      status: 'given',
      administeredBy: 'Nurse Smith',
      administeredAt: '08:29:12 AM'
    },
    {
      id: '3',
      time: '9:00 AM',
      student: 'Sarah Williams',
      medication: 'Insulin Lispro 5 units',
      status: 'missed',
    },
    {
      id: '4',
      time: '10:00 AM',
      student: 'Alex Martinez',
      medication: 'Amoxicillin 250mg',
      status: 'given',
      administeredBy: 'Nurse Smith',
      administeredAt: '10:02:33 AM'
    },
    {
      id: '5',
      time: '11:30 AM',
      student: 'Olivia Brown',
      medication: 'EpiPen Jr 0.15mg',
      status: 'pending',
    },
    {
      id: '6',
      time: '12:00 PM',
      student: 'James Taylor',
      medication: 'Albuterol Inhaler 90mcg',
      status: 'given',
      administeredBy: 'Nurse Smith',
      administeredAt: '12:01:15 PM'
    },
    {
      id: '7',
      time: '1:00 PM',
      student: 'Sophia Davis',
      medication: 'Acetaminophen 325mg',
      status: 'pending',
    },
    {
      id: '8',
      time: '2:00 PM',
      student: 'Liam Anderson',
      medication: 'Methylphenidate 10mg',
      status: 'given',
      administeredBy: 'Nurse Smith',
      administeredAt: '02:00:08 PM'
    },
  ]);

  const stats = {
    total: doses.length,
    given: doses.filter(d => d.status === 'given').length,
    pending: doses.filter(d => d.status === 'pending').length,
    missed: doses.filter(d => d.status === 'missed').length,
  };

  const handleGiveNow = (doseId: string) => {
    const dose = doses.find(d => d.id === doseId);
    if (dose) {
      navigate('/nurse/medications/dose-confirmation', {
        state: {
          student: dose.student,
          medication: dose.medication,
          scheduledTime: dose.time
        }
      });
    }
  };

  const handleLogMissedReason = (doseId: string) => {
    // Navigate to missed dose reason logging screen
    console.log('Log reason for missed dose:', doseId);
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'given':
        return (
          <div className="w-6 h-6 rounded-full bg-[#10B981] flex items-center justify-center">
            <Check className="w-4 h-4 text-white" strokeWidth={2.5} />
          </div>
        );
      case 'pending':
        return (
          <div className="w-6 h-6 rounded-full bg-[#F59E0B] flex items-center justify-center">
            <Clock className="w-3.5 h-3.5 text-white" strokeWidth={2.5} />
          </div>
        );
      case 'missed':
        return (
          <div className="w-6 h-6 rounded-full bg-[#DC2626] flex items-center justify-center">
            <X className="w-4 h-4 text-white" strokeWidth={2.5} />
          </div>
        );
      case 'upcoming':
        return (
          <div className="w-6 h-6 rounded-full bg-[#E2E8F0] flex items-center justify-center">
            <Clock className="w-3.5 h-3.5 text-[#64748B]" strokeWidth={2.5} />
          </div>
        );
      default:
        return null;
    }
  };

  return (
    <div className="flex flex-col h-full bg-white">
      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2"
          aria-label="Go back"
        >
          <ChevronLeft className="w-6 h-6 text-gray-900" />
        </button>

        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900">
          Today's Doses
        </h1>

        <span className="text-[13px] text-[#64748B]">
          {today}
        </span>
      </header>

      <div className="flex-1 overflow-y-auto">
        {/* Summary Stats */}
        <div className="px-4 pt-4 pb-3">
          <div className="grid grid-cols-4 gap-2">
            <div className="text-center">
              <div className="font-medium text-gray-900">{stats.total}</div>
              <div className="text-[13px] text-[#64748B]">Total</div>
            </div>
            <div className="text-center">
              <div className="font-medium text-[#10B981] flex items-center justify-center gap-1">
                {stats.given}
                <Check className="w-3.5 h-3.5" strokeWidth={2.5} />
              </div>
              <div className="text-[13px] text-[#64748B]">Given</div>
            </div>
            <div className="text-center">
              <div className="font-medium text-[#F59E0B]">{stats.pending}</div>
              <div className="text-[13px] text-[#64748B]">Pending</div>
            </div>
            <div className="text-center">
              <div className="font-medium text-[#DC2626]">{stats.missed}</div>
              <div className="text-[13px] text-[#64748B]">Missed</div>
            </div>
          </div>

          {/* Progress Bar */}
          <div className="mt-3">
            <div className="h-1.5 bg-[#E2E8F0] rounded-full overflow-hidden">
              <div
                className="h-full bg-[#10B981] transition-all duration-300"
                style={{ width: `${(stats.given / stats.total) * 100}%` }}
              />
            </div>
          </div>
        </div>

        {/* Timeline */}
        <div className="px-4 pb-24">
          {doses.map((dose, index) => (
            <div key={dose.id} className="flex gap-3 relative">
              {/* Time Column */}
              <div className="w-12 flex-shrink-0 pt-3 text-center">
                <div className="text-[13px] text-[#64748B] leading-tight">
                  {dose.time}
                </div>
              </div>

              {/* Timeline */}
              <div className="flex flex-col items-center flex-shrink-0">
                {/* Status Icon */}
                <div className="relative z-10 mt-3">
                  {getStatusIcon(dose.status)}
                </div>

                {/* Vertical Line */}
                {index < doses.length - 1 && (
                  <div className="w-px flex-1 bg-[#E2E8F0] min-h-[60px]" />
                )}
              </div>

              {/* Content Card */}
              <div className="flex-1 pb-4">
                <div
                  className={`
                    mt-2 p-3 rounded-xl border
                    ${dose.status === 'missed'
                      ? 'border-l-[3px] border-l-[#DC2626] border-t border-r border-b border-gray-200'
                      : 'border-gray-200'
                    }
                  `}
                >
                  {/* Missed Chip */}
                  {dose.status === 'missed' && (
                    <div className="mb-2">
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium bg-[#FEE2E2] text-[#DC2626]">
                        Missed
                      </span>
                    </div>
                  )}

                  {/* Student & Medication */}
                  <div className="mb-1">
                    <div className="text-[14px] font-medium text-gray-900">
                      {dose.student}
                    </div>
                    <div className="text-[13px] text-[#64748B]">
                      {dose.medication}
                    </div>
                  </div>

                  {/* Status-specific content */}
                  {dose.status === 'given' && dose.administeredBy && (
                    <div className="flex items-start gap-1.5 mt-2 text-[12px] text-[#64748B]">
                      <Lock className="w-3 h-3 mt-0.5 flex-shrink-0" />
                      <span>
                        Administered by {dose.administeredBy} at {dose.administeredAt}
                      </span>
                    </div>
                  )}

                  {dose.status === 'pending' && (
                    <button
                      onClick={() => handleGiveNow(dose.id)}
                      className="mt-2 px-3 py-1.5 bg-[#10B981] text-white text-[13px] font-medium rounded-full min-h-[44px] min-w-[44px]"
                    >
                      Give now
                    </button>
                  )}

                  {dose.status === 'missed' && (
                    <div className="mt-2 space-y-2">
                      <button
                        onClick={() => handleGiveNow(dose.id)}
                        className="px-3 py-1.5 bg-[#DC2626] text-white text-[13px] font-medium rounded-full min-h-[44px]"
                      >
                        Overdue — log reason
                      </button>
                      <button
                        onClick={() => handleLogMissedReason(dose.id)}
                        className="text-[13px] text-[#DC2626] font-medium underline min-h-[44px]"
                      >
                        Log reason for missed dose
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
