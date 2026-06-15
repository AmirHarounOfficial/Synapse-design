import React, { useState, useEffect } from 'react';
import { Clock, ShieldAlert, ArrowRight, ShieldCheck, RefreshCw, X, LogOut, Smartphone } from 'lucide-react';
import { useNavigate } from 'react-router';

interface SysSessionExpiryProps {
  standalone?: boolean;
  initialRole?: string;
}

export function SysSessionExpiry({ standalone = true, initialRole = 'Nurse' }: SysSessionExpiryProps) {
  const navigate = useNavigate();
  const [role, setRole] = useState<string>(initialRole);
  const [isWarningOpen, setIsWarningOpen] = useState(true);
  const [secondsLeft, setSecondsLeft] = useState(300); // 5 minutes = 300 seconds
  const [isAccelerated, setIsAccelerated] = useState(false);
  const [sessionState, setSessionState] = useState<'active' | 'warning' | 'expired'>('warning');

  // Countdown timer logic
  useEffect(() => {
    if (!isWarningOpen || sessionState !== 'warning') return;

    const interval = setInterval(() => {
      setSecondsLeft((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          setSessionState('expired');
          setIsWarningOpen(false);
          // Redirect to login after a brief delay
          setTimeout(() => {
            navigate('/login');
          }, 2000);
          return 0;
        }
        return prev - (isAccelerated ? 10 : 1); // accelerated mode ticks 10s per second
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [isWarningOpen, isAccelerated, sessionState, navigate]);

  const formatTime = (totalSeconds: number) => {
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleStaySignedIn = () => {
    setSecondsLeft(300);
    setSessionState('active');
    setIsWarningOpen(false);
  };

  const handleSignOut = () => {
    setSessionState('expired');
    setIsWarningOpen(false);
    setTimeout(() => {
      navigate('/login');
    }, 1500);
  };

  const handleTriggerWarning = () => {
    setSecondsLeft(300);
    setSessionState('warning');
    setIsWarningOpen(true);
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col items-center justify-center p-4 select-none">
      {/* Standalone Demo Controls */}
      {standalone && (
        <div className="absolute top-4 left-4 right-4 z-50 bg-slate-800/90 backdrop-blur-md rounded-xl p-3 border border-slate-700 flex flex-col sm:flex-row gap-3 items-center justify-between shadow-xl max-w-md mx-auto">
          <div className="flex items-center gap-2">
            <Smartphone className="w-5 h-5 text-indigo-400" />
            <span className="text-xs font-semibold text-slate-300">SYS-04 Demo Controls</span>
          </div>
          <div className="flex items-center gap-2">
            <label className="flex items-center gap-1.5 cursor-pointer">
              <input
                type="checkbox"
                checked={isAccelerated}
                onChange={() => setIsAccelerated(!isAccelerated)}
                className="rounded border-slate-600 bg-slate-700 text-indigo-600 focus:ring-0 focus:ring-offset-0 w-3.5 h-3.5"
              />
              <span className="text-[11px] text-slate-300 font-bold">Speed up Timer</span>
            </label>
            {sessionState !== 'warning' && (
              <button
                onClick={handleTriggerWarning}
                className="bg-indigo-600 hover:bg-indigo-700 text-white text-[11px] font-bold px-2 py-1 rounded transition-all active:scale-95"
              >
                Re-Trigger Expiry
              </button>
            )}
          </div>
        </div>
      )}

      {/* Simulator Viewport */}
      <div className="relative w-full max-w-[393px] h-[852px] bg-slate-100 rounded-[52px] shadow-2xl border-[12px] border-slate-950 overflow-hidden flex flex-col text-slate-800">
        {/* iOS Dynamic Island */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[110px] h-[30px] bg-black rounded-b-[18px] z-50 flex items-center justify-center">
          <div className="w-3 h-3 rounded-full bg-slate-900/90 ml-6" />
        </div>

        {/* Mock iOS Status Bar */}
        <div className="h-[44px] flex items-center justify-between px-6 text-slate-800 text-[13px] font-semibold select-none z-40 bg-white">
          <span>3:35 PM</span>
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
            Nurse Admin Portal
          </h1>
          <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-xs font-semibold text-slate-700">
            RN
          </div>
        </header>

        {/* Main Simulated App Content */}
        <div className="flex-1 overflow-y-auto p-4 bg-slate-50 space-y-4">
          {sessionState === 'active' && (
            <div className="bg-emerald-50 border border-emerald-300 rounded-xl p-3.5 shadow-sm flex items-center gap-3 animate-scale-in">
              <ShieldCheck className="w-5 h-5 text-emerald-600 flex-shrink-0" />
              <div>
                <h4 className="text-xs font-bold text-emerald-900">Session Renewed Successfully</h4>
                <p className="text-[10px] text-emerald-700 leading-normal">
                  Your secure connection has been extended. Next timeout check in 15 minutes.
                </p>
              </div>
            </div>
          )}

          {sessionState === 'expired' && (
            <div className="bg-rose-50 border border-rose-300 rounded-xl p-3.5 shadow-sm flex items-center gap-3 animate-scale-in">
              <RefreshCw className="w-5 h-5 text-rose-600 flex-shrink-0 animate-spin" />
              <div>
                <h4 className="text-xs font-bold text-rose-900">Session Expired</h4>
                <p className="text-[10px] text-rose-700 leading-normal">
                  You are being securely logged out due to inactivity...
                </p>
              </div>
            </div>
          )}

          <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-3">
            <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider">Active Clinical Dossier</h3>
            <h4 className="text-sm font-bold text-slate-800">Medication Log Verification</h4>
            <div className="space-y-2.5">
              <div className="h-6 bg-slate-100 rounded w-5/6" />
              <div className="h-6 bg-slate-100 rounded w-2/3" />
              <div className="h-10 bg-slate-100 rounded" />
            </div>
          </div>
        </div>

        {/* Bottom Sheet Backdrop */}
        {isWarningOpen && (
          <div
            onClick={handleStaySignedIn}
            className="absolute inset-0 bg-black/60 z-40 transition-opacity duration-300 animate-fade-in"
          />
        )}

        {/* SCREEN SYS-04 — Session Expiry Warning Bottom Sheet */}
        <div
          className={`absolute bottom-0 left-0 right-0 bg-white rounded-t-[20px] shadow-2xl border-t border-slate-200 z-50 transition-transform duration-300 ease-out pb-8 ${
            isWarningOpen ? 'translate-y-0' : 'translate-y-full'
          }`}
        >
          {/* Bottom Sheet Grabber */}
          <div className="w-12 h-1.5 bg-slate-300 rounded-full mx-auto my-3" />

          <div className="px-5 space-y-4">
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-2 bg-rose-50 border border-rose-200 px-3 py-1 rounded-full text-rose-700 font-bold text-[10px] uppercase">
                <Clock className="w-3.5 h-3.5 text-rose-500 animate-pulse" />
                <span>Security Warning</span>
              </div>
              <button
                onClick={handleStaySignedIn}
                className="w-7 h-7 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 hover:bg-slate-200 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-1">
              <h3 className="text-lg font-bold text-slate-900">
                Your session will expire in 5 minutes due to inactivity.
              </h3>
              <p className="text-xs text-slate-500 leading-relaxed">
                For security reasons and HIPAA compliance, clinical sessions automatically close after extended inactivity.
              </p>
            </div>

            {/* Countdown clock visual */}
            <div className="bg-slate-950 text-white rounded-xl p-4 flex flex-col items-center justify-center border border-slate-800 shadow-inner">
              <div className="text-[10px] font-bold text-rose-500 uppercase tracking-widest mb-1 animate-pulse">
                Auto-Logout Countdown
              </div>
              <div className="font-mono text-[36px] font-semibold leading-none tracking-wider text-rose-400">
                {formatTime(secondsLeft)}
              </div>
            </div>

            {/* Action buttons */}
            <div className="space-y-2.5 pt-2">
              {/* Stay signed in primary button */}
              <button
                onClick={handleStaySignedIn}
                className="w-full bg-[#2563EB] hover:bg-[#1D4ED8] text-white font-bold text-[14px] py-3 px-4 rounded-xl flex items-center justify-center gap-1.5 transition-all active:scale-[0.98] shadow-md shadow-indigo-100"
              >
                Stay signed in
              </button>
              {/* Sign out secondary button */}
              <button
                onClick={handleSignOut}
                className="w-full bg-white hover:bg-slate-50 text-slate-700 border border-slate-200 font-bold text-[14px] py-3 px-4 rounded-xl flex items-center justify-center gap-1.5 transition-all active:scale-[0.98] shadow-sm"
              >
                <LogOut className="w-4 h-4 text-slate-500" /> Sign out
              </button>
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
