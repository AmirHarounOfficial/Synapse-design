import { ChevronLeft, Camera, AlertTriangle, Upload } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function AddMedicationStep1() {
  const navigate = useNavigate();
  const [photoCapture, setPhotoCapture] = useState<'idle' | 'capturing' | 'captured'>('idle');

  const handleCapture = () => {
    setPhotoCapture('capturing');
    // Simulate photo capture
    setTimeout(() => {
      setPhotoCapture('captured');
      // Auto-navigate to step 2
      setTimeout(() => {
        navigate('/nurse/medications/add/step2');
      }, 500);
    }, 1000);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <button
          onClick={() => navigate('/nurse/medications')}
          className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
        >
          <ChevronLeft className="w-6 h-6 text-[#0F172A]" />
        </button>
        <h1 className="flex-1 text-[17px] font-medium text-[#0F172A] text-center" style={{ fontWeight: 500 }}>
          Add Medication
        </h1>
        <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 500 }}>
          Step 1 of 3
        </span>
      </div>

      {/* Progress Bar */}
      <div className="flex gap-1 px-4 py-3 bg-[#FFFFFF] border-b border-[#E2E8F0]">
        <div className="flex-1 h-1 bg-[#2563EB] rounded-full" />
        <div className="flex-1 h-1 bg-[#E2E8F0] rounded-full" />
        <div className="flex-1 h-1 bg-[#E2E8F0] rounded-full" />
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Camera Viewfinder */}
        <div className="flex flex-col items-center">
          <div className="relative w-full max-w-[320px] h-[240px] bg-[#1F2937] rounded-xl flex items-center justify-center overflow-hidden">
            {/* Camera frame corners */}
            <div className="absolute top-4 left-4 w-8 h-8 border-t-2 border-l-2 border-[#2563EB]" />
            <div className="absolute top-4 right-4 w-8 h-8 border-t-2 border-r-2 border-[#2563EB]" />
            <div className="absolute bottom-4 left-4 w-8 h-8 border-b-2 border-l-2 border-[#2563EB]" />
            <div className="absolute bottom-4 right-4 w-8 h-8 border-b-2 border-r-2 border-[#2563EB]" />

            {photoCapture === 'idle' && (
              <Camera className="w-16 h-16 text-[#64748B]" />
            )}

            {photoCapture === 'capturing' && (
              <div className="text-white text-center">
                <div className="w-12 h-12 border-4 border-white/30 border-t-white rounded-full animate-spin mx-auto mb-3" />
                <p className="text-sm" style={{ fontWeight: 500 }}>Capturing...</p>
              </div>
            )}

            {photoCapture === 'captured' && (
              <div className="text-white text-center">
                <div className="w-12 h-12 bg-[#10B981] rounded-full flex items-center justify-center mx-auto mb-3">
                  <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                  </svg>
                </div>
                <p className="text-sm" style={{ fontWeight: 500 }}>Photo captured!</p>
              </div>
            )}
          </div>

          <p className="text-[13px] text-[#64748B] mt-3 text-center" style={{ fontWeight: 400 }}>
            Point camera at medication label
          </p>
        </div>

        {/* Instructions Card */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3" style={{ fontWeight: 600 }}>
            Instructions
          </h3>
          <ol className="space-y-2 list-decimal list-inside text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
            <li>Place bottle face-up</li>
            <li>Ensure label is fully visible</li>
            <li>Hold steady in good lighting</li>
          </ol>
        </div>

        {/* Requirement Notice */}
        <div className="bg-[#FFFBEB] border-l-4 border-[#F59E0B] rounded-xl p-4">
          <div className="flex gap-3">
            <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-[13px] text-[#92400E]" style={{ fontWeight: 400 }}>
                <span className="font-semibold" style={{ fontWeight: 600 }}>FDA requires:</span> medication must be in original labeled container with student name, medication name, and dosage visible.
              </p>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3 pt-4">
          <button
            onClick={handleCapture}
            disabled={photoCapture !== 'idle'}
            className="w-full h-[52px] bg-[#2563EB] text-white rounded-xl font-semibold disabled:opacity-40"
            style={{ fontWeight: 600 }}
          >
            {photoCapture === 'capturing' ? 'Capturing...' : 'Capture Photo'}
          </button>

          <button className="w-full h-[52px] bg-[#FFFFFF] text-[#2563EB] border-2 border-[#2563EB] rounded-xl font-semibold flex items-center justify-center gap-2" style={{ fontWeight: 600 }}>
            <Upload className="w-5 h-5" />
            Upload from Photos
          </button>
        </div>
      </div>
    </div>
  );
}
