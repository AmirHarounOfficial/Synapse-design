import { useNavigate } from 'react-router';
import { ArrowLeft, FileText, AlertTriangle, Calendar } from 'lucide-react';

interface ExpiringDocument {
  id: string;
  name: string;
  expiryDate: string;
  daysUntilExpiry: number;
  requirements: string[];
}

export function ParentDocumentExpiryAlert() {
  const navigate = useNavigate();

  const expiringDocuments: ExpiringDocument[] = [
    {
      id: '1',
      name: 'Health Insurance Card',
      expiryDate: 'June 22, 2026',
      daysUntilExpiry: 28,
      requirements: [
        'Front and back photos of new card',
        'Must be clear and legible',
        'All information visible'
      ]
    },
    {
      id: '2',
      name: 'Physician Care Plan',
      expiryDate: 'June 10, 2026',
      daysUntilExpiry: 16,
      requirements: [
        'Updated care plan signed by physician',
        'PDF format required',
        'Must include current year'
      ]
    },
    {
      id: '3',
      name: 'Emergency Contact Form',
      expiryDate: 'June 2, 2026',
      daysUntilExpiry: 8,
      requirements: [
        'Updated emergency contact information',
        'Parent/guardian signature required',
        'All phone numbers verified'
      ]
    },
    {
      id: '4',
      name: 'Allergy Action Plan',
      expiryDate: 'May 29, 2026',
      daysUntilExpiry: 4,
      requirements: [
        'Updated plan from allergist',
        'Current medication orders',
        'Parent and physician signatures required'
      ]
    }
  ];

  const getUrgencyConfig = (days: number) => {
    if (days < 7) {
      return {
        bg: 'bg-[#FEE2E2]',
        border: 'border-[#DC2626]',
        text: 'text-[#DC2626]',
        badgeBg: 'bg-[#DC2626]',
        badgeText: 'text-white'
      };
    } else if (days < 30) {
      return {
        bg: 'bg-[#FEF3C7]',
        border: 'border-[#F59E0B]',
        text: 'text-[#F59E0B]',
        badgeBg: 'bg-[#F59E0B]',
        badgeText: 'text-white'
      };
    }
    return {
      bg: 'bg-[#F0F9FF]',
      border: 'border-[#0369A1]',
      text: 'text-[#0369A1]',
      badgeBg: 'bg-[#0369A1]',
      badgeText: 'text-white'
    };
  };

  const handleUploadDocument = (docId: string) => {
    // In real app, navigate to document upload with pre-selected document type
    navigate('/parent/app/upload-document');
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
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
          Document Renewals
        </h1>
      </header>

      <div className="px-4 py-4">
        {/* Alert Banner */}
        <div className="bg-[#FEE2E2] border border-[#DC2626] rounded-xl p-4 mb-4">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-[#DC2626] flex-shrink-0 mt-0.5" />
            <div>
              <div className="text-[14px] font-semibold text-[#991B1B] mb-1">
                Action Required
              </div>
              <p className="text-[12px] text-[#991B1B] leading-relaxed">
                {expiringDocuments.length} document{expiringDocuments.length !== 1 ? 's' : ''} expiring soon. Please upload renewed documents to avoid delays in care.
              </p>
            </div>
          </div>
        </div>

        {/* Expiring Documents List */}
        <div className="space-y-3">
          {expiringDocuments.map((doc) => {
            const config = getUrgencyConfig(doc.daysUntilExpiry);

            return (
              <div
                key={doc.id}
                className={`${config.bg} border ${config.border} rounded-xl p-4`}
              >
                {/* Header */}
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-start gap-3 flex-1">
                    <FileText className={`w-5 h-5 ${config.text} flex-shrink-0 mt-0.5`} />
                    <div className="flex-1">
                      <h3 className="text-[15px] font-semibold text-gray-900 mb-1">
                        {doc.name}
                      </h3>
                      <div className="flex items-center gap-2 text-[12px] text-[#64748B]">
                        <Calendar className="w-3.5 h-3.5" />
                        <span>Expires {doc.expiryDate}</span>
                      </div>
                    </div>
                  </div>
                  <div className={`px-2 py-1 rounded ${config.badgeBg} ${config.badgeText} text-[11px] font-semibold whitespace-nowrap`}>
                    {doc.daysUntilExpiry} {doc.daysUntilExpiry === 1 ? 'day' : 'days'}
                  </div>
                </div>

                {/* Requirements */}
                <div className="bg-white/60 rounded-lg p-3 mb-3">
                  <h4 className="text-[12px] font-semibold text-gray-900 mb-2">
                    Upload Requirements:
                  </h4>
                  <ul className="space-y-1">
                    {doc.requirements.map((req, index) => (
                      <li key={index} className="text-[11px] text-[#64748B] flex gap-1.5">
                        <span className="text-[#64748B]">•</span>
                        <span>{req}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                {/* Upload Button */}
                <button
                  onClick={() => handleUploadDocument(doc.id)}
                  className={`w-full min-h-[48px] px-4 py-3 bg-gray-900 text-white rounded-lg text-[14px] font-semibold`}
                >
                  Upload Now
                </button>
              </div>
            );
          })}
        </div>

        {/* Info Card */}
        <div className="bg-[#EFF6FF] border border-[#2563EB] rounded-xl p-4 mt-4">
          <h3 className="text-[13px] font-semibold text-[#1E40AF] mb-2">
            Why Document Renewal is Important
          </h3>
          <p className="text-[12px] text-[#1E40AF] leading-relaxed">
            Expired documents may prevent the school nurse from administering medication or providing necessary care. Please upload renewed documents as soon as possible.
          </p>
        </div>

        {/* Format Requirements */}
        <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mt-4">
          <h3 className="text-[13px] font-semibold text-gray-900 mb-2">
            Acceptable File Formats
          </h3>
          <ul className="text-[12px] text-[#64748B] space-y-1">
            <li>• PDF documents (preferred)</li>
            <li>• Clear photos (JPG, PNG)</li>
            <li>• Maximum file size: 10MB</li>
            <li>• All text must be legible</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
