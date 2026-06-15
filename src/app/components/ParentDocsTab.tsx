import { useNavigate } from 'react-router';
import { ArrowLeft, FileText, CheckCircle, Clock, AlertTriangle } from 'lucide-react';

export function ParentDocsTab() {
  const navigate = useNavigate();

  const documents = [
    { id: '1', name: 'Birth Certificate', status: 'approved', uploadedDate: 'May 1, 2026' },
    { id: '2', name: 'Health Insurance Card', status: 'expiring', expiryDate: 'Jun 22, 2026' },
    { id: '3', name: 'Immunization Records', status: 'approved', uploadedDate: 'May 1, 2026' },
    { id: '4', name: 'Physician Care Plan', status: 'pending', uploadedDate: 'May 20, 2026' }
  ];

  const getStatusConfig = (status: string) => {
    switch (status) {
      case 'approved':
        return { icon: CheckCircle, text: 'Approved', color: 'text-[#10B981]', bg: 'bg-[#D1FAE5]' };
      case 'pending':
        return { icon: Clock, text: 'Pending Review', color: 'text-[#F59E0B]', bg: 'bg-[#FEF3C7]' };
      case 'expiring':
        return { icon: AlertTriangle, text: 'Expiring Soon', color: 'text-[#DC2626]', bg: 'bg-[#FEE2E2]' };
      default:
        return { icon: FileText, text: 'Unknown', color: 'text-[#64748B]', bg: 'bg-gray-100' };
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-gray-900">
          Documents
        </h1>
      </header>

      <div className="px-4 py-4">
        {/* Document List */}
        <div className="space-y-3">
          {documents.map((doc) => {
            const statusConfig = getStatusConfig(doc.status);
            const StatusIcon = statusConfig.icon;

            return (
              <div
                key={doc.id}
                className="bg-white rounded-xl border border-gray-200 p-4"
              >
                <div className="flex items-start gap-3">
                  <div className={`w-12 h-12 rounded-xl ${statusConfig.bg} flex items-center justify-center flex-shrink-0`}>
                    <FileText className={`w-6 h-6 ${statusConfig.color}`} />
                  </div>
                  <div className="flex-1">
                    <div className="text-[15px] font-medium text-gray-900 mb-1">
                      {doc.name}
                    </div>
                    <div className="flex items-center gap-1.5 mb-2">
                      <StatusIcon className={`w-3.5 h-3.5 ${statusConfig.color}`} />
                      <span className={`text-[12px] ${statusConfig.color}`}>
                        {statusConfig.text}
                      </span>
                    </div>
                    {'uploadedDate' in doc && (
                      <div className="text-[12px] text-[#64748B]">
                        Uploaded {doc.uploadedDate}
                      </div>
                    )}
                    {'expiryDate' in doc && (
                      <div className="text-[12px] text-[#DC2626]">
                        Expires {doc.expiryDate}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
