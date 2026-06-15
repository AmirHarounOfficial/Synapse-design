import { ChevronLeft, ShieldCheck } from 'lucide-react';
import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router';

export function TwoFactorAuth() {
  const navigate = useNavigate();
  const [code, setCode] = useState(['', '', '', '', '', '']);
  const [countdown, setCountdown] = useState(45);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    // Focus first input on mount
    inputRefs.current[0]?.focus();
  }, []);

  useEffect(() => {
    // Countdown timer
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(countdown - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [countdown]);

  const handleInputChange = (index: number, value: string) => {
    // Only allow digits
    if (value && !/^\d$/.test(value)) return;

    const newCode = [...code];
    newCode[index] = value;
    setCode(newCode);

    // Auto-focus next input
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !code[index] && index > 0) {
      // Move to previous input on backspace if current is empty
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    const newCode = [...code];

    for (let i = 0; i < pastedData.length; i++) {
      newCode[i] = pastedData[i];
    }

    setCode(newCode);

    // Focus the next empty input or the last one
    const nextEmptyIndex = newCode.findIndex(digit => !digit);
    if (nextEmptyIndex !== -1) {
      inputRefs.current[nextEmptyIndex]?.focus();
    } else {
      inputRefs.current[5]?.focus();
    }
  };

  const isComplete = code.every(digit => digit !== '');

  const handleVerify = () => {
    if (isComplete) {
      navigate('/biometric');
    }
  };

  const handleResend = () => {
    if (countdown === 0) {
      setCountdown(45);
      setCode(['', '', '', '', '', '']);
      inputRefs.current[0]?.focus();
    }
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="w-full h-screen bg-[#F8FAFC]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center border-b border-[#E2E8F0]">
        <button
          onClick={() => navigate('/login')}
          className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
        >
          <ChevronLeft className="w-6 h-6 text-[#0F172A]" />
        </button>
        <h1 className="flex-1 text-center text-[17px] font-medium text-[#0F172A] pr-10" style={{ fontWeight: 500 }}>
          Verify your identity
        </h1>
      </div>

      {/* Content */}
      <div className="px-4 pt-8">
        {/* Illustration area */}
        <div className="flex justify-center mb-6">
          <div className="w-[60px] h-[60px] rounded-full bg-[#2563EB]/10 flex items-center justify-center">
            <ShieldCheck className="w-8 h-8 text-[#2563EB]" />
          </div>
        </div>

        {/* Heading */}
        <h2 className="text-[18px] font-medium text-[#0F172A] text-center mb-2" style={{ fontWeight: 500 }}>
          Enter verification code
        </h2>

        {/* Body text */}
        <p className="text-[14px] text-[#64748B] text-center mb-8" style={{ fontWeight: 400 }}>
          A 6-digit code was sent to j***@school.edu
        </p>

        {/* OTP input */}
        <div className="flex gap-2 justify-center mb-6" onPaste={handlePaste}>
          {code.map((digit, index) => (
            <input
              key={index}
              ref={el => inputRefs.current[index] = el}
              type="text"
              inputMode="numeric"
              maxLength={1}
              value={digit}
              onChange={(e) => handleInputChange(index, e.target.value)}
              onKeyDown={(e) => handleKeyDown(index, e)}
              aria-label={`Digit ${index + 1} of 6`}
              className="w-[48px] h-[56px] text-center text-xl font-semibold rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] outline-none transition-all focus:border-[#2563EB] focus:border-2 focus:ring-0"
            />
          ))}
        </div>

        {/* Resend code */}
        <div className="text-center mb-8">
          {countdown > 0 ? (
            <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
              Resend in {formatTime(countdown)}
            </span>
          ) : (
            <button
              onClick={handleResend}
              className="text-[13px] text-[#2563EB] font-medium min-h-[44px] px-4"
              style={{ fontWeight: 500 }}
            >
              Resend code
            </button>
          )}
        </div>

        {/* Verify button */}
        <button
          onClick={handleVerify}
          disabled={!isComplete}
          className="w-full h-[52px] bg-[#2563EB] text-white rounded-xl font-semibold transition-opacity disabled:opacity-40"
          style={{ fontWeight: 600 }}
        >
          Verify
        </button>
      </div>
    </div>
  );
}
