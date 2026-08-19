import { Bell, Bot, FileText, AlertTriangle, Calendar, Clock, Table, File, Shield, EyeOff, Info, Headphones, Book, Lock, ChevronRight } from 'lucide-react';
import { useState } from 'react';
import { useNavigate } from 'react-router';

export function SecretarySettings() {
  const navigate = useNavigate();
  const [notifications, setNotifications] = useState({
    parentMessages: true,
    chatbotEscalations: true,
    importErrors: true,
    clinicCopies: true,
    documentExpiry: true
  });

  const [showLockSheet, setShowLockSheet] = useState(false);
  const [showSignOutDialog, setShowSignOutDialog] = useState(false);

  const profileInfo = {
    initials: 'SL',
    name: 'Sarah Lopez',
    role: 'School Secretary',
    school: 'Lakewood Elementary School',
    officeHours: '08:00 AM — 4:30 PM'
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
            <div className="w-16 h-16 rounded-full bg-[#ECFEFF] flex items-center justify-center flex-shrink-0">
              <span className="text-[22px] font-medium text-[#0E7490]">{profileInfo.initials}</span>
            </div>
            <div className="flex-1">
              <div className="text-[17px] font-medium text-[#0F172A] mb-1">
                {profileInfo.name}
              </div>
              <div className="inline-flex items-center px-2 py-0.5 rounded-full bg-[#ECFEFF] mb-1">
                <span className="text-[12px] font-medium text-[#0E7490]">
                  {profileInfo.role}
                </span>
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
            {/* Parent messages */}
            <div className="p-4 flex items-center gap-3 min-h-[52px]">
              <Bell className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  Parent messages received
                </div>
                <div className="text-[12px] text-[#64748B]">
                  New messages from parents in your inbox
                </div>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, parentMessages: !notifications.parentMessages })}
                className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                  notifications.parentMessages ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                }`}
              >
                <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                  notifications.parentMessages ? 'ml-6' : 'ml-1'
                }`} />
              </button>
            </div>

            {/* Chatbot escalations */}
            <div className="p-4 flex items-center gap-3 min-h-[52px]">
              <Bot className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  Chatbot escalations
                </div>
                <div className="text-[12px] text-[#64748B]">
                  When the AI assistant transfers a conversation to you
                </div>
              </div>
              <button
                onClick={() => setShowLockSheet(true)}
                className="flex items-center gap-1 flex-shrink-0"
              >
                <Lock className="w-4 h-4 text-[#64748B]" />
                <div className="w-12 h-7 rounded-full bg-[#2563EB]">
                  <div className="w-5 h-5 bg-white rounded-full mt-1 ml-6" />
                </div>
              </button>
            </div>

            {/* Student import errors */}
            <div className="p-4 flex items-center gap-3 min-h-[52px]">
              <FileText className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  Student import errors
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Alerts when an Excel/CSV import has validation failures
                </div>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, importErrors: !notifications.importErrors })}
                className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                  notifications.importErrors ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                }`}
              >
                <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                  notifications.importErrors ? 'ml-6' : 'ml-1'
                }`} />
              </button>
            </div>

            {/* Clinic copies */}
            <div className="p-4 flex items-center gap-3 min-h-[52px]">
              <AlertTriangle className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  Clinic copies
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Receive copies of emergency clinic notifications sent to parents
                </div>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, clinicCopies: !notifications.clinicCopies })}
                className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                  notifications.clinicCopies ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                }`}
              >
                <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                  notifications.clinicCopies ? 'ml-6' : 'ml-1'
                }`} />
              </button>
            </div>

            {/* Document expiry reminders */}
            <div className="p-4 flex items-center gap-3 min-h-[52px]">
              <Calendar className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  Document expiry reminders
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Students with documents expiring within 30 days
                </div>
              </div>
              <button
                onClick={() => setNotifications({ ...notifications, documentExpiry: !notifications.documentExpiry })}
                className={`w-12 h-7 rounded-full transition-colors flex-shrink-0 ${
                  notifications.documentExpiry ? 'bg-[#2563EB]' : 'bg-[#E2E8F0]'
                }`}
              >
                <div className={`w-5 h-5 bg-white rounded-full mt-1 transition-transform ${
                  notifications.documentExpiry ? 'ml-6' : 'ml-1'
                }`} />
              </button>
            </div>
          </div>
        </div>

        {/* Working Hours Section */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wider mb-2 px-1">
            Working Hours
          </h2>
          <div className="bg-white rounded-xl border border-gray-200">
            <button className="w-full p-4 flex items-start gap-3 active:bg-gray-50">
              <Clock className="w-5 h-5 text-[#64748B] flex-shrink-0 mt-0.5" />
              <div className="flex-1 text-left">
                <div className="flex items-center justify-between mb-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Office hours
                  </div>
                  <div className="text-[14px] text-[#2563EB]">
                    {profileInfo.officeHours}
                  </div>
                </div>
                <div className="text-[12px] text-[#64748B] leading-relaxed">
                  Notifications are batched outside these hours (except emergency escalations).
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Import History Section */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wider mb-2 px-1">
            Import History
          </h2>
          <div className="bg-white rounded-xl border border-gray-200">
            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <Table className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <div className="flex-1 text-left">
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  View past imports
                </div>
                <div className="text-[12px] text-[#64748B]">
                  See all Excel/CSV student imports and their results
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
              <div className="text-[12px] text-[#64748B] flex-shrink-0 mr-2">
                Student basic info — no clinical records
              </div>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>

            <button className="w-full p-4 flex items-center gap-3 active:bg-gray-50">
              <EyeOff className="w-5 h-5 text-[#64748B] flex-shrink-0" />
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
                SchooKeep v1.0.0
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

      {/* Lock Sheet */}
      {showLockSheet && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end">
          <div className="bg-white rounded-t-3xl w-full p-6 animate-slide-up">
            <div className="w-12 h-1 bg-[#E2E8F0] rounded-full mx-auto mb-6" />
            <div className="flex items-start gap-3 mb-4">
              <Lock className="w-6 h-6 text-[#F59E0B] flex-shrink-0 mt-1" />
              <div>
                <h3 className="text-[17px] font-semibold text-[#0F172A] mb-2">
                  Required Notification
                </h3>
                <p className="text-[14px] text-[#64748B] leading-relaxed">
                  Chatbot escalations must be received by the secretary to ensure no parent query goes unanswered.
                </p>
              </div>
            </div>
            <button
              onClick={() => setShowLockSheet(false)}
              className="w-full h-[52px] bg-[#2563EB] text-white rounded-xl font-medium text-[15px] active:bg-[#1D4ED8]"
            >
              Got it
            </button>
          </div>
        </div>
      )}

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
