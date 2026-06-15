import { User, TrendingUp, FileText, Cloud, Bell, Calendar, Users, Clipboard, Archive, File, Shield, Lock, Info, Headphones, Book, ChevronRight, ChevronDown } from 'lucide-react';
import { useState } from 'react';

export function CounselorSettings() {
  const [notifications, setNotifications] = useState({
    newCase: true,
    trendAlerts: true,
    reportReminders: true,
    weatherSummaries: true,
    parentResponses: true
  });

  const [showReminderPicker, setShowReminderPicker] = useState(false);
  const [reminderDays, setReminderDays] = useState(3);
  const [showSignOutDialog, setShowSignOutDialog] = useState(false);

  const profileInfo = {
    initials: 'RM',
    name: 'Rachel Martinez',
    role: 'Student Counselor',
    credential: 'License #SC-47829',
    school: 'Lakewood Elementary School'
  };

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
        {/* Profile Section */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-3 mb-3">
            <div className="w-16 h-16 rounded-full bg-[#F5F3FF] flex items-center justify-center flex-shrink-0">
              <span className="text-[22px] font-medium text-[#6D28D9]">{profileInfo.initials}</span>
            </div>
            <div className="flex-1">
              <div className="text-[17px] font-medium text-[#0F172A] mb-1">
                {profileInfo.name}
              </div>
              <div className="inline-flex items-center px-2 py-0.5 rounded-full bg-[#F5F3FF] mb-1">
                <span className="text-[12px] font-medium text-[#6D28D9]">
                  {profileInfo.role}
                </span>
              </div>
              <div className="text-[12px] text-[#64748B] mb-0.5">
                {profileInfo.credential}
              </div>
              <div className="text-[13px] text-[#64748B]">
                {profileInfo.school}
              </div>
            </div>
          </div>
          <div className="flex justify-end">
            <button className="text-[14px] text-[#2563EB] font-medium">
              Edit profile
            </button>
          </div>
        </div>

        {/* Notifications Section */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wider mb-2 px-1">
            Notifications
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {/* New case assigned */}
            <div className="p-4 flex items-center gap-3 min-h-[52px]">
              <User className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  New case assigned
                </div>
                <div className="text-[12px] text-[#64748B]">
                  When a student is referred to you by the nurse or admin
                </div>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, newCase: !notifications.newCase })}
                className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                  notifications.newCase ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                }`}
              >
                <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                  notifications.newCase ? 'ml-6' : 'ml-1'
                }`} />
              </button>
            </div>

            {/* Tag trend alerts */}
            <div className="p-4">
              <div className="flex items-center gap-3 min-h-[52px] mb-2">
                <TrendingUp className="w-5 h-5 text-[#64748B] flex-shrink-0" />
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                    Tag trend alerts
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    When the same psychosocial tag is logged 3+ times for one student in 7 days
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, trendAlerts: !notifications.trendAlerts })}
                  className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                    notifications.trendAlerts ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                  }`}
                >
                  <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                    notifications.trendAlerts ? 'ml-6' : 'ml-1'
                  }`} />
                </button>
              </div>
              {notifications.trendAlerts && (
                <div className="ml-8 text-[11px] text-[#F59E0B] leading-relaxed">
                  Helps identify students needing escalated support.
                </div>
              )}
            </div>

            {/* Report due reminders */}
            <div className="p-4">
              <div className="flex items-center gap-3 min-h-[52px] mb-2">
                <FileText className="w-5 h-5 text-[#64748B] flex-shrink-0" />
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                    Report due reminders
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    Reminders before a periodic report is due
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, reportReminders: !notifications.reportReminders })}
                  className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                    notifications.reportReminders ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                  }`}
                >
                  <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                    notifications.reportReminders ? 'ml-6' : 'ml-1'
                  }`} />
                </button>
              </div>
              {notifications.reportReminders && (
                <button
                  onClick={() => setShowReminderPicker(!showReminderPicker)}
                  className="ml-8 flex items-center gap-2 text-[13px] text-[#2563EB] font-medium"
                >
                  Remind me: {reminderDays} days before
                  <ChevronDown className={`w-4 h-4 transition-transform ${showReminderPicker ? 'rotate-180' : ''}`} />
                </button>
              )}
              {notifications.reportReminders && showReminderPicker && (
                <div className="ml-8 mt-2 bg-[#F8FAFC] rounded-lg p-2 space-y-1">
                  {[1, 2, 3, 7].map((days) => (
                    <button
                      key={days}
                      onClick={() => {
                        setReminderDays(days);
                        setShowReminderPicker(false);
                      }}
                      className={`w-full px-3 py-2 rounded text-[13px] text-left ${
                        reminderDays === days
                          ? 'bg-[#2563EB] text-white'
                          : 'text-[#0F172A] active:bg-white'
                      }`}
                    >
                      {days} {days === 1 ? 'day' : 'days'} before
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Weather-linked tag summaries */}
            <div className="p-4 flex items-center gap-3 min-h-[52px]">
              <Cloud className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  Weather-linked tag summaries
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Daily summary of tags logged during active weather advisories
                </div>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, weatherSummaries: !notifications.weatherSummaries })}
                className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                  notifications.weatherSummaries ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                }`}
              >
                <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                  notifications.weatherSummaries ? 'ml-6' : 'ml-1'
                }`} />
              </button>
            </div>

            {/* Parent responses */}
            <div className="p-4 flex items-center gap-3 min-h-[52px]">
              <Bell className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  Parent responses to referrals
                </div>
                <div className="text-[12px] text-[#64748B]">
                  When a parent acknowledges an external referral you submitted
                </div>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, parentResponses: !notifications.parentResponses })}
                className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                  notifications.parentResponses ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                }`}
              >
                <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                  notifications.parentResponses ? 'ml-6' : 'ml-1'
                }`} />
              </button>
            </div>
          </div>
        </div>

        {/* Report Defaults Section */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wider mb-2 px-1">
            Report Defaults
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Calendar className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  Default report date range
                </div>
              </div>
              <div className="text-[14px] text-[#2563EB]">
                Last 30 days
              </div>
            </button>

            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Users className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  Default report scope
                </div>
              </div>
              <div className="text-[14px] text-[#2563EB]">
                All students
              </div>
            </button>
          </div>
        </div>

        {/* Active Cases Section */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wider mb-2 px-1">
            Active Cases
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Clipboard className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  My active cases
                </div>
              </div>
              <div className="w-6 h-6 rounded-full bg-[#7C3AED] flex items-center justify-center">
                <span className="text-[12px] font-bold text-white">4</span>
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>

            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Archive className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  Closed cases
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>
          </div>
        </div>

        {/* Data & Privacy Section */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wider mb-2 px-1">
            Data & Privacy
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <File className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  Confidentiality agreement
                </div>
              </div>
              <div className="text-[12px] text-[#64748B] flex-shrink-0">
                Signed May 1, 2026
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>

            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Shield className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  My data access level
                </div>
              </div>
              <div className="text-[12px] text-[#7C3AED] flex-shrink-0 mr-2">
                Psychosocial records only
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>

            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Lock className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  Two-factor authentication
                </div>
              </div>
              <div className="text-[12px] text-[#10B981] flex-shrink-0">
                Enabled
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>
          </div>
        </div>

        {/* About Section */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wider mb-2 px-1">
            About
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            <div className="p-4 flex items-center gap-3">
              <Info className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  App version
                </div>
              </div>
              <div className="text-[12px] text-[#64748B] flex-shrink-0">
                Synapse v1.0.0
              </div>
            </div>

            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Headphones className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  Contact support
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>

            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Book className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A]">
                  UAE PDPL Privacy Declaration
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Governed by Federal Decree-Law No. 45 of 2021
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>
          </div>
        </div>

        {/* Sign Out Button */}
        <div className="pt-4">
          <button
            onClick={() => setShowSignOutDialog(true)}
            className="w-full h-[52px] bg-white rounded-xl border border-gray-200 text-[#DC2626] font-medium text-[14px] active:bg-gray-50"
          >
            تسجيل الخروج · Sign out
          </button>
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
