import { useNavigate, useParams } from 'react-router';
import { ChevronLeft, Check, Lock } from 'lucide-react';
import { useState } from 'react';

export function DocumentViewer() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [currentPage, setCurrentPage] = useState(1);
  const [isApproved, setIsApproved] = useState(false);
  const [showApproveDialog, setShowApproveDialog] = useState(false);
  const [showIncompleteDialog, setShowIncompleteDialog] = useState(false);

  // Mock document data - would come from API based on id
  const document = {
    id,
    type: 'Immunization Records',
    studentName: 'Maya Chen',
    studentGrade: '5th Grade',
    uploadedDate: 'May 18, 2026',
    uploadedTime: '8:42 PM',
    fileSize: '1.2 MB',
    fileType: 'PDF',
    totalPages: 3,
    approvedBy: 'Nurse J. Smith',
    approvedCredential: 'RN-4521',
    approvedDate: 'May 19, 2026',
    approvedTime: '09:14 AM'
  };

  const handleApprove = () => {
    setShowApproveDialog(true);
  };

  const confirmApprove = () => {
    setIsApproved(true);
    setShowApproveDialog(false);
  };

  const handleMarkIncomplete = () => {
    setShowIncompleteDialog(true);
  };

  const confirmMarkIncomplete = () => {
    setShowIncompleteDialog(false);
    // Navigate back or show success message
    navigate(-1);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="flex items-center px-4 h-14">
          <button
            onClick={() => navigate(-1)}
            className="flex items-center justify-center w-11 h-11 -ml-2"
            aria-label="Go back"
          >
            <ChevronLeft className="w-6 h-6 text-gray-900" />
          </button>

          <div className="absolute left-1/2 -translate-x-1/2 text-center">
            <h1 className="font-medium text-gray-900 text-[15px]">
              {document.type}
            </h1>
            <p className="text-[12px] text-[#64748B]">
              {document.studentName}
            </p>
          </div>
        </div>
      </header>

      <div className="px-4 py-4 pb-[200px]">
        {/* Document Metadata Card */}
        <div className="bg-white rounded-xl p-4 border border-gray-200 mb-4">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <div className="text-[11px] text-[#64748B] mb-1 uppercase tracking-wide">
                Student
              </div>
              <div className="text-[14px] font-medium text-gray-900">
                {document.studentName}
              </div>
              <div className="text-[12px] text-[#64748B]">
                {document.studentGrade}
              </div>
            </div>

            <div>
              <div className="text-[11px] text-[#64748B] mb-1 uppercase tracking-wide">
                Document Type
              </div>
              <span className="inline-flex items-center px-2 py-1 rounded-full text-[11px] font-medium bg-[#DBEAFE] text-[#1E40AF]">
                {document.type}
              </span>
            </div>

            <div>
              <div className="text-[11px] text-[#64748B] mb-1 uppercase tracking-wide">
                Uploaded
              </div>
              <div className="text-[13px] text-gray-900">
                {document.uploadedDate}
              </div>
              <div className="text-[12px] text-[#64748B]">
                {document.uploadedTime}
              </div>
            </div>

            <div>
              <div className="text-[11px] text-[#64748B] mb-1 uppercase tracking-wide">
                File Size
              </div>
              <div className="text-[13px] text-gray-900">
                {document.fileSize} · {document.fileType}
              </div>
            </div>
          </div>
        </div>

        {/* Approval Banner (only shows after approval) */}
        {isApproved && (
          <div className="bg-[#D1FAE5] border border-[#10B981] rounded-xl p-3 mb-4">
            <div className="flex items-start gap-2">
              <Lock className="w-4 h-4 text-[#065F46] mt-0.5 flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[13px] font-medium text-[#065F46]">
                  Approved on {document.approvedDate} at {document.approvedTime}
                </div>
                <div className="text-[12px] text-[#065F46]">
                  {document.approvedBy} {document.approvedCredential}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Document Preview Area */}
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden mb-4">
          {/* Simulated PDF Preview */}
          <div className="aspect-[8.5/11] bg-white p-6 border-b border-gray-200 flex items-center justify-center">
            <div className="w-full h-full bg-[#FAFAFA] rounded border border-gray-200 flex items-center justify-center">
              <div className="text-center text-[#64748B]">
                <div className="text-[14px] mb-2">Document Preview</div>
                <div className="text-[12px]">{document.type}</div>
              </div>
            </div>
          </div>

          {/* Page Navigation */}
          <div className="py-3 flex items-center justify-center gap-2">
            <button
              onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
              disabled={currentPage === 1}
              className="px-3 py-1.5 rounded text-[13px] text-[#64748B] disabled:opacity-50 min-h-[44px]"
            >
              Previous
            </button>

            <div className="flex items-center gap-1">
              {Array.from({ length: document.totalPages }, (_, i) => i + 1).map((page) => (
                <button
                  key={page}
                  onClick={() => setCurrentPage(page)}
                  className={`w-2 h-2 rounded-full transition-colors ${
                    page === currentPage ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                  }`}
                  aria-label={`Go to page ${page}`}
                />
              ))}
            </div>

            <span className="text-[13px] text-[#64748B] min-w-[80px] text-center">
              Page {currentPage} of {document.totalPages}
            </span>

            <button
              onClick={() => setCurrentPage(Math.min(document.totalPages, currentPage + 1))}
              disabled={currentPage === document.totalPages}
              className="px-3 py-1.5 rounded text-[13px] text-[#64748B] disabled:opacity-50 min-h-[44px]"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      {/* Action Buttons (fixed at bottom) */}
      {!isApproved && (
        <div className="fixed bottom-[83px] left-0 right-0 bg-white border-t border-gray-200 p-4 space-y-3">
          <button
            onClick={handleApprove}
            className="w-full px-4 py-3.5 bg-[#10B981] text-white rounded-lg text-[15px] font-medium flex items-center justify-center gap-2 min-h-[52px]"
          >
            <Check className="w-5 h-5" />
            Approve
          </button>

          <button
            onClick={handleMarkIncomplete}
            className="w-full px-4 py-3.5 bg-white border-2 border-[#F59E0B] text-[#F59E0B] rounded-lg text-[15px] font-medium min-h-[52px]"
          >
            Mark Incomplete — Request resubmission
          </button>
        </div>
      )}

      {/* Approved State */}
      {isApproved && (
        <div className="fixed bottom-[83px] left-0 right-0 bg-white border-t border-gray-200 p-4">
          <div className="flex items-center justify-center gap-2 text-[#10B981] py-2">
            <Check className="w-5 h-5" />
            <Lock className="w-4 h-4" />
            <span className="text-[15px] font-medium">Approved ✓</span>
          </div>
        </div>
      )}

      {/* Approve Confirmation Dialog */}
      {showApproveDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full">
            <h3 className="text-[17px] font-semibold text-gray-900 mb-2">
              Approve Document?
            </h3>
            <p className="text-[14px] text-[#64748B] mb-6">
              This will approve the {document.type} for {document.studentName}. This action cannot be undone.
            </p>

            <div className="flex gap-3">
              <button
                onClick={() => setShowApproveDialog(false)}
                className="flex-1 px-4 py-2.5 bg-white border border-[#E2E8F0] text-[#64748B] rounded-lg text-[15px] font-medium min-h-[44px]"
              >
                Cancel
              </button>
              <button
                onClick={confirmApprove}
                className="flex-1 px-4 py-2.5 bg-[#10B981] text-white rounded-lg text-[15px] font-medium min-h-[44px]"
              >
                Approve
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Mark Incomplete Confirmation Dialog */}
      {showIncompleteDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full">
            <h3 className="text-[17px] font-semibold text-gray-900 mb-2">
              Mark as Incomplete?
            </h3>
            <p className="text-[14px] text-[#64748B] mb-6">
              This will notify the parent that the {document.type} needs to be resubmitted.
            </p>

            <div className="flex gap-3">
              <button
                onClick={() => setShowIncompleteDialog(false)}
                className="flex-1 px-4 py-2.5 bg-white border border-[#E2E8F0] text-[#64748B] rounded-lg text-[15px] font-medium min-h-[44px]"
              >
                Cancel
              </button>
              <button
                onClick={confirmMarkIncomplete}
                className="flex-1 px-4 py-2.5 bg-[#F59E0B] text-white rounded-lg text-[15px] font-medium min-h-[44px]"
              >
                Mark Incomplete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
