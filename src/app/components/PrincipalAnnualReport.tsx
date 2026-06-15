import { ArrowLeft, Download, Eye, Check } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function PrincipalAnnualReport() {
  const navigate = useNavigate();
  const [academicYear, setAcademicYear] = useState('2025-2026');
  const [includes, setIncludes] = useState({
    clinicVisits: true,
    medicationCompliance: true,
    emergencyEvents: true,
    documentStatus: true,
    staffActivity: true,
    wellnessTrends: true
  });

  const toggleInclude = (key: keyof typeof includes) => {
    setIncludes({ ...includes, [key]: !includes[key] });
  };

  const handlePreview = () => {
    alert('Opening preview...');
  };

  const handleGenerate = () => {
    alert('Generating annual report PDF with school branding and Principal digital signature...');
  };

  const reportItems = [
    { key: 'clinicVisits' as const, label: 'Total clinic visits', description: 'Monthly breakdown and trends' },
    { key: 'medicationCompliance' as const, label: 'Medication compliance', description: 'Adherence rates and statistics' },
    { key: 'emergencyEvents' as const, label: 'Emergency events', description: 'Incidents requiring immediate response' },
    { key: 'documentStatus' as const, label: 'Document status', description: 'Parent consent and form completion' },
    { key: 'staffActivity' as const, label: 'Staff activity summary', description: 'System usage and engagement metrics' },
    { key: 'wellnessTrends' as const, label: 'Student wellness trends', description: 'Counselor tags and patterns' }
  ];

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
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Annual Report
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Academic Year */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
            Academic Year
          </label>
          <select
            value={academicYear}
            onChange={(e) => setAcademicYear(e.target.value)}
            className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent appearance-none"
            style={{
              backgroundImage: `url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1.5L6 6.5L11 1.5' stroke='%2364748B' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E")`,
              backgroundRepeat: 'no-repeat',
              backgroundPosition: 'right 16px center'
            }}
          >
            <option value="2025-2026">2025–2026 (Current)</option>
            <option value="2024-2025">2024–2025</option>
            <option value="2023-2024">2023–2024</option>
          </select>
        </div>

        {/* Report Includes */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Report Includes
          </h2>
          <div className="space-y-3">
            {reportItems.map((item) => (
              <label key={item.key} className="flex items-start gap-3">
                <div className="relative flex items-center justify-center flex-shrink-0 mt-0.5">
                  <input
                    type="checkbox"
                    checked={includes[item.key]}
                    onChange={() => toggleInclude(item.key)}
                    className="w-5 h-5 rounded border-gray-300 text-[#2563EB] focus:ring-[#2563EB] cursor-pointer"
                  />
                </div>
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                    {item.label}
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    {item.description}
                  </div>
                </div>
              </label>
            ))}
          </div>
        </div>

        {/* Report Details */}
        <div className="bg-[#F1F5F9] rounded-lg p-4">
          <div className="text-[12px] text-[#64748B] leading-relaxed">
            The report will be generated as a professionally formatted PDF with:
          </div>
          <ul className="mt-2 space-y-1 text-[12px] text-[#64748B]">
            <li className="flex items-start gap-2">
              <Check className="w-3 h-3 text-[#10B981] mt-0.5 flex-shrink-0" />
              <span>School branding and logo</span>
            </li>
            <li className="flex items-start gap-2">
              <Check className="w-3 h-3 text-[#10B981] mt-0.5 flex-shrink-0" />
              <span>Principal digital signature</span>
            </li>
            <li className="flex items-start gap-2">
              <Check className="w-3 h-3 text-[#10B981] mt-0.5 flex-shrink-0" />
              <span>Charts and statistical summaries</span>
            </li>
            <li className="flex items-start gap-2">
              <Check className="w-3 h-3 text-[#10B981] mt-0.5 flex-shrink-0" />
              <span>FERPA-compliant aggregate data only</span>
            </li>
          </ul>
        </div>
      </div>

      {/* Bottom Buttons */}
      <div className="bg-white border-t border-gray-200 p-4 space-y-2">
        <button
          onClick={handlePreview}
          className="w-full h-[44px] bg-white border border-gray-300 text-[#0F172A] rounded-lg font-medium text-[14px] flex items-center justify-center gap-2 active:bg-gray-50"
        >
          <Eye className="w-5 h-5" />
          Preview
        </button>
        <button
          onClick={handleGenerate}
          className="w-full h-[48px] bg-[#2563EB] text-white rounded-lg font-medium text-[15px] flex items-center justify-center gap-2 active:bg-[#1D4ED8]"
        >
          <Download className="w-5 h-5" />
          Generate & Download
        </button>
      </div>
    </div>
  );
}
