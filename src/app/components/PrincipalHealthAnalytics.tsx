import { useNavigate } from 'react-router';
import { Calendar, Heart, Users, Pill, AlertTriangle, Info, CloudAlert } from 'lucide-react';
import { useState } from 'react';

export function PrincipalHealthAnalytics() {
  const navigate = useNavigate();
  const [dateRange, setDateRange] = useState('month');

  const stats = [
    { label: 'Total clinic visits', value: '147', icon: Heart, color: 'text-[#14B8A6]', bg: 'bg-[#CCFBF1]' },
    { label: 'Unique students seen', value: '62', icon: Users, color: 'text-[#2563EB]', bg: 'bg-[#DBEAFE]' },
    { label: 'Medications administered', value: '312', icon: Pill, color: 'text-[#10B981]', bg: 'bg-[#D1FAE5]' },
    { label: 'Emergency events', value: '3', icon: AlertTriangle, color: 'text-[#DC2626]', bg: 'bg-[#FEE2E2]' }
  ];

  const weeklyVisits = [
    { week: 'Week 1', visits: 18, hasAdvisory: false, isRamadan: false },
    { week: 'Week 2', visits: 22, hasAdvisory: false, isRamadan: false },
    { week: 'Week 3', visits: 15, hasAdvisory: false, isRamadan: false },
    { week: 'Week 4', visits: 19, hasAdvisory: false, isRamadan: false },
    { week: 'Week 5', visits: 42, hasAdvisory: true, isRamadan: true },
    { week: 'Week 6', visits: 38, hasAdvisory: true, isRamadan: true },
    { week: 'Week 7', visits: 45, hasAdvisory: true, isRamadan: false },
    { week: 'Week 8', visits: 21, hasAdvisory: false, isRamadan: false }
  ];

  const maxVisits = Math.max(...weeklyVisits.map(w => w.visits));

  const conditions = [
    { category: 'Respiratory / Asthma', count: 34, percentage: 23, color: 'bg-[#2563EB]' },
    { category: 'Injury', count: 28, percentage: 19, color: 'bg-[#14B8A6]' },
    { category: 'Gastrointestinal', count: 22, percentage: 15, color: 'bg-[#10B981]' },
    { category: 'Headache', count: 18, percentage: 12, color: 'bg-[#F59E0B]' },
    { category: 'Fever / Illness', count: 15, percentage: 10, color: 'bg-[#8B5CF6]' },
    { category: 'Other', count: 30, percentage: 21, color: 'bg-[#64748B]' }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Health Analytics
        </h1>
        <button className="flex items-center gap-2 px-3 h-[36px] bg-[#F1F5F9] rounded-lg text-[13px] font-medium text-[#0F172A]">
          <Calendar className="w-4 h-4" />
          <select
            value={dateRange}
            onChange={(e) => setDateRange(e.target.value)}
            className="bg-transparent outline-none text-[13px] font-medium"
          >
            <option value="month">This month</option>
            <option value="semester">This semester</option>
            <option value="year">This year</option>
          </select>
        </button>
      </header>

      {/* Privacy Notice */}
      <div className="px-4 pt-4">
        <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-lg p-3">
          <div className="flex items-start gap-2">
            <Info className="w-4 h-4 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <p className="text-[11px] text-[#1E40AF] leading-relaxed">
              This dashboard shows aggregate statistics. No individual student data is displayed.
            </p>
          </div>
        </div>
      </div>

      <div className="px-4 py-4 space-y-4">
        {/* Stat Summary */}
        <div className="grid grid-cols-2 gap-3">
          {stats.map((stat) => {
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
        </div>

        {/* Visit Trends Chart */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[14px] font-semibold text-[#0F172A]">
              Weekly Clinic Visits
            </h2>
            <span className="text-[10px] text-slate-400 font-semibold uppercase">
              Source: UAE NCM (المركز الوطني للأرصاد)
            </span>
          </div>
          
          <div className="space-y-2">
            {weeklyVisits.map((week, index) => (
              <div key={index} className="flex items-center gap-2">
                <div className="w-12 text-[10px] text-[#64748B] flex-shrink-0">
                  {week.week}
                </div>
                <div className="flex-1 relative">
                  <div className="w-full h-6 bg-[#F1F5F9] rounded overflow-hidden">
                    <div
                      className={`h-full rounded ${
                        week.isRamadan 
                          ? 'bg-amber-600' 
                          : (week.hasAdvisory ? 'bg-[#F59E0B]' : 'bg-[#2563EB]')
                      }`}
                      style={{ width: `${(week.visits / maxVisits) * 100}%` }}
                    />
                  </div>
                  {week.isRamadan && (
                    <div className="absolute top-0 bottom-0 left-0 w-0.5 bg-amber-500 flex items-center">
                      <span className="absolute -left-20 text-[9px] font-bold text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded border border-amber-200 whitespace-nowrap z-10">
                        رمضان · Ramadan
                      </span>
                    </div>
                  )}
                  {week.hasAdvisory && !week.isRamadan && (
                    <CloudAlert className="absolute right-1 top-1/2 -translate-y-1/2 w-3 h-3 text-white" />
                  )}
                </div>
                <div className="w-8 text-[11px] text-[#0F172A] font-medium text-right flex-shrink-0">
                  {week.visits}
                </div>
              </div>
            ))}
          </div>
          <div className="mt-3 flex items-center flex-wrap gap-4 text-[10px]">
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 bg-[#2563EB] rounded" />
              <span className="text-[#64748B]">Normal week</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 bg-[#F59E0B] rounded" />
              <span className="text-[#64748B]">Advisory week</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 bg-amber-600 rounded" />
              <span className="text-[#64748B]">رمضان · Ramadan</span>
            </div>
          </div>
        </div>

        {/* Weather Correlation */}
        <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4">
          <div className="flex items-start gap-3 text-left">
            <CloudAlert className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[13px] font-semibold text-[#92400E] mb-1">
                Weather Correlation (UAE NCM)
              </div>
              <div className="text-[12px] text-[#92400E] leading-relaxed">
                During the 3 Haboob / عاصفة رملية (Sandstorm) days this month, respiratory clinic visits increased 340% vs. average.
              </div>
            </div>
          </div>
        </div>

        {/* Condition Breakdown */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Visit Categories
          </h2>
          <div className="space-y-3">
            {conditions.map((condition) => (
              <div key={condition.category}>
                <div className="flex items-center justify-between mb-1">
                  <div className="text-[12px] font-medium text-[#0F172A]">
                    {condition.category}
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    {condition.count} visits · {condition.percentage}%
                  </div>
                </div>
                <div className="w-full h-2 bg-[#F1F5F9] rounded-full overflow-hidden">
                  <div
                    className={`h-full ${condition.color} rounded-full`}
                    style={{ width: `${condition.percentage}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Medication Compliance */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-center justify-between mb-2">
            <h2 className="text-[14px] font-semibold text-[#0F172A]">
              Medication Compliance
            </h2>
            <Pill className="w-5 h-5 text-[#10B981]" />
          </div>
          <div className="text-[24px] font-semibold text-[#10B981] mb-1">
            98.2%
          </div>
          <div className="text-[12px] text-[#64748B]">
            Of scheduled doses administered on time
          </div>
          <div className="w-full h-2 bg-[#F1F5F9] rounded-full overflow-hidden mt-3">
            <div className="h-full bg-[#10B981] rounded-full" style={{ width: '98.2%' }} />
          </div>
        </div>
      </div>
    </div>
  );
}
