import { ArrowLeft, AlertTriangle, Users, GraduationCap, Info } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function PrincipalStudentPromotion() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [confirmationText, setConfirmationText] = useState('');

  const requiredText = 'PROMOTE LAKEWOOD ELEMENTARY';

  const promotionData = {
    toPromote: 487,
    graduating: 43,
    heldBack: 2,
    heldBackNames: ['James Wilson (Grade 3)', 'Emily Davis (Grade 5)'],
    newYearStart: 'September 2, 2026'
  };

  const handleReviewConfirm = () => {
    setStep(2);
  };

  const handleExecute = () => {
    if (confirmationText === requiredText) {
      if (window.confirm('This action cannot be undone. Execute year-end promotion?')) {
        alert('Year-end promotion executed successfully. All students have been promoted.');
        navigate('/principal/home');
      }
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col" style={{ width: '393px', height: '852px' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
          aria-label="Go back"
        >
          <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
        </button>
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Year-End Promotion
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Warning Banner */}
        <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[13px] font-semibold text-[#92400E] mb-1">
                ⚠ Critical System Action
              </div>
              <div className="text-[12px] text-[#92400E] leading-relaxed">
                This action promotes all students one grade level and archives graduating students. It cannot be undone.
              </div>
            </div>
          </div>
        </div>

        {/* Progress Indicator */}
        <div className="flex items-center gap-2">
          {[1, 2, 3].map((s) => (
            <div key={s} className="flex items-center flex-1">
              <div
                className={`h-1 flex-1 rounded-full ${
                  s <= step ? 'bg-[#2563EB]' : 'bg-gray-200'
                }`}
              />
            </div>
          ))}
        </div>

        {/* Step 1: Review Summary */}
        {step >= 1 && (
          <div className="bg-white rounded-xl border border-gray-200 p-4">
            <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3 flex items-center gap-2">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center text-[12px] font-bold ${
                step > 1 ? 'bg-[#10B981] text-white' : 'bg-[#2563EB] text-white'
              }`}>
                1
              </div>
              Review Summary
            </h2>

            <div className="space-y-3">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                  <Users className="w-5 h-5 text-[#2563EB]" />
                </div>
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Students to be promoted
                  </div>
                  <div className="text-[20px] font-semibold text-[#2563EB]">
                    {promotionData.toPromote}
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F3F0FF] flex items-center justify-center flex-shrink-0">
                  <GraduationCap className="w-5 h-5 text-[#8B5CF6]" />
                </div>
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Students graduating
                  </div>
                  <div className="text-[20px] font-semibold text-[#8B5CF6]">
                    {promotionData.graduating}
                  </div>
                  <div className="text-[11px] text-[#64748B]">
                    Records will be archived (read-only, permanent)
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#FEF3C7] flex items-center justify-center flex-shrink-0">
                  <AlertTriangle className="w-5 h-5 text-[#F59E0B]" />
                </div>
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Students not promoted
                  </div>
                  <div className="text-[20px] font-semibold text-[#F59E0B]">
                    {promotionData.heldBack}
                  </div>
                  <div className="text-[12px] text-[#64748B] mt-1">
                    {promotionData.heldBackNames.join(', ')}
                  </div>
                </div>
              </div>

              <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-lg p-3 mt-3">
                <div className="flex items-start gap-2">
                  <Info className="w-4 h-4 text-[#2563EB] flex-shrink-0 mt-0.5" />
                  <div className="flex-1">
                    <div className="text-[12px] text-[#1E40AF]">
                      <strong>New school year start date:</strong> {promotionData.newYearStart}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {step === 1 && (
              <button
                onClick={handleReviewConfirm}
                className="w-full h-[48px] bg-[#2563EB] text-white rounded-lg font-medium text-[15px] mt-4 active:bg-[#1D4ED8]"
              >
                Confirm & Continue
              </button>
            )}
          </div>
        )}

        {/* Step 2: Type Confirmation */}
        {step >= 2 && (
          <div className="bg-white rounded-xl border border-gray-200 p-4">
            <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3 flex items-center gap-2">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center text-[12px] font-bold ${
                step > 2 ? 'bg-[#10B981] text-white' : 'bg-[#2563EB] text-white'
              }`}>
                2
              </div>
              Type Confirmation
            </h2>

            <div className="mb-3">
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                Type "{requiredText}" to unlock
              </label>
              <input
                type="text"
                value={confirmationText}
                onChange={(e) => setConfirmationText(e.target.value)}
                placeholder={requiredText}
                className="w-full h-[48px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>

            {confirmationText === requiredText && (
              <div className="flex items-center gap-2 p-3 bg-[#D1FAE5] border border-[#10B981] rounded-lg">
                <div className="w-5 h-5 rounded-full bg-[#10B981] flex items-center justify-center flex-shrink-0">
                  <span className="text-white text-[12px]">✓</span>
                </div>
                <span className="text-[12px] font-medium text-[#065F46]">
                  Confirmation text matches
                </span>
              </div>
            )}

            {step === 2 && confirmationText === requiredText && (
              <button
                onClick={() => setStep(3)}
                className="w-full h-[48px] bg-[#2563EB] text-white rounded-lg font-medium text-[15px] mt-4 active:bg-[#1D4ED8]"
              >
                Continue to Final Step
              </button>
            )}
          </div>
        )}

        {/* Step 3: Execute */}
        {step >= 3 && (
          <div className="bg-white rounded-xl border-2 border-[#DC2626] p-4">
            <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3 flex items-center gap-2">
              <div className="w-6 h-6 rounded-full bg-[#DC2626] text-white flex items-center justify-center text-[12px] font-bold">
                3
              </div>
              Final Confirmation
            </h2>

            <div className="bg-[#FEE2E2] border border-[#DC2626] rounded-lg p-3 mb-4">
              <div className="flex items-start gap-2">
                <AlertTriangle className="w-4 h-4 text-[#DC2626] flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <div className="text-[12px] font-semibold text-[#991B1B] mb-1">
                    Final Warning
                  </div>
                  <div className="text-[11px] text-[#991B1B] leading-relaxed">
                    This action is irreversible. All students will be promoted immediately. Graduating students will be permanently archived.
                  </div>
                </div>
              </div>
            </div>

            <button
              onClick={handleExecute}
              className="w-full h-[52px] bg-[#DC2626] text-white rounded-lg font-semibold text-[15px] flex items-center justify-center gap-2 active:bg-[#B91C1C]"
            >
              <AlertTriangle className="w-5 h-5" />
              Execute Promotion
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
