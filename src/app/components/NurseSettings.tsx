import { useNavigate } from 'react-router';
import { ChevronRight, Bell, Lock, FileText, HelpCircle, LogOut, Shield } from 'lucide-react';
import { useState } from 'react';

export function NurseSettings() {
  const navigate = useNavigate();

  const [notifications, setNotifications] = useState({
    medicationDue: true,
    clinicReferrals: true,
    emergency: true,
    documents: true,
    system: false
  });

  const [autoLockMinutes, setAutoLockMinutes] = useState(5);
  const [requireBiometric, setRequireBiometric] = useState(true);

  const nurse = {
    name: 'Jane Smith',
    initials: 'JS',
    license: 'RN-4521',
    role: 'School Nurse'
  };

  const toggleNotification = (key: keyof typeof notifications) => {
    setNotifications(prev => ({ ...prev, [key]: !prev[key] }));
  };

  const handleSignOut = () => {
    if (window.confirm('تسجيل الخروج · Sign out?\n\nهل أنت متأكد من رغبتك في تسجيل الخروج؟\nAre you sure you want to sign out?')) {
      navigate('/login');
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="font-medium text-gray-900">
          Settings
        </h1>
      </header>

      <div className="px-4 py-6 space-y-6">
        {/* Profile Section */}
        <div className="bg-white rounded-xl p-4 border border-gray-200">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-16 h-16 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[20px] font-medium">
              {nurse.initials}
            </div>
            <div className="flex-1">
              <h2 className="text-[18px] font-medium text-gray-900 mb-1">
                {nurse.name}
              </h2>
              <p className="text-[13px] text-[#64748B] mb-2">
                License #{nurse.license}
              </p>
              <span className="inline-flex items-center px-2 py-1 rounded-full text-[11px] font-medium bg-[#DBEAFE] text-[#1E40AF]">
                {nurse.role}
              </span>
            </div>
          </div>
          <button className="w-full px-4 py-2.5 bg-[#F8FAFC] text-[#2563EB] rounded-lg text-[14px] font-medium min-h-[44px]">
            Edit profile
          </button>
        </div>

        {/* Notifications Section */}
        <div>
          <h3 className="text-[14px] font-medium text-gray-900 mb-3 px-1">
            Notifications
          </h3>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-200">
            <div className="p-4">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <Bell className="w-5 h-5 text-[#64748B]" />
                  <div>
                    <div className="text-[14px] font-medium text-gray-900">
                      Medication due
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Push, SMS, Email
                    </div>
                  </div>
                </div>
                <input
                  type="checkbox"
                  checked={notifications.medicationDue}
                  onChange={() => toggleNotification('medicationDue')}
                  className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                    before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                    checked:before:translate-x-6"
                />
              </div>
            </div>

            <div className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Bell className="w-5 h-5 text-[#64748B]" />
                  <div>
                    <div className="text-[14px] font-medium text-gray-900">
                      Clinic referrals
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Push, SMS
                    </div>
                  </div>
                </div>
                <input
                  type="checkbox"
                  checked={notifications.clinicReferrals}
                  onChange={() => toggleNotification('clinicReferrals')}
                  className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                    before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                    checked:before:translate-x-6"
                />
              </div>
            </div>

            <div className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Bell className="w-5 h-5 text-[#64748B]" />
                  <div>
                    <div className="text-[14px] font-medium text-gray-900">
                      Emergency
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Push, SMS, Email
                    </div>
                  </div>
                </div>
                <input
                  type="checkbox"
                  checked={notifications.emergency}
                  onChange={() => toggleNotification('emergency')}
                  className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                    before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                    checked:before:translate-x-6"
                />
              </div>
            </div>

            <div className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Bell className="w-5 h-5 text-[#64748B]" />
                  <div>
                    <div className="text-[14px] font-medium text-gray-900">
                      Documents
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Push
                    </div>
                  </div>
                </div>
                <input
                  type="checkbox"
                  checked={notifications.documents}
                  onChange={() => toggleNotification('documents')}
                  className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                    before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                    checked:before:translate-x-6"
                />
              </div>
            </div>

            <div className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Bell className="w-5 h-5 text-[#64748B]" />
                  <div>
                    <div className="text-[14px] font-medium text-gray-900">
                      System
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      App updates & maintenance
                    </div>
                  </div>
                </div>
                <input
                  type="checkbox"
                  checked={notifications.system}
                  onChange={() => toggleNotification('system')}
                  className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                    before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                    checked:before:translate-x-6"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Session & Security Section */}
        <div>
          <h3 className="text-[14px] font-medium text-gray-900 mb-3 px-1">
            Session & Security
          </h3>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-200">
            <div className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Lock className="w-5 h-5 text-[#64748B]" />
                  <div>
                    <div className="text-[14px] font-medium text-gray-900">
                      Auto-lock after
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Currently: {autoLockMinutes} minutes
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setAutoLockMinutes(Math.max(3, autoLockMinutes - 1))}
                    className="w-8 h-8 rounded-lg bg-[#F8FAFC] flex items-center justify-center text-[#64748B]"
                  >
                    -
                  </button>
                  <span className="text-[14px] font-medium text-gray-900 min-w-[20px] text-center">
                    {autoLockMinutes}
                  </span>
                  <button
                    onClick={() => setAutoLockMinutes(Math.min(10, autoLockMinutes + 1))}
                    className="w-8 h-8 rounded-lg bg-[#F8FAFC] flex items-center justify-center text-[#64748B]"
                  >
                    +
                  </button>
                </div>
              </div>
            </div>

            <div className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Shield className="w-5 h-5 text-[#64748B]" />
                  <div>
                    <div className="text-[14px] font-medium text-gray-900">
                      Require biometric on return
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Face ID or Touch ID
                    </div>
                  </div>
                </div>
                <input
                  type="checkbox"
                  checked={requireBiometric}
                  onChange={(e) => setRequireBiometric(e.target.checked)}
                  className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#2563EB] relative transition-colors cursor-pointer
                    before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                    checked:before:translate-x-6"
                />
              </div>
            </div>

            <button className="w-full p-4 flex items-center justify-between min-h-[60px]">
              <div className="flex items-center gap-3">
                <Lock className="w-5 h-5 text-[#64748B]" />
                <div className="text-left">
                  <div className="text-[14px] font-medium text-gray-900">
                    Active session info
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    Device & location details
                  </div>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B]" />
            </button>
          </div>
        </div>

        {/* My Reports Section */}
        <div>
          <h3 className="text-[14px] font-medium text-gray-900 mb-3 px-1">
            My Reports
          </h3>
          <button
            onClick={() => navigate('/nurse/reports/generate')}
            className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center justify-between min-h-[60px]"
          >
            <div className="flex items-center gap-3">
              <FileText className="w-5 h-5 text-[#64748B]" />
              <div className="text-left">
                <div className="text-[14px] font-medium text-gray-900">
                  View my generated reports
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Access report history
                </div>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-[#64748B]" />
          </button>
        </div>

        {/* About & Help Section */}
        <div>
          <h3 className="text-[14px] font-medium text-gray-900 mb-3 px-1">
            About & Help
          </h3>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-200">
            <button className="w-full p-4 flex items-center justify-between min-h-[60px]">
              <div className="flex items-center gap-3">
                <HelpCircle className="w-5 h-5 text-[#64748B]" />
                <div className="text-left">
                  <div className="text-[14px] font-medium text-gray-900">
                    Contact support
                  </div>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B]" />
            </button>

            <button className="w-full p-4 flex items-center justify-between min-h-[60px]">
              <div className="flex items-center gap-3">
                <Shield className="w-5 h-5 text-[#64748B]" />
                <div className="text-left">
                  <div className="text-[14px] font-medium text-gray-900">
                    UAE PDPL Privacy Declaration
                  </div>
                  <div className="text-[11px] text-[#64748B]">
                    Governed by Federal Decree-Law No. 45 of 2021
                  </div>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B]" />
            </button>

            <div className="p-4">
              <div className="text-[12px] text-[#64748B]">
                Version 1.0.0 (Build 2026.05.25)
              </div>
            </div>
          </div>
        </div>

        {/* Sign Out */}
        <button
          onClick={handleSignOut}
          className="w-full bg-white rounded-xl border border-[#DC2626] p-4 flex items-center justify-center gap-2 min-h-[60px] text-[#DC2626]"
        >
          <LogOut className="w-5 h-5" />
          <span className="text-[15px] font-medium">تسجيل الخروج · Sign out</span>
        </button>
      </div>
    </div>
  );
}
