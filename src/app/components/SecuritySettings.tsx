import { useNavigate } from 'react-router';
import { ArrowLeft, User, FileText, LogOut, Shield, Lock } from 'lucide-react';
import { useState } from 'react';

export function SecuritySettings() {
  const navigate = useNavigate();
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  const userInfo = {
    name: 'Marcus Johnson',
    badgeNumber: '#042',
    role: 'Security Officer',
    shift: 'Morning Shift (7:00 AM - 3:00 PM)',
    email: 'm.johnson@school.edu',
    lastLogin: 'May 25, 2026 at 7:02 AM'
  };

  const handleLogout = () => {
    setShowLogoutConfirm(true);
  };

  const confirmLogout = () => {
    // In real app, clear auth tokens
    navigate('/login');
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

      <div className="px-4 py-4 space-y-4">
        {/* User Profile Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-4 mb-4">
            <div className="w-16 h-16 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
              <User className="w-8 h-8 text-[#2563EB]" />
            </div>
            <div className="flex-1">
              <div className="text-[17px] font-semibold text-gray-900 mb-1">
                {userInfo.name}
              </div>
              <div className="text-[14px] text-[#64748B] mb-1">
                {userInfo.role} {userInfo.badgeNumber}
              </div>
              <div className="text-[13px] text-[#64748B]">
                {userInfo.shift}
              </div>
            </div>
          </div>

          <div className="pt-4 border-t border-gray-100 space-y-2">
            <div className="flex justify-between">
              <span className="text-[13px] text-[#64748B]">Email</span>
              <span className="text-[13px] font-medium text-gray-900">{userInfo.email}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-[13px] text-[#64748B]">Last Login</span>
              <span className="text-[13px] font-medium text-gray-900">{userInfo.lastLogin}</span>
            </div>
          </div>
        </div>

        {/* Compliance Section */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            COMPLIANCE & PRIVACY
          </h2>

          <div className="space-y-2">
            {/* Confidentiality Agreement */}
            <button className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3 active:bg-gray-50">
              <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <Shield className="w-5 h-5 text-[#2563EB]" />
              </div>
              <div className="flex-1 text-left">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  Confidentiality Agreement
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Signed on May 15, 2026
                </div>
              </div>
              <div className="flex items-center gap-1 px-2 py-1 rounded-md bg-[#D1FAE5] text-[#065F46] text-[11px] font-semibold">
                <Lock className="w-3 h-3" />
                Active
              </div>
            </button>

            {/* FERPA Training */}
            <button className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3 active:bg-gray-50">
              <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <FileText className="w-5 h-5 text-[#2563EB]" />
              </div>
              <div className="flex-1 text-left">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  FERPA Training Certificate
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Completed May 15, 2026 • Valid until May 2027
                </div>
              </div>
            </button>

            {/* Security Protocols */}
            <button className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3 active:bg-gray-50">
              <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <Shield className="w-5 h-5 text-[#2563EB]" />
              </div>
              <div className="flex-1 text-left">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  Student Safety Protocols
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Last reviewed May 20, 2026
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Info Notice */}
        <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-3">
          <p className="text-[12px] text-[#64748B] leading-relaxed text-center">
            All pickup verification actions are permanently logged for security compliance. Records cannot be modified or deleted.
          </p>
        </div>

        {/* Logout Button */}
        <button
          onClick={handleLogout}
          className="w-full px-4 py-3.5 bg-white text-[#DC2626] border-2 border-[#DC2626] rounded-lg text-[15px] font-semibold min-h-[52px] flex items-center justify-center gap-2"
        >
          <LogOut className="w-5 h-5" />
          Log Out
        </button>

        <div className="text-[12px] text-[#94A3B8] text-center">
          SchooKeep v2.1.0 • Security Portal
        </div>
      </div>

      {/* Logout Confirmation Dialog */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowLogoutConfirm(false)}
          />
          <div className="relative bg-white rounded-2xl p-6 max-w-sm w-full">
            <div className="w-16 h-16 rounded-full bg-[#FEE2E2] flex items-center justify-center mx-auto mb-4">
              <LogOut className="w-8 h-8 text-[#DC2626]" />
            </div>
            <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
              Log Out of SchooKeep?
            </h3>
            <p className="text-[14px] text-[#64748B] mb-6 text-center">
              You will need to re-authenticate with 2FA to access the security portal again.
            </p>

            <div className="flex gap-3">
              <button
                onClick={() => setShowLogoutConfirm(false)}
                className="flex-1 px-4 py-3.5 bg-white text-gray-900 border border-gray-200 rounded-lg text-[15px] font-medium min-h-[52px]"
              >
                Cancel
              </button>
              <button
                onClick={confirmLogout}
                className="flex-1 px-4 py-3.5 bg-[#DC2626] text-white rounded-lg text-[15px] font-medium min-h-[52px]"
              >
                Log Out
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
