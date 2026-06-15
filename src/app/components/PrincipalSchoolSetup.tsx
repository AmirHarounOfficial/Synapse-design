import { ArrowLeft, Upload, Plus, X } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function PrincipalSchoolSetup() {
  const navigate = useNavigate();
  const [schoolName, setSchoolName] = useState('Lakewood Elementary');
  const [address, setAddress] = useState('123 Oak Street, Springfield, CA 94025');
  const [phone, setPhone] = useState('(555) 123-4567');
  const [principalName, setPrincipalName] = useState('Dr. Linda Rodriguez');
  const [primaryColor, setPrimaryColor] = useState('#2563EB');
  const [schoolYearStart, setSchoolYearStart] = useState('2025-09-02');
  const [schoolYearEnd, setSchoolYearEnd] = useState('2026-06-15');
  const [schoolHoursStart, setSchoolHoursStart] = useState('07:30');
  const [schoolHoursEnd, setSchoolHoursEnd] = useState('17:00');

  const [holidays, setHolidays] = useState([
    { id: '1', name: 'Thanksgiving Break', start: '2025-11-24', end: '2025-11-29' },
    { id: '2', name: 'Winter Break', start: '2025-12-20', end: '2026-01-03' },
    { id: '3', name: 'Spring Break', start: '2026-03-15', end: '2026-03-22' }
  ]);

  const handleSave = () => {
    alert('School settings saved successfully');
  };

  const handleAddHoliday = () => {
    const newId = (holidays.length + 1).toString();
    setHolidays([...holidays, { id: newId, name: '', start: '', end: '' }]);
  };

  const handleRemoveHoliday = (id: string) => {
    setHolidays(holidays.filter(h => h.id !== id));
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
          School Settings
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* School Info */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            School Information
          </h2>
          <div className="space-y-3">
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                School Name
              </label>
              <input
                type="text"
                value={schoolName}
                onChange={(e) => setSchoolName(e.target.value)}
                className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                Address
              </label>
              <input
                type="text"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                Phone
              </label>
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                Principal Name
              </label>
              <input
                type="text"
                value={principalName}
                onChange={(e) => setPrincipalName(e.target.value)}
                className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
          </div>
        </div>

        {/* Branding */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Branding
          </h2>
          <div className="space-y-3">
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                School Logo
              </label>
              <button className="w-full h-[100px] border-2 border-dashed border-gray-300 rounded-lg bg-[#F8FAFC] flex flex-col items-center justify-center gap-2 active:bg-gray-100">
                <Upload className="w-6 h-6 text-[#64748B]" />
                <span className="text-[13px] font-medium text-[#64748B]">
                  Tap to upload logo
                </span>
                <span className="text-[11px] text-[#94A3B8]">
                  PNG or SVG, max 2MB
                </span>
              </button>
            </div>
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                Primary Color
              </label>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={primaryColor}
                  onChange={(e) => setPrimaryColor(e.target.value)}
                  placeholder="#2563EB"
                  className="flex-1 h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                />
                <div
                  className="w-[44px] h-[44px] rounded-lg border border-gray-300 flex-shrink-0"
                  style={{ backgroundColor: primaryColor }}
                />
              </div>
            </div>
          </div>
        </div>

        {/* Academic Calendar */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Academic Calendar
          </h2>
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                  Year Start
                </label>
                <input
                  type="date"
                  value={schoolYearStart}
                  onChange={(e) => setSchoolYearStart(e.target.value)}
                  className="w-full h-[44px] px-3 bg-white border border-gray-300 rounded-lg text-[13px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                  Year End
                </label>
                <input
                  type="date"
                  value={schoolYearEnd}
                  onChange={(e) => setSchoolYearEnd(e.target.value)}
                  className="w-full h-[44px] px-3 bg-white border border-gray-300 rounded-lg text-[13px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                />
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-[13px] font-medium text-[#0F172A]">
                  Holidays
                </label>
                <button
                  onClick={handleAddHoliday}
                  className="text-[13px] text-[#2563EB] font-medium flex items-center gap-1"
                >
                  <Plus className="w-4 h-4" />
                  Add
                </button>
              </div>
              <div className="space-y-2">
                {holidays.map((holiday) => (
                  <div key={holiday.id} className="flex items-start gap-2 p-3 bg-[#F8FAFC] rounded-lg">
                    <div className="flex-1 space-y-2">
                      <input
                        type="text"
                        value={holiday.name}
                        placeholder="Holiday name"
                        className="w-full h-[36px] px-3 bg-white border border-gray-300 rounded text-[13px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                      />
                      <div className="grid grid-cols-2 gap-2">
                        <input
                          type="date"
                          value={holiday.start}
                          className="w-full h-[36px] px-2 bg-white border border-gray-300 rounded text-[11px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                        />
                        <input
                          type="date"
                          value={holiday.end}
                          className="w-full h-[36px] px-2 bg-white border border-gray-300 rounded text-[11px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                        />
                      </div>
                    </div>
                    <button
                      onClick={() => handleRemoveHoliday(holiday.id)}
                      className="w-8 h-8 flex items-center justify-center rounded hover:bg-gray-200"
                    >
                      <X className="w-4 h-4 text-[#64748B]" />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* School Hours */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            School Hours
          </h2>
          <p className="text-[12px] text-[#64748B] mb-3">
            Governs system lock/unlock times for staff access
          </p>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                Start Time
              </label>
              <input
                type="time"
                value={schoolHoursStart}
                onChange={(e) => setSchoolHoursStart(e.target.value)}
                className="w-full h-[44px] px-3 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                End Time
              </label>
              <input
                type="time"
                value={schoolHoursEnd}
                onChange={(e) => setSchoolHoursEnd(e.target.value)}
                className="w-full h-[44px] px-3 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Button */}
      <div className="bg-white border-t border-gray-200 p-4">
        <button
          onClick={handleSave}
          className="w-full h-[48px] bg-[#2563EB] text-white rounded-lg font-medium text-[15px] active:bg-[#1D4ED8]"
        >
          Save Changes
        </button>
      </div>
    </div>
  );
}
