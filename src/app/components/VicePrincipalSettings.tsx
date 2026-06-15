import { ChevronRight, Lock, Bell, User, Shield, FileText, LogOut, Mail } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function VicePrincipalSettings() {
  const navigate = useNavigate();
  const [showSignOutDialog, setShowSignOutDialog] = useState(false);

  const profileInfo = {
    name: 'Victoria Davis',
    role: 'Vice Principal',
    email: 'v.davis@synapse.ae',
    initials: 'VD',
    delegatedBy: 'Principal M. Davis',
    delegationDate: '2026-05-01'
  };

  const settingsSections = [
    {
      title: 'Account',
      items: [
        { id: 'profile', label: 'Profile information', icon: User, action: () => {} },
        { id: 'permissions', label: 'My access level', icon: Lock, action: () => navigate('/vice-principal/permissions'), badge: '2 granted' },
        { id: 'notifications', label: 'Notification preferences', icon: Bell, action: () => {} }
      ]
    },
    {
      title: 'Privacy & Security',
      items: [
        { id: 'confidentiality', label: 'Confidentiality agreement', icon: Shield, action: () => {}, badge: 'Signed' },
        { id: 'data-access', label: 'Data access scope', icon: FileText, action: () => {}, badge: 'View only' }
      ]
    },
    {
      title: 'Communication',
      items: [
        { id: 'contact-principal', label: 'Message Principal', icon: Mail, action: () => navigate('/vice-principal/messages?compose=principal') }
      ]
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Settings
        </h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Profile Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-3 mb-4">
            <div className="w-16 h-16 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
              <span className="text-[20px] font-medium text-[#2563EB]">{profileInfo.initials}</span>
            </div>
            <div className="flex-1">
              <div className="text-[16px] font-semibold text-[#0F172A] mb-0.5">
                {profileInfo.name}
              </div>
              <div className="text-[13px] text-[#64748B] mb-2">
                {profileInfo.role}
              </div>
              <div className="text-[12px] text-[#64748B]">
                {profileInfo.email}
              </div>
            </div>
          </div>

          <div className="bg-[#EFF6FF] rounded-lg p-3">
            <div className="text-[12px] text-[#1E40AF] leading-relaxed">
              <strong>Delegated role:</strong> Permissions granted by {profileInfo.delegatedBy} on {new Date(profileInfo.delegationDate).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
            </div>
          </div>
        </div>

        {/* Settings Sections */}
        {settingsSections.map((section) => (
          <div key={section.title}>
            <h2 className="text-[13px] font-semibold text-[#64748B] uppercase tracking-wider mb-2 px-1">
              {section.title}
            </h2>
            <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
              {section.items.map((item) => {
                const Icon = item.icon;
                return (
                  <button
                    key={item.id}
                    onClick={item.action}
                    className="w-full p-4 flex items-center gap-3 active:bg-gray-50 text-left"
                  >
                    <div className="w-10 h-10 rounded-full bg-[#F1F5F9] flex items-center justify-center flex-shrink-0">
                      <Icon className="w-5 h-5 text-[#64748B]" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-[14px] font-medium text-[#0F172A]">
                        {item.label}
                      </div>
                      {item.badge && (
                        <div className="text-[12px] text-[#64748B] mt-0.5">
                          {item.badge}
                        </div>
                      )}
                    </div>
                    <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
                  </button>
                );
              })}
            </div>
          </div>
        ))}

        {/* App Info */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="text-[13px] text-[#64748B] text-center space-y-1">
            <div>Synapse Health Manager</div>
            <div>Version 2.1.0 (Build 487)</div>
            <div className="pt-2">
              <button className="text-[#2563EB] font-medium">
                UAE PDPL Privacy Declaration
              </button>
              {' · '}
              <button className="text-[#2563EB] font-medium">
                Terms of Service
              </button>
            </div>
          </div>
        </div>

        {/* Sign Out */}
        <button
          onClick={() => setShowSignOutDialog(true)}
          className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center justify-center gap-2 active:bg-gray-50"
        >
          <LogOut className="w-5 h-5 text-[#DC2626]" />
          <span className="text-[14px] font-medium text-[#DC2626]">
            تسجيل الخروج · Sign out
          </span>
        </button>

        {/* Legal Notice */}
        <div className="bg-[#F1F5F9] rounded-lg p-3">
          <p className="text-[11px] text-[#64748B] leading-relaxed text-center font-medium">
            Access to Synapse is governed by UAE PDPL and DHA school health guidelines. All activities are logged for compliance and audit purposes under UAE regulations.
          </p>
        </div>
      </div>

      {/* Sign Out Dialog */}
      {showSignOutDialog && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center px-6">
          <div className="bg-white rounded-2xl w-full max-w-[320px] p-6">
            <h3 className="text-[17px] font-semibold text-[#0F172A] mb-2 text-center">
              تسجيل الخروج · Sign out?
            </h3>
            <p className="text-[14px] text-[#64748B] mb-6 text-center leading-relaxed">
              هل أنت متأكد من رغبتك في تسجيل الخروج؟<br/>
              You'll need to sign in again to access your account.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowSignOutDialog(false)}
                className="flex-1 h-[44px] bg-[#F1F5F9] text-[#0F172A] rounded-lg font-medium text-[15px] active:bg-[#E2E8F0]"
              >
                إلغاء · Cancel
              </button>
              <button
                onClick={() => navigate('/login')}
                className="flex-1 h-[44px] bg-[#DC2626] text-white rounded-lg font-medium text-[15px] active:bg-[#B91C1C]"
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
