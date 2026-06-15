import { useNavigate } from 'react-router';
import { Heart, Pill, FileText, AlertTriangle, Users, Lock, Mail, CloudAlert, Moon, BarChart3, CheckCircle } from 'lucide-react';
import { useState } from 'react';

export function PrincipalDashboard() {
  const navigate = useNavigate();
  const [advisoryActive, setAdvisoryActive] = useState(false);
  const [advisoryTime, setAdvisoryTime] = useState('');

  const healthStats = [
    { label: 'Clinic visits today', value: '12', icon: Heart, color: 'text-[#14B8A6]', bg: 'bg-[#CCFBF1]' },
    { label: 'Medications due', value: '8', icon: Pill, color: 'text-[#2563EB]', bg: 'bg-[#DBEAFE]' },
    { label: 'Pending docs', value: '3', icon: FileText, color: 'text-[#F59E0B]', bg: 'bg-[#FEF3C7]', hasBadge: true },
    { label: 'Active alerts', value: '1', icon: AlertTriangle, color: 'text-[#DC2626]', bg: 'bg-[#FEE2E2]', hasBadge: true }
  ];

  const quickActions = [
    { id: 'message', label: 'Send Message', icon: Mail, color: 'text-[#06B6D4]', bg: 'bg-[#CFFAFE]', action: () => {} },
    { id: 'advisory', label: 'Issue Advisory', icon: CloudAlert, color: 'text-[#F59E0B]', bg: 'bg-[#FEF3C7]', action: () => navigate('/principal/weather-advisory') },
    { id: 'after-hours', label: 'After-Hours Access', icon: Moon, color: 'text-[#64748B]', bg: 'bg-[#F1F5F9]', action: () => {} },
    { id: 'report', label: 'Generate Report', icon: BarChart3, color: 'text-[#2563EB]', bg: 'bg-[#DBEAFE]', action: () => {} }
  ];

  const handleIssueAdvisory = () => {
    setAdvisoryActive(true);
    setAdvisoryTime(new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }));
  };

  const handleDismissAdvisory = () => {
    setAdvisoryActive(false);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Lakewood Elementary
        </h1>
        <button
          onClick={() => navigate('/principal/settings')}
          className="w-10 h-10 -mr-2 flex items-center justify-center"
        >
          <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center">
            <span className="text-[14px] font-medium text-[#2563EB]">LR</span>
          </div>
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* School Health Summary Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[16px] font-medium text-[#0F172A] mb-3">
            Today's Health Overview
          </h2>
          <div className="grid grid-cols-2 gap-3 mb-3">
            {healthStats.map((stat) => {
              const Icon = stat.icon;
              return (
                <div key={stat.label} className="flex items-center gap-2">
                  <div className={`w-8 h-8 rounded-full ${stat.bg} flex items-center justify-center flex-shrink-0 relative`}>
                    <Icon className={`w-4 h-4 ${stat.color}`} />
                    {stat.hasBadge && (
                      <div className="absolute -top-0.5 -right-0.5 w-2 h-2 bg-[#DC2626] rounded-full" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-[13px] text-[#64748B] leading-tight">
                      {stat.label}
                    </div>
                    <div className="text-[16px] font-semibold text-[#0F172A]">
                      {stat.value}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
          <button
            onClick={() => navigate('/principal/analytics')}
            className="text-[13px] text-[#2563EB] font-medium"
          >
            View full analytics →
          </button>
        </div>

        {/* Weather Advisory Card */}
        {!advisoryActive ? (
          <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4">
            <div className="flex items-start gap-3 mb-3">
              <CloudAlert className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[14px] font-semibold text-[#92400E] mb-1">
                  ⚠ AQI Advisory — Moderate dust risk at 2PM today
                </div>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <button
                onClick={() => navigate('/principal/weather-advisory')}
                className="flex-1 h-[40px] bg-[#2563EB] text-white rounded-lg font-medium text-[14px] active:bg-[#1D4ED8]"
              >
                Issue advisory now
              </button>
              <button
                onClick={handleDismissAdvisory}
                className="text-[14px] text-[#92400E] font-medium px-3"
              >
                Dismiss
              </button>
            </div>
          </div>
        ) : (
          <div className="bg-[#D1FAE5] border border-[#10B981] rounded-xl p-4">
            <div className="flex items-start gap-3">
              <CheckCircle className="w-5 h-5 text-[#10B981] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[14px] font-semibold text-[#065F46]">
                  Advisory active — issued at {advisoryTime}
                </div>
                <div className="text-[12px] text-[#065F46] mt-1">
                  All staff and parents have been notified
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Staff Activity Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <Users className="w-5 h-5 text-[#64748B]" />
              <span className="text-[14px] font-medium text-[#0F172A]">
                Active staff now: 14 of 18
              </span>
            </div>
          </div>
          <div className="w-full h-2 bg-[#F1F5F9] rounded-full overflow-hidden mb-2">
            <div className="h-full bg-[#10B981] rounded-full" style={{ width: '77.8%' }} />
          </div>
          <button
            onClick={() => navigate('/principal/staff')}
            className="text-[13px] text-[#2563EB] font-medium"
          >
            View all →
          </button>
        </div>

        {/* Legal Status Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-3 mb-3">
            <Lock className="w-5 h-5 text-[#64748B] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[14px] font-medium text-[#0F172A] mb-1">
                Platform agreement: Active ✓
              </div>
              <button className="text-[13px] text-[#F59E0B] font-medium">
                Parent consents pending: 3
              </button>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div>
          <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
            Quick Actions
          </h2>
          <div className="grid grid-cols-2 gap-3">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <button
                  key={action.id}
                  onClick={action.action}
                  className="bg-white rounded-xl border border-gray-200 p-4 flex flex-col items-center gap-3 min-h-[100px] active:bg-gray-50"
                >
                  <div className={`w-12 h-12 rounded-full ${action.bg} flex items-center justify-center`}>
                    <Icon className={`w-6 h-6 ${action.color}`} />
                  </div>
                  <span className="text-[13px] font-medium text-[#0F172A] text-center">
                    {action.label}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
