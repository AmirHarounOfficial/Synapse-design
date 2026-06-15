import { ArrowLeft, AlertTriangle, Package, Wrench, CheckCircle, Mail } from 'lucide-react';
import { useNavigate } from 'react-router';

export function VicePrincipalClinicReadiness() {
  const navigate = useNavigate();

  const equipmentIssues = [
    {
      id: '1',
      item: 'AED battery',
      issue: 'Expires July 2026 - replacement needed',
      severity: 'high'
    },
    {
      id: '2',
      item: 'Blood pressure cuff',
      issue: 'Calibration due before start of 2026-27 year',
      severity: 'medium'
    },
    {
      id: '3',
      item: 'Eye wash station',
      issue: 'Requires maintenance inspection',
      severity: 'medium'
    }
  ];

  const supplyIssues = [
    {
      id: '1',
      item: 'Epinephrine auto-injectors',
      issue: '3 units expire August 2026',
      severity: 'high'
    },
    {
      id: '2',
      item: 'Glucose monitoring strips',
      issue: 'Low stock (12 remaining)',
      severity: 'low'
    }
  ];

  const statusCounts = {
    needsAttention: 3,
    lowSupply: 1,
    equipmentMaintenance: 1
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col pb-[83px]" style={{ width: '393px', height: '852px' }}>
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
          Clinic Readiness Report
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Report Source */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
              <span className="text-[14px] font-medium text-[#2563EB]">JC</span>
            </div>
            <div className="flex-1">
              <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                Year-End Report from Jennifer Clarke, RN
              </div>
              <div className="text-[12px] text-[#64748B]">
                School Nurse • Submitted May 29, 2026
              </div>
            </div>
          </div>
        </div>

        {/* Status Summary */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Status Summary
          </h2>
          <div className="flex flex-wrap gap-2">
            <div className="inline-flex items-center px-3 py-1.5 rounded-full bg-[#FEE2E2] border border-[#DC2626]">
              <span className="text-[12px] font-medium text-[#DC2626]">
                {statusCounts.needsAttention} Needs Attention
              </span>
            </div>
            <div className="inline-flex items-center px-3 py-1.5 rounded-full bg-[#FEF3C7] border border-[#F59E0B]">
              <span className="text-[12px] font-medium text-[#92400E]">
                {statusCounts.lowSupply} Low Supply
              </span>
            </div>
            <div className="inline-flex items-center px-3 py-1.5 rounded-full bg-[#DBEAFE] border border-[#2563EB]">
              <span className="text-[12px] font-medium text-[#1E40AF]">
                {statusCounts.equipmentMaintenance} Equipment Maintenance
              </span>
            </div>
          </div>
        </div>

        {/* Equipment Issues */}
        <div>
          <div className="flex items-center gap-2 mb-3">
            <Wrench className="w-5 h-5 text-[#0F172A]" />
            <h2 className="text-[14px] font-semibold text-[#0F172A]">
              Equipment Issues
            </h2>
          </div>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {equipmentIssues.map((item) => (
              <div key={item.id} className="p-4">
                <div className="flex items-start gap-3">
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                    item.severity === 'high' ? 'bg-[#FEE2E2]' : 'bg-[#FEF3C7]'
                  }`}>
                    <AlertTriangle className={`w-4 h-4 ${
                      item.severity === 'high' ? 'text-[#DC2626]' : 'text-[#F59E0B]'
                    }`} />
                  </div>
                  <div className="flex-1">
                    <div className="text-[14px] font-medium text-[#0F172A] mb-1">
                      {item.item}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      {item.issue}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Supply Issues */}
        <div>
          <div className="flex items-center gap-2 mb-3">
            <Package className="w-5 h-5 text-[#0F172A]" />
            <h2 className="text-[14px] font-semibold text-[#0F172A]">
              Supply Issues
            </h2>
          </div>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {supplyIssues.map((item) => (
              <div key={item.id} className="p-4">
                <div className="flex items-start gap-3">
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                    item.severity === 'high' ? 'bg-[#FEE2E2]' : 'bg-[#F1F5F9]'
                  }`}>
                    <Package className={`w-4 h-4 ${
                      item.severity === 'high' ? 'text-[#DC2626]' : 'text-[#64748B]'
                    }`} />
                  </div>
                  <div className="flex-1">
                    <div className="text-[14px] font-medium text-[#0F172A] mb-1">
                      {item.item}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      {item.issue}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Forward to Administration */}
        <button
          onClick={() => navigate('/vice-principal/messages?compose=principal&subject=Clinic Readiness Report')}
          className="w-full bg-[#2563EB] text-white rounded-xl p-4 flex items-center justify-center gap-2 active:bg-[#1D4ED8] min-h-[52px]"
        >
          <Mail className="w-5 h-5" />
          <span className="text-[14px] font-medium">
            Forward to Principal
          </span>
        </button>

        {/* Info */}
        <div className="bg-[#F1F5F9] rounded-lg p-3">
          <p className="text-[12px] text-[#64748B] leading-relaxed">
            This report has been generated by the school nurse. As Vice Principal, you can review and forward it to the Principal for budgetary and administrative action.
          </p>
        </div>
      </div>
    </div>
  );
}
