import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Info } from 'lucide-react';

export function ParentSchoolCodeEntry() {
  const navigate = useNavigate();
  const [code, setCode] = useState('');
  const [showInfo, setShowInfo] = useState(false);

  const formatCode = (value: string) => {
    // Remove non-alphanumeric characters
    const cleaned = value.replace(/[^A-Za-z0-9]/g, '').toUpperCase();
    
    // Format as XXXX-XXXX
    if (cleaned.length > 4) {
      return `${cleaned.slice(0, 4)}-${cleaned.slice(4, 8)}`;
    }
    return cleaned;
  };

  const handleCodeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    const formatted = formatCode(value);
    setCode(formatted);
  };

  const isValidCode = code.replace('-', '').length === 8;

  const handleContinue = () => {
    if (isValidCode) {
      // In real app, validate code with API
      navigate('/parent/onboarding/confirm-child');
    }
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Progress Bar */}
      <div className="h-1 bg-gray-100">
        <div className="h-full bg-[#2563EB]" style={{ width: '12.5%' }} />
      </div>

      <div className="px-6 pt-12">
        {/* Logo */}
        <div className="flex justify-center mb-10">
          <div className="text-[28px] font-semibold text-[#2563EB]">
            SchooKeep
          </div>
        </div>

        {/* Content */}
        <div className="text-center mb-10">
          <h1 className="text-[20px] font-medium text-gray-900 mb-3">
            Set up your child's health profile
          </h1>
          <p className="text-[14px] text-[#64748B]">
            Enter the invitation code from your school
          </p>
        </div>

        {/* Code Input */}
        <div className="mb-4">
          <input
            type="text"
            value={code}
            onChange={handleCodeChange}
            placeholder="XXXX-XXXX"
            maxLength={9}
            className="w-full h-16 px-4 text-center text-[24px] font-medium text-gray-900 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-[#2563EB] tracking-widest"
            autoCapitalize="characters"
          />
        </div>

        {/* Continue Button */}
        <button
          onClick={handleContinue}
          disabled={!isValidCode}
          className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold disabled:opacity-40 disabled:cursor-not-allowed mb-4"
        >
          Continue
        </button>

        {/* Help Link */}
        <button
          onClick={() => setShowInfo(true)}
          className="w-full text-[14px] text-[#2563EB] font-medium"
        >
          I don't have a code
        </button>
      </div>

      {/* Info Sheet */}
      {showInfo && (
        <div className="fixed inset-0 z-50 flex items-end">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowInfo(false)}
          />
          <div className="relative bg-white rounded-t-3xl p-6 w-full">
            {/* Handle */}
            <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mb-6" />

            <div className="w-12 h-12 rounded-full bg-[#EFF6FF] flex items-center justify-center mx-auto mb-4">
              <Info className="w-6 h-6 text-[#2563EB]" />
            </div>

            <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
              Need an Invitation Code?
            </h3>
            <p className="text-[14px] text-[#64748B] mb-6 text-center leading-relaxed">
              Contact your school secretary to receive your invitation code. Each code is unique to your child and expires after first use.
            </p>

            <button
              onClick={() => setShowInfo(false)}
              className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold"
            >
              Got it
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
