import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, Check, Send } from 'lucide-react';
import { useState } from 'react';

export function BusStudentBoarding() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [isConfirming, setIsConfirming] = useState(false);

  // Mock student data - in real app would fetch based on id
  const student = {
    id: id || '5',
    name: 'Noah Williams',
    grade: '4th Grade',
    stopNumber: 5,
    initials: 'NW',
    parentName: 'Sarah Williams'
  };

  const currentTime = new Date().toLocaleTimeString('en-US', { 
    hour: '2-digit', 
    minute: '2-digit' 
  });

  const handleConfirmBoarding = () => {
    setShowConfirmation(true);
  };

  const handleFinalConfirm = () => {
    setIsConfirming(true);
    // Simulate sending notification
    setTimeout(() => {
      navigate('/bus/route');
    }, 1500);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200 relative">
        <button
          onClick={() => navigate('/bus/route')}
          className="p-2 -ml-2 min-h-[44px] min-w-[44px] flex items-center justify-center"
        >
          <ArrowLeft className="w-6 h-6 text-gray-900" />
        </button>
        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900">
          Confirm Boarding
        </h1>
      </header>

      <div className="px-4 py-6 space-y-6">
        {/* Student Info Card */}
        <div className="bg-white rounded-2xl border border-gray-200 p-6">
          <div className="flex flex-col items-center text-center">
            {/* Avatar */}
            <div className="w-20 h-20 rounded-full bg-[#EFF6FF] flex items-center justify-center mb-4">
              <span className="text-[28px] font-semibold text-[#2563EB]">
                {student.initials}
              </span>
            </div>

            {/* Student Details */}
            <h2 className="text-[24px] font-bold text-gray-900 mb-1">
              {student.name}
            </h2>
            <div className="text-[15px] text-[#64748B] mb-1">
              {student.grade}
            </div>
            <div className="inline-flex items-center px-3 py-1.5 rounded-lg bg-[#F8FAFC] text-[#64748B] text-[13px] font-medium">
              Stop {student.stopNumber}
            </div>
          </div>
        </div>

        {/* Info Notice */}
        <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-xl p-4">
          <div className="flex items-start gap-3">
            <Send className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[13px] text-[#1E40AF] font-semibold mb-1">
                Parent Notification
              </div>
              <p className="text-[12px] text-[#1E40AF] leading-relaxed">
                When you confirm boarding, <strong>{student.parentName}</strong> will receive an automatic push notification: "Your child {student.name.split(' ')[0]} has boarded the bus at {currentTime}"
              </p>
            </div>
          </div>
        </div>

        {/* Confirm Button */}
        <button
          onClick={handleConfirmBoarding}
          className="w-full px-4 py-4 bg-[#10B981] text-white rounded-lg text-[17px] font-semibold min-h-[52px] flex items-center justify-center gap-2 shadow-lg"
        >
          <Check className="w-6 h-6" />
          Confirm Boarding
        </button>

        {/* Cancel Link */}
        <button
          onClick={() => navigate('/bus/route')}
          className="w-full text-[#64748B] text-[15px] font-medium py-3 min-h-[44px]"
        >
          Cancel
        </button>
      </div>

      {/* Confirmation Dialog */}
      {showConfirmation && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => !isConfirming && setShowConfirmation(false)}
          />
          <div className="relative bg-white rounded-2xl p-6 max-w-sm w-full">
            {!isConfirming ? (
              <>
                <div className="w-16 h-16 rounded-full bg-[#D1FAE5] flex items-center justify-center mx-auto mb-4">
                  <Check className="w-8 h-8 text-[#10B981]" />
                </div>
                <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
                  Confirm Student Boarding
                </h3>
                <p className="text-[14px] text-[#64748B] mb-6 text-center">
                  Mark <strong>{student.name}</strong> as boarded at {currentTime}?
                </p>

                <div className="flex gap-3">
                  <button
                    onClick={() => setShowConfirmation(false)}
                    className="flex-1 px-4 py-3.5 bg-white text-gray-900 border border-gray-200 rounded-lg text-[15px] font-medium min-h-[52px]"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleFinalConfirm}
                    className="flex-1 px-4 py-3.5 bg-[#10B981] text-white rounded-lg text-[15px] font-medium min-h-[52px]"
                  >
                    Confirm
                  </button>
                </div>
              </>
            ) : (
              <>
                <div className="w-16 h-16 rounded-full bg-[#D1FAE5] flex items-center justify-center mx-auto mb-4">
                  <Send className="w-8 h-8 text-[#10B981] animate-pulse" />
                </div>
                <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
                  Sending Notification...
                </h3>
                <p className="text-[14px] text-[#64748B] text-center">
                  Notifying {student.parentName}
                </p>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
