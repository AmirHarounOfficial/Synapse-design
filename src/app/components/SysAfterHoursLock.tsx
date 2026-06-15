import React, { useState } from 'react';
import { Lock, ShieldAlert, ArrowRight, CheckCircle2, RefreshCw, Smartphone } from 'lucide-react';
import { useNavigate } from 'react-router';

interface SysAfterHoursLockProps {
  standalone?: boolean;
  initialRole?: string;
  onOverrideSuccess?: () => void;
}

export function SysAfterHoursLock({ standalone = true, initialRole = 'Nurse', onOverrideSuccess }: SysAfterHoursLockProps) {
  const navigate = useNavigate();
  const [role, setRole] = useState<string>(initialRole);
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const handleOverride = (e: React.FormEvent) => {
    e.preventDefault();
    if (code === '9999' || code.toUpperCase() === 'EMERGENCY2026') {
      setSuccess(true);
      setError('');
      if (onOverrideSuccess) {
        setTimeout(() => {
          onOverrideSuccess();
        }, 1500);
      }
    } else {
      setError('Invalid authorization code. Please try again or contact your Principal.');
      setSuccess(false);
    }
  };

  const isLocked = role !== 'Parent';

  return (
    <div className={`min-h-screen bg-slate-900 flex flex-col items-center justify-center p-4 select-none ${standalone ? 'font-sans' : ''}`}>
      {/* Standalone Role Swapper for easy testing */}
      {standalone && (
        <div className="absolute top-4 left-4 right-4 z-50 bg-slate-800/90 backdrop-blur-md rounded-xl p-3 border border-slate-700 flex flex-col sm:flex-row gap-3 items-center justify-between shadow-xl max-w-md mx-auto">
          <div className="flex items-center gap-2">
            <Smartphone className="w-5 h-5 text-indigo-400" />
            <span className="text-xs font-semibold text-slate-300">SYS-01 Demo Controls</span>
          </div>
          <div className="flex items-center gap-2">
            <label className="text-[11px] text-slate-400 font-medium">Role:</label>
            <select
              value={role}
              onChange={(e) => {
                setRole(e.target.value);
                setSuccess(false);
                setError('');
                setCode('');
              }}
              className="bg-slate-700 text-xs text-white border border-slate-600 rounded px-2 py-1 outline-none focus:border-indigo-500"
            >
              <option value="Nurse">School Nurse (Staff)</option>
              <option value="Teacher">Teacher (Staff)</option>
              <option value="Counselor">Counselor (Staff)</option>
              <option value="Secretary">Secretary (Staff)</option>
              <option value="Parent">Parent (Unrestricted)</option>
            </select>
          </div>
        </div>
      )}

      {/* Simulator Viewport */}
      <div className="relative w-full max-w-[393px] h-[852px] bg-slate-800 rounded-[52px] shadow-2xl border-[12px] border-slate-950 overflow-hidden flex flex-col">
        {/* iOS Dynamic Island */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[110px] h-[30px] bg-black rounded-b-[18px] z-50 flex items-center justify-center">
          <div className="w-3 h-3 rounded-full bg-slate-900/90 ml-6" />
        </div>

        {/* Mock iOS Status Bar */}
        <div className="h-[44px] flex items-center justify-between px-6 text-white text-[13px] font-semibold select-none z-40 bg-slate-950/20">
          <span>7:15 PM</span>
          <div className="flex items-center gap-1.5">
            <svg className="w-4 h-4 fill-white" viewBox="0 0 24 24"><path d="M12 3c-4.97 0-9 4.03-9 9 0 2.12.74 4.07 1.97 5.61L4.35 19.4c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l1.9-1.9C9.13 19.57 10.5 20 12 20c4.97 0 9-4.03 9-9s-4.03-9-9-9zm0 15c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/></svg>
            <span className="text-[11px]">5G</span>
            <div className="w-[20px] h-[10px] border border-white rounded-[3px] p-[1px] flex items-center">
              <div className="w-[14px] h-[6px] bg-white rounded-[1.5px]" />
            </div>
          </div>
        </div>

        {/* Background Simulated App Screen (Blurred) */}
        <div className="flex-1 flex flex-col p-4 bg-slate-50 filter blur-[2px] transition-all duration-300">
          <div className="h-10 bg-indigo-600 rounded-lg mb-4 flex items-center px-3 text-white font-bold text-sm">
            Synapse Dashboard
          </div>
          <div className="flex-1 space-y-3">
            <div className="h-28 bg-white border border-slate-200 rounded-xl p-3 shadow-sm space-y-2">
              <div className="h-4 bg-slate-200 w-1/3 rounded" />
              <div className="h-8 bg-slate-100 rounded" />
              <div className="h-6 bg-slate-100 rounded" />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="h-24 bg-white border border-slate-200 rounded-xl p-3 shadow-sm" />
              <div className="h-24 bg-white border border-slate-200 rounded-xl p-3 shadow-sm" />
            </div>
            <div className="h-36 bg-white border border-slate-200 rounded-xl p-3 shadow-sm" />
          </div>
        </div>

        {/* Lock Screen Overlay (rgba 0,0,0,0.85) */}
        {isLocked ? (
          <div className="absolute inset-0 bg-black/85 z-40 flex flex-col items-center justify-center p-6 animate-fade-in">
            {success ? (
              <div className="bg-white w-[320px] rounded-[12px] p-6 shadow-2xl flex flex-col items-center text-center animate-scale-in">
                <div className="w-16 h-16 rounded-full bg-emerald-50 flex items-center justify-center mb-4">
                  <CheckCircle2 className="w-10 h-10 text-emerald-500" />
                </div>
                <h3 className="text-xl font-semibold text-slate-900 mb-2">Override Accepted</h3>
                <p className="text-sm text-slate-500 mb-6">
                  Emergency bypass granted. Temporary access is unlocked.
                </p>
                <div className="inline-flex items-center gap-2 text-xs font-semibold text-emerald-600 bg-emerald-50 px-3 py-1.5 rounded-full">
                  <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                  Loading Synapse Portal...
                </div>
              </div>
            ) : (
              <div className="bg-white w-[320px] rounded-[12px] p-6 shadow-2xl flex flex-col items-center text-center animate-scale-in">
                {/* Lock Icon 48px, #64748B */}
                <div className="w-16 h-16 rounded-full bg-slate-50 flex items-center justify-center mb-4">
                  <Lock className="w-[48px] h-[48px] text-[#64748B]" />
                </div>

                {/* Heading 20px 500 #0F172A */}
                <h3 className="text-[20px] font-medium text-[#0F172A] tracking-tight leading-6 mb-3">
                  System Locked
                </h3>

                {/* Description */}
                <p className="text-[13px] leading-5 text-slate-500 mb-4 px-1">
                  Synapse is only accessible during school hours (Mon–Fri, 7:30 AM – 5:00 PM).
                </p>

                {/* School hours next shown */}
                <div className="bg-slate-50 border border-slate-100 rounded-lg py-2.5 px-3 w-full mb-5 flex items-center justify-center gap-2">
                  <ShieldAlert className="w-4 h-4 text-amber-500 flex-shrink-0" />
                  <span className="text-[12px] font-semibold text-slate-700">
                    Next access: Tomorrow at 7:30 AM
                  </span>
                </div>

                {/* Divider line */}
                <div className="w-full h-px bg-slate-100 mb-4" />

                {/* Emergency authorization */}
                <form onSubmit={handleOverride} className="w-full text-left space-y-3">
                  <div className="text-[11px] font-medium text-slate-500 uppercase tracking-wider">
                    Emergency Exception
                  </div>
                  <div className="text-[12px] text-slate-600 leading-4">
                    If you have an emergency authorization code from your Principal, enter it below:
                  </div>
                  <div className="space-y-2">
                    <input
                      type="password"
                      value={code}
                      onChange={(e) => setCode(e.target.value)}
                      placeholder="Enter emergency code"
                      className="w-full border border-slate-200 rounded-lg px-3 py-2 text-[14px] text-slate-900 bg-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-400 focus:border-transparent transition-all"
                    />
                    {error && (
                      <p className="text-[11px] text-rose-500 font-medium leading-tight">
                        {error}
                      </p>
                    )}
                    <button
                      type="submit"
                      className="w-full bg-[#FFFFFF] border border-slate-200 text-slate-800 hover:bg-slate-50 text-[14px] font-semibold py-2 px-4 rounded-lg flex items-center justify-center gap-1.5 active:scale-[0.98] transition-all shadow-sm"
                    >
                      Override Access <ArrowRight className="w-4 h-4" />
                    </button>
                  </div>
                  <div className="text-[10px] text-slate-400 text-center pt-2">
                    Try demo bypass code: <span className="font-bold text-slate-500">9999</span>
                  </div>
                </form>
              </div>
            )}
          </div>
        ) : (
          <div className="absolute inset-0 bg-transparent z-40 flex flex-col items-center justify-center p-6 bg-slate-950/10">
            <div className="bg-emerald-50/95 backdrop-blur-md border border-emerald-200 w-[320px] rounded-[12px] p-5 shadow-2xl text-center animate-scale-in">
              <div className="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-3">
                <CheckCircle2 className="w-6 h-6 text-emerald-600" />
              </div>
              <h3 className="text-[16px] font-semibold text-emerald-900 mb-1">
                Parent Access Unrestricted
              </h3>
              <p className="text-[12px] leading-5 text-emerald-700">
                You are logged in under a **Parent** role. Parents maintain unrestricted 24/7 access to view child health records, dose history, and bus tracking.
              </p>
              <button
                onClick={() => navigate('/parent/app/home')}
                className="mt-4 w-full bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold py-2 px-4 rounded-lg transition-all active:scale-95 shadow-sm"
              >
                Go to Parent Dashboard
              </button>
            </div>
          </div>
        )}

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
