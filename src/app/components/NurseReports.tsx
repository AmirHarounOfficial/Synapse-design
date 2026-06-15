import { useNavigate } from 'react-router';
import { FileText, ChevronRight } from 'lucide-react';

export function NurseReports() {
  const navigate = useNavigate();

  const reportSections = [
    {
      id: 'generate',
      title: 'Generate Report',
      description: 'Create daily, weekly, or custom reports',
      path: '/nurse/reports/generate'
    },
    {
      id: 'documents',
      title: 'Document Review',
      description: 'Review pending parent submissions',
      badge: 3,
      badgeColor: 'bg-[#DC2626]',
      path: '/nurse/documents/review'
    },
    {
      id: 'medication',
      title: 'Medication Reports',
      description: 'Dose logs and compliance tracking',
      path: null
    },
    {
      id: 'clinic',
      title: 'Clinic Visit Reports',
      description: 'Visit statistics and trends',
      path: null
    },
    {
      id: 'compliance',
      title: 'Compliance Reports',
      description: 'Required screenings and documentation',
      path: null
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center border-b border-[#E2E8F0]">
        <h1 className="text-[17px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
          Reports
        </h1>
      </div>

      {/* Content */}
      <div className="px-4 pt-6 space-y-3">
        {reportSections.map((section) => (
          <button
            key={section.id}
            onClick={() => section.path && navigate(section.path)}
            disabled={!section.path}
            className="w-full text-left bg-white rounded-xl p-4 border border-gray-200 flex items-center gap-3 disabled:opacity-50"
          >
            <div className="w-12 h-12 rounded-lg bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
              <FileText className="w-6 h-6 text-[#2563EB]" />
            </div>

            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1">
                <h3 className="text-[15px] font-medium text-gray-900">
                  {section.title}
                </h3>
                {section.badge !== undefined && (
                  <span className={`flex items-center justify-center w-5 h-5 ${section.badgeColor} text-white text-[11px] font-semibold rounded-full`}>
                    {section.badge}
                  </span>
                )}
              </div>
              <p className="text-[13px] text-[#64748B]">
                {section.description}
              </p>
            </div>

            {section.path && (
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            )}
          </button>
        ))}
      </div>
    </div>
  );
}
