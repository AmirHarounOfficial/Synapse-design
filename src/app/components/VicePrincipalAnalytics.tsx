import { TrendingUp, Users, Heart, Activity, Lock, Info } from 'lucide-react';

export function VicePrincipalAnalytics() {
  const weeklyVisits = [
    { day: 'Mon', visits: 8 },
    { day: 'Tue', visits: 12 },
    { day: 'Wed', visits: 15 },
    { day: 'Thu', visits: 10 },
    { day: 'Fri', visits: 14 }
  ];

  const maxVisits = Math.max(...weeklyVisits.map(d => d.visits));

  const availableMetrics = [
    { label: 'Total clinic visits', value: '59', change: '+12%', icon: Heart, color: 'text-[#14B8A6]', bg: 'bg-[#CCFBF1]' },
    { label: 'Daily average', value: '11.8', change: '+2.4', icon: Activity, color: 'text-[#2563EB]', bg: 'bg-[#DBEAFE]' },
    { label: 'Peak day', value: 'Wed', change: '15 visits', icon: TrendingUp, color: 'text-[#10B981]', bg: 'bg-[#D1FAE5]' }
  ];

  const lockedMetrics = [
    { label: 'Medication details', subtitle: 'Principal access only' },
    { label: 'Condition breakdown', subtitle: 'Principal access only' },
    { label: 'Individual student data', subtitle: 'Principal access only' }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Analytics
        </h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Permission Notice */}
        <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-xl p-4">
          <div className="flex items-start gap-3">
            <Info className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[13px] text-[#1E40AF] leading-relaxed">
                You have access to aggregate health analytics. Detailed breakdowns and individual student data require Principal authorization.
              </div>
            </div>
          </div>
        </div>

        {/* Time Period */}
        <div className="flex items-center justify-between">
          <h2 className="text-[15px] font-semibold text-[#0F172A]">
            This Week's Summary
          </h2>
          <div className="text-[12px] text-[#64748B]">
            May 26 - May 30, 2026
          </div>
        </div>

        {/* Available Metrics */}
        <div className="grid grid-cols-3 gap-3">
          {availableMetrics.map((metric) => {
            const Icon = metric.icon;
            return (
              <div key={metric.label} className="bg-white rounded-xl border border-gray-200 p-3">
                <div className={`w-8 h-8 rounded-full ${metric.bg} flex items-center justify-center mb-2`}>
                  <Icon className={`w-4 h-4 ${metric.color}`} />
                </div>
                <div className="text-[18px] font-semibold text-[#0F172A] mb-0.5">
                  {metric.value}
                </div>
                <div className="text-[10px] text-[#64748B] mb-1">
                  {metric.label}
                </div>
                <div className="text-[10px] text-[#10B981] font-medium">
                  {metric.change}
                </div>
              </div>
            );
          })}
        </div>

        {/* Weekly Trend Chart */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-4">
            Daily Clinic Visits
          </h3>
          <div className="flex items-end justify-between gap-2 h-32">
            {weeklyVisits.map((day) => {
              const heightPercentage = (day.visits / maxVisits) * 100;
              return (
                <div key={day.day} className="flex-1 flex flex-col items-center gap-2">
                  <div className="w-full flex flex-col items-center justify-end flex-1">
                    <div className="text-[11px] font-medium text-[#0F172A] mb-1">
                      {day.visits}
                    </div>
                    <div
                      className="w-full bg-[#2563EB] rounded-t"
                      style={{ height: `${heightPercentage}%` }}
                    />
                  </div>
                  <div className="text-[11px] text-[#64748B] font-medium">
                    {day.day}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Locked Sections */}
        <div>
          <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3 flex items-center gap-2">
            <Lock className="w-4 h-4 text-[#64748B]" />
            <span>Limited Access</span>
          </h2>
          <div className="space-y-3">
            {lockedMetrics.map((metric) => (
              <div
                key={metric.label}
                className="bg-white rounded-xl border border-gray-200 p-4 opacity-60 relative"
              >
                <div className="absolute top-3 right-3">
                  <Lock className="w-4 h-4 text-[#64748B]" />
                </div>
                <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                  {metric.label}
                </div>
                <div className="text-[12px] text-[#64748B]">
                  {metric.subtitle}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Stats Info */}
        <div className="bg-[#F1F5F9] rounded-lg p-3">
          <div className="flex items-start gap-2">
            <Users className="w-4 h-4 text-[#64748B] flex-shrink-0 mt-0.5" />
            <div className="text-[12px] text-[#64748B] leading-relaxed">
              <strong>Privacy Notice:</strong> All analytics shown are aggregate data only. No individual student health information is displayed. Detailed breakdowns require Principal authorization.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
