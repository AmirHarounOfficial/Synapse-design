import { useNavigate } from 'react-router';
import { AlertTriangle, CheckCircle, Circle } from 'lucide-react';

interface Step {
  id: string;
  title: string;
  completed: boolean;
}

export function ParentProfileNotActive() {
  const navigate = useNavigate();

  // In real app, this would be determined by actual completion status
  const steps: Step[] = [
    { id: 'code', title: 'School code verified', completed: true },
    { id: 'emergency', title: 'Emergency consent signed', completed: true },
    { id: 'privacy', title: 'Privacy agreement signed', completed: false },
    { id: 'documents', title: 'Documents uploaded', completed: false },
    { id: 'pickups', title: 'Authorized pickups added', completed: false }
  ];

  const completedCount = steps.filter(s => s.completed).length;
  const nextIncompleteStep = steps.find(s => !s.completed);

  const handleContinue = () => {
    // Navigate to first incomplete step
    if (nextIncompleteStep) {
      switch (nextIncompleteStep.id) {
        case 'emergency':
          navigate('/parent/onboarding/emergency-consent');
          break;
        case 'privacy':
          navigate('/parent/onboarding/privacy-agreement');
          break;
        case 'documents':
          navigate('/parent/onboarding/documents');
          break;
        case 'pickups':
          navigate('/parent/onboarding/authorized-pickups');
          break;
        default:
          navigate('/parent/onboarding/code');
      }
    }
  };

  return (
    <div className="min-h-screen bg-white flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
        {/* Alert Icon */}
        <div className="w-24 h-24 rounded-full bg-[#FEF3C7] flex items-center justify-center mb-8">
          <AlertTriangle className="w-14 h-14 text-[#F59E0B]" />
        </div>

        {/* Title */}
        <h1 className="text-[24px] font-semibold text-gray-900 mb-3 text-center">
          Setup Required
        </h1>
        <p className="text-[15px] text-[#64748B] mb-8 text-center max-w-xs">
          Complete your child's health profile to access all features
        </p>

        {/* Progress */}
        <div className="w-full max-w-sm mb-8">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[13px] font-medium text-gray-900">Setup Progress</span>
            <span className="text-[13px] font-semibold text-[#2563EB]">
              {completedCount} of {steps.length}
            </span>
          </div>
          <div className="h-2 bg-gray-100 rounded-full overflow-hidden mb-6">
            <div
              className="h-full bg-[#2563EB] transition-all duration-300"
              style={{ width: `${(completedCount / steps.length) * 100}%` }}
            />
          </div>

          {/* Steps List */}
          <div className="space-y-3">
            {steps.map((step) => (
              <div
                key={step.id}
                className="flex items-center gap-3"
              >
                {step.completed ? (
                  <div className="w-6 h-6 rounded-full bg-[#D1FAE5] flex items-center justify-center flex-shrink-0">
                    <CheckCircle className="w-4 h-4 text-[#10B981]" />
                  </div>
                ) : (
                  <div className="w-6 h-6 rounded-full bg-[#FEF3C7] flex items-center justify-center flex-shrink-0">
                    <Circle className="w-4 h-4 text-[#F59E0B]" />
                  </div>
                )}
                <span
                  className={`text-[14px] ${
                    step.completed ? 'text-[#64748B] line-through' : 'text-gray-900 font-medium'
                  }`}
                >
                  {step.title}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Info Card */}
        <div className="w-full max-w-sm bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mb-8">
          <p className="text-[12px] text-[#64748B] text-center leading-relaxed">
            Your setup is {Math.round((completedCount / steps.length) * 100)}% complete. Finish the remaining steps to activate Maya's health profile and enable real-time health monitoring.
          </p>
        </div>
      </div>

      {/* Bottom Action */}
      <div className="p-6 border-t border-gray-200 bg-white">
        <button
          onClick={handleContinue}
          className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold"
        >
          Continue Setup
        </button>
      </div>
    </div>
  );
}
