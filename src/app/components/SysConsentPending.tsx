import React, { useState } from 'react';
import { AlertTriangle, CheckCircle, Clock, Pill, Bus, FileText, Lock, ChevronRight, CheckCircle2, ShieldAlert, Sparkles, Smartphone } from 'lucide-react';
import { useNavigate } from 'react-router';

interface SysConsentPendingProps {
  standalone?: boolean;
}

export function SysConsentPending({ standalone = true }: SysConsentPendingProps) {
  const navigate = useNavigate();
  const [isCompleted, setIsCompleted] = useState(false);
  const [loading, setLoading] = useState(false);

  // Checklist items
  const [steps, setSteps] = useState([
    { id: '1', label: 'School code entry', completed: true },
    { id: '2', label: 'Confirm child connection', completed: true },
    { id: '3', label: 'Emergency medical consent', completed: false, required: true },
    { id: '4', label: 'Upload immunization records', completed: false, required: true },
    { id: '5', label: 'Designate authorized pickups', completed: true },
  ]);

  const completedCount = steps.filter(s => s.completed).length;
  const progressPercent = Math.round((completedCount / steps.length) * 100);

  const handleCompleteSetup = () => {
    setLoading(true);
    setTimeout(() => {
      setSteps(prev => prev.map(s => ({ ...s, completed: true })));
      setIsCompleted(true);
      setLoading(false);
    }, 1500);
  };

  const handleReset = () => {
    setSteps([
      { id: '1', label: 'School code entry', completed: true },
      { id: '2', label: 'Confirm child connection', completed: true },
      { id: '3', label: 'Emergency medical consent', completed: false, required: true },
      { id: '4', label: 'Upload immunization records', completed: false, required: true },
      { id: '5', label: 'Designate authorized pickups', completed: true },
    ]);
    setIsCompleted(false);
  };

  const recentActivity = [
    { id: '1', type: 'medication', description: 'Ritalin administered', time: '10:30 AM' },
    { id: '2', type: 'bus', description: 'Boarded Route 12', time: '7:45 AM' },
  ];

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col items-center justify-center p-4 select-none">
      {/* Standalone Demo Controls */}
      {standalone && (
        <div className="absolute top-4 left-4 right-4 z-50 bg-slate-800/90 backdrop-blur-md rounded-xl p-3 border border-slate-700 flex flex-col sm:flex-row gap-3 items-center justify-between shadow-xl max-w-md mx-auto">
          <div className="flex items-center gap-2">
            <Smartphone className="w-5 h-5 text-indigo-400" />
            <span className="text-xs font-semibold text-slate-300">SYS-03 Demo Controls</span>
          </div>
          <div className="flex items-center gap-2">
            {isCompleted && (
              <button
                onClick={handleReset}
                className="bg-slate-700 hover:bg-slate-600 text-white text-[11px] font-bold px-2 py-1 rounded transition-all active:scale-95"
              >
                Reset Onboarding Gate
              </button>
            )}
            <span className="text-[11px] text-slate-400 font-medium">
              State: <span className={isCompleted ? 'text-emerald-400 font-bold' : 'text-amber-400 font-bold'}>
                {isCompleted ? 'Unlocked' : 'Locked'}
              </span>
            </span>
          </div>
        </div>
      )}

      {/* Simulator Viewport */}
      <div className="relative w-full max-w-[393px] h-[852px] bg-slate-50 rounded-[52px] shadow-2xl border-[12px] border-slate-950 overflow-hidden flex flex-col text-slate-800">
        {/* iOS Dynamic Island */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[110px] h-[30px] bg-black rounded-b-[18px] z-50 flex items-center justify-center">
          <div className="w-3 h-3 rounded-full bg-slate-900/90 ml-6" />
        </div>

        {/* Mock iOS Status Bar */}
        <div className="h-[44px] flex items-center justify-between px-6 text-slate-800 text-[13px] font-semibold select-none z-40 bg-white">
          <span>2:15 PM</span>
          <div className="flex items-center gap-1.5">
            <svg className="w-4 h-4 fill-slate-800" viewBox="0 0 24 24"><path d="M12 3c-4.97 0-9 4.03-9 9 0 2.12.74 4.07 1.97 5.61L4.35 19.4c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l1.9-1.9C9.13 19.57 10.5 20 12 20c4.97 0 9-4.03 9-9s-4.03-9-9-9zm0 15c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/></svg>
            <span className="text-[11px]">5G</span>
            <div className="w-[20px] h-[10px] border border-slate-800 rounded-[3px] p-[1px] flex items-center">
              <div className="w-[14px] h-[6px] bg-slate-800 rounded-[1.5px]" />
            </div>
          </div>
        </div>

        {/* Top App Bar */}
        <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-slate-200 flex-shrink-0 z-30">
          <h1 className="text-[17px] font-bold text-slate-900 tracking-tight">
            Maya's Health Home
          </h1>
          <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-xs font-semibold text-slate-700">
            JT
          </div>
        </header>

        {/* Scrollable Container */}
        <div className="flex-1 overflow-y-auto pb-24">
          <div className="p-4 space-y-4">
            
            {/* SCREEN SYS-03 — Consent Pending Gate Amber Card */}
            {!isCompleted ? (
              <div className="bg-[#FFFBEB] border-2 border-[#F59E0B] rounded-xl p-4 shadow-sm animate-slide-down">
                <div className="flex items-start gap-2.5 mb-3">
                  <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
                  <div>
                    {/* Heading */}
                    <h3 className="text-[14px] font-bold text-[#92400E]">
                      Your child's health profile is not yet active
                    </h3>
                    <p className="text-[11px] text-[#B45309] mt-0.5">
                      Onboarding checklist incomplete. Complete remaining steps to activate portal.
                    </p>
                  </div>
                </div>

                {/* Progress bar */}
                <div className="space-y-1 mb-3 bg-white/50 p-2.5 rounded-lg border border-amber-200/50">
                  <div className="flex justify-between text-[11px] font-bold text-[#92400E]">
                    <span>Setup Checklist</span>
                    <span>{completedCount} of {steps.length} steps ({progressPercent}%)</span>
                  </div>
                  <div className="w-full bg-amber-200/40 h-2 rounded-full overflow-hidden">
                    <div
                      className="bg-[#F59E0B] h-full rounded-full transition-all duration-500"
                      style={{ width: `${progressPercent}%` }}
                    />
                  </div>
                </div>

                {/* Steps checklist */}
                <ul className="space-y-2 mb-4">
                  {steps.map((step) => (
                    <li key={step.id} className="flex items-center gap-2 text-xs">
                      {step.completed ? (
                        <CheckCircle2 className="w-4 h-4 text-emerald-600 flex-shrink-0" />
                      ) : (
                        <div className="w-4 h-4 rounded-full border-2 border-amber-400 bg-amber-50 flex-shrink-0" />
                      )}
                      <span className={`font-medium ${step.completed ? 'text-slate-500 line-through' : 'text-slate-800'}`}>
                        {step.label}
                      </span>
                      {step.required && !step.completed && (
                        <span className="text-[9px] bg-amber-100 text-[#92400E] font-bold px-1.5 py-0.5 rounded ml-auto">
                          Required
                        </span>
                      )}
                    </li>
                  ))}
                </ul>

                {/* Complete setup primary button */}
                <button
                  onClick={handleCompleteSetup}
                  disabled={loading}
                  className="w-full bg-[#F59E0B] hover:bg-[#D97706] text-white font-bold text-[13px] py-2.5 px-4 rounded-lg flex items-center justify-center gap-1.5 transition-all active:scale-[0.98] shadow-sm disabled:bg-amber-300 disabled:cursor-not-allowed"
                >
                  {loading ? (
                    <>
                      <div className="w-4 h-4 border-2 border-white/50 border-t-white rounded-full animate-spin" />
                      Verifying consent files...
                    </>
                  ) : (
                    <>
                      Complete setup <ChevronRight className="w-4 h-4" />
                    </>
                  )}
                </button>
              </div>
            ) : (
              /* Success Onboarding Completed banner */
              <div className="bg-[#ECFDF5] border border-emerald-300 rounded-xl p-4 shadow-sm flex items-center gap-3 animate-scale-in">
                <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 flex-shrink-0">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-emerald-900">Health Profile Fully Active!</h3>
                  <p className="text-[11px] text-emerald-600 leading-normal mt-0.5">
                    Thank you, James! Maya's medical dossier has been securely synced with the school nurse.
                  </p>
                </div>
              </div>
            )}

            {/* Simulated parent dashboard details (Blocked/Blurred when incomplete) */}
            <div className="relative">
              
              {/* Lock screen screen-blur wrapper */}
              <div className={`space-y-4 transition-all duration-500 ${!isCompleted ? 'blur-[3.5px] pointer-events-none opacity-50 select-none' : ''}`}>
                {/* Simulated Medication Activity Card */}
                <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-3">
                  <div className="flex items-center justify-between">
                    <h4 className="text-[13px] font-bold text-slate-800 flex items-center gap-2">
                      <Pill className="w-4 h-4 text-indigo-500" />
                      Medication Administrations
                    </h4>
                    <span className="text-[10px] text-slate-400">Today</span>
                  </div>
                  <div className="bg-slate-50 rounded-lg p-3 border border-slate-100 flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-indigo-50 flex items-center justify-center text-indigo-600 flex-shrink-0">
                      <Pill className="w-4 h-4" />
                    </div>
                    <div>
                      <div className="text-xs font-bold text-slate-800">Ritalin administered</div>
                      <div className="text-[10px] text-slate-500">10:30 AM by Nurse Reynolds</div>
                    </div>
                  </div>
                </div>

                {/* Simulated Recent Activity */}
                <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-3">
                  <h4 className="text-[13px] font-bold text-slate-800">Activity Log</h4>
                  <div className="space-y-2">
                    {recentActivity.map((activity) => (
                      <div key={activity.id} className="flex justify-between items-center text-xs py-1 border-b border-slate-100 last:border-0 pb-1.5 last:pb-0">
                        <span className="text-slate-600 font-medium">{activity.description}</span>
                        <span className="text-slate-400 text-[10px]">{activity.time}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Simulated Medical Records */}
                <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
                  <h4 className="text-[13px] font-bold text-slate-800 mb-2">Clinic Visits</h4>
                  <div className="flex items-center gap-2 text-xs text-slate-500 bg-slate-50 p-2.5 rounded-lg border border-slate-100">
                    <FileText className="w-4 h-4 text-slate-400 flex-shrink-0" />
                    <span>Minor scratch treated • 3 days ago</span>
                  </div>
                </div>
              </div>

              {/* Blur Lock Overlay */}
              {!isCompleted && (
                <div className="absolute inset-0 bg-transparent flex flex-col items-center justify-center p-6 text-center select-none z-20">
                  <div className="bg-slate-900/10 p-3 rounded-full border border-slate-900/10 mb-2.5">
                    <Lock className="w-6 h-6 text-slate-800/80" />
                  </div>
                  <h4 className="text-xs font-bold text-slate-800">Health Features Blocked</h4>
                  <p className="text-[10px] text-slate-600 max-w-[200px] mt-1">
                    Emergency records, meds history, and activity logs are locked until health profile is active.
                  </p>
                </div>
              )}
            </div>

          </div>
        </div>

        {/* Mock iOS Home Indicator */}
        <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 w-[140px] h-[5px] bg-slate-900/40 rounded-full z-50" />
      </div>

      {standalone && (
        <button
          onClick={() => navigate('/')}
          className="mt-6 text-slate-400 hover:text-white text-xs font-semibold underline underline-offset-4 flex items-center gap-1.5"
        >
          Return to Navigation Map
        </button>
      )}
    </div>
  );
}
