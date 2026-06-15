import { AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function DoseConflictAlert() {
  const navigate = useNavigate();
  const [selectedOption, setSelectedOption] = useState<'accept' | 'override'>('accept');
  const [overrideJustification, setOverrideJustification] = useState('');

  const handleConfirm = () => {
    // Simulate update
    setTimeout(() => {
      navigate('/nurse/medications');
    }, 500);
  };

  const canSubmit = selectedOption === 'accept' || (selectedOption === 'override' && overrideJustification.trim().length > 0);

  return (
    <div className="fixed inset-0 bg-[#F8FAFC] z-50 overflow-y-auto">
      {/* Amber Header Section */}
      <div className="bg-[#F59E0B] h-[120px] flex flex-col items-center justify-center">
        <div className="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center mb-3">
          <AlertTriangle className="w-10 h-10 text-white" />
        </div>
        <h1 className="text-[20px] font-semibold text-white" style={{ fontWeight: 600 }}>
          Dose Conflict Detected
        </h1>
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Conflict Information */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] space-y-4">
          <div>
            <h3 className="text-[14px] font-semibold text-[#0F172A] mb-2" style={{ fontWeight: 600 }}>
              Parent Report
            </h3>
            <p className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
              Parent reported home dose given at 7:02 AM (reported at 7:18 AM)
            </p>
          </div>

          <div className="pt-3 border-t border-[#E2E8F0]">
            <h3 className="text-[14px] font-semibold text-[#0F172A] mb-2" style={{ fontWeight: 600 }}>
              Prescribed Interval
            </h3>
            <p className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
              4 hours between doses
            </p>
          </div>

          <div className="pt-3 border-t border-[#E2E8F0]">
            <h3 className="text-[14px] font-semibold text-[#DC2626] mb-2 flex items-center gap-2" style={{ fontWeight: 600 }}>
              <AlertTriangle className="w-4 h-4" />
              Conflict Detected
            </h3>
            <p className="text-[13px] text-[#991B1B] bg-[#FEE2E2] rounded-lg p-3" style={{ fontWeight: 400 }}>
              Scheduled school dose (11:00 AM) falls within 3h 58min of home dose — BELOW minimum interval
            </p>
          </div>
        </div>

        {/* Recommended Adjustment */}
        <div className="bg-[#D1FAE5] border-l-4 border-[#10B981] rounded-xl p-4">
          <div className="flex items-start gap-3">
            <div className="w-8 h-8 rounded-full bg-[#10B981] flex items-center justify-center flex-shrink-0">
              <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <div className="flex-1">
              <h3 className="text-[14px] font-semibold text-[#065F46] mb-1" style={{ fontWeight: 600 }}>
                Recommended Adjustment
              </h3>
              <p className="text-[13px] text-[#065F46]" style={{ fontWeight: 400 }}>
                Suggested school dose time: 11:15 AM
              </p>
              <p className="text-[12px] text-[#047857] mt-1" style={{ fontWeight: 400 }}>
                This maintains the 4-hour minimum interval
              </p>
            </div>
          </div>
        </div>

        {/* Nurse Action Required */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] space-y-4">
          <h3 className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
            Nurse Action Required
          </h3>

          {/* Accept Option */}
          <label className="flex items-start gap-3 cursor-pointer">
            <input
              type="radio"
              name="action"
              checked={selectedOption === 'accept'}
              onChange={() => setSelectedOption('accept')}
              className="mt-1 w-5 h-5 text-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
            />
            <div className="flex-1">
              <p className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
                Accept adjusted time (11:15 AM)
              </p>
              <p className="text-[13px] text-[#64748B] mt-1" style={{ fontWeight: 400 }}>
                Update schedule to recommended time
              </p>
            </div>
          </label>

          {/* Override Option */}
          <label className="flex items-start gap-3 cursor-pointer">
            <input
              type="radio"
              name="action"
              checked={selectedOption === 'override'}
              onChange={() => setSelectedOption('override')}
              className="mt-1 w-5 h-5 text-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
            />
            <div className="flex-1">
              <p className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
                Override with justification
              </p>
              <p className="text-[13px] text-[#64748B] mt-1" style={{ fontWeight: 400 }}>
                Proceed with original time (requires clinical justification)
              </p>
            </div>
          </label>

          {/* Override Justification Field */}
          {selectedOption === 'override' && (
            <div className="ml-8 mt-3">
              <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
                Clinical Justification *
              </label>
              <textarea
                value={overrideJustification}
                onChange={(e) => setOverrideJustification(e.target.value)}
                placeholder="Enter clinical justification for override..."
                rows={4}
                className="w-full px-4 py-3 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB] resize-none"
                style={{ fontWeight: 400 }}
              />
              <p className="text-[12px] text-[#64748B] mt-2" style={{ fontWeight: 400 }}>
                This justification will be permanently recorded in the medication log
              </p>
            </div>
          )}
        </div>

        {/* Accessibility Note */}
        <div className="bg-[#EFF6FF] border-l-4 border-[#2563EB] rounded-xl p-4">
          <p className="text-[12px] text-[#1E40AF]" style={{ fontWeight: 400 }}>
            <span className="font-semibold" style={{ fontWeight: 600 }}>Accessibility note:</span> Red highlight indicates conflict below minimum interval. Green card shows safe recommended time. Action required before proceeding.
          </p>
        </div>

        {/* Confirm Button */}
        <button
          onClick={handleConfirm}
          disabled={!canSubmit}
          className="w-full h-[52px] bg-[#2563EB] text-white rounded-xl font-semibold disabled:opacity-40"
          style={{ fontWeight: 600 }}
        >
          Confirm and Update Schedule
        </button>
      </div>
    </div>
  );
}
