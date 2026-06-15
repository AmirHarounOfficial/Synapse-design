import { ChevronLeft, MoreVertical, AlertTriangle, CheckCircle, Bell } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function LowSupplyAlert() {
  const navigate = useNavigate();
  const [parentNotified, setParentNotified] = useState(false);
  const [notificationDate, setNotificationDate] = useState('');

  const handleNotifyParent = () => {
    const now = new Date();
    const formatted = now.toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric'
    }) + ' at ' + now.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });
    setNotificationDate(formatted);
    setParentNotified(true);
  };

  const dosesRemaining = 10;
  const totalDoses = 30;
  const supplyPercentage = (dosesRemaining / totalDoses) * 100;

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <button
          onClick={() => navigate('/nurse/medications')}
          className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
        >
          <ChevronLeft className="w-6 h-6 text-[#0F172A]" />
        </button>
        <h1 className="flex-1 text-[17px] font-medium text-[#0F172A] text-center pr-10" style={{ fontWeight: 500 }}>
          Maya Chen
        </h1>
        <button className="p-2 min-w-[44px] min-h-[44px] flex items-center justify-center">
          <MoreVertical className="w-6 h-6 text-[#64748B]" />
        </button>
      </div>

      {/* Amber Banner */}
      <div className="bg-[#F59E0B] px-4 py-3 flex items-center gap-3">
        <AlertTriangle className="w-6 h-6 text-white flex-shrink-0" />
        <h2 className="text-[16px] font-semibold text-white" style={{ fontWeight: 600 }}>
          Supply Alert
        </h2>
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Alert Card */}
        <div className="bg-[#FFFBEB] border-l-4 border-[#F59E0B] rounded-xl p-4">
          <div className="flex items-start gap-3 mb-4">
            <AlertTriangle className="w-6 h-6 text-[#F59E0B] flex-shrink-0 mt-1" />
            <div className="flex-1">
              <h3 className="text-[16px] font-semibold text-[#92400E] mb-2" style={{ fontWeight: 600 }}>
                5 days of Methylphenidate remaining for Maya Chen
              </h3>

              <div className="space-y-2 text-[13px] text-[#92400E]" style={{ fontWeight: 400 }}>
                <div className="flex justify-between">
                  <span>Current count:</span>
                  <span className="font-semibold" style={{ fontWeight: 600 }}>{dosesRemaining} doses</span>
                </div>
                <div className="flex justify-between">
                  <span>Expected depletion:</span>
                  <span className="font-semibold" style={{ fontWeight: 600 }}>May 24, 2026</span>
                </div>
                <div className="flex justify-between">
                  <span>Expiry date:</span>
                  <span className="font-semibold" style={{ fontWeight: 600 }}>June 15, 2026</span>
                </div>
              </div>
            </div>
          </div>

          {/* Supply Status Progress Bar */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <span className="text-[12px] font-semibold text-[#92400E]" style={{ fontWeight: 600 }}>
                Supply Status
              </span>
              <span className="text-[12px] font-semibold text-[#92400E]" style={{ fontWeight: 600 }}>
                {dosesRemaining} of {totalDoses} doses
              </span>
            </div>
            <div className="w-full bg-[#FEF3C7] rounded-full h-2">
              <div
                className="bg-[#F59E0B] h-2 rounded-full transition-all"
                style={{ width: `${supplyPercentage}%` }}
              />
            </div>
          </div>
        </div>

        {/* Action Section */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] space-y-4">
          <h3 className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
            Actions
          </h3>

          {!parentNotified ? (
            <>
              <button
                onClick={handleNotifyParent}
                className="w-full h-[52px] bg-[#2563EB] text-white rounded-xl font-semibold flex items-center justify-center gap-2"
                style={{ fontWeight: 600 }}
              >
                <Bell className="w-5 h-5" />
                Notify Parent
              </button>

              <p className="text-[12px] text-[#64748B] text-center" style={{ fontWeight: 400 }}>
                Sends automatic supply alert to parent via SMS and app notification
              </p>
            </>
          ) : (
            <div className="bg-[#D1FAE5] border-l-4 border-[#10B981] rounded-xl p-4">
              <div className="flex items-start gap-3">
                <CheckCircle className="w-5 h-5 text-[#10B981] flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <p className="text-[14px] font-semibold text-[#065F46] mb-1" style={{ fontWeight: 600 }}>
                    Parent Notified
                  </p>
                  <p className="text-[13px] text-[#065F46]" style={{ fontWeight: 400 }}>
                    {notificationDate}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Medication Details Card */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] space-y-3">
          <h3 className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
            Medication Details
          </h3>

          <div className="space-y-2">
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Medication</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>Methylphenidate 10mg</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Type</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>Permanent</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E2E8F0]">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Daily Doses</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>1 dose at 8:00 AM</span>
            </div>
            <div className="flex justify-between py-2">
              <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>Prescribing Physician</span>
              <span className="text-[13px] text-[#0F172A] font-medium" style={{ fontWeight: 500 }}>Dr. Rodriguez</span>
            </div>
          </div>
        </div>

        {/* Reorder Information */}
        <div className="bg-[#EFF6FF] border-l-4 border-[#2563EB] rounded-xl p-4">
          <h3 className="text-[14px] font-semibold text-[#1E40AF] mb-2" style={{ fontWeight: 600 }}>
            Reorder Information
          </h3>
          <p className="text-[13px] text-[#1E40AF] mb-3" style={{ fontWeight: 400 }}>
            Parents must coordinate with prescribing physician for refill authorization. School policy requires 7-day supply buffer.
          </p>
          <p className="text-[12px] text-[#1E40AF]" style={{ fontWeight: 400 }}>
            <span className="font-semibold" style={{ fontWeight: 600 }}>Recommended action:</span> Notify parent at least 7 days before depletion
          </p>
        </div>
      </div>
    </div>
  );
}
