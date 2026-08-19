import { ArrowLeft, Lock, Eye, AlertTriangle, FileText } from 'lucide-react';
import { useNavigate } from 'react-router';

export function PrincipalLegalDocuments() {
  const navigate = useNavigate();

  const signedDocuments = [
    {
      id: '1',
      name: 'Platform Data Processing Agreement (DPA) · UAE PDPL Compliant',
      signedDate: '2026-05-01',
      type: 'compliance'
    },
    {
      id: '2',
      name: 'UAE PDPL Controller-Processor Declaration',
      signedDate: '2026-05-01',
      type: 'compliance'
    },
    {
      id: '3',
      name: 'Dubai DHA Medical Liability Disclaimer',
      signedDate: '2026-05-01',
      type: 'legal'
    }
  ];

  const pendingDocuments = [
    {
      id: '1',
      name: 'DPA renewal due June 1, 2026',
      type: 'renewal',
      urgency: 'high'
    }
  ];

  const consentStatus = {
    total: 487,
    active: 458,
    incomplete: 3,
    percentage: 94
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
          Legal & Compliance
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Emirate Context Banner */}
        <div className="bg-[#ECFEFF] border border-[#A5F3FC] rounded-xl p-4 flex items-center justify-between">
          <div>
            <div className="text-[11px] font-semibold text-[#0E7490] uppercase tracking-wider">Active Jurisdiction</div>
            <div className="text-[15px] font-bold text-[#164E63] flex items-center gap-1.5 mt-0.5">
              <span>🇦🇪</span> Emirate of Dubai (دبي)
            </div>
            <div className="text-[12px] text-[#0891B2] mt-1">
              Governed by UAE PDPL & DHA School Health Guidelines
            </div>
          </div>
          <span className="px-2 py-1 rounded bg-[#0E7490] text-white text-[10px] font-bold flex-shrink-0">DHA COMPLIANT</span>
        </div>

        {/* Government Systems Integration */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Government Systems Integration
          </h2>
          <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-100">
            <div>
              <div className="text-[13px] font-semibold text-[#0F172A]">HASANA (حصنة) Integration</div>
              <div className="text-[11px] text-[#64748B] mt-0.5">Dubai DHA Immunization Sync</div>
            </div>
            <span className="px-2.5 py-1 rounded bg-emerald-100 text-[#10B981] text-[11px] font-bold">
              Authorized & Active
            </span>
          </div>
        </div>

        {/* Data Protection Officer (DPO) */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Data Protection Officer (DPO)
          </h2>
          <div className="border-2 border-dashed border-gray-200 rounded-lg p-4 text-center">
            <div className="flex flex-col items-center justify-center">
              <FileText className="w-8 h-8 text-gray-400 mb-2" />
              <div className="text-[13px] font-medium text-[#0F172A]">
                DPO Registration Certificate
              </div>
              <div className="text-[11px] text-[#64748B] mt-1">
                Upload your UAE PDPL DPO appointment certificate (PDF, Max 5MB)
              </div>
              
              <div className="mt-3 w-full flex items-center justify-between bg-gray-50 border border-gray-100 rounded p-2 text-left text-[12px]">
                <span className="text-[#0F172A] font-medium truncate flex-1">dpo_certificate_dubai.pdf</span>
                <span className="text-emerald-600 font-semibold flex-shrink-0 flex items-center gap-1 ml-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Verified
                </span>
              </div>
              
              <button className="mt-3 text-[13px] text-[#2563EB] font-semibold hover:underline">
                Re-upload certificate
              </button>
            </div>
          </div>
        </div>

        {/* Pending Section */}
        {pendingDocuments.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-3">
              <AlertTriangle className="w-5 h-5 text-[#F59E0B]" />
              <h2 className="text-[14px] font-semibold text-[#F59E0B]">
                Pending Actions
              </h2>
            </div>
            <div className="bg-white rounded-xl border border-[#F59E0B] divide-y divide-gray-100">
              {pendingDocuments.map((doc) => (
                <div key={doc.id} className="p-4">
                  <div className="flex items-start gap-3 mb-3">
                    <FileText className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-[#0F172A] mb-1">
                        Renewal Required
                      </div>
                      <div className="text-[13px] text-[#64748B]">
                        {doc.name}
                      </div>
                    </div>
                  </div>
                  <button className="w-full h-[44px] bg-[#F59E0B] text-white rounded-lg font-medium text-[14px] active:bg-[#D97706]">
                    Review & Re-sign
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Signed Documents */}
        <div>
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Signed Documents
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {signedDocuments.map((doc) => (
              <div key={doc.id} className="p-4 flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#D1FAE5] flex items-center justify-center flex-shrink-0">
                  <Lock className="w-5 h-5 text-[#10B981]" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                    {doc.name}
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    Signed {new Date(doc.signedDate).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                  </div>
                </div>
                <button className="flex items-center gap-1 text-[13px] text-[#2563EB] font-medium flex-shrink-0">
                  <Eye className="w-4 h-4" />
                  View
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Parent Consent Status */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Parent Consent Status
          </h2>

          <div className="flex items-center justify-between mb-2">
            <div className="text-[13px] text-[#64748B]">
              {consentStatus.active} of {consentStatus.total} students have active parent consent
            </div>
            <div className="text-[16px] font-semibold text-[#10B981]">
              {consentStatus.percentage}%
            </div>
          </div>

          <div className="w-full h-3 bg-[#F1F5F9] rounded-full overflow-hidden mb-3">
            <div
              className="h-full bg-[#10B981] rounded-full"
              style={{ width: `${consentStatus.percentage}%` }}
            />
          </div>

          <div className="flex items-center justify-between">
            <div className="text-[13px] text-[#64748B]">
              Incomplete consents
            </div>
            <button className="text-[13px] text-[#F59E0B] font-medium">
              {consentStatus.incomplete} incomplete
            </button>
          </div>
        </div>

        {/* Legal Framework */}
        <div className="bg-[#F1F5F9] rounded-lg p-4">
          <h3 className="text-[13px] font-semibold text-[#0F172A] mb-2">
            Legal Framework
          </h3>
          <div className="space-y-2 text-[12px] text-[#64748B]">
            <div className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-[#2563EB] flex-shrink-0 mt-1.5" />
              <span>
                <strong>UAE PDPL</strong> (Federal Decree-Law No. 45 of 2021) governs general data privacy protections
              </span>
            </div>
            <div className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-[#2563EB] flex-shrink-0 mt-1.5" />
              <span>
                <strong>DHA Guidelines</strong> protect student clinical data and DHA school clinic operating procedures
              </span>
            </div>
            <div className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-[#2563EB] flex-shrink-0 mt-1.5" />
              <span>
                <strong>HASANA Sync Protocols</strong> dictate mandatory reporting of childhood immunizations
              </span>
            </div>
          </div>
        </div>

        {/* Document Types Info */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h3 className="text-[13px] font-semibold text-[#0F172A] mb-3">
            Document Types
          </h3>
          <div className="space-y-3">
            <div>
              <div className="text-[13px] font-medium text-[#0F172A] mb-0.5">
                Platform Data Processing Agreement (DPA)
              </div>
              <div className="text-[11px] text-[#64748B] leading-relaxed">
                Defines how student data is processed, stored, and protected by the SchooKeep platform in accordance with the UAE PDPL.
              </div>
            </div>
            <div>
              <div className="text-[13px] font-medium text-[#0F172A] mb-0.5">
                UAE PDPL Controller-Processor Declaration
              </div>
              <div className="text-[11px] text-[#64748B] leading-relaxed">
                Delineates the responsibilities of the school (Controller) and SchooKeep (Processor) under the Federal Decree-Law No. 45 of 2021.
              </div>
            </div>
            <div>
              <div className="text-[13px] font-medium text-[#0F172A] mb-0.5">
                DHA Medical Liability Disclaimer
              </div>
              <div className="text-[11px] text-[#64748B] leading-relaxed">
                Clarifies DHA clinic licensing operational protocols, emergency consent scopes, and platform disclaimer boundaries.
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
