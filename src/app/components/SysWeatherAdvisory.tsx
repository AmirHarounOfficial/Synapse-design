import React, { useState } from 'react';
import { AlertTriangle, X, CloudDrizzle, Info, ShieldAlert, Sparkles, Smile, Smartphone } from 'lucide-react';
import { useNavigate } from 'react-router';

interface SysWeatherAdvisoryProps {
  standalone?: boolean;
  initialRole?: string;
}

export function SysWeatherAdvisory({ standalone = true, initialRole = 'Nurse' }: SysWeatherAdvisoryProps) {
  const navigate = useNavigate();
  const [role, setRole] = useState<string>(initialRole);
  const [isBannerVisible, setIsBannerVisible] = useState(true);
  const [isBottomSheetOpen, setIsBottomSheetOpen] = useState(false);

  const restrictedStudents = [
    { id: '1', name: 'Maya Thompson', grade: '4th Grade', condition: 'Severe Asthma', room: 'Room 204', note: 'Requires inhaler (Albuterol) prior to physical activity if outdoors.' },
    { id: '2', name: 'Liam Carter', grade: '2nd Grade', condition: 'Severe Grass Allergies', room: 'Room 112', note: 'Avoid dry winds/recess outdoors when AQI exceeds 150.' },
    { id: '3', name: 'Sophia Chen', grade: '5th Grade', condition: 'Exercise-Induced Bronchospasm', room: 'Room 301', note: 'Has active PE waiver for high AQI days.' },
  ];

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col items-center justify-center p-4 select-none">
      {/* Standalone Demo Controls */}
      {standalone && (
        <div className="absolute top-4 left-4 right-4 z-50 bg-slate-800/90 backdrop-blur-md rounded-xl p-3 border border-slate-700 flex flex-col sm:flex-row gap-3 items-center justify-between shadow-xl max-w-md mx-auto">
          <div className="flex items-center gap-2">
            <Smartphone className="w-5 h-5 text-indigo-400" />
            <span className="text-xs font-semibold text-slate-300">SYS-02 Demo Controls</span>
          </div>
          <div className="flex items-center gap-2.5">
            <select
              value={role}
              onChange={(e) => {
                setRole(e.target.value);
                setIsBottomSheetOpen(false);
              }}
              className="bg-slate-700 text-xs text-white border border-slate-600 rounded px-2 py-1 outline-none focus:border-indigo-500"
            >
              <option value="Nurse">School Nurse (Staff View)</option>
              <option value="Teacher">Teacher (Staff View)</option>
              <option value="Parent">Parent (Guardian View)</option>
            </select>
            {!isBannerVisible && (
              <button
                onClick={() => setIsBannerVisible(true)}
                className="bg-indigo-600 hover:bg-indigo-700 text-white text-[11px] font-bold px-2 py-1 rounded transition-all active:scale-95"
              >
                Restore Banner
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
          <span>10:45 AM</span>
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
            {role === 'Parent' ? 'Parent Portal' : 'Synapse Clinical'}
          </h1>
          <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-xs font-semibold text-slate-700">
            {role === 'Parent' ? 'JT' : 'RN'}
          </div>
        </header>

        {/* SCREEN SYS-02 — Weather Advisory Active State Amber Banner (48px) */}
        {isBannerVisible && (
          <div
            onClick={() => setIsBottomSheetOpen(true)}
            className="h-[48px] bg-[#FEF3C7] border-b border-[#F59E0B] px-3 flex items-center justify-between gap-2 cursor-pointer hover:bg-[#FDE68A] transition-all flex-shrink-0 z-30 select-none animate-slide-down"
          >
            <div className="flex items-center gap-2 min-w-0">
              {/* Left: warning triangle icon */}
              <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0" />
              {/* Center: text */}
              <span className="text-[13px] font-semibold text-[#92400E] truncate">
                AQI Advisory Active — Tap for details
              </span>
            </div>
            {/* Right: X dismiss */}
            <button
              onClick={(e) => {
                e.stopPropagation();
                setIsBannerVisible(false);
              }}
              className="w-8 h-8 -mr-1 rounded-full flex items-center justify-center hover:bg-amber-200/50 text-[#92400E] transition-colors"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* Main Simulated App Content */}
        <div className="flex-1 overflow-y-auto p-4 bg-slate-50 space-y-4">
          <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm space-y-3">
            <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2">
              <CloudDrizzle className="w-4 h-4 text-slate-600" />
              Local Conditions
            </h3>
            <div className="grid grid-cols-2 gap-3 text-center">
              <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
                <div className="text-[22px] font-black text-rose-600">156</div>
                <div className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Air Quality (AQI)</div>
              </div>
              <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
                <div className="text-[22px] font-black text-slate-700">84°F</div>
                <div className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Temperature</div>
              </div>
            </div>
            <p className="text-[12px] leading-relaxed text-slate-500">
              Active alert remains in effect for this zip code until 6:00 PM. Indoor protocols are advised for sensitive groups.
            </p>
          </div>

          <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
            <h3 className="text-sm font-bold text-slate-800 mb-2">School Status</h3>
            <div className="flex items-center gap-3">
              <div className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse" />
              <span className="text-xs font-semibold text-slate-600">Indoor Recess Active</span>
            </div>
          </div>
        </div>

        {/* Bottom Sheet Backdrop */}
        {isBottomSheetOpen && (
          <div
            onClick={() => setIsBottomSheetOpen(false)}
            className="absolute inset-0 bg-black/60 z-40 transition-opacity duration-300 animate-fade-in"
          />
        )}

        {/* Bottom Sheet with Details */}
        <div
          className={`absolute bottom-0 left-0 right-0 bg-white rounded-t-[20px] shadow-2xl border-t border-slate-200 z-50 transition-transform duration-300 ease-out pb-8 ${
            isBottomSheetOpen ? 'translate-y-0' : 'translate-y-full'
          }`}
        >
          {/* Bottom Sheet Grabber */}
          <div className="w-12 h-1.5 bg-slate-300 rounded-full mx-auto my-3" />

          <div className="px-5 space-y-4">
            <div className="flex items-start justify-between">
              <div>
                <span className="bg-rose-100 text-rose-700 font-bold text-[10px] uppercase px-2.5 py-0.5 rounded-full">
                  Unhealthy (AQI 156)
                </span>
                <h3 className="text-lg font-bold text-slate-900 mt-1">AQI Advisory Details</h3>
              </div>
              <button
                onClick={() => setIsBottomSheetOpen(false)}
                className="w-7 h-7 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 hover:bg-slate-200 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <p className="text-xs text-slate-500 leading-relaxed">
              Air quality is currently in the **Unhealthy** tier. High levels of fine particulate matter pose risks to respiratory health. All outdoor recess, physical education, and events have been moved indoors.
            </p>

            {/* Role Dynamic Content */}
            {role === 'Parent' ? (
              /* Parent View: "Your child is safe indoors" */
              <div className="bg-[#ECFDF5] border border-[#10B981] rounded-xl p-4 space-y-3 animate-scale-in">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 flex-shrink-0">
                    <Smile className="w-6 h-6" />
                  </div>
                  <div>
                    <h4 className="text-[14px] font-bold text-[#065F46] leading-tight">
                      Your child is safe indoors
                    </h4>
                    <p className="text-[11px] text-[#047857] mt-0.5">
                      Lakeside Elementary Elementary School
                    </p>
                  </div>
                </div>

                <div className="h-px bg-emerald-200/50" />

                <div className="text-[12px] leading-relaxed text-[#065F46] space-y-2">
                  <p>
                    <strong>Maya Thompson (4th Grade)</strong> has been moved indoors. Recess and gym class will take place in the gym.
                  </p>
                  <div className="bg-white/80 rounded-lg p-2.5 border border-emerald-100 flex items-start gap-2">
                    <Info className="w-4 h-4 text-emerald-600 flex-shrink-0 mt-0.5" />
                    <p className="text-[11px] text-[#065F46]">
                      School health team is monitoring air circulation systems, and inhaler access is prepared in the clinic.
                    </p>
                  </div>
                </div>
              </div>
            ) : (
              /* Nurse/Teacher View: Restricted Students List */
              <div className="space-y-3 animate-scale-in">
                <div className="flex items-center justify-between">
                  <h4 className="text-[13px] font-bold text-slate-800 flex items-center gap-1.5">
                    <ShieldAlert className="w-4 h-4 text-rose-500" />
                    Restricted Students ({restrictedStudents.length})
                  </h4>
                  <span className="text-[10px] bg-slate-100 text-slate-600 font-semibold px-2 py-0.5 rounded">
                    My Classrooms
                  </span>
                </div>

                <div className="max-h-[220px] overflow-y-auto space-y-2.5 pr-1 scrollbar-hide">
                  {restrictedStudents.map((student) => (
                    <div
                      key={student.id}
                      className="bg-slate-50 border border-slate-200 rounded-lg p-3 hover:border-slate-300 transition-colors"
                    >
                      <div className="flex items-start justify-between">
                        <div>
                          <span className="text-xs font-bold text-slate-900">{student.name}</span>
                          <span className="text-[10px] text-slate-500 ml-2">{student.grade} • {student.room}</span>
                        </div>
                        <span className="bg-rose-50 border border-rose-200 text-rose-700 text-[9px] font-extrabold px-2 py-0.5 rounded">
                          {student.condition}
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-600 leading-normal mt-1.5 bg-white p-2 rounded border border-slate-100">
                        {student.note}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            )}
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
