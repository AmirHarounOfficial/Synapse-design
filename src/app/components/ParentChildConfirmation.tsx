import { useNavigate } from 'react-router';
import { CheckCircle, AlertCircle } from 'lucide-react';

export function ParentChildConfirmation() {
  const navigate = useNavigate();

  // In real app, this would come from API after code validation
  const childInfo = {
    firstName: 'Maya',
    lastName: 'Thompson',
    grade: '4th Grade',
    school: 'Lakeside Elementary School',
    schoolId: 'LS-2024-0892'
  };

  const initials = `${childInfo.firstName[0]}${childInfo.lastName[0]}`;

  const handleConfirm = () => {
    navigate('/parent/onboarding/emergency-consent');
  };

  const handleReject = () => {
    navigate('/parent/onboarding/code');
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Progress Bar */}
      <div className="h-1 bg-gray-100">
        <div className="h-full bg-[#2563EB]" style={{ width: '25%' }} />
      </div>

      <div className="px-6 pt-12">
        {/* Avatar */}
        <div className="flex justify-center mb-8">
          <div className="w-20 h-20 rounded-full bg-[#EFF6FF] flex items-center justify-center">
            <span className="text-[28px] font-semibold text-[#2563EB]">
              {initials}
            </span>
          </div>
        </div>

        {/* Child Info */}
        <div className="text-center mb-8">
          <h1 className="text-[24px] font-semibold text-gray-900 mb-2">
            {childInfo.firstName} {childInfo.lastName}
          </h1>
          <div className="space-y-1">
            <p className="text-[15px] text-[#64748B]">
              {childInfo.grade}
            </p>
            <p className="text-[15px] text-[#64748B]">
              {childInfo.school}
            </p>
            <p className="text-[13px] text-[#94A3B8]">
              ID: {childInfo.schoolId}
            </p>
          </div>
        </div>

        {/* Confirmation Prompt */}
        <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mb-8">
          <h2 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
            Is this your child?
          </h2>
          <p className="text-[13px] text-[#64748B] text-center leading-relaxed">
            This information was entered by your school's administrative staff.
          </p>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3">
          <button
            onClick={handleConfirm}
            className="w-full min-h-[52px] px-4 py-3.5 bg-[#10B981] text-white rounded-lg text-[15px] font-semibold flex items-center justify-center gap-2"
          >
            <CheckCircle className="w-5 h-5" />
            Yes, continue
          </button>

          <button
            onClick={handleReject}
            className="w-full min-h-[52px] px-4 py-3.5 bg-white text-gray-900 border border-gray-200 rounded-lg text-[15px] font-medium flex items-center justify-center gap-2"
          >
            <AlertCircle className="w-5 h-5" />
            No, wrong child
          </button>
        </div>

        {/* Privacy Note */}
        <div className="mt-8 text-center">
          <p className="text-[12px] text-[#94A3B8]">
            If this information is incorrect, please contact your school's main office.
          </p>
        </div>
      </div>
    </div>
  );
}
