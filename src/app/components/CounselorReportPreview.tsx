import { ArrowLeft, Download, Share2, Send } from 'lucide-react';
import { useNavigate } from 'react-router';

export function CounselorReportPreview() {
  const navigate = useNavigate();

  const handleSendToSecretary = () => {
    // In real app, would route through secretary workflow
    alert('Report sent to secretary for parent distribution');
    navigate('/counselor/home');
  };

  const handleSendToParent = () => {
    // In real app, would send directly to parent
    alert('Report sent directly to parent');
    navigate('/counselor/home');
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
        <h1 className="text-[17px] font-medium text-[#0F172A] flex-1">
          Report Preview
        </h1>
        <button className="p-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center">
          <Share2 className="w-5 h-5 text-[#0F172A]" />
        </button>
        <button className="p-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center">
          <Download className="w-5 h-5 text-[#0F172A]" />
        </button>
      </header>

      {/* PDF Preview */}
      <div className="flex-1 overflow-y-auto bg-[#E2E8F0] p-4">
        <div className="bg-white rounded-lg shadow-lg p-6 space-y-4">
          {/* Report Header */}
          <div className="border-b border-gray-200 pb-4">
            <div className="flex items-center justify-between mb-2">
              <img
                src="https://via.placeholder.com/120x40/2563EB/FFFFFF?text=SYNAPSE"
                alt="Synapse"
                className="h-8"
              />
              <div className="text-[10px] text-[#64748B] text-right">
                <div>Report Date: 05/31/2026</div>
                <div>Report ID: WB-2026-0531-001</div>
              </div>
            </div>
            <h2 className="text-[16px] font-semibold text-[#0F172A]">
              Student Wellbeing Report
            </h2>
            <p className="text-[11px] text-[#64748B]">
              Lincoln Elementary School • Confidential
            </p>
          </div>

          {/* Student Info */}
          <div>
            <h3 className="text-[12px] font-semibold text-[#0F172A] mb-2">
              Student Information
            </h3>
            <div className="text-[11px] space-y-1">
              <div className="flex">
                <span className="w-24 text-[#64748B]">Name:</span>
                <span className="text-[#0F172A]">Maya Thompson</span>
              </div>
              <div className="flex">
                <span className="w-24 text-[#64748B]">Grade:</span>
                <span className="text-[#0F172A]">4th Grade</span>
              </div>
              <div className="flex">
                <span className="w-24 text-[#64748B]">Report Period:</span>
                <span className="text-[#0F172A]">May 1-31, 2026 (30 days)</span>
              </div>
            </div>
          </div>

          {/* Tag Frequency */}
          <div>
            <h3 className="text-[12px] font-semibold text-[#0F172A] mb-2">
              Tag Frequency Analysis
            </h3>
            <div className="space-y-2">
              <div className="flex items-center gap-2">
                <div className="flex-1 h-6 bg-[#F3F0FF] rounded overflow-hidden">
                  <div className="h-full bg-[#7C3AED]" style={{ width: '60%' }} />
                </div>
                <span className="text-[11px] text-[#0F172A] w-32">Headache (3)</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="flex-1 h-6 bg-[#F3F0FF] rounded overflow-hidden">
                  <div className="h-full bg-[#7C3AED]" style={{ width: '40%' }} />
                </div>
                <span className="text-[11px] text-[#0F172A] w-32">Difficulty focusing (2)</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="flex-1 h-6 bg-[#F3F0FF] rounded overflow-hidden">
                  <div className="h-full bg-[#7C3AED]" style={{ width: '20%' }} />
                </div>
                <span className="text-[11px] text-[#0F172A] w-32">Low mood (1)</span>
              </div>
            </div>
          </div>

          {/* Environmental Correlations */}
          <div>
            <h3 className="text-[12px] font-semibold text-[#0F172A] mb-2">
              Environmental Correlations
            </h3>
            <div className="bg-[#FEF3C7] border border-[#FDE68A] rounded-lg p-3">
              <p className="text-[11px] text-[#92400E] leading-relaxed">
                <strong>Pattern Detected:</strong> 67% of headache tags occurred during AQI advisory days (2 of 3 instances). Consider air quality as contributing factor.
              </p>
            </div>
          </div>

          {/* Trend Notices */}
          <div>
            <h3 className="text-[12px] font-semibold text-[#0F172A] mb-2">
              Trend Notices
            </h3>
            <div className="bg-[#FEF2F2] border border-[#FCA5A5] rounded-lg p-3">
              <p className="text-[11px] text-[#991B1B] leading-relaxed">
                <strong>Recommendation:</strong> Repeated "Headache" pattern warrants environmental assessment and possible pediatric consultation.
              </p>
            </div>
          </div>

          {/* Digital Signature */}
          <div className="border-t border-gray-200 pt-4 mt-6">
            <div className="text-[10px] text-[#64748B]">
              <div className="mb-1">
                <strong>Digitally signed by:</strong> Dr. Sarah Chen
              </div>
              <div className="mb-1">
                <strong>Counselor ID:</strong> SC-2026-0142
              </div>
              <div>
                <strong>Signature Date:</strong> May 31, 2026 at 2:34 PM PST
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Actions */}
      <div className="bg-white border-t border-gray-200 p-4 space-y-2">
        <button
          onClick={handleSendToSecretary}
          className="w-full h-[48px] bg-[#2563EB] text-white rounded-lg font-medium text-[15px] flex items-center justify-center gap-2 active:bg-[#1D4ED8]"
        >
          <Send className="w-5 h-5" />
          Send to Secretary
        </button>
        <button
          onClick={handleSendToParent}
          className="w-full h-[48px] bg-white border border-gray-300 text-[#0F172A] rounded-lg font-medium text-[15px] flex items-center justify-center gap-2 active:bg-gray-50"
        >
          <Send className="w-5 h-5" />
          Send to Parent Directly
        </button>
      </div>
    </div>
  );
}
