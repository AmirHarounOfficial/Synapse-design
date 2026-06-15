import { useNavigate } from 'react-router';
import { AlertTriangle, CheckCircle, AlertCircle, Users, Stethoscope, ChevronRight, Calendar, Bell, Settings } from 'lucide-react';
import { useState } from 'react';

export function TeacherDashboard() {
  const navigate = useNavigate();
  const [showWeatherBanner, setShowWeatherBanner] = useState(true);

  const todayStats = {
    present: 22,
    total: 24,
    absent: 2,
    medicalAlerts: 3
  };

  const upcomingReleases = [
    {
      id: '1',
      name: 'Emma Rodriguez',
      initials: 'ER',
      time: '10:30 AM',
      reason: 'Scheduled medication',
      status: 'pending'
    },
    {
      id: '2',
      name: 'Marcus Chen',
      initials: 'MC',
      time: '11:00 AM',
      reason: 'Routine check',
      status: 'called',
      calledAt: '11:02 AM'
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <div className="bg-white border-b border-gray-200 px-4 py-3">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-[17px] font-medium text-gray-900">
              Ms. Sarah Johnson
            </h1>
            <p className="text-[13px] text-[#64748B]">
              Room 204 — Grade 5
            </p>
          </div>
          <div className="flex items-center gap-1">
            <button
              onClick={() => navigate('/teacher/notifications')}
              className="flex items-center justify-center w-11 h-11 relative"
              aria-label="Notifications"
            >
              <Bell className="w-6 h-6 text-[#64748B]" />
              <div className="absolute top-2 right-2 w-2 h-2 bg-[#DC2626] rounded-full" />
            </button>
            <button
              onClick={() => navigate('/teacher/settings')}
              className="flex items-center justify-center w-11 h-11"
              aria-label="Settings"
            >
              <Settings className="w-6 h-6 text-[#64748B]" />
            </button>
          </div>
        </div>
      </div>

      <div className="px-4 py-4 space-y-4">
        {/* Today Summary */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            Today's Summary
          </h2>
          <div className="grid grid-cols-3 gap-2">
            <div className="bg-white rounded-lg border border-gray-200 p-3">
              <div className="flex items-center gap-1 mb-1">
                <CheckCircle className="w-4 h-4 text-[#10B981]" />
                <span className="text-[11px] text-[#64748B]">Present</span>
              </div>
              <div className="text-[20px] font-semibold text-gray-900">
                {todayStats.present}/{todayStats.total}
              </div>
            </div>

            <div className="bg-white rounded-lg border border-gray-200 p-3">
              <div className="flex items-center gap-1 mb-1">
                <Users className="w-4 h-4 text-[#64748B]" />
                <span className="text-[11px] text-[#64748B]">Absent</span>
              </div>
              <div className="text-[20px] font-semibold text-gray-900">
                {todayStats.absent}
              </div>
            </div>

            <div className="bg-white rounded-lg border border-gray-200 p-3">
              <div className="flex items-center gap-1 mb-1">
                <AlertCircle className="w-4 h-4 text-[#F59E0B]" />
                <span className="text-[11px] text-[#64748B]">Alerts</span>
              </div>
              <div className="text-[20px] font-semibold text-gray-900">
                {todayStats.medicalAlerts}
              </div>
            </div>
          </div>
        </div>

        {/* Weather Restriction Banner */}
        {showWeatherBanner && (
          <div className="bg-[#FEF3C7] border border-[#F59E0B] border-l-[3px] rounded-xl p-3">
            <div className="flex items-start gap-2 mb-2">
              <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <p className="text-[13px] text-[#92400E] font-medium mb-1">
                  Dust Storm Advisory
                </p>
                <p className="text-[13px] text-[#92400E]">
                  3 students must remain indoors today
                </p>
              </div>
            </div>
            <button
              onClick={() => navigate('/teacher/weather-restriction')}
              className="text-[13px] text-[#F59E0B] font-medium underline min-h-[44px] px-2 -ml-2"
            >
              View list
            </button>
          </div>
        )}

        {/* Medical Alerts Card */}
        <button
          onClick={() => navigate('/teacher/health-considerations')}
          className="w-full text-left bg-white rounded-xl border border-gray-200 border-l-[3px] border-l-[#F59E0B] p-4"
        >
          <div className="flex items-start gap-3 mb-2">
            <div className="w-10 h-10 rounded-full bg-[#FEF3C7] flex items-center justify-center flex-shrink-0">
              <AlertCircle className="w-5 h-5 text-[#F59E0B]" />
            </div>
            <div className="flex-1">
              <h3 className="text-[14px] font-medium text-gray-900 mb-1">
                Health Considerations
              </h3>
              <p className="text-[13px] text-[#64748B]">
                {todayStats.medicalAlerts} students have active health considerations
              </p>
            </div>
            <ChevronRight className="w-5 h-5 text-[#64748B] flex-shrink-0" />
          </div>
          <p className="text-[12px] text-[#92400E]">
            Tap to view safe-activity guidance
          </p>
        </button>

        {/* Upcoming Releases */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            Upcoming Clinic Visits
          </h2>
          <div className="space-y-2">
            {upcomingReleases.map((release) => (
              <div
                key={release.id}
                className="bg-white rounded-xl border border-gray-200 p-3"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[14px] font-medium flex-shrink-0">
                    {release.initials}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-[14px] font-medium text-gray-900">
                      {release.name}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      {release.time} • {release.reason}
                    </div>
                  </div>
                  {release.status === 'called' ? (
                    <div className="flex flex-col items-end gap-1">
                      <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-[11px] font-medium bg-[#DBEAFE] text-[#1E40AF]">
                        <Stethoscope className="w-3 h-3" />
                        Called to clinic
                      </span>
                      <span className="text-[11px] text-[#64748B]">
                        {release.calledAt}
                      </span>
                    </div>
                  ) : (
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-[11px] font-medium bg-[#F8FAFC] text-[#64748B]">
                      Scheduled
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div>
          <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
            Quick Actions
          </h2>
          <div className="space-y-3">
            <button
              onClick={() => navigate('/teacher/attendance')}
              className="w-full px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-medium min-h-[52px] flex items-center justify-center gap-2"
            >
              <Calendar className="w-5 h-5" />
              Take Attendance
            </button>
            <button
              onClick={() => navigate('/teacher/clinic-referral')}
              className="w-full px-4 py-3.5 bg-white border-2 border-[#2563EB] text-[#2563EB] rounded-lg text-[15px] font-medium min-h-[52px] flex items-center justify-center gap-2"
            >
              <Stethoscope className="w-5 h-5" />
              Send Clinic Referral
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
