import { ArrowLeft, User, ChevronRight, Plus, Shield, FileText, Download, AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function ParentProfileSettings() {
  const navigate = useNavigate();

  const [notifications, setNotifications] = useState({
    emergencyAlerts: true, // locked, cannot disable
    clinicVisits: true,
    medicationAdministered: true,
    busBoardingArrival: true,
    documentReminders: true,
    schoolAnnouncements: false
  });

  const parent = {
    firstName: 'James',
    lastName: 'Thompson',
    initials: 'JT',
    role: 'Parent / Guardian'
  };

  const linkedChildren = [
    {
      id: '1',
      firstName: 'Maya',
      lastName: 'Thompson',
      initials: 'MT',
      grade: '4th Grade',
      school: 'Lincoln Elementary',
      healthStatus: 'Active',
      healthStatusColor: 'text-[#10B981]'
    }
  ];

  const signedConsents = [
    {
      id: '1',
      title: 'FERPA Privacy Agreement',
      date: 'Signed 08/15/2025'
    },
    {
      id: '2',
      title: 'Emergency Medical Treatment Consent',
      date: 'Signed 08/15/2025'
    },
    {
      id: '3',
      title: 'Photo & Video Release',
      date: 'Signed 08/15/2025'
    }
  ];

  const handleSignOut = () => {
    // In real app, would clear auth tokens and redirect
    navigate('/login');
  };

  const handleWithdrawConsent = () => {
    // Show warning dialog
    alert('Withdrawing consent will deactivate your account and restrict access to school services. This action requires administrator review.');
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
        <div className="flex-1">
          <h1 className="text-[17px] font-medium text-[#0F172A]">Profile & Settings</h1>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto">
        {/* Profile Header */}
        <div className="bg-white border-b border-gray-200 px-4 py-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-16 h-16 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
              <span className="text-[20px] font-semibold text-[#2563EB]">
                {parent.initials}
              </span>
            </div>
            <div className="flex-1">
              <div className="text-[17px] font-semibold text-[#0F172A] mb-0.5">
                {parent.firstName} {parent.lastName}
              </div>
              <div className="inline-flex items-center px-2 py-1 rounded-full bg-[#F1F5F9] text-[12px] font-medium text-[#64748B]">
                {parent.role}
              </div>
            </div>
          </div>
          <button className="text-[14px] text-[#2563EB] font-medium">
            Edit profile
          </button>
        </div>

        <div className="px-4 py-4 space-y-6">
          {/* Linked Children */}
          <section>
            <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
              Linked Children
            </h2>
            <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
              {linkedChildren.map((child) => (
                <div key={child.id} className="p-4">
                  <div className="flex items-center gap-3 mb-2">
                    <div className="w-10 h-10 rounded-full bg-[#EDE9FE] flex items-center justify-center flex-shrink-0">
                      <span className="text-sm font-medium text-[#7C3AED]">
                        {child.initials}
                      </span>
                    </div>
                    <div className="flex-1">
                      <div className="text-[15px] font-semibold text-[#0F172A]">
                        {child.firstName} {child.lastName}
                      </div>
                      <div className="text-[13px] text-[#64748B]">
                        {child.grade} • {child.school}
                      </div>
                    </div>
                  </div>
                  <div className="ml-13">
                    <span className="inline-flex items-center text-[13px]">
                      Health profile: <span className={`ml-1 font-medium ${child.healthStatusColor}`}>{child.healthStatus} ✓</span>
                    </span>
                  </div>
                </div>
              ))}

              {/* Add Child Row */}
              <button className="w-full p-4 flex items-center gap-3 text-left active:bg-gray-50">
                <div className="w-10 h-10 rounded-full bg-[#F1F5F9] flex items-center justify-center flex-shrink-0">
                  <Plus className="w-5 h-5 text-[#64748B]" />
                </div>
                <span className="text-[15px] font-medium text-[#2563EB]">
                  Add child
                </span>
              </button>
            </div>
          </section>

          {/* Notification Preferences */}
          <section>
            <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
              Notification Preferences
            </h2>
            <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
              {/* Emergency Alerts - LOCKED */}
              <div className="p-4 flex items-center gap-3">
                <AlertTriangle className="w-5 h-5 text-[#DC2626] flex-shrink-0" />
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                    Emergency alerts
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    Required by school policy
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-11 h-6 bg-[#2563EB] rounded-full flex items-center px-1 cursor-not-allowed opacity-60">
                    <div className="w-4 h-4 bg-white rounded-full ml-auto" />
                  </div>
                  <Shield className="w-4 h-4 text-[#64748B]" />
                </div>
              </div>

              {/* Clinic Visits */}
              <div className="p-4 flex items-center gap-3">
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Clinic visits
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, clinicVisits: !notifications.clinicVisits })}
                  className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
                    notifications.clinicVisits ? 'bg-[#2563EB]' : 'bg-gray-300'
                  }`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                    notifications.clinicVisits ? 'ml-auto' : ''
                  }`} />
                </button>
              </div>

              {/* Medication Administered */}
              <div className="p-4 flex items-center gap-3">
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Medication administered
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, medicationAdministered: !notifications.medicationAdministered })}
                  className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
                    notifications.medicationAdministered ? 'bg-[#2563EB]' : 'bg-gray-300'
                  }`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                    notifications.medicationAdministered ? 'ml-auto' : ''
                  }`} />
                </button>
              </div>

              {/* Bus Boarding/Arrival */}
              <div className="p-4 flex items-center gap-3">
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Bus boarding/arrival
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, busBoardingArrival: !notifications.busBoardingArrival })}
                  className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
                    notifications.busBoardingArrival ? 'bg-[#2563EB]' : 'bg-gray-300'
                  }`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                    notifications.busBoardingArrival ? 'ml-auto' : ''
                  }`} />
                </button>
              </div>

              {/* Document Reminders */}
              <div className="p-4 flex items-center gap-3">
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Document reminders
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, documentReminders: !notifications.documentReminders })}
                  className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
                    notifications.documentReminders ? 'bg-[#2563EB]' : 'bg-gray-300'
                  }`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                    notifications.documentReminders ? 'ml-auto' : ''
                  }`} />
                </button>
              </div>

              {/* School Announcements */}
              <div className="p-4 flex items-center gap-3">
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    School announcements
                  </div>
                </div>
                <button
                  onClick={() => setNotifications({ ...notifications, schoolAnnouncements: !notifications.schoolAnnouncements })}
                  className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
                    notifications.schoolAnnouncements ? 'bg-[#2563EB]' : 'bg-gray-300'
                  }`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                    notifications.schoolAnnouncements ? 'ml-auto' : ''
                  }`} />
                </button>
              </div>
            </div>
          </section>

          {/* Authorized Persons */}
          <section>
            <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
              Authorized Persons
            </h2>
            <button
              onClick={() => navigate('/parent/app/authorized-persons')}
              className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3 active:bg-gray-50"
            >
              <User className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              <span className="flex-1 text-left text-[14px] font-medium text-[#0F172A]">
                Manage pickup authorizations
              </span>
              <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
            </button>
          </section>

          {/* Legal & Privacy */}
          <section>
            <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
              Legal & Privacy
            </h2>
            <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
              {/* Signed Consents */}
              <div className="p-4">
                <div className="text-[14px] font-medium text-[#0F172A] mb-3">
                  My signed consents
                </div>
                <div className="space-y-2">
                  {signedConsents.map((consent) => (
                    <div key={consent.id} className="flex items-center justify-between py-2">
                      <div className="flex-1">
                        <div className="text-[13px] font-medium text-[#0F172A]">
                          {consent.title}
                        </div>
                        <div className="text-[12px] text-[#64748B]">
                          {consent.date}
                        </div>
                      </div>
                      <button className="text-[13px] text-[#2563EB] font-medium">
                        View
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Request Data Export */}
              <button className="w-full p-4 flex items-center gap-3 text-left active:bg-gray-50">
                <Download className="w-5 h-5 text-[#64748B] flex-shrink-0" />
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    Request data export
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    FERPA right to access records
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              </button>

              {/* Withdraw Consent */}
              <button
                onClick={handleWithdrawConsent}
                className="w-full p-4 flex items-center gap-3 text-left active:bg-gray-50"
              >
                <AlertTriangle className="w-5 h-5 text-[#DC2626] flex-shrink-0" />
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#DC2626]">
                    Withdraw consent
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    Impact warning will be shown
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
              </button>
            </div>
          </section>

          {/* Sign Out Button */}
          <button
            onClick={handleSignOut}
            className="w-full bg-white border border-[#DC2626] rounded-xl p-4 text-[15px] font-medium text-[#DC2626] active:bg-red-50"
          >
            Sign out
          </button>
        </div>
      </div>
    </div>
  );
}
