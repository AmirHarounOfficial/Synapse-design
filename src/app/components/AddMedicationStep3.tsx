import { ChevronLeft, Info, CheckCircle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function AddMedicationStep3() {
  const navigate = useNavigate();
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  const [checklist, setChecklist] = useState({
    physicianOrder: true,
    parentAuth: true,
    photoCapture: true,
    doseSchedule: true,
    stateCompliance: true
  });

  const allChecked = Object.values(checklist).every(v => v);

  const handleSubmit = () => {
    setShowConfirmDialog(true);
  };

  const handleConfirm = () => {
    // Simulate submission
    setTimeout(() => {
      navigate('/nurse/medications');
    }, 500);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <button
          onClick={() => navigate('/nurse/medications/add/step2')}
          className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
        >
          <ChevronLeft className="w-6 h-6 text-[#0F172A]" />
        </button>
        <h1 className="flex-1 text-[17px] font-medium text-[#0F172A] text-center" style={{ fontWeight: 500 }}>
          Add Medication
        </h1>
        <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 500 }}>
          Step 3 of 3
        </span>
      </div>

      {/* Progress Bar */}
      <div className="flex gap-1 px-4 py-3 bg-[#FFFFFF] border-b border-[#E2E8F0]">
        <div className="flex-1 h-1 bg-[#10B981] rounded-full" />
        <div className="flex-1 h-1 bg-[#10B981] rounded-full" />
        <div className="flex-1 h-1 bg-[#2563EB] rounded-full" />
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Summary Card */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] space-y-3">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3" style={{ fontWeight: 600 }}>
            Medication Summary
          </h3>

          <div className="space-y-2">
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Student</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>Maya Chen - Grade 5</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Medication</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>Methylphenidate 10mg</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Type</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>Permanent</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Daily Doses</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>1 dose</span>
            </div>
            <div className="flex justify-between py-2">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Dose Time</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>08:00 AM</span>
            </div>
          </div>
        </div>

        {/* Confirmation Checklist */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-4" style={{ fontWeight: 600 }}>
            Confirmation Checklist
          </h3>

          <div className="space-y-3">
            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={checklist.physicianOrder}
                onChange={(e) => setChecklist({ ...checklist, physicianOrder: e.target.checked })}
                className="w-5 h-5 rounded border-2 border-[#E2E8F0] text-[#10B981] focus:ring-2 focus:ring-[#10B981]"
              />
              <span className="text-[14px] text-[#0F172A]" style={{ fontWeight: 400 }}>
                Physician order on file
              </span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={checklist.parentAuth}
                onChange={(e) => setChecklist({ ...checklist, parentAuth: e.target.checked })}
                className="w-5 h-5 rounded border-2 border-[#E2E8F0] text-[#10B981] focus:ring-2 focus:ring-[#10B981]"
              />
              <span className="text-[14px] text-[#0F172A]" style={{ fontWeight: 400 }}>
                Parent authorization signed
              </span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={checklist.photoCapture}
                onChange={(e) => setChecklist({ ...checklist, photoCapture: e.target.checked })}
                className="w-5 h-5 rounded border-2 border-[#E2E8F0] text-[#10B981] focus:ring-2 focus:ring-[#10B981]"
              />
              <span className="text-[14px] text-[#0F172A]" style={{ fontWeight: 400 }}>
                Medication photo captured
              </span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={checklist.doseSchedule}
                onChange={(e) => setChecklist({ ...checklist, doseSchedule: e.target.checked })}
                className="w-5 h-5 rounded border-2 border-[#E2E8F0] text-[#10B981] focus:ring-2 focus:ring-[#10B981]"
              />
              <span className="text-[14px] text-[#0F172A]" style={{ fontWeight: 400 }}>
                Dose schedule set
              </span>
            </label>

            <label className="flex items-center gap-3 opacity-60 cursor-not-allowed">
              <input
                type="checkbox"
                checked={checklist.stateCompliance}
                disabled
                className="w-5 h-5 rounded border-2 border-[#E2E8F0] text-[#10B981]"
              />
              <span className="text-[14px] text-[#0F172A]" style={{ fontWeight: 400 }}>
                State compliance verified
              </span>
            </label>
          </div>
        </div>

        {/* State Compliance Note */}
        <div className="bg-[#EFF6FF] border-l-4 border-[#2563EB] rounded-xl p-4">
          <div className="flex gap-3">
            <Info className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <p className="text-[13px] text-[#1E40AF]" style={{ fontWeight: 400 }}>
              Your state requires a licensed RN for medication administration. This task cannot be delegated.
            </p>
          </div>
        </div>

        {/* Submit Button */}
        <button
          onClick={handleSubmit}
          disabled={!allChecked}
          className="w-full h-[52px] bg-[#10B981] text-white rounded-xl font-semibold disabled:opacity-40"
          style={{ fontWeight: 600 }}
        >
          Add Medication
        </button>
      </div>

      {/* Confirmation Dialog */}
      {showConfirmDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-[#FFFFFF] rounded-2xl p-6 max-w-[340px] w-full animate-scale-in">
            <div className="w-12 h-12 rounded-full bg-[#FEF3C7] flex items-center justify-center mx-auto mb-4">
              <Info className="w-6 h-6 text-[#F59E0B]" />
            </div>

            <h2 className="text-[18px] font-semibold text-[#0F172A] text-center mb-2" style={{ fontWeight: 600 }}>
              Confirm Medication Record
            </h2>

            <p className="text-[14px] text-[#64748B] text-center mb-6" style={{ fontWeight: 400 }}>
              This medication record is permanent and cannot be deleted. Proceed?
            </p>

            <div className="space-y-2">
              <button
                onClick={handleConfirm}
                className="w-full h-[48px] bg-[#10B981] text-white rounded-xl font-semibold"
                style={{ fontWeight: 600 }}
              >
                Confirm
              </button>
              <button
                onClick={() => setShowConfirmDialog(false)}
                className="w-full h-[48px] bg-[#FFFFFF] text-[#64748B] border border-[#E2E8F0] rounded-xl font-semibold"
                style={{ fontWeight: 600 }}
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
