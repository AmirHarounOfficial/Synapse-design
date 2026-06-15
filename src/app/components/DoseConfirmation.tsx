import { CheckCircle, Lock, Clock, AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState, useEffect } from 'react';

export function DoseConfirmation() {
  const navigate = useNavigate();
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [currentTime, setCurrentTime] = useState('10:48 AM');
  const [minutesUntil, setMinutesUntil] = useState(12);
  const [confirmationTime, setConfirmationTime] = useState('');

  useEffect(() => {
    // Update current time every second
    const timer = setInterval(() => {
      const now = new Date();
      const formatted = now.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      });
      setCurrentTime(formatted);
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const handleAdminister = () => {
    setShowConfirmDialog(true);
  };

  const handleConfirm = () => {
    const now = new Date();
    const timestamp = now.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    });
    setConfirmationTime(timestamp);
    setShowConfirmDialog(false);
    setShowSuccess(true);

    // Auto-navigate after showing success
    setTimeout(() => {
      navigate('/nurse/medications');
    }, 2500);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center border-b border-[#E2E8F0]">
        <h1 className="text-[17px] font-medium text-[#DC2626]" style={{ fontWeight: 500 }}>
          Medication Due
        </h1>
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-4">
        {/* Student Card */}
        <button
          onClick={() => navigate('/nurse/students/maya-chen')}
          className="w-full bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] flex items-center gap-3"
        >
          <div className="w-12 h-12 rounded-full bg-[#2563EB] flex items-center justify-center text-white text-lg font-semibold flex-shrink-0">
            MC
          </div>
          <div className="flex-1 text-left">
            <p className="text-[16px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
              Maya Chen
            </p>
            <p className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
              Grade 5 · Room 204
            </p>
          </div>
        </button>

        {/* Medication Card */}
        <div className="bg-[#FFFFFF] rounded-xl p-6 border-2 border-[#2563EB] space-y-4">
          <div>
            <h2 className="text-[22px] font-medium text-[#0F172A] mb-2" style={{ fontWeight: 500 }}>
              Methylphenidate 10mg
            </h2>

            {/* Scheduled Time */}
            <div className="mb-3">
              <p className="text-[13px] text-[#64748B] mb-1" style={{ fontWeight: 400 }}>
                Scheduled Time
              </p>
              <p className="text-[32px] font-medium text-[#2563EB]" style={{ fontWeight: 500 }}>
                11:00 AM
              </p>
            </div>

            {/* Current Time */}
            <div className="flex items-center gap-2 mb-3">
              <Clock className="w-4 h-4 text-[#64748B]" />
              <p className="text-[14px] text-[#64748B]" style={{ fontWeight: 400 }}>
                Current time: {currentTime}
              </p>
            </div>

            {/* Countdown Chip */}
            <div className="inline-flex items-center gap-1.5 bg-[#FEF3C7] text-[#92400E] px-3 py-2 rounded-full mb-4">
              <AlertTriangle className="w-4 h-4" />
              <span className="text-[13px] font-semibold" style={{ fontWeight: 600 }}>
                {minutesUntil} minutes until scheduled dose
              </span>
            </div>

            {/* Dose Info */}
            <div className="space-y-2 pt-4 border-t border-[#E2E8F0]">
              <p className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
                Dose 2 of 3 today
              </p>
              <p className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
                14 doses remaining
              </p>
            </div>
          </div>

          {/* Physician Order Reminder */}
          <div className="flex items-center gap-2 bg-[#F8FAFC] rounded-lg p-3">
            <Lock className="w-4 h-4 text-[#64748B] flex-shrink-0" />
            <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
              Physician order by Dr. Rodriguez on file ✓
            </p>
          </div>
        </div>

        {/* Primary Action */}
        <button
          onClick={handleAdminister}
          className="w-full h-[52px] bg-[#10B981] text-white rounded-xl font-semibold flex items-center justify-center gap-2"
          style={{ fontWeight: 600 }}
        >
          <CheckCircle className="w-5 h-5" />
          Mark as Administered
        </button>

        {/* Delay Option */}
        <button className="w-full text-[14px] text-[#2563EB] font-semibold min-h-[44px]" style={{ fontWeight: 600 }}>
          Delay dose
        </button>
      </div>

      {/* Confirmation Dialog */}
      {showConfirmDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-[#FFFFFF] rounded-2xl p-6 max-w-[360px] w-full animate-scale-in">
            <div className="w-12 h-12 rounded-full bg-[#FEF3C7] flex items-center justify-center mx-auto mb-4">
              <AlertTriangle className="w-6 h-6 text-[#F59E0B]" />
            </div>

            <h2 className="text-[18px] font-semibold text-[#0F172A] text-center mb-2" style={{ fontWeight: 600 }}>
              Confirm Administration
            </h2>

            <p className="text-[14px] text-[#64748B] text-center mb-6" style={{ fontWeight: 400 }}>
              This action is irreversible. Confirm administration of Methylphenidate 10mg to Maya Chen at {currentTime}?
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

      {/* Success Screen */}
      {showSuccess && (
        <div className="fixed inset-0 bg-[#FFFFFF] flex items-center justify-center z-50">
          <div className="text-center px-6 animate-scale-in">
            <div className="w-20 h-20 rounded-full bg-[#10B981] flex items-center justify-center mx-auto mb-6">
              <CheckCircle className="w-12 h-12 text-white" />
            </div>

            <h2 className="text-[24px] font-semibold text-[#0F172A] mb-2" style={{ fontWeight: 600 }}>
              Dose Administered
            </h2>

            <p className="text-[16px] text-[#64748B] mb-6" style={{ fontWeight: 400 }}>
              Recorded at {confirmationTime}
            </p>

            <div className="flex items-center justify-center gap-2 bg-[#F8FAFC] rounded-lg p-4">
              <Lock className="w-5 h-5 text-[#64748B]" />
              <p className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
                Record permanently locked
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
