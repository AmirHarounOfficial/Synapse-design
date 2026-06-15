import { useNavigate } from 'react-router';
import { ChevronLeft, ChevronRight, Shield, Users, LogOut } from 'lucide-react';
import { useState } from 'react';

export function TeacherSettings() {
  const navigate = useNavigate();
  const [weatherAlerts, setWeatherAlerts] = useState(true);
  const [clinicNotifications, setClinicNotifications] = useState(true);
  const [systemAnnouncements, setSystemAnnouncements] = useState(true);
  const [showSignOutDialog, setShowSignOutDialog] = useState(false);

  const teacher = {
    name: 'Sarah Johnson',
    initials: 'SJ',
    room: 'Room 204',
    grade: 'Grade 5 Homeroom',
    school: 'Lincoln Elementary School',
    agreementSignedDate: 'August 15, 2025'
  };

  const handleSignOut = () => {
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2"
          aria-label="Go back"
        >
          <ChevronLeft className="w-6 h-6 text-gray-900" />
        </button>

        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900">
          Settings
        </h1>
      </header>

      <div className="px-4 py-4 space-y-6">
        {/* Profile Section */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-16 h-16 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[20px] font-medium flex-shrink-0">
              {teacher.initials}
            </div>
            <div className="flex-1">
              <h2 className="text-[17px] font-medium text-gray-900">
                {teacher.name}
              </h2>
              <p className="text-[14px] text-[#64748B]">
                {teacher.room} — {teacher.grade}
              </p>
              <p className="text-[13px] text-[#94A3B8]">
                {teacher.school}
              </p>
            </div>
          </div>
          <button
            onClick={() => navigate('/agreement')}
            className="text-[13px] text-[#2563EB] font-medium underline min-h-[44px] px-2 -ml-2"
          >
            View confidentiality agreement
          </button>
        </div>

        {/* Notification Preferences */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            Notification Preferences
          </h2>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-200">
            {/* Medical Alerts - Locked ON */}
            <div className="p-4 min-h-[52px] flex items-center justify-between">
              <div className="flex-1">
                <div className="text-[14px] font-medium text-gray-900">
                  Medical alerts for my students
                </div>
                <div className="text-[12px] text-[#64748B] mt-0.5">
                  Required — cannot be disabled
                </div>
              </div>
              <div className="w-12 h-6 rounded-full bg-[#2563EB] relative flex-shrink-0 opacity-50 cursor-not-allowed">
                <div className="absolute w-5 h-5 rounded-full bg-white top-0.5 right-0.5" />
              </div>
            </div>

            {/* Weather Advisories */}
            <label className="p-4 min-h-[52px] flex items-center justify-between cursor-pointer">
              <div className="text-[14px] font-medium text-gray-900">
                Weather advisories
              </div>
              <input
                type="checkbox"
                checked={weatherAlerts}
                onChange={(e) => setWeatherAlerts(e.target.checked)}
                className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                  before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                  checked:before:translate-x-6"
              />
            </label>

            {/* Clinic Call Notifications */}
            <label className="p-4 min-h-[52px] flex items-center justify-between cursor-pointer">
              <div className="text-[14px] font-medium text-gray-900">
                Clinic call notifications
              </div>
              <input
                type="checkbox"
                checked={clinicNotifications}
                onChange={(e) => setClinicNotifications(e.target.checked)}
                className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                  before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                  checked:before:translate-x-6"
              />
            </label>

            {/* System Announcements */}
            <label className="p-4 min-h-[52px] flex items-center justify-between cursor-pointer">
              <div className="text-[14px] font-medium text-gray-900">
                System announcements
              </div>
              <input
                type="checkbox"
                checked={systemAnnouncements}
                onChange={(e) => setSystemAnnouncements(e.target.checked)}
                className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                  before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                  checked:before:translate-x-6"
              />
            </label>
          </div>
        </div>

        {/* My Students */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            My Students
          </h2>

          <button
            onClick={() => {/* Navigate to roster view */}}
            className="w-full bg-white rounded-xl border border-gray-200 p-4 min-h-[52px] flex items-center justify-between"
          >
            <div className="flex items-center gap-3">
              <Users className="w-5 h-5 text-[#64748B]" />
              <span className="text-[14px] font-medium text-gray-900">
                View my class roster
              </span>
            </div>
            <ChevronRight className="w-5 h-5 text-[#64748B]" />
          </button>
        </div>

        {/* Data & Privacy */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            Data & Privacy
          </h2>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-200">
            {/* Confidentiality Agreement */}
            <button
              onClick={() => navigate('/agreement')}
              className="w-full p-4 min-h-[52px] flex items-center justify-between"
            >
              <div className="text-left flex-1">
                <div className="text-[14px] font-medium text-gray-900 mb-0.5">
                  Confidentiality agreement (UAE PDPL Compliant)
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Signed {teacher.agreementSignedDate}
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>

            {/* Data Access Level */}
            <div className="p-4 min-h-[52px] flex items-center justify-between">
              <div className="flex items-center gap-3 flex-1">
                <Shield className="w-5 h-5 text-[#2563EB]" />
                <span className="text-[14px] font-medium text-gray-900">
                  My data access level
                </span>
              </div>
              <span className="inline-flex items-center px-3 py-1 rounded-full text-[12px] font-medium bg-[#EFF6FF] text-[#2563EB]">
                Contraindications only — read-only
              </span>
            </div>
          </div>
        </div>

        {/* Sign Out */}
        <button
          onClick={() => setShowSignOutDialog(true)}
          className="w-full px-4 py-3.5 bg-white border border-gray-200 text-[#DC2626] rounded-lg text-[15px] font-medium min-h-[52px] flex items-center justify-center gap-2"
        >
          <LogOut className="w-5 h-5" />
          تسجيل الخروج · Sign out
        </button>
      </div>

      {/* Sign Out Confirmation Dialog */}
      {showSignOutDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full">
            <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
              تسجيل الخروج · Sign Out?
            </h3>
            <p className="text-[14px] text-[#64748B] mb-6 text-center leading-relaxed">
              هل أنت متأكد من رغبتك في تسجيل الخروج؟<br/>
              You will need to sign in again to access Synapse.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowSignOutDialog(false)}
                className="flex-1 px-4 py-2.5 bg-white border border-gray-200 text-gray-900 rounded-lg text-[15px] font-medium min-h-[44px]"
              >
                إلغاء · Cancel
              </button>
              <button
                onClick={handleSignOut}
                className="flex-1 px-4 py-2.5 bg-[#DC2626] text-white rounded-lg text-[15px] font-medium min-h-[44px]"
              >
                تسجيل الخروج · Sign out
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
