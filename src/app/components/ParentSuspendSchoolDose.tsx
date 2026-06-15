import { useState } from 'react';
import { useNavigate } from 'react-router';
import { X, AlertTriangle, CheckCircle } from 'lucide-react';

export function ParentSuspendSchoolDose() {
  const navigate = useNavigate();
  const [reason, setReason] = useState('');
  const [note, setNote] = useState('');
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);

  const reasons = [
    'Dose taken after school hours',
    'Medication at doctor appointment',
    'Other (required note)'
  ];

  const handleSuspend = () => {
    if (reason && (reason !== 'Other (required note)' || note)) {
      setShowConfirmDialog(true);
    }
  };

  const handleConfirm = () => {
    setShowConfirmDialog(false);
    setShowSuccess(true);
  };

  const handleDone = () => {
    navigate('/parent/app/medications');
  };

  if (showSuccess) {
    return (
      <div className="fixed inset-0 z-50 flex items-end bg-black/50">
        <div className="bg-white rounded-t-3xl p-6 w-full">
          <div className="w-16 h-16 rounded-full bg-[#D1FAE5] flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-8 h-8 text-[#10B981]" />
          </div>

          <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
            School Dose Suspended
          </h3>
          <p className="text-[14px] text-[#64748B] mb-6 text-center">
            School nurse has been notified. Today's school dose will not be administered.
          </p>

          <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mb-6">
            <div className="flex justify-between mb-2">
              <span className="text-[13px] text-[#64748B]">Reason</span>
              <span className="text-[13px] font-medium text-gray-900">{reason}</span>
            </div>
            {note && (
              <div className="pt-2 border-t border-gray-100 mt-2">
                <span className="text-[13px] text-[#64748B] block mb-1">Note</span>
                <p className="text-[13px] text-gray-900">{note}</p>
              </div>
            )}
            <div className="flex justify-between pt-2 border-t border-gray-100 mt-2">
              <span className="text-[13px] text-[#64748B]">Logged at</span>
              <span className="text-[13px] font-medium text-gray-900">
                {new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}
              </span>
            </div>
          </div>

          <button
            onClick={handleDone}
            className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold"
          >
            Done
          </button>
        </div>
      </div>
    );
  }

  if (showConfirmDialog) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
        <div className="bg-white rounded-2xl p-6 max-w-sm w-full">
          <div className="w-16 h-16 rounded-full bg-[#FEE2E2] flex items-center justify-center mx-auto mb-4">
            <AlertTriangle className="w-8 h-8 text-[#DC2626]" />
          </div>

          <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
            Suspend Today's Dose?
          </h3>
          <p className="text-[14px] text-[#64748B] mb-6 text-center">
            School nurse will be notified and today's school dose will be suspended. This is logged permanently and cannot be undone.
          </p>

          <div className="flex gap-3">
            <button
              onClick={() => setShowConfirmDialog(false)}
              className="flex-1 min-h-[52px] px-4 py-3.5 bg-white text-gray-900 border border-gray-200 rounded-lg text-[15px] font-medium"
            >
              Cancel
            </button>
            <button
              onClick={handleConfirm}
              className="flex-1 min-h-[52px] px-4 py-3.5 bg-white text-[#DC2626] border-2 border-[#DC2626] rounded-lg text-[15px] font-semibold"
            >
              Confirm
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end bg-black/50">
      <div className="bg-white rounded-t-3xl w-full max-h-[90vh] overflow-y-auto">
        {/* Handle */}
        <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mt-3 mb-4" />

        <div className="px-6 pb-6">
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-[17px] font-semibold text-gray-900">
              Suspend today's school dose
            </h2>
            <button
              onClick={() => navigate(-1)}
              className="w-8 h-8 -mr-2 flex items-center justify-center"
            >
              <X className="w-6 h-6 text-gray-900" />
            </button>
          </div>

          {/* Reason Picker */}
          <div className="mb-4">
            <label className="block text-[13px] font-medium text-gray-900 mb-2">
              Reason <span className="text-[#DC2626]">*</span>
            </label>
            <select
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              className="w-full min-h-[48px] px-4 border border-gray-200 rounded-lg text-[15px] focus:outline-none focus:border-[#2563EB]"
            >
              <option value="">Select reason</option>
              {reasons.map((r) => (
                <option key={r} value={r}>
                  {r}
                </option>
              ))}
            </select>
          </div>

          {/* Note Field */}
          <div className="mb-4">
            <label className="block text-[13px] font-medium text-gray-900 mb-2">
              Note {reason === 'Other (required note)' && <span className="text-[#DC2626]">*</span>}
            </label>
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              placeholder={reason === 'Other (required note)' ? 'Please explain why the dose needs to be suspended' : 'Add any additional context...'}
              rows={4}
              className="w-full px-4 py-3 border border-gray-200 rounded-lg text-[15px] focus:outline-none focus:border-[#2563EB] resize-none"
            />
          </div>

          {/* Warning */}
          <div className="bg-[#FEE2E2] border border-[#DC2626] rounded-xl p-4 mb-4">
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-5 h-5 text-[#DC2626] flex-shrink-0 mt-0.5" />
              <div>
                <div className="text-[13px] font-semibold text-[#991B1B] mb-1">
                  Important
                </div>
                <p className="text-[12px] text-[#991B1B] leading-relaxed">
                  This is a permanent suspension for today only. The school nurse will not administer the scheduled dose. Tomorrow's schedule will resume normally.
                </p>
              </div>
            </div>
          </div>

          {/* Info */}
          <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-3 mb-6">
            <p className="text-[12px] text-[#64748B] leading-relaxed">
              Use this feature only when your child has received or will receive their medication outside of school today. All suspensions are logged and cannot be reversed.
            </p>
          </div>

          {/* Submit Button */}
          <button
            onClick={handleSuspend}
            disabled={!reason || (reason === 'Other (required note)' && !note)}
            className="w-full min-h-[52px] px-4 py-3.5 bg-white text-[#DC2626] border-2 border-[#DC2626] rounded-lg text-[15px] font-semibold disabled:opacity-40 disabled:cursor-not-allowed"
          >
            Confirm Suspension
          </button>
        </div>
      </div>
    </div>
  );
}
