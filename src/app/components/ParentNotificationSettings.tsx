import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Lock } from 'lucide-react';

interface NotificationPreferences {
  clinicPush: boolean;
  clinicSMS: boolean;
  clinicEmail: boolean;
  medicationPush: boolean;
  medicationSMS: boolean;
  documentsPush: boolean;
  documentsEmail: boolean;
  emergencyPush: boolean;
  emergencySMS: boolean;
}

export function ParentNotificationSettings() {
  const navigate = useNavigate();
  const [preferences, setPreferences] = useState<NotificationPreferences>({
    clinicPush: true,
    clinicSMS: true,
    clinicEmail: false,
    medicationPush: true,
    medicationSMS: false,
    documentsPush: true,
    documentsEmail: true,
    emergencyPush: true,
    emergencySMS: true
  });

  const togglePreference = (key: keyof NotificationPreferences) => {
    // Prevent toggling emergency notifications
    if (key === 'emergencyPush' || key === 'emergencySMS') {
      return;
    }
    
    setPreferences({
      ...preferences,
      [key]: !preferences[key]
    });
  };

  const ToggleSwitch = ({ 
    enabled, 
    onChange, 
    disabled 
  }: { 
    enabled: boolean; 
    onChange: () => void; 
    disabled?: boolean;
  }) => (
    <button
      onClick={onChange}
      disabled={disabled}
      className={`relative w-12 h-7 rounded-full transition-colors ${
        disabled 
          ? 'bg-[#10B981] cursor-not-allowed' 
          : enabled 
          ? 'bg-[#2563EB]' 
          : 'bg-gray-200'
      }`}
    >
      <div
        className={`absolute top-0.5 w-6 h-6 bg-white rounded-full shadow transition-transform ${
          enabled ? 'translate-x-[21px]' : 'translate-x-0.5'
        }`}
      />
    </button>
  );

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 -ml-2 flex items-center justify-center"
        >
          <ArrowLeft className="w-6 h-6 text-gray-900" />
        </button>
        <h1 className="flex-1 text-center font-medium text-gray-900 pr-10">
          Notification Preferences
        </h1>
      </header>

      <div className="px-4 py-4">
        {/* Clinic Alerts */}
        <div className="mb-6">
          <h2 className="text-[15px] font-semibold text-gray-900 mb-3">
            Clinic Alerts
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  Push Notifications
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Real-time alerts on your device
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.clinicPush}
                onChange={() => togglePreference('clinicPush')}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  SMS Text Messages
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Text message notifications
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.clinicSMS}
                onChange={() => togglePreference('clinicSMS')}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  Email
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Email summaries
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.clinicEmail}
                onChange={() => togglePreference('clinicEmail')}
              />
            </div>
          </div>
        </div>

        {/* Medication */}
        <div className="mb-6">
          <h2 className="text-[15px] font-semibold text-gray-900 mb-3">
            Medication
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  Push Notifications
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Dose confirmations and reminders
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.medicationPush}
                onChange={() => togglePreference('medicationPush')}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  SMS Text Messages
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Text message confirmations
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.medicationSMS}
                onChange={() => togglePreference('medicationSMS')}
              />
            </div>
          </div>
        </div>

        {/* Documents */}
        <div className="mb-6">
          <h2 className="text-[15px] font-semibold text-gray-900 mb-3">
            Documents
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  Push Notifications
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Approval status and expiry reminders
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.documentsPush}
                onChange={() => togglePreference('documentsPush')}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                  Email
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Document status updates
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.documentsEmail}
                onChange={() => togglePreference('documentsEmail')}
              />
            </div>
          </div>
        </div>

        {/* Emergency (Locked) */}
        <div className="mb-6">
          <h2 className="text-[15px] font-semibold text-gray-900 mb-3">
            Emergency
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            <div className="p-4 flex items-center justify-between">
              <div className="flex-1 pr-3">
                <div className="flex items-center gap-2 mb-0.5">
                  <span className="text-[15px] font-medium text-gray-900">
                    Push Notifications
                  </span>
                  <Lock className="w-4 h-4 text-[#10B981]" />
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Critical emergency alerts (required)
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.emergencyPush}
                onChange={() => {}}
                disabled
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1 pr-3">
                <div className="flex items-center gap-2 mb-0.5">
                  <span className="text-[15px] font-medium text-gray-900">
                    SMS Text Messages
                  </span>
                  <Lock className="w-4 h-4 text-[#10B981]" />
                </div>
                <div className="text-[12px] text-[#64748B]">
                  Emergency text alerts (required)
                </div>
              </div>
              <ToggleSwitch
                enabled={preferences.emergencySMS}
                onChange={() => {}}
                disabled
              />
            </div>
          </div>
        </div>

        {/* Emergency Info */}
        <div className="bg-[#FEE2E2] border border-[#DC2626] rounded-xl p-4">
          <div className="flex items-center gap-2 mb-2">
            <Lock className="w-4 h-4 text-[#DC2626]" />
            <span className="text-[13px] font-semibold text-[#991B1B]">
              Emergency Alerts Cannot Be Disabled
            </span>
          </div>
          <p className="text-[12px] text-[#991B1B] leading-relaxed">
            For your child's safety, emergency notifications are always enabled and cannot be turned off. These alerts are only sent for critical situations requiring immediate parent authorization or notification.
          </p>
        </div>
      </div>
    </div>
  );
}
