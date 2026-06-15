import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Camera, File, Image, CheckCircle, Upload, AlertCircle } from 'lucide-react';

interface PendingDocument {
  id: string;
  name: string;
  required: boolean;
}

export function ParentDocumentUploadScreen() {
  const navigate = useNavigate();
  const [showUploadOptions, setShowUploadOptions] = useState<string | null>(null);
  const [uploadingDoc, setUploadingDoc] = useState<string | null>(null);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [uploadedDocs, setUploadedDocs] = useState<string[]>([]);

  const [pendingDocuments, setPendingDocuments] = useState<PendingDocument[]>([
    { id: '1', name: 'Updated Immunization Record', required: true },
    { id: '2', name: 'Emergency Contact Form', required: true },
    { id: '3', name: 'Photo ID (Parent/Guardian)', required: false }
  ]);

  const handleDocumentClick = (docId: string) => {
    if (!uploadedDocs.includes(docId)) {
      setShowUploadOptions(docId);
    }
  };

  const handleUploadMethod = (method: 'camera' | 'files' | 'photos') => {
    const docId = showUploadOptions;
    if (!docId) return;

    setShowUploadOptions(null);
    setUploadingDoc(docId);
    setUploadProgress(0);

    // Simulate upload progress
    const interval = setInterval(() => {
      setUploadProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval);
          setUploadingDoc(null);
          setUploadedDocs((prev) => [...prev, docId]);
          return 100;
        }
        return prev + 10;
      });
    }, 200);
  };

  const allDocsUploaded = pendingDocuments.every((doc) => uploadedDocs.includes(doc.id));

  if (allDocsUploaded) {
    return (
      <div className="min-h-screen bg-[#F8FAFC] flex flex-col">
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
            Upload Document
          </h1>
        </header>

        <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
          {/* Success Icon */}
          <div className="w-24 h-24 rounded-full bg-[#D1FAE5] flex items-center justify-center mb-6">
            <CheckCircle className="w-14 h-14 text-[#10B981]" />
          </div>

          {/* Message */}
          <h1 className="text-[24px] font-semibold text-gray-900 mb-3 text-center">
            All Documents Submitted ✓
          </h1>
          <p className="text-[15px] text-[#64748B] mb-8 text-center max-w-sm">
            Your documents have been submitted to the school nurse for review. You'll receive a notification when they're approved.
          </p>

          {/* Document List */}
          <div className="w-full max-w-sm space-y-2 mb-8">
            {pendingDocuments.map((doc) => (
              <div
                key={doc.id}
                className="bg-white border border-gray-200 rounded-xl p-3 flex items-center gap-3"
              >
                <CheckCircle className="w-5 h-5 text-[#10B981]" />
                <span className="text-[14px] text-gray-900 flex-1">{doc.name}</span>
              </div>
            ))}
          </div>

          <button
            onClick={() => navigate('/parent/app/home')}
            className="w-full max-w-sm min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold"
          >
            Done
          </button>
        </div>
      </div>
    );
  }

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
          Upload Document
        </h1>
      </header>

      <div className="px-4 py-4">
        {/* Info Banner */}
        <div className="bg-[#EFF6FF] border border-[#2563EB] rounded-xl p-4 mb-4">
          <p className="text-[12px] text-[#1E40AF] leading-relaxed">
            The school nurse has requested the following documents. Tap each document type to upload.
          </p>
        </div>

        {/* Pending Documents */}
        <div className="space-y-3">
          {pendingDocuments.map((doc) => {
            const isUploaded = uploadedDocs.includes(doc.id);
            const isUploading = uploadingDoc === doc.id;

            return (
              <button
                key={doc.id}
                onClick={() => handleDocumentClick(doc.id)}
                disabled={isUploaded || isUploading}
                className="w-full bg-white rounded-xl border border-gray-200 p-4 text-left disabled:opacity-60"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="text-[15px] font-medium text-gray-900 mb-1">
                      {doc.name}
                    </div>
                    {doc.required && !isUploaded && (
                      <div className="inline-flex items-center px-2 py-0.5 rounded bg-[#FEE2E2] text-[#DC2626] text-[11px] font-semibold">
                        MISSING
                      </div>
                    )}
                  </div>
                  {isUploaded ? (
                    <CheckCircle className="w-6 h-6 text-[#10B981]" />
                  ) : isUploading ? (
                    <Upload className="w-6 h-6 text-[#2563EB] animate-pulse" />
                  ) : (
                    <AlertCircle className="w-6 h-6 text-[#DC2626]" />
                  )}
                </div>

                {/* Upload Progress */}
                {isUploading && (
                  <div className="space-y-2">
                    <div className="flex justify-between text-[12px] text-[#64748B]">
                      <span>Uploading...</span>
                      <span>{uploadProgress}%</span>
                    </div>
                    <div className="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-[#2563EB] transition-all duration-200"
                        style={{ width: `${uploadProgress}%` }}
                      />
                    </div>
                  </div>
                )}

                {/* Success Message */}
                {isUploaded && (
                  <div className="bg-[#D1FAE5] border border-[#10B981] rounded-lg p-2">
                    <p className="text-[12px] text-[#065F46]">
                      Document submitted for nurse review
                    </p>
                  </div>
                )}
              </button>
            );
          })}
        </div>

        {/* Requirements Info */}
        <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mt-4">
          <h3 className="text-[13px] font-semibold text-gray-900 mb-2">
            Document Requirements
          </h3>
          <ul className="text-[12px] text-[#64748B] space-y-1">
            <li>• File formats: PDF, JPG, PNG</li>
            <li>• Maximum file size: 10MB</li>
            <li>• Images must be clear and legible</li>
            <li>• All information must be visible</li>
          </ul>
        </div>
      </div>

      {/* Upload Options Sheet */}
      {showUploadOptions && (
        <div className="fixed inset-0 z-50 flex items-end bg-black/50">
          <div className="bg-white rounded-t-3xl w-full">
            {/* Handle */}
            <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mt-3 mb-4" />

            <div className="px-6 pb-6">
              <h2 className="text-[17px] font-semibold text-gray-900 mb-4">
                Upload Document
              </h2>

              <div className="space-y-2">
                <button
                  onClick={() => handleUploadMethod('camera')}
                  className="w-full min-h-[56px] px-4 py-3 bg-white border border-gray-200 rounded-lg flex items-center gap-3 active:bg-gray-50"
                >
                  <Camera className="w-6 h-6 text-[#2563EB]" />
                  <div className="flex-1 text-left">
                    <div className="text-[15px] font-medium text-gray-900">
                      Take Photo
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Use camera to capture document
                    </div>
                  </div>
                </button>

                <button
                  onClick={() => handleUploadMethod('files')}
                  className="w-full min-h-[56px] px-4 py-3 bg-white border border-gray-200 rounded-lg flex items-center gap-3 active:bg-gray-50"
                >
                  <File className="w-6 h-6 text-[#2563EB]" />
                  <div className="flex-1 text-left">
                    <div className="text-[15px] font-medium text-gray-900">
                      Choose File
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Select PDF or document file
                    </div>
                  </div>
                </button>

                <button
                  onClick={() => handleUploadMethod('photos')}
                  className="w-full min-h-[56px] px-4 py-3 bg-white border border-gray-200 rounded-lg flex items-center gap-3 active:bg-gray-50"
                >
                  <Image className="w-6 h-6 text-[#2563EB]" />
                  <div className="flex-1 text-left">
                    <div className="text-[15px] font-medium text-gray-900">
                      Photo Library
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Choose from existing photos
                    </div>
                  </div>
                </button>
              </div>

              <button
                onClick={() => setShowUploadOptions(null)}
                className="w-full min-h-[52px] px-4 py-3.5 bg-white text-gray-900 border border-gray-200 rounded-lg text-[15px] font-medium mt-4"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// Export with both names for compatibility
export const ParentDocumentUpload = ParentDocumentUploadScreen;