import { useNavigate } from 'react-router';
import { ArrowLeft, Lock, Plus, CheckCircle, Clock, XCircle } from 'lucide-react';

interface DoseRecord {
  id: string;
  time: string;
  administeredBy: string;
  status: 'Administered' | 'Delayed' | 'Missed';
}

interface Medication {
  id: string;
  name: string;
  dosage: string;
  doses: DoseRecord[];
}

export function ParentMedicationLog() {
  const navigate = useNavigate();

  const medications: Medication[] = [
    {
      id: '1',
      name: 'Ritalin',
      dosage: '10mg',
      doses: [
        {
          id: '1',
          time: '10:30 AM',
          administeredBy: 'Sarah Martinez, RN',
          status: 'Administered'
        },
        {
          id: '2',
          time: '10:35 AM (Yesterday)',
          administeredBy: 'Sarah Martinez, RN',
          status: 'Delayed'
        },
        {
          id: '3',
          time: '10:30 AM (May 23)',
          administeredBy: 'Sarah Martinez, RN',
          status: 'Administered'
        }
      ]
    },
    {
      id: '2',
      name: 'Albuterol Inhaler',
      dosage: '2 puffs',
      doses: [
        {
          id: '4',
          time: '2:15 PM (May 22)',
          administeredBy: 'Sarah Martinez, RN',
          status: 'Administered'
        }
      ]
    }
  ];

  const getStatusConfig = (status: string) => {
    switch (status) {
      case 'Administered':
        return {
          icon: CheckCircle,
          color: 'text-[#10B981]',
          bg: 'bg-[#D1FAE5]'
        };
      case 'Delayed':
        return {
          icon: Clock,
          color: 'text-[#F59E0B]',
          bg: 'bg-[#FEF3C7]'
        };
      case 'Missed':
        return {
          icon: XCircle,
          color: 'text-[#DC2626]',
          bg: 'bg-[#FEE2E2]'
        };
      default:
        return {
          icon: CheckCircle,
          color: 'text-[#64748B]',
          bg: 'bg-gray-100'
        };
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 -ml-2 flex items-center justify-center"
        >
          <ArrowLeft className="w-6 h-6 text-gray-900" />
        </button>
        <h1 className="flex-1 text-center font-medium text-gray-900 pr-10">
          Medication Records
        </h1>
      </header>

      <div className="px-4 py-4">
        {/* Read-only Notice */}
        <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-3 mb-4 flex items-center gap-2">
          <Lock className="w-4 h-4 text-[#64748B]" />
          <p className="text-[12px] text-[#64748B]">
            Records are read-only. All doses are administered and logged by school nurse.
          </p>
        </div>

        {/* Medication Sections */}
        <div className="space-y-4">
          {medications.map((medication) => (
            <div key={medication.id}>
              {/* Section Header */}
              <div className="mb-3">
                <h2 className="text-[17px] font-semibold text-gray-900">
                  {medication.name}
                </h2>
                <p className="text-[13px] text-[#64748B]">
                  {medication.dosage}
                </p>
              </div>

              {/* Dose List */}
              <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
                {medication.doses.map((dose) => {
                  const statusConfig = getStatusConfig(dose.status);
                  const StatusIcon = statusConfig.icon;

                  return (
                    <div key={dose.id} className="p-4 flex items-center gap-3">
                      <div className={`w-10 h-10 rounded-full ${statusConfig.bg} flex items-center justify-center flex-shrink-0`}>
                        <StatusIcon className={`w-5 h-5 ${statusConfig.color}`} />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center justify-between mb-1">
                          <span className="text-[14px] font-medium text-gray-900">
                            {dose.time}
                          </span>
                          <span className={`px-2 py-0.5 rounded text-[11px] font-semibold ${statusConfig.color} ${statusConfig.bg}`}>
                            {dose.status}
                          </span>
                        </div>
                        <div className="text-[12px] text-[#64748B]">
                          {dose.administeredBy}
                        </div>
                      </div>
                      <Lock className="w-4 h-4 text-[#94A3B8]" />
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
        </div>

        {/* Info Card */}
        <div className="bg-[#EFF6FF] border border-[#2563EB] rounded-xl p-4 mt-4">
          <p className="text-[12px] text-[#1E40AF] leading-relaxed">
            All medication administration is performed by licensed school nurses following physician orders. Records cannot be modified and are maintained for compliance.
          </p>
        </div>
      </div>

      {/* FAB - Report Home Dose */}
      <button
        onClick={() => navigate('/parent/app/report-home-dose')}
        className="fixed bottom-[99px] right-4 w-14 h-14 bg-[#2563EB] text-white rounded-full shadow-lg flex items-center justify-center"
      >
        <Plus className="w-6 h-6" />
      </button>
    </div>
  );
}
