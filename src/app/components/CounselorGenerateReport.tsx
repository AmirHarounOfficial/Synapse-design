import { ArrowLeft, Search, Calendar, ChevronRight } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function CounselorGenerateReport() {
  const navigate = useNavigate();
  const [selectedStudent, setSelectedStudent] = useState('Maya Thompson');
  const [reportType, setReportType] = useState<'individual' | 'class'>('individual');
  const [dateRange, setDateRange] = useState('last-30-days');
  const [submitToParent, setSubmitToParent] = useState(false);

  const handleGenerate = () => {
    navigate('/counselor/report-preview');
  };

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
          Generate Report
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Report Type */}
        <div>
          <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
            Report Type
          </label>
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => setReportType('individual')}
              className={`h-[48px] rounded-lg font-medium text-[14px] transition-colors border ${
                reportType === 'individual'
                  ? 'bg-[#7C3AED] text-white border-[#7C3AED]'
                  : 'bg-white text-[#0F172A] border-gray-300 active:bg-gray-50'
              }`}
            >
              Individual
            </button>
            <button
              onClick={() => setReportType('class')}
              className={`h-[48px] rounded-lg font-medium text-[14px] transition-colors border ${
                reportType === 'class'
                  ? 'bg-[#7C3AED] text-white border-[#7C3AED]'
                  : 'bg-white text-[#0F172A] border-gray-300 active:bg-gray-50'
              }`}
            >
              Class Summary
            </button>
          </div>
        </div>

        {/* Student Selector (only for individual reports) */}
        {reportType === 'individual' && (
          <div>
            <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
              Student
            </label>
            <button className="w-full h-[48px] px-4 bg-white border border-gray-300 rounded-lg flex items-center justify-between active:bg-gray-50">
              <span className="text-[15px] text-[#0F172A]">
                {selectedStudent}
              </span>
              <ChevronRight className="w-5 h-5 text-[#64748B]" />
            </button>
          </div>
        )}

        {/* Date Range */}
        <div>
          <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
            Date Range
          </label>
          <select
            value={dateRange}
            onChange={(e) => setDateRange(e.target.value)}
            className="w-full h-[48px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#7C3AED] focus:border-transparent appearance-none"
            style={{
              backgroundImage: `url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1.5L6 6.5L11 1.5' stroke='%2364748B' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E")`,
              backgroundRepeat: 'no-repeat',
              backgroundPosition: 'right 16px center'
            }}
          >
            <option value="last-7-days">Last 7 days</option>
            <option value="last-30-days">Last 30 days</option>
            <option value="last-90-days">Last 90 days</option>
            <option value="school-year">Full school year</option>
            <option value="custom">Custom range...</option>
          </select>
        </div>

        {/* Report Includes */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="text-[14px] font-medium text-[#0F172A] mb-3">
            Report Includes
          </div>
          <ul className="space-y-2 text-[13px] text-[#64748B]">
            <li className="flex items-start gap-2">
              <span className="text-[#10B981] mt-0.5">✓</span>
              <span>Tag frequency analysis</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-[#10B981] mt-0.5">✓</span>
              <span>Environmental correlations (AQI, weather)</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-[#10B981] mt-0.5">✓</span>
              <span>Trend notices and pattern detection</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-[#10B981] mt-0.5">✓</span>
              <span>Confidential counselor notes</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-[#10B981] mt-0.5">✓</span>
              <span>Digital signature with counselor name, ID, and date</span>
            </li>
          </ul>
        </div>

        {/* Submit to Parent Toggle */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                Submit to parent
              </div>
              <div className="text-[12px] text-[#64748B]">
                {submitToParent ? 'Routed through secretary' : 'Save to records only'}
              </div>
            </div>
            <button
              onClick={() => setSubmitToParent(!submitToParent)}
              className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
                submitToParent ? 'bg-[#7C3AED]' : 'bg-gray-300'
              }`}
            >
              <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                submitToParent ? 'ml-auto' : ''
              }`} />
            </button>
          </div>
        </div>

        {/* Preview Note */}
        <div className="bg-[#F1F5F9] rounded-lg p-3">
          <p className="text-[12px] text-[#64748B] leading-relaxed">
            The report will be generated as a signed PDF. You can preview it before sending to ensure all information is accurate.
          </p>
        </div>
      </div>

      {/* Bottom Buttons */}
      <div className="bg-white border-t border-gray-200 p-4 space-y-2">
        <button
          onClick={handleGenerate}
          className="w-full h-[48px] bg-[#7C3AED] text-white rounded-lg font-medium text-[15px] active:bg-[#6D28D9]"
        >
          Preview Report
        </button>
      </div>
    </div>
  );
}
