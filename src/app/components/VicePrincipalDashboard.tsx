import { useNavigate } from 'react-router';
import { Info, Heart, Users, Pill, Lock, AlertTriangle, BarChart3, Clipboard } from 'lucide-react';

export function VicePrincipalDashboard() {
  const navigate = useNavigate();

  const availableStats = [
    { label: "Today's clinic visits", value: '12', icon: Heart, color: 'text-[#14B8A6]', bg: 'bg-[#CCFBF1]', locked: false },
    { label: 'Staff active', value: '14', icon: Users, color: 'text-[#2563EB]', bg: 'bg-[#DBEAFE]', locked: false }
  ];

  const lockedStats = [
    { label: 'Medication details', subtitle: 'Access not granted', icon: Pill }
  ];

  const quickActions = [
    { id: 'analytics', label: 'View analytics', icon: BarChart3, color: 'text-[#2563EB]', bg: 'bg-[#DBEAFE]', locked: false, action: () => navigate('/vice-principal/analytics') },
    { id: 'clinic', label: 'View clinic readiness', icon: Clipboard, color: 'text-[#10B981]', bg: 'bg-[#D1FAE5]', locked: false, action: () => navigate('/vice-principal/clinic-readiness') },
    { id: 'staff', label: 'Manage staff', icon: Users, color: 'text-[#64748B]', bg: 'bg-[#F1F5F9]', locked: true, action: () => {} },
    { id: 'advisory', label: 'Issue advisory', icon: AlertTriangle, color: 'text-[#64748B]', bg: 'bg-[#F1F5F9]', locked: true, action: () => {} }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Deputy Dashboard
        </h1>
        <button
          onClick={() => navigate('/vice-principal/settings')}
          className="w-10 h-10 -mr-2 flex items-center justify-center"
        >
          <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center">
            <span className="text-[14px] font-medium text-[#2563EB]">VD</span>
          </div>
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Delegation Notice */}
        <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-xl p-4">
          <div className="flex items-start gap-3">
            <Info className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[13px] text-[#1E40AF] leading-relaxed">
                Your permissions are delegated by Principal M. Davis. Contact the Principal to modify your access.
              </div>
            </div>
          </div>
        </div>

        {/* Summary Stats */}
        <div>
          <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
            Summary
          </h2>
          <div className="grid grid-cols-2 gap-3">
            {availableStats.map((stat) => {
              const Icon = stat.icon;
              return (
                <div key={stat.label} className="bg-white rounded-xl border border-gray-200 p-3">
                  <div className={`w-10 h-10 rounded-full ${stat.bg} flex items-center justify-center mb-2`}>
                    <Icon className={`w-5 h-5 ${stat.color}`} />
                  </div>
                  <div className="text-[20px] font-semibold text-[#0F172A] mb-0.5">
                    {stat.value}
                  </div>
                  <div className="text-[11px] text-[#64748B]">
                    {stat.label}
                  </div>
                </div>
              );
            })}
            {lockedStats.map((stat) => {
              const Icon = stat.icon;
              return (
                <div key={stat.label} className="bg-white rounded-xl border border-gray-200 p-3 opacity-50 relative">
                  <div className="absolute top-2 right-2">
                    <Lock className="w-4 h-4 text-[#64748B]" />
                  </div>
                  <div className="w-10 h-10 rounded-full bg-[#F1F5F9] flex items-center justify-center mb-2">
                    <Icon className="w-5 h-5 text-[#64748B]" />
                  </div>
                  <div className="text-[14px] font-medium text-[#64748B] mb-0.5">
                    {stat.label}
                  </div>
                  <div className="text-[11px] text-[#64748B]">
                    {stat.subtitle}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Clinic Readiness Alert */}
        <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[14px] font-semibold text-[#92400E] mb-1">
                ⚠ 3 clinic items require end-of-year attention
              </div>
              <button
                onClick={() => navigate('/vice-principal/clinic-readiness')}
                className="text-[13px] text-[#2563EB] font-medium"
              >
                Review →
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
                  disabled={action.locked}
                  className={`bg-white rounded-xl border border-gray-200 p-4 flex flex-col items-center gap-3 min-h-[100px] relative ${
                    action.locked ? 'opacity-50 cursor-not-allowed' : 'active:bg-gray-50'
                  }`}
                >
                  {action.locked && (
                    <div className="absolute top-2 right-2">
                      <Lock className="w-4 h-4 text-[#64748B]" />
                    </div>
                  )}
                  <div className={`w-12 h-12 rounded-full ${action.bg} flex items-center justify-center`}>
                    <Icon className={`w-6 h-6 ${action.color}`} />
                  </div>
                  <span className="text-[13px] font-medium text-[#0F172A] text-center">
                    {action.label}
                  </span>
                  {action.locked && (
                    <span className="text-[10px] text-[#64748B] text-center">
                      Request access from Principal
                    </span>
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* Access Info */}
        <button
          onClick={() => navigate('/vice-principal/permissions')}
          className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center justify-between active:bg-gray-50"
        >
          <div className="flex items-center gap-3">
            <Lock className="w-5 h-5 text-[#64748B]" />
            <span className="text-[14px] font-medium text-[#0F172A]">
              View my access level
            </span>
          </div>
          <svg className="w-5 h-5 text-[#64748B]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
          </svg>
        </button>
      </div>
    </div>
  );
}
