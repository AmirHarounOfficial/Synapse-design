import { useNavigate } from 'react-router';
import { ChevronLeft, FileText, Shield, Syringe, ChevronDown, ChevronUp, Check } from 'lucide-react';
import { useState } from 'react';

interface Document {
  id: string;
  type: 'immunization' | 'consent' | 'physician-order' | 'insurance' | 'care-plan';
  name: string;
  studentName: string;
  submittedBy: string;
  submittedDate: string;
  status: 'pending' | 'approved' | 'incomplete';
  approvedBy?: string;
  approvedDate?: string;
  notifiedDate?: string;
  thumbnailUrl?: string;
}

export function DocumentReviewQueue() {
  const navigate = useNavigate();
  const [approvedExpanded, setApprovedExpanded] = useState(false);

  const documents: Document[] = [
    {
      id: '1',
      type: 'immunization',
      name: 'Immunization Records',
      studentName: 'Maya Chen',
      submittedBy: 'Parent uploaded',
      submittedDate: 'May 18, 2026 · 8:42 PM',
      status: 'pending'
    },
    {
      id: '2',
      type: 'physician-order',
      name: 'Physician Order',
      studentName: 'Alex Martinez',
      submittedBy: 'Parent uploaded',
      submittedDate: 'May 19, 2026 · 9:15 AM',
      status: 'pending'
    },
    {
      id: '3',
      type: 'consent',
      name: 'Medication Consent Form',
      studentName: 'Sarah Williams',
      submittedBy: 'Parent uploaded',
      submittedDate: 'May 19, 2026 · 2:30 PM',
      status: 'pending'
    },
    {
      id: '4',
      type: 'insurance',
      name: 'Insurance Card',
      studentName: 'James Taylor',
      submittedBy: 'Parent uploaded',
      submittedDate: 'May 17, 2026 · 11:20 AM',
      status: 'approved',
      approvedBy: 'Nurse Smith',
      approvedDate: 'May 17'
    },
    {
      id: '5',
      type: 'immunization',
      name: 'Immunization Records',
      studentName: 'Emma Johnson',
      submittedBy: 'Parent uploaded',
      submittedDate: 'May 16, 2026 · 3:45 PM',
      status: 'approved',
      approvedBy: 'Nurse Smith',
      approvedDate: 'May 16'
    },
    {
      id: '6',
      type: 'physician-order',
      name: 'Physician Order',
      studentName: 'Olivia Brown',
      submittedBy: 'Parent uploaded',
      submittedDate: 'May 15, 2026 · 10:22 AM',
      status: 'incomplete',
      notifiedDate: 'May 16'
    }
  ];

  const pendingDocs = documents.filter(d => d.status === 'pending');
  const approvedDocs = documents.filter(d => d.status === 'approved');
  const incompleteDocs = documents.filter(d => d.status === 'incomplete');

  const getDocumentIcon = (type: string) => {
    switch (type) {
      case 'immunization':
        return <Syringe className="w-5 h-5 text-[#2563EB]" />;
      case 'consent':
        return <Shield className="w-5 h-5 text-[#2563EB]" />;
      case 'physician-order':
        return <FileText className="w-5 h-5 text-[#2563EB]" />;
      case 'insurance':
        return <FileText className="w-5 h-5 text-[#2563EB]" />;
      case 'care-plan':
        return <FileText className="w-5 h-5 text-[#2563EB]" />;
      default:
        return <FileText className="w-5 h-5 text-[#2563EB]" />;
    }
  };

  const handleReview = (docId: string) => {
    navigate(`/nurse/documents/review/${docId}`);
  };

  const handleRequestInfo = (docId: string) => {
    console.log('Request more info:', docId);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2"
          aria-label="Go back"
        >
          <ChevronLeft className="w-6 h-6 text-gray-900" />
        </button>

        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900 flex items-center gap-2">
          Document Review
          {pendingDocs.length > 0 && (
            <span className="flex items-center justify-center w-5 h-5 bg-[#DC2626] text-white text-[11px] font-semibold rounded-full">
              {pendingDocs.length}
            </span>
          )}
        </h1>
      </header>

      <div className="px-4 py-4 space-y-6">
        {/* Pending Review Section */}
        <div>
          <div className="flex items-center gap-2 mb-3">
            <div className="h-px flex-1 bg-[#F59E0B]" />
            <h2 className="text-[13px] font-medium text-[#F59E0B] uppercase tracking-wide">
              Pending Review
            </h2>
            <div className="h-px flex-1 bg-[#F59E0B]" />
          </div>

          {pendingDocs.length > 0 ? (
            <div className="space-y-3">
              {pendingDocs.map((doc) => (
                <div
                  key={doc.id}
                  className="bg-white rounded-xl p-4 border border-gray-200 border-l-[3px] border-l-[#F59E0B]"
                >
                  <div className="flex items-start gap-3 mb-3">
                    {/* Icon */}
                    <div className="w-10 h-10 rounded-lg bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                      {getDocumentIcon(doc.type)}
                    </div>

                    {/* Document Info */}
                    <div className="flex-1 min-w-0">
                      <div className="text-[14px] font-medium text-gray-900 mb-1">
                        {doc.name} — {doc.studentName}
                      </div>
                      <div className="text-[12px] text-[#64748B]">
                        {doc.submittedBy} · {doc.submittedDate}
                      </div>
                    </div>

                    {/* Preview Thumbnail */}
                    <div className="w-20 h-[60px] rounded bg-[#F8FAFC] border border-gray-200 flex items-center justify-center flex-shrink-0">
                      <FileText className="w-6 h-6 text-[#64748B]" />
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex gap-2">
                    <button
                      onClick={() => handleReview(doc.id)}
                      className="flex-1 px-4 py-2.5 bg-[#2563EB] text-white rounded-lg text-[13px] font-medium min-h-[44px]"
                    >
                      Review
                    </button>
                    <button
                      onClick={() => handleRequestInfo(doc.id)}
                      className="flex-1 px-4 py-2.5 bg-white border border-[#E2E8F0] text-[#64748B] rounded-lg text-[13px] font-medium min-h-[44px]"
                    >
                      Request more info
                    </button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="bg-white rounded-xl p-8 border border-gray-200 text-center">
              <div className="flex items-center justify-center gap-2 text-[#10B981]">
                <Check className="w-5 h-5" />
                <span className="text-[15px] font-medium">
                  All documents reviewed ✓
                </span>
              </div>
            </div>
          )}
        </div>

        {/* Incomplete Section */}
        {incompleteDocs.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-3">
              <div className="h-px flex-1 bg-[#DC2626]" />
              <h2 className="text-[13px] font-medium text-[#DC2626] uppercase tracking-wide">
                Incomplete
              </h2>
              <div className="h-px flex-1 bg-[#DC2626]" />
            </div>

            <div className="space-y-3">
              {incompleteDocs.map((doc) => (
                <div
                  key={doc.id}
                  className="bg-white rounded-xl p-4 border border-gray-200 border-l-[3px] border-l-[#DC2626]"
                >
                  <div className="flex items-start gap-3">
                    {/* Icon */}
                    <div className="w-10 h-10 rounded-lg bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                      {getDocumentIcon(doc.type)}
                    </div>

                    {/* Document Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium bg-[#FEE2E2] text-[#DC2626]">
                          Incomplete
                        </span>
                      </div>
                      <div className="text-[14px] font-medium text-gray-900 mb-1">
                        {doc.name} — {doc.studentName}
                      </div>
                      <div className="text-[12px] text-[#64748B] mb-1">
                        {doc.submittedBy} · {doc.submittedDate}
                      </div>
                      <div className="text-[12px] text-[#DC2626]">
                        Parent notified: {doc.notifiedDate}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Approved Section */}
        {approvedDocs.length > 0 && (
          <div>
            <button
              onClick={() => setApprovedExpanded(!approvedExpanded)}
              className="w-full mb-3"
            >
              <div className="flex items-center gap-2">
                <div className="h-px flex-1 bg-[#10B981]" />
                <div className="flex items-center gap-2">
                  <h2 className="text-[13px] font-medium text-[#10B981] uppercase tracking-wide">
                    Approved
                  </h2>
                  <span className="text-[12px] text-[#64748B]">
                    {approvedDocs.length} approved this month
                  </span>
                  {approvedExpanded ? (
                    <ChevronUp className="w-4 h-4 text-[#10B981]" />
                  ) : (
                    <ChevronDown className="w-4 h-4 text-[#10B981]" />
                  )}
                </div>
                <div className="h-px flex-1 bg-[#10B981]" />
              </div>
            </button>

            {approvedExpanded && (
              <div className="space-y-3">
                {approvedDocs.map((doc) => (
                  <div
                    key={doc.id}
                    className="bg-white rounded-xl p-4 border border-gray-200 border-l-[3px] border-l-[#10B981]"
                  >
                    <div className="flex items-start gap-3">
                      {/* Icon */}
                      <div className="w-10 h-10 rounded-lg bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                        {getDocumentIcon(doc.type)}
                      </div>

                      {/* Document Info */}
                      <div className="flex-1 min-w-0">
                        <div className="text-[14px] font-medium text-gray-900 mb-1">
                          {doc.name} — {doc.studentName}
                        </div>
                        <div className="text-[12px] text-[#64748B] mb-2">
                          {doc.submittedBy} · {doc.submittedDate}
                        </div>
                        <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium bg-[#D1FAE5] text-[#065F46]">
                          Approved by {doc.approvedBy} · {doc.approvedDate}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
