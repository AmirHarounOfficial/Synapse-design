import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, CheckCircle, ChevronDown } from 'lucide-react';

interface ClinicVisit {
  id: string;
  date: string;
  time: string;
  reason: string;
  category: 'Minor' | 'Moderate' | 'Emergency';
  nurseName: string;
  verified: boolean;
}

export function ParentClinicHistory() {
  const navigate = useNavigate();
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const visits: ClinicVisit[] = [
    {
      id: '1',
      date: 'May 25, 2026',
      time: '10:45 AM',
      reason: 'Minor injury',
      category: 'Minor',
      nurseName: 'Sarah Martinez, RN',
      verified: true
    },
    {
      id: '2',
      date: 'May 22, 2026',
      time: '2:15 PM',
      reason: 'Headache',
      category: 'Minor',
      nurseName: 'Sarah Martinez, RN',
      verified: true
    },
    {
      id: '3',
      date: 'May 18, 2026',
      time: '11:30 AM',
      reason: 'Allergic reaction',
      category: 'Moderate',
      nurseName: 'Sarah Martinez, RN',
      verified: true
    },
    {
      id: '4',
      date: 'May 10, 2026',
      time: '9:20 AM',
      reason: 'Medication administration',
      category: 'Minor',
      nurseName: 'Sarah Martinez, RN',
      verified: true
    }
  ];

  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'Emergency':
        return 'bg-[#FEE2E2] text-[#DC2626]';
      case 'Moderate':
        return 'bg-[#FEF3C7] text-[#F59E0B]';
      default:
        return 'bg-[#F0F9FF] text-[#0369A1]';
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
          Clinic History
        </h1>
      </header>

      <div className="px-4 py-4">
        {/* Filter Bar */}
        <div className="flex gap-3 mb-4">
          <button className="flex-1 min-h-[44px] px-4 py-2 bg-white border border-gray-200 rounded-lg flex items-center justify-between">
            <span className="text-[14px] text-gray-900">All dates</span>
            <ChevronDown className="w-4 h-4 text-[#64748B]" />
          </button>
          <button className="flex-1 min-h-[44px] px-4 py-2 bg-white border border-gray-200 rounded-lg flex items-center justify-between">
            <span className="text-[14px] text-gray-900">All reasons</span>
            <ChevronDown className="w-4 h-4 text-[#64748B]" />
          </button>
        </div>

        {/* Visit List */}
        <div className="space-y-3">
          {visits.map((visit) => (
            <button
              key={visit.id}
              onClick={() => setExpandedId(expandedId === visit.id ? null : visit.id)}
              className="w-full bg-white rounded-xl border border-gray-200 p-4 text-left active:bg-gray-50"
            >
              {/* Header */}
              <div className="flex items-start justify-between mb-3">
                <div>
                  <div className="text-[15px] font-semibold text-gray-900 mb-1">
                    {visit.reason}
                  </div>
                  <div className="text-[13px] text-[#64748B]">
                    {visit.date} at {visit.time}
                  </div>
                </div>
                <span className={`px-2 py-0.5 rounded text-[11px] font-semibold ${getCategoryColor(visit.category)}`}>
                  {visit.category.toUpperCase()}
                </span>
              </div>

              {/* Always Visible Info */}
              <div className="flex items-center gap-2 mb-3">
                <CheckCircle className="w-4 h-4 text-[#10B981]" />
                <span className="text-[12px] text-[#10B981] font-medium">
                  Record is secure ✓
                </span>
              </div>

              {/* Expanded Info */}
              {expandedId === visit.id && (
                <div className="pt-3 border-t border-gray-100 space-y-2">
                  <div className="flex justify-between">
                    <span className="text-[13px] text-[#64748B]">Attended by</span>
                    <span className="text-[13px] font-medium text-gray-900">{visit.nurseName}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-[13px] text-[#64748B]">Timestamp</span>
                    <span className="text-[13px] font-medium text-gray-900">{visit.date} {visit.time}</span>
                  </div>
                  <div className="bg-[#F8FAFC] border border-gray-200 rounded-lg p-3 mt-3">
                    <p className="text-[12px] text-[#64748B] leading-relaxed">
                      Detailed clinical information is protected under FERPA and HIPAA. Only category and nurse attestation are shown to maintain privacy compliance.
                    </p>
                  </div>
                </div>
              )}
            </button>
          ))}
        </div>

        {/* Info Card */}
        <div className="bg-[#EFF6FF] border border-[#2563EB] rounded-xl p-4 mt-4">
          <p className="text-[12px] text-[#1E40AF] leading-relaxed">
            Complete clinic records including clinical notes and diagnoses are maintained by the school nurse and are available upon written request per FERPA guidelines.
          </p>
        </div>
      </div>
    </div>
  );
}
