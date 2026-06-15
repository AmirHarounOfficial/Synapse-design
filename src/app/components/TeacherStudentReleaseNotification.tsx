import { useNavigate } from 'react-router';
import { Stethoscope, X } from 'lucide-react';
import { useState } from 'react';

export function TeacherStudentReleaseNotification() {
  const navigate = useNavigate();
  const [isAcknowledged, setIsAcknowledged] = useState(false);

  const notification = {
    studentName: 'Maya Chen',
    time: new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }),
    reason: 'Called to clinic'
  };

  const handleAcknowledge = () => {
    setIsAcknowledged(true);
    setTimeout(() => {
      navigate('/teacher/home');
    }, 1500);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Notification Overlay */}
      {!isAcknowledged ? (
        <div className="fixed top-[44px] left-0 right-0 z-50 px-4 pt-4 animate-in slide-in-from-top duration-300">
          <div className="bg-white rounded-xl border-2 border-[#2563EB] shadow-lg p-4">
            <div className="flex items-start gap-3 mb-3">
              <div className="w-10 h-10 rounded-full bg-[#DBEAFE] flex items-center justify-center flex-shrink-0">
                <Stethoscope className="w-5 h-5 text-[#2563EB]" />
              </div>
              <div className="flex-1">
                <h3 className="text-[15px] font-medium text-gray-900 mb-1">
                  Student Called to Clinic
                </h3>
                <p className="text-[14px] text-[#64748B]">
                  {notification.studentName} has been called to the clinic
                </p>
                <p className="text-[12px] text-[#64748B] mt-1">
                  {notification.time}
                </p>
              </div>
            </div>
            <button
              onClick={handleAcknowledge}
              className="w-full px-4 py-3 bg-[#2563EB] text-white rounded-lg text-[15px] font-medium min-h-[44px]"
            >
              Acknowledge
            </button>
          </div>
        </div>
      ) : (
        <div className="fixed top-[44px] left-0 right-0 z-50 px-4 pt-4 animate-in fade-in duration-300">
          <div className="bg-[#D1FAE5] rounded-xl border border-[#10B981] p-3">
            <div className="flex items-center gap-2">
              <div className="w-5 h-5 rounded-full bg-[#10B981] flex items-center justify-center flex-shrink-0">
                <div className="w-2 h-2 bg-white rounded-full" />
              </div>
              <p className="text-[14px] text-[#065F46] font-medium">
                Notification acknowledged
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Background Content (Teacher's current screen) */}
      <div className="px-4 py-4">
        <div className="bg-white rounded-xl border border-gray-200 p-6 text-center">
          <p className="text-[14px] text-[#64748B]">
            This notification appears as an overlay on your current screen
          </p>
        </div>
      </div>
    </div>
  );
}
