import React, { useState, useEffect } from 'react';
import {
  Smartphone,
  Lock,
  AlertTriangle,
  FileCheck2,
  Clock,
  ArrowRight,
  ShieldCheck,
  RotateCcw,
  Sparkles,
  Users,
  Settings,
  HelpCircle,
  X,
  Plus,
  Smile,
  ShieldAlert
} from 'lucide-react';
import { useNavigate } from 'react-router';

export function SystemStateShowcase() {
  const navigate = useNavigate();
  const [activeState, setActiveState] = useState<'SYS-01' | 'SYS-02' | 'SYS-03' | 'SYS-04' | 'SYS-05'>('SYS-01');
  
  // Simulation variables
  const [role, setRole] = useState<'Nurse' | 'Parent' | 'Teacher' | 'Counselor'>('Nurse');
  const [s5RamadanActive, setS5RamadanActive] = useState(true);

  
  // State 1 parameters
  const [s1BypassCode, setS1BypassCode] = useState('');
  const [s1Error, setS1Error] = useState('');
  const [s1OverrideAccepted, setS1OverrideAccepted] = useState(false);
  const [isAfterHours, setIsAfterHours] = useState(true);

  // State 2 parameters
  const [s2BannerVisible, setS2BannerVisible] = useState(true);
  const [s2BottomSheetOpen, setS2BottomSheetOpen] = useState(false);

  // State 3 parameters
  const [s3Completed, setS3Completed] = useState(false);
  const [s3Loading, setS3Loading] = useState(false);

  // State 4 parameters
  const [s4WarningOpen, setS4WarningOpen] = useState(true);
  const [s4SecondsLeft, setS4SecondsLeft] = useState(300);
  const [s4IsAccelerated, setS4IsAccelerated] = useState(false);
  const [s4SessionState, setS4SessionState] = useState<'warning' | 'active' | 'expired'>('warning');

  // Change state resets
  useEffect(() => {
    // Reset secondary flags when switching active state
    if (activeState === 'SYS-01') {
      setRole('Nurse');
    } else if (activeState === 'SYS-02') {
      setRole('Nurse');
      setS2BannerVisible(true);
      setS2BottomSheetOpen(false);
    } else if (activeState === 'SYS-03') {
      setRole('Parent'); // SYS-03 is strictly for parents
    } else if (activeState === 'SYS-04') {
      setRole('Nurse'); // HIPAA timeout applies to clinicians
      setS4WarningOpen(true);
      setS4SecondsLeft(300);
      setS4SessionState('warning');
    } else if (activeState === 'SYS-05') {
      setRole('Nurse');
      localStorage.setItem('sys_ramadan_active', s5RamadanActive ? 'true' : 'false');
      window.dispatchEvent(new Event('ramadan_state_change'));
    }

  }, [activeState]);

  // State 4 countdown logic
  useEffect(() => {
    if (activeState !== 'SYS-04' || !s4WarningOpen || s4SessionState !== 'warning') return;

    const interval = setInterval(() => {
      setS4SecondsLeft((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          setS4SessionState('expired');
          setS4WarningOpen(false);
          return 0;
        }
        return prev - (s4IsAccelerated ? 15 : 1);
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [activeState, s4WarningOpen, s4IsAccelerated, s4SessionState]);

  // Code validation helper
  const handleS1Submit = (e: React.FormEvent) => {
    e.preventDefault();
    if (s1BypassCode === '9999' || s1BypassCode.toUpperCase() === 'EMERGENCY2026') {
      setS1OverrideAccepted(true);
      setS1Error('');
    } else {
      setS1Error('Invalid emergency code. Verify and try again.');
    }
  };

  const handleS3Complete = () => {
    setS3Loading(true);
    setTimeout(() => {
      setS3Completed(true);
      setS3Loading(false);
    }, 1200);
  };

  const formatS4Time = (totalSeconds: number) => {
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  // Switch to specific child safe state
  const isS1Locked = isAfterHours && role !== 'Parent' && !s1OverrideAccepted;

  return (
    <main className="min-h-screen bg-[#0F172A] text-white flex flex-col font-sans select-none overflow-x-hidden">
      {/* Top Banner Header */}
      <header className="border-b border-slate-800 bg-[#1E293B]/70 backdrop-blur-md sticky top-0 z-50">
        <div className="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="bg-indigo-600 p-2.5 rounded-xl shadow-lg shadow-indigo-500/20">
              <Smartphone className="w-6 h-6 text-white" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-xl font-bold tracking-tight text-white sm:text-2xl">
                  SchooKeep System States
                </h1>
                <span className="bg-indigo-900/60 border border-indigo-700 text-indigo-300 font-extrabold text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-full">
                  iPhone 16 Pro Simulator
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                Interactive mockup presentation highlighting custom safety-critical gates, warnings, and overlays.
              </p>
            </div>
          </div>
          
          <button
            onClick={() => navigate('/')}
            className="bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 hover:border-slate-600 text-xs font-semibold px-4 py-2 rounded-xl transition-all shadow-md active:scale-95 flex items-center gap-1.5"
          >
            <RotateCcw className="w-3.5 h-3.5" /> Return to Map
          </button>
        </div>
      </header>

      {/* Main Interactive Workbench */}
      <div className="flex-1 mx-auto max-w-7xl w-full px-4 py-6 sm:px-6 lg:px-8 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        
        {/* Left Side: Control Deck and Specifications (7 Cols) */}
        <section className="lg:col-span-7 space-y-6">
          
          {/* Active Screen Tab Selector */}
          <div className="bg-[#1E293B] border border-slate-800 rounded-2xl p-4 shadow-xl">
            <h2 className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-3 flex items-center gap-1.5">
              <Sparkles className="w-4 h-4 text-indigo-400" /> Select System State to Demo
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              
              {/* Tab SYS-01 */}
              <button
                onClick={() => setActiveState('SYS-01')}
                className={`flex items-start gap-3 p-3.5 rounded-xl border text-left transition-all ${
                  activeState === 'SYS-01'
                    ? 'bg-indigo-600/10 border-indigo-500 shadow-md'
                    : 'bg-[#151F32] border-slate-800 hover:border-slate-700 hover:bg-slate-800/40'
                }`}
              >
                <div className={`p-2 rounded-lg ${activeState === 'SYS-01' ? 'bg-indigo-600 text-white' : 'bg-slate-800 text-slate-400'}`}>
                  <Lock className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-[13px] font-bold text-white leading-tight">SYS-01 — After-Hours Lock</div>
                  <div className="text-[11px] text-slate-400 mt-1 leading-normal">
                    Applies locks to staff roles after-hours, leaving parents unrestricted. Includes principal code bypass.
                  </div>
                </div>
              </button>

              {/* Tab SYS-02 */}
              <button
                onClick={() => setActiveState('SYS-02')}
                className={`flex items-start gap-3 p-3.5 rounded-xl border text-left transition-all ${
                  activeState === 'SYS-02'
                    ? 'bg-indigo-600/10 border-indigo-500 shadow-md'
                    : 'bg-[#151F32] border-slate-800 hover:border-slate-700 hover:bg-slate-800/40'
                }`}
              >
                <div className={`p-2 rounded-lg ${activeState === 'SYS-02' ? 'bg-indigo-600 text-white' : 'bg-slate-800 text-slate-400'}`}>
                  <AlertTriangle className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-[13px] font-bold text-white leading-tight">SYS-02 — AQI/Weather Banner</div>
                  <div className="text-[11px] text-slate-400 mt-1 leading-normal">
                    Active top-pinned advisory banner. Opens custom bottom sheets detailing restricted students or parental reassurance.
                  </div>
                </div>
              </button>

              {/* Tab SYS-03 */}
              <button
                onClick={() => setActiveState('SYS-03')}
                className={`flex items-start gap-3 p-3.5 rounded-xl border text-left transition-all ${
                  activeState === 'SYS-03'
                    ? 'bg-indigo-600/10 border-indigo-500 shadow-md'
                    : 'bg-[#151F32] border-slate-800 hover:border-slate-700 hover:bg-slate-800/40'
                }`}
              >
                <div className={`p-2 rounded-lg ${activeState === 'SYS-03' ? 'bg-indigo-600 text-white' : 'bg-slate-800 text-slate-400'}`}>
                  <FileCheck2 className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-[13px] font-bold text-white leading-tight">SYS-03 — Onboarding Consent</div>
                  <div className="text-[11px] text-slate-400 mt-1 leading-normal">
                    Amber border pending card placed at top of parent home. Blurs and locks all features until complete.
                  </div>
                </div>
              </button>

              {/* Tab SYS-04 */}
              <button
                onClick={() => setActiveState('SYS-04')}
                className={`flex items-start gap-3 p-3.5 rounded-xl border text-left transition-all ${
                  activeState === 'SYS-04'
                    ? 'bg-indigo-600/10 border-indigo-500 shadow-md'
                    : 'bg-[#151F32] border-slate-800 hover:border-slate-700 hover:bg-slate-800/40'
                }`}
              >
                <div className={`p-2 rounded-lg ${activeState === 'SYS-04' ? 'bg-indigo-600 text-white' : 'bg-slate-800 text-slate-400'}`}>
                  <Clock className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-[13px] font-bold text-white leading-tight">SYS-04 — Session Timeout</div>
                  <div className="text-[11px] text-slate-400 mt-1 leading-normal">
                    A slide-up HIPAA warning sheet ticking down to auto-logout for clinical and administrative staff.
                  </div>
                </div>
              </button>

              {/* Tab SYS-05 */}
              <button
                onClick={() => {
                  setActiveState('SYS-05');
                  localStorage.setItem('sys_ramadan_active', 'true');
                  window.dispatchEvent(new Event('ramadan_state_change'));
                }}
                className={`flex items-start gap-3 p-3.5 rounded-xl border text-left transition-all ${
                  activeState === 'SYS-05'
                    ? 'bg-indigo-600/10 border-indigo-500 shadow-md'
                    : 'bg-[#151F32] border-slate-800 hover:border-slate-700 hover:bg-slate-800/40'
                }`}
              >
                <div className={`p-2 rounded-lg ${activeState === 'SYS-05' ? 'bg-indigo-600 text-white' : 'bg-slate-800 text-slate-400'}`}>
                  <Moon className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-[13px] font-bold text-white leading-tight">SYS-05 — Ramadan Mode</div>
                  <div className="text-[11px] text-slate-400 mt-1 leading-normal">
                    Compressed school day timings, persistent alert banners, and rescheduled clinical dose reminders.
                  </div>
                </div>
              </button>

            </div>
          </div>


          {/* Simulation Controllers (Interactive Options) */}
          <div className="bg-[#1E293B] border border-slate-800 rounded-2xl p-5 shadow-xl space-y-4">
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1.5">
              <Settings className="w-4 h-4 text-indigo-400" /> Interactive Sandbox Settings
            </h3>
            
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              
              {/* Role Switcher (Active for states that distinguish roles) */}
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                  Demonstrate User Role:
                </label>
                <div className="relative">
                  <select
                    value={role}
                    disabled={activeState === 'SYS-03'} // SYS-03 is strictly for parents
                    onChange={(e) => setRole(e.target.value as any)}
                    className="w-full bg-[#151F32] text-xs text-white border border-slate-700 rounded-xl px-3.5 py-2.5 outline-none focus:border-indigo-500 disabled:opacity-50 transition-all"
                  >
                    <option value="Nurse">School Nurse (Clinical Staff)</option>
                    <option value="Teacher">Teacher (Academic Staff)</option>
                    <option value="Counselor">Counselor (Clinical Staff)</option>
                    <option value="Parent">Parent / Guardian (Non-Staff)</option>
                  </select>
                </div>
                {activeState === 'SYS-03' && (
                  <span className="text-[10px] text-slate-500 font-medium block mt-1">
                    * Consent pending is restricted to Parent home dashboard.
                  </span>
                )}
              </div>

              {/* State Specific Sandbox Actions */}
              <div className="flex flex-col justify-end">
                {activeState === 'SYS-01' && (
                  <div className="space-y-2">
                    <label className="block text-xs font-semibold text-slate-300">
                      Time Context:
                    </label>
                    <div className="flex gap-2">
                      <button
                        onClick={() => {
                          setIsAfterHours(true);
                          setS1OverrideAccepted(false);
                          setS1BypassCode('');
                          setS1Error('');
                        }}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          isAfterHours ? 'bg-indigo-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        After-Hours (Lock)
                      </button>
                      <button
                        onClick={() => setIsAfterHours(false)}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          !isAfterHours ? 'bg-indigo-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        School Hours (Open)
                      </button>
                    </div>
                  </div>
                )}

                {activeState === 'SYS-02' && (
                  <div className="space-y-2">
                    <label className="block text-xs font-semibold text-slate-300">
                      Banner State:
                    </label>
                    <div className="flex gap-2">
                      <button
                        onClick={() => setS2BannerVisible(true)}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          s2BannerVisible ? 'bg-indigo-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        Active Banner
                      </button>
                      <button
                        onClick={() => setS2BannerVisible(false)}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          !s2BannerVisible ? 'bg-indigo-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        Dismissed
                      </button>
                    </div>
                  </div>
                )}

                {activeState === 'SYS-03' && (
                  <div className="space-y-2">
                    <label className="block text-xs font-semibold text-slate-300">
                      Profile Status:
                    </label>
                    <div className="flex gap-2">
                      <button
                        onClick={() => {
                          setS3Completed(false);
                          setS3Loading(false);
                        }}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          !s3Completed ? 'bg-indigo-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        Setup Incomplete
                      </button>
                      <button
                        onClick={() => setS3Completed(true)}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          s3Completed ? 'bg-indigo-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        Fully Activated
                      </button>
                    </div>
                  </div>
                )}

                {activeState === 'SYS-04' && (
                  <div className="space-y-2">
                    <label className="block text-xs font-semibold text-slate-300">
                      Timer Sandbox:
                    </label>
                    <div className="flex gap-2">
                      <button
                        onClick={() => {
                          setS4SecondsLeft(300);
                          setS4SessionState('warning');
                          setS4WarningOpen(true);
                        }}
                        className="flex-1 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 text-[11px] font-bold py-2 rounded-lg transition-all active:scale-95"
                      >
                        Reset to 05:00
                      </button>
                      <button
                        onClick={() => setS4IsAccelerated(!s4IsAccelerated)}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          s4IsAccelerated ? 'bg-rose-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        {s4IsAccelerated ? 'Normal Speed' : 'Accelerate Timer'}
                      </button>
                    </div>
                  </div>
                )}

                {activeState === 'SYS-05' && (
                  <div className="space-y-2">
                    <label className="block text-xs font-semibold text-slate-300">
                      Ramadan Mode:
                    </label>
                    <div className="flex gap-2">
                      <button
                        onClick={() => {
                          setS5RamadanActive(true);
                          localStorage.setItem('sys_ramadan_active', 'true');
                          window.dispatchEvent(new Event('ramadan_state_change'));
                        }}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          s5RamadanActive ? 'bg-indigo-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        Active Mode (SYS-05)
                      </button>
                      <button
                        onClick={() => {
                          setS5RamadanActive(false);
                          localStorage.setItem('sys_ramadan_active', 'false');
                          window.dispatchEvent(new Event('ramadan_state_change'));
                        }}
                        className={`flex-1 text-[11px] font-bold py-2 rounded-lg transition-all ${
                          !s5RamadanActive ? 'bg-indigo-600 text-white' : 'bg-[#151F32] text-slate-400 border border-slate-700'
                        }`}
                      >
                        Standard Hours
                      </button>
                    </div>
                  </div>
                )}
              </div>


            </div>
          </div>

          {/* High-Fidelity Technical Specifications Sheet */}
          <div className="bg-[#1E293B] border border-slate-800 rounded-2xl p-5 shadow-xl space-y-4">
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1.5">
              <HelpCircle className="w-4 h-4 text-indigo-400" /> UI Component Specifications
            </h3>
            
            {activeState === 'SYS-01' && (
              <div className="space-y-3.5 text-xs text-slate-300 animate-fade-in">
                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">DARK OVERLAY</span>
                    <span className="font-mono text-indigo-400">rgba(0, 0, 0, 0.85)</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">CENTER CARD</span>
                    <span className="text-indigo-400">320px wide • 12px radius</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">LOCK ICON COLOR</span>
                    <span className="font-mono text-indigo-400">#64748B</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">TYPOGRAPHY</span>
                    <span className="text-indigo-400">20px 500 #0F172A</span>
                  </div>
                </div>
                <div className="bg-slate-800/40 rounded-xl p-3.5 border border-slate-800 space-y-2">
                  <h4 className="font-bold text-slate-200">Role-Based Access Governance:</h4>
                  <p className="text-[11px] leading-relaxed text-slate-400">
                    - **Staff Roles** (Nurse, Teacher, Counselor, Secretary) are entirely locked after-hours. They can temporarily bypass this using a valid authorization code signed by the Principal.
                  </p>
                  <p className="text-[11px] leading-relaxed text-slate-400">
                    - **Parent Roles** are never locked. Parents have unrestricted 24/7 access to review clinic logs, medication compliance, and emergency pickup codes.
                  </p>
                </div>
              </div>
            )}

            {activeState === 'SYS-02' && (
              <div className="space-y-3.5 text-xs text-slate-300 animate-fade-in">
                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">BANNER HEIGHT</span>
                    <span className="text-indigo-400">48px pinned banner</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">BANNER DESIGN</span>
                    <span className="text-indigo-400">Amber warning + X dismiss</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">STAFF ACTION</span>
                    <span className="text-indigo-400">List of restricted students</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">PARENT ACTION</span>
                    <span className="text-indigo-400">"Child safe indoors" assurance</span>
                  </div>
                </div>
                <div className="bg-slate-800/40 rounded-xl p-3.5 border border-slate-800 space-y-2">
                  <h4 className="font-bold text-slate-200">Interactive Features:</h4>
                  <p className="text-[11px] leading-relaxed text-slate-400">
                    Tapping the weather alert banner triggers a secure sliding drawer bottom sheet from the baseline, ensuring immediate details are rendered in-context without disrupting active workflows.
                  </p>
                </div>
              </div>
            )}

            {activeState === 'SYS-03' && (
              <div className="space-y-3.5 text-xs text-slate-300 animate-fade-in">
                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">CARD DESIGN</span>
                    <span className="text-indigo-400">Amber border + checklist</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">PROGRESS BAR</span>
                    <span className="text-indigo-400">Calculates completed steps %</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">PRIMARY ACTION</span>
                    <span className="text-indigo-400">"Complete setup" primary button</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">FEATURE GATING</span>
                    <span className="text-indigo-400">Heavy blur + lock overlays below</span>
                  </div>
                </div>
                <div className="bg-slate-800/40 rounded-xl p-3.5 border border-slate-800 space-y-2">
                  <h4 className="font-bold text-slate-200">Gating Rationale:</h4>
                  <p className="text-[11px] leading-relaxed text-slate-400">
                    Protects student medical records by blocking access until legal consent forms and immunization records are verified. The blur provides visual interest and motivation to complete onboarding.
                  </p>
                </div>
              </div>
            )}

            {activeState === 'SYS-04' && (
              <div className="space-y-3.5 text-xs text-slate-300 animate-fade-in">
                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">WARNING THRESHOLD</span>
                    <span className="text-indigo-400">5 minutes prior to expiry</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">DIGITAL TIMER</span>
                    <span className="font-mono text-indigo-400">MM:SS active ticking clock</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">PRIMARY BUTTON</span>
                    <span className="text-indigo-400">"Stay signed in" resets session</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">SECONDARY BUTTON</span>
                    <span className="text-indigo-400">"Sign out" handles immediate logout</span>
                  </div>
                </div>
                <div className="bg-slate-800/40 rounded-xl p-3.5 border border-slate-800 space-y-2">
                  <h4 className="font-bold text-slate-200">HIPAA & Security Compliance:</h4>
                  <p className="text-[11px] leading-relaxed text-slate-400">
                    Automatic clinical session expiry prevents unauthorized access to protected health information (PHI) on unattended school terminals.
                  </p>
                </div>
              </div>
            )}

            {activeState === 'SYS-05' && (
              <div className="space-y-3.5 text-xs text-slate-300 animate-fade-in">
                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">SCHOOL HOURS</span>
                    <span className="font-mono text-indigo-400">08:00 AM - 01:30 PM</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">PERSISTENT ALERT</span>
                    <span className="text-indigo-400">Bilingual banner at top of viewport</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">DISMISS TO PILL</span>
                    <span className="text-indigo-400">Collapses to crescent moon in corner</span>
                  </div>
                  <div className="bg-[#151F32] p-3 rounded-xl border border-slate-800">
                    <span className="text-[10px] text-slate-500 font-bold block mb-1">CLINICAL SLA</span>
                    <span className="text-indigo-400">Prompts nurses to review timings</span>
                  </div>
                </div>
                <div className="bg-slate-800/40 rounded-xl p-3.5 border border-slate-800 space-y-2">
                  <h4 className="font-bold text-slate-200">Ramadan Mode active guidelines:</h4>
                  <p className="text-[11px] leading-relaxed text-slate-400">
                    - Compressed school hours apply school-wide. Any medication schedules falling outside these hours are flagged for rescheduling.
                  </p>
                  <p className="text-[11px] leading-relaxed text-slate-400">
                    - The persistent banner alert serves to keep clinical staff aligned on daily dose timings.
                  </p>
                </div>
              </div>
            )}


          </div>

        </section>

        {/* Right Side: Immersive iPhone 16 Pro Simulator (5 Cols) */}
        <section className="lg:col-span-5 flex justify-center sticky top-24">
          <div className="relative">
            
            {/* iPhone 16 Pro Device Frame Container */}
            <div className="relative w-[393px] h-[852px] bg-slate-900 rounded-[54px] shadow-[0_25px_60px_-15px_rgba(0,0,0,0.8)] border-[12px] border-slate-950 overflow-hidden flex flex-col text-slate-800 select-none">
              
              {/* Dynamic Island */}
              <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[110px] h-[30px] bg-black rounded-b-[18px] z-50 flex items-center justify-center">
                <div className="w-3 h-3 rounded-full bg-slate-950 ml-6" />
              </div>

              {/* Status Bar */}
              <div className="h-[44px] flex items-center justify-between px-6 text-slate-800 text-[13px] font-semibold select-none z-40 bg-white border-b border-slate-100 flex-shrink-0">
                <span className="font-medium">
                  {activeState === 'SYS-01' ? '7:15 PM' : activeState === 'SYS-04' ? '3:35 PM' : '10:45 AM'}
                </span>
                <div className="flex items-center gap-1.5">
                  <svg className="w-4.5 h-4.5 fill-slate-800" viewBox="0 0 24 24"><path d="M12 3c-4.97 0-9 4.03-9 9 0 2.12.74 4.07 1.97 5.61L4.35 19.4c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l1.9-1.9C9.13 19.57 10.5 20 12 20c4.97 0 9-4.03 9-9s-4.03-9-9-9zm0 15c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/></svg>
                  <span className="text-[10px]">5G</span>
                  <div className="w-[20px] h-[10px] border border-slate-800 rounded-[3px] p-[1px] flex items-center">
                    <div className="w-[14px] h-[6px] bg-slate-800 rounded-[1.5px]" />
                  </div>
                </div>
              </div>

              {/* Dynamic Viewport Content Switcher */}
              <div className="flex-1 flex flex-col relative bg-slate-50 overflow-hidden">
                
                {/* -------------------- STATE 1 AFTER-HOURS LOCK -------------------- */}
                {activeState === 'SYS-01' && (
                  <div className="flex-1 flex flex-col relative bg-slate-100">
                    {/* Simulated Background Dashboard */}
                    <div className="flex-1 flex flex-col p-4 bg-slate-50 filter blur-[2.5px] transition-all duration-300 select-none">
                      <div className="h-10 bg-indigo-600 rounded-lg mb-4 flex items-center px-3 text-white font-bold text-sm">
                        SchooKeep Dashboard
                      </div>
                      <div className="flex-1 space-y-3">
                        <div className="h-28 bg-white border border-slate-200 rounded-xl p-3 shadow-sm" />
                        <div className="grid grid-cols-2 gap-3">
                          <div className="h-24 bg-white border border-slate-200 rounded-xl p-3 shadow-sm" />
                          <div className="h-24 bg-white border border-slate-200 rounded-xl p-3 shadow-sm" />
                        </div>
                        <div className="h-36 bg-white border border-slate-200 rounded-xl p-3 shadow-sm" />
                      </div>
                    </div>

                    {/* Dark Overlay rgba(0,0,0,0.85) */}
                    {isS1Locked ? (
                      <div className="absolute inset-0 bg-black/85 z-40 flex flex-col items-center justify-center p-6 animate-fade-in">
                        <div className="bg-white w-[320px] rounded-[12px] p-6 shadow-2xl flex flex-col items-center text-center animate-scale-in">
                          
                          {/* Lock Icon */}
                          <div className="w-16 h-16 rounded-full bg-slate-50 flex items-center justify-center mb-4 border border-slate-100">
                            <Lock className="w-[48px] h-[48px] text-[#64748B]" />
                          </div>

                          {/* Lock Heading */}
                          <h3 className="text-[20px] font-medium text-[#0F172A] tracking-tight leading-6 mb-3">
                            System Locked
                          </h3>

                          {/* Description */}
                          <p className="text-[13px] leading-5 text-slate-500 mb-4 px-1">
                            SchooKeep is only accessible during school hours (Mon–Fri, 7:30 AM – 5:00 PM).
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

                          {/* Emergency Section */}
                          <form onSubmit={handleS1Submit} className="w-full text-left space-y-3">
                            <div className="text-[11px] font-medium text-slate-500 uppercase tracking-wider">
                              Emergency Exception
                            </div>
                            <div className="text-[12px] text-slate-600 leading-4">
                              If you have an emergency authorization code from your Principal, enter it below:
                            </div>
                            <div className="space-y-2">
                              <input
                                type="password"
                                value={s1BypassCode}
                                onChange={(e) => setS1BypassCode(e.target.value)}
                                placeholder="Enter emergency code"
                                className="w-full border border-slate-200 rounded-lg px-3 py-2 text-[14px] text-slate-900 bg-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-400 focus:border-transparent transition-all"
                              />
                              {s1Error && (
                                <p className="text-[11px] text-rose-500 font-medium leading-tight">
                                  {s1Error}
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
                              Demo bypass code: <span className="font-bold text-slate-500">9999</span>
                            </div>
                          </form>
                        </div>
                      </div>
                    ) : (
                      /* Unlocked state display */
                      <div className="absolute inset-0 bg-transparent z-40 flex flex-col items-center justify-center p-6 bg-slate-950/10">
                        <div className="bg-emerald-50/95 backdrop-blur-md border border-emerald-200 w-[320px] rounded-[12px] p-5 shadow-2xl text-center animate-scale-in">
                          <div className="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-3">
                            <ShieldCheck className="w-6 h-6 text-emerald-600" />
                          </div>
                          <h3 className="text-[16px] font-semibold text-emerald-900 mb-1">
                            {role === 'Parent' ? 'Parent Portal Unlocked' : 'Bypass Override Success!'}
                          </h3>
                          <p className="text-[12px] leading-5 text-emerald-700">
                            {role === 'Parent'
                              ? 'Parents have persistent 24/7 access to student health records. The security lock is automatically bypassed.'
                              : 'Bypass authorization granted. School hours constraint bypassed.'}
                          </p>
                          <button
                            onClick={() => {
                              setS1OverrideAccepted(false);
                              setIsAfterHours(true);
                              setS1BypassCode('');
                            }}
                            className="mt-4 w-full bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold py-2 px-4 rounded-lg transition-all active:scale-95 shadow-sm"
                          >
                            Re-lock Simulator
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                )}

                {/* -------------------- STATE 2 WEATHER ADVISORY BANNER -------------------- */}
                {activeState === 'SYS-02' && (
                  <div className="flex-1 flex flex-col relative bg-slate-50 select-none">
                    
                    {/* Top Pinned Banner (below app bar) */}
                    {s2BannerVisible && (
                      <div
                        onClick={() => setS2BottomSheetOpen(true)}
                        className="h-[48px] bg-[#FEF3C7] border-b border-[#F59E0B] px-3 flex items-center justify-between gap-2 cursor-pointer hover:bg-[#FDE68A] transition-all flex-shrink-0 z-30 select-none animate-slide-down"
                      >
                        <div className="flex items-center gap-2 min-w-0">
                          {/* warning triangle icon */}
                          <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 animate-bounce" />
                          {/* Center: text */}
                          <span className="text-[13px] font-semibold text-[#92400E] truncate">
                            AQI Advisory Active — Tap for details
                          </span>
                        </div>
                        {/* Right: X dismiss */}
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setS2BannerVisible(false);
                          }}
                          className="w-8 h-8 -mr-1 rounded-full flex items-center justify-center hover:bg-amber-200/50 text-[#92400E] transition-colors"
                        >
                          <X className="w-4 h-4" />
                        </button>
                      </div>
                    )}

                    {/* Background Simulated App Layout */}
                    <div className="flex-1 p-4 space-y-4">
                      <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-2">
                        <div className="text-xs font-bold text-slate-400 uppercase tracking-widest">Active Alerts</div>
                        <div className="h-6 bg-slate-100 rounded w-1/2" />
                        <div className="h-16 bg-slate-100 rounded" />
                      </div>
                    </div>

                    {/* Bottom Sheet Backdrop */}
                    {s2BottomSheetOpen && (
                      <div
                        onClick={() => setS2BottomSheetOpen(false)}
                        className="absolute inset-0 bg-black/60 z-40 transition-opacity duration-300 animate-fade-in"
                      />
                    )}

                    {/* Bottom Sheet Slider */}
                    <div
                      className={`absolute bottom-0 left-0 right-0 bg-white rounded-t-[20px] shadow-2xl border-t border-slate-200 z-50 transition-transform duration-300 ease-out pb-8 ${
                        s2BottomSheetOpen ? 'translate-y-0' : 'translate-y-full'
                      }`}
                    >
                      {/* Handle grabber */}
                      <div className="w-12 h-1.5 bg-slate-300 rounded-full mx-auto my-3" />

                      <div className="px-5 space-y-4">
                        <div className="flex items-start justify-between">
                          <div>
                            <span className="bg-rose-100 text-rose-700 font-bold text-[10px] uppercase px-2.5 py-0.5 rounded-full">
                              AQI 156 • Unhealthy
                            </span>
                            <h3 className="text-lg font-bold text-slate-900 mt-1">AQI Advisory Details</h3>
                          </div>
                          <button
                            onClick={() => setS2BottomSheetOpen(false)}
                            className="w-7 h-7 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 hover:bg-slate-200 transition-colors"
                          >
                            <X className="w-4 h-4" />
                          </button>
                        </div>

                        {/* Dynamic content depending on role */}
                        {role === 'Parent' ? (
                          /* Parent: "Your child is safe indoors" */
                          <div className="bg-[#ECFDF5] border border-[#10B981] rounded-xl p-4 space-y-2 animate-scale-in text-left">
                            <div className="flex items-center gap-2">
                              <Smile className="w-5 h-5 text-emerald-600 flex-shrink-0" />
                              <h4 className="text-[13px] font-bold text-[#065F46]">
                                Your child is safe indoors
                              </h4>
                            </div>
                            <p className="text-[11px] leading-relaxed text-[#065F46]">
                              <strong>Maya Thompson</strong> (4th Grade) is currently safe inside Room 204. Out-of-door recess and high-intensity PE activities are suspended due to AQI.
                            </p>
                          </div>
                        ) : (
                          /* Nurse/Teacher: Restricted Students List */
                          <div className="space-y-3 text-left animate-scale-in">
                            <h4 className="text-[12px] font-bold text-slate-800 flex items-center gap-1.5">
                              <ShieldAlert className="w-4 h-4 text-rose-500" />
                              Restricted Students:
                            </h4>
                            <div className="max-h-[180px] overflow-y-auto space-y-2 pr-1 scrollbar-hide">
                              <div className="bg-slate-50 border border-slate-200 rounded-lg p-2.5">
                                <div className="flex justify-between font-bold text-[11px]">
                                  <span>Maya Thompson</span>
                                  <span className="text-rose-600 font-extrabold text-[9px] bg-rose-50 px-1.5 py-0.5 rounded">Asthma</span>
                                </div>
                                <p className="text-[10px] text-slate-500 mt-1">Requires albuterol prior to physical activity.</p>
                              </div>
                              <div className="bg-slate-50 border border-slate-200 rounded-lg p-2.5">
                                <div className="flex justify-between font-bold text-[11px]">
                                  <span>Liam Carter</span>
                                  <span className="text-rose-600 font-extrabold text-[9px] bg-rose-50 px-1.5 py-0.5 rounded">Allergies</span>
                                </div>
                                <p className="text-[10px] text-slate-500 mt-1">Avoid high grass pollen and exposure over 150 AQI.</p>
                              </div>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>

                  </div>
                )}

                {/* -------------------- STATE 3 CONSENT PENDING GATE -------------------- */}
                {activeState === 'SYS-03' && (
                  <div className="flex-1 flex flex-col relative bg-slate-50 select-none">
                    
                    {/* Page Content */}
                    <div className="flex-1 overflow-y-auto p-4 space-y-4">
                      
                      {/* Onboarding Gate Amber Card */}
                      {!s3Completed ? (
                        <div className="bg-[#FFFBEB] border-2 border-[#F59E0B] rounded-xl p-4 shadow-sm animate-slide-down text-left">
                          <div className="flex items-start gap-2.5 mb-3">
                            <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
                            <div>
                              <h3 className="text-[14px] font-bold text-[#92400E]">
                                Your child's health profile is not yet active
                              </h3>
                              <p className="text-[10px] text-[#B45309] mt-0.5">
                                Onboarding setup incomplete. Please respond to the medical consent.
                              </p>
                            </div>
                          </div>

                          {/* Progress bar */}
                          <div className="space-y-1 mb-3 bg-white/50 p-2.5 rounded-lg border border-amber-200/50">
                            <div className="flex justify-between text-[11px] font-bold text-[#92400E]">
                              <span>Onboarding Progress</span>
                              <span>3 of 5 steps completed</span>
                            </div>
                            <div className="w-full bg-amber-200/40 h-2 rounded-full overflow-hidden">
                              <div className="bg-[#F59E0B] h-full rounded-full w-[60%]" />
                            </div>
                          </div>

                          {/* Primary Button */}
                          <button
                            onClick={handleS3Complete}
                            disabled={s3Loading}
                            className="w-full bg-[#F59E0B] hover:bg-[#D97706] text-white font-bold text-[13px] py-2 px-4 rounded-lg flex items-center justify-center gap-1.5 transition-all active:scale-[0.98] shadow-sm disabled:bg-amber-300"
                          >
                            {s3Loading ? (
                              <>
                                <div className="w-4 h-4 border-2 border-white/50 border-t-white rounded-full animate-spin" />
                                Synchronizing medical keys...
                              </>
                            ) : (
                              <>
                                Complete setup <ArrowRight className="w-4 h-4" />
                              </>
                            )}
                          </button>
                        </div>
                      ) : (
                        /* Success Panel */
                        <div className="bg-[#ECFDF5] border border-emerald-300 rounded-xl p-4 shadow-sm flex items-center gap-3 animate-scale-in text-left">
                          <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 flex-shrink-0">
                            <ShieldCheck className="w-6 h-6" />
                          </div>
                          <div>
                            <h3 className="text-xs font-bold text-emerald-950">Setup Complete!</h3>
                            <p className="text-[10px] text-emerald-600 leading-normal mt-0.5">
                              Health records are successfully validated. Dashboard is now fully active.
                            </p>
                          </div>
                        </div>
                      )}

                      {/* Parent dashboard beneath (Blurred and locked if incomplete) */}
                      <div className="relative">
                        <div className={`space-y-3 text-left transition-all duration-500 ${!s3Completed ? 'blur-[3.5px] pointer-events-none opacity-40 select-none' : ''}`}>
                          <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-2">
                            <h4 className="text-xs font-bold text-slate-800">Current Medications</h4>
                            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100 text-xs font-semibold text-slate-600">
                              Ritalin 10mg • 1 Dose Remaining
                            </div>
                          </div>
                          <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-2">
                            <h4 className="text-xs font-bold text-slate-800">Recent Activity</h4>
                            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100 text-[11px] text-slate-500">
                              No recent clinic visits this week.
                            </div>
                          </div>
                        </div>

                        {/* Lock Overlay */}
                        {!s3Completed && (
                          <div className="absolute inset-0 bg-transparent flex flex-col items-center justify-center text-center p-4">
                            <Lock className="w-5 h-5 text-slate-800 mb-1" />
                            <span className="text-xs font-bold text-slate-800">Section Locked</span>
                            <span className="text-[10px] text-slate-500 max-w-[180px] leading-tight mt-0.5">
                              Please respond to emergency medical consents to view records.
                            </span>
                          </div>
                        )}
                      </div>

                    </div>

                  </div>
                )}

                {/* -------------------- STATE 4 SESSION TIMEOUT WARNING -------------------- */}
                {activeState === 'SYS-04' && (
                  <div className="flex-1 flex flex-col relative bg-slate-50 select-none">
                    
                    {/* Simulated Background Dashboard */}
                    <div className="flex-1 p-4 space-y-4">
                      {s4SessionState === 'active' && (
                        <div className="bg-emerald-50 border border-emerald-300 rounded-xl p-3.5 shadow-sm flex items-center gap-3 animate-scale-in text-left">
                          <ShieldCheck className="w-5 h-5 text-emerald-600 flex-shrink-0" />
                          <div>
                            <h4 className="text-xs font-bold text-emerald-900">Session Renewed Successfully</h4>
                            <p className="text-[10px] text-emerald-700 leading-normal">
                              Your clinical workspace remains active. Next check in 15m.
                            </p>
                          </div>
                        </div>
                      )}

                      {s4SessionState === 'expired' && (
                        <div className="bg-rose-50 border border-rose-300 rounded-xl p-3.5 shadow-sm flex items-center gap-3 animate-scale-in text-left">
                          <RefreshCw className="w-5 h-5 text-rose-600 flex-shrink-0 animate-spin" />
                          <div>
                            <h4 className="text-xs font-bold text-rose-900">Session Expired</h4>
                            <p className="text-[10px] text-rose-700 leading-normal">
                              Securely logging out...
                            </p>
                          </div>
                        </div>
                      )}

                      <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-3">
                        <div className="h-6 bg-slate-100 rounded w-1/3" />
                        <div className="h-20 bg-slate-100 rounded" />
                      </div>
                    </div>

                    {/* Bottom Sheet Backdrop */}
                    {s4WarningOpen && (
                      <div
                        onClick={handleStaySignedIn}
                        className="absolute inset-0 bg-black/60 z-40 transition-opacity duration-300 animate-fade-in"
                      />
                    )}

                    {/* Bottom Sheet Warning */}
                    <div
                      className={`absolute bottom-0 left-0 right-0 bg-white rounded-t-[20px] shadow-2xl border-t border-slate-200 z-50 transition-transform duration-300 ease-out pb-8 ${
                        s4WarningOpen ? 'translate-y-0' : 'translate-y-full'
                      }`}
                    >
                      {/* Bottom Sheet Grabber */}
                      <div className="w-12 h-1.5 bg-slate-300 rounded-full mx-auto my-3" />

                      <div className="px-5 space-y-4">
                        <div className="flex items-start justify-between">
                          <div className="flex items-center gap-2 bg-rose-50 border border-rose-200 px-3 py-1 rounded-full text-rose-700 font-bold text-[10px] uppercase">
                            <Clock className="w-3.5 h-3.5 text-rose-500 animate-pulse" />
                            <span>Security Timeout</span>
                          </div>
                          <button
                            onClick={handleStaySignedIn}
                            className="w-7 h-7 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 hover:bg-slate-200 transition-colors"
                          >
                            <X className="w-4 h-4" />
                          </button>
                        </div>

                        <div className="space-y-1 text-left">
                          <h3 className="text-md font-bold text-slate-900 leading-snug">
                            Your session will expire in 5 minutes due to inactivity.
                          </h3>
                          <p className="text-[11px] text-slate-500 leading-normal">
                            Clinical operations automatically shut down to prevent HIPAA breaches on unattended devices.
                          </p>
                        </div>

                        {/* Digital Timer */}
                        <div className="bg-slate-950 text-white rounded-xl p-3 flex flex-col items-center justify-center border border-slate-800 shadow-inner">
                          <div className="text-[9px] font-bold text-rose-500 uppercase tracking-widest mb-0.5">
                            Auto-Logout Countdown
                          </div>
                          <div className="font-mono text-[32px] font-semibold leading-none tracking-wider text-rose-400">
                            {formatS4Time(s4SecondsLeft)}
                          </div>
                        </div>

                        {/* Action buttons */}
                        <div className="space-y-2 pt-1.5">
                          <button
                            onClick={handleStaySignedIn}
                            className="w-full bg-[#2563EB] hover:bg-[#1D4ED8] text-white font-bold text-[13px] py-2.5 px-4 rounded-xl flex items-center justify-center transition-all active:scale-[0.98] shadow-md"
                          >
                            Stay signed in
                          </button>
                          <button
                            onClick={handleSignOut}
                            className="w-full bg-white hover:bg-slate-50 text-slate-700 border border-slate-200 font-bold text-[13px] py-2.5 px-4 rounded-xl flex items-center justify-center gap-1.5 transition-all active:scale-[0.98] shadow-sm"
                          >
                            Sign out
                          </button>
                        </div>
                      </div>
                    </div>

                  </div>
                )}

                {/* -------------------- STATE 5 RAMADAN MODE ACTIVE -------------------- */}
                {activeState === 'SYS-05' && (
                  <div className="flex-1 flex flex-col relative bg-slate-50 text-left">
                    
                    {/* Simulated Ramadan Banner Overlay inside simulator */}
                    {s5RamadanActive && (
                      <div className="bg-[#FFFBEB] border-b border-[#F59E0B] p-3 flex items-start gap-2 text-left z-30 select-none animate-slide-down">
                        <div className="w-6 h-6 rounded-full bg-[#FEF3C7] flex items-center justify-center text-amber-600 flex-shrink-0">
                          <Moon className="w-3.5 h-3.5 fill-current" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[11px] font-bold text-[#92400E] leading-tight">
                            Ramadan Mubarak · رمضان كريم
                          </h4>
                          <p className="text-[9px] text-[#64748B]">
                            Modified school hours: 08:00 AM – 1:30 PM
                          </p>
                        </div>
                      </div>
                    )}

                    {/* Simulated Background Dashboard */}
                    <div className="flex-1 p-4 space-y-3.5 overflow-y-auto">
                      <div className="flex items-center justify-between">
                        <h4 className="text-xs font-bold text-gray-900">School Clinic Dashboard</h4>
                        <span className="text-[10px] font-bold text-[#0D9488] bg-[#0D9488]/10 px-2 py-0.5 rounded border border-[#0D9488]/30">
                          DHA COMPLIANT
                        </span>
                      </div>

                      {/* Warning Callout Box */}
                      {s5RamadanActive && (
                        <div className="bg-[#FEF2F2] border border-[#FECACA] rounded-xl p-3 space-y-2">
                          <div className="flex items-start gap-2 text-[11px] font-semibold text-[#991B1B]">
                            <Clock className="w-4.5 h-4.5 text-red-500 flex-shrink-0 mt-0.5" />
                            <span>Clinical Dose Timing Conflict</span>
                          </div>
                          <p className="text-[10px] text-red-600 leading-relaxed">
                            <strong>Emma Rodriguez</strong> (Ritalin 10mg) is scheduled at 2:00 PM, which falls outside the modified school hours (ends at 1:30 PM).
                          </p>
                          <button
                            onClick={() => alert('Dose successfully rescheduled to 1:00 PM to fall within school hours.')}
                            className="bg-red-600 hover:bg-red-700 text-white font-bold text-[10px] px-3 py-1.5 rounded-lg active:scale-95 transition-all shadow cursor-pointer"
                          >
                            Reschedule to 1:00 PM
                          </button>
                        </div>
                      )}

                      <div className="bg-white rounded-xl border border-slate-200 p-3 shadow-sm space-y-2.5 text-left">
                        <h4 className="text-[11px] font-bold text-slate-800 uppercase tracking-wider">Today's Queue</h4>
                        <div className="flex justify-between items-center text-xs p-2 bg-slate-50 rounded border border-slate-100">
                          <span className="font-semibold text-slate-700">Emma Rodriguez</span>
                          <span className="text-amber-600 font-bold bg-amber-50 px-1.5 py-0.5 rounded border border-amber-200">2:00 PM Dose</span>
                        </div>
                        <div className="flex justify-between items-center text-xs p-2 bg-slate-50 rounded border border-slate-100">
                          <span className="font-semibold text-slate-700">Marcus Chen</span>
                          <span className="text-slate-500 bg-slate-100 px-1.5 py-0.5 rounded">11:30 AM (Done)</span>
                        </div>
                      </div>
                    </div>

                  </div>
                )}

              </div>

              {/* iOS Home swipe indicator */}
              <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 w-[140px] h-[5px] bg-slate-950/20 rounded-full z-50 flex-shrink-0" />
            </div>

            {/* Simulated hardware side buttons for iPhone 16 Pro mockup */}
            <div className="absolute top-[180px] -left-[15px] w-[3px] h-[35px] bg-slate-800 rounded-l" /> {/* Action Button */}
            <div className="absolute top-[230px] -left-[15px] w-[3px] h-[60px] bg-slate-800 rounded-l" /> {/* Volume Up */}
            <div className="absolute top-[300px] -left-[15px] w-[3px] h-[60px] bg-slate-800 rounded-l" /> {/* Volume Down */}
            <div className="absolute top-[250px] -right-[15px] w-[3px] h-[80px] bg-slate-800 rounded-r" /> {/* Power Button */}

          </div>
        </section>

      </div>
    </main>
  );
}
