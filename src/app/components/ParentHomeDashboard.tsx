import { useNavigate } from 'react-router';
import { Bell, CheckCircle, Clock, Pill, Bus, FileText, MessageCircle, Upload, AlertTriangle } from 'lucide-react';

export function ParentHomeDashboard() {
  const navigate = useNavigate();

  // In real app, this would come from API
  const parent = {
    firstName: 'James'
  };

  const children = [
    {
      id: '1',
      firstName: 'Maya',
      lastName: 'Thompson',
      grade: '4th Grade',
      school: 'Lakeside Elementary',
      status: 'Present',
      lastClinicVisit: '3 days ago'
    }
  ];

  const currentChild = children[0];

  const recentActivity = [
    {
      id: '1',
      type: 'medication',
      icon: Pill,
      description: 'Ritalin administered',
      time: '10:30 AM',
      color: 'text-[#2563EB]',
      bg: 'bg-[#EFF6FF]'
    },
    {
      id: '2',
      type: 'bus',
      icon: Bus,
      description: 'Boarded Route 12',
      time: '7:45 AM',
      color: 'text-[#10B981]',
      bg: 'bg-[#D1FAE5]'
    },
    {
      id: '3',
      type: 'clinic',
      icon: FileText,
      description: 'Clinic visit - Minor',
      time: '3 days ago',
      color: 'text-[#64748B]',
      bg: 'bg-gray-100'
    }
  ];

  const quickActions = [
    {
      id: 'report-dose',
      label: 'Report home dose',
      icon: Clock,
      color: 'text-[#2563EB]',
      bg: 'bg-[#EFF6FF]',
      action: () => navigate('/parent/app/report-home-dose')
    },
    {
      id: 'medications',
      label: 'View medications',
      icon: Pill,
      color: 'text-[#10B981]',
      bg: 'bg-[#D1FAE5]',
      action: () => navigate('/parent/app/medications')
    },
    {
      id: 'upload',
      label: 'Upload document',
      icon: Upload,
      color: 'text-[#F59E0B]',
      bg: 'bg-[#FEF3C7]',
      action: () => navigate('/parent/app/document-upload')
    },
    {
      id: 'chat',
      label: 'Chat with school',
      icon: MessageCircle,
      color: 'text-[#8B5CF6]',
      bg: 'bg-[#EDE9FE]',
      action: () => navigate('/parent/app/chat')
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-gray-900">
          Hello, {parent.firstName} 👋
        </h1>
        <button
          onClick={() => navigate('/parent/app/notifications')}
          className="w-10 h-10 -mr-2 flex items-center justify-center relative"
        >
          <Bell className="w-6 h-6 text-gray-900" />
          <div className="absolute top-2 right-2 w-2 h-2 bg-[#DC2626] rounded-full" />
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Today Overview Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-3 mb-4">
            <div className="w-12 h-12 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
              <span className="text-[17px] font-semibold text-[#2563EB]">
                {currentChild.firstName[0]}{currentChild.lastName[0]}
              </span>
            </div>
            <div className="flex-1">
              <div className="text-[17px] font-semibold text-gray-900 mb-0.5">
                {currentChild.firstName} {currentChild.lastName}
              </div>
              <div className="text-[13px] text-[#64748B]">
                {currentChild.grade} • {currentChild.school}
              </div>
            </div>
          </div>

          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-[#10B981]" />
              <span className="text-[14px] text-gray-900">
                School status: <span className="font-semibold text-[#10B981]">Present ✓</span>
              </span>
            </div>
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-[#64748B]" />
              <span className="text-[14px] text-[#64748B]">
                Last clinic visit: {currentChild.lastClinicVisit}
              </span>
            </div>
          </div>
        </div>

        {/* Pending Consent Banner */}
        <button
          onClick={() => navigate('/parent/app/emergency-consent')}
          className="w-full bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4 flex items-start gap-3 active:bg-[#FDE68A]"
        >
          <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
          <div className="flex-1 text-left">
            <div className="text-[15px] font-semibold text-[#92400E] mb-1">
              Emergency consent request pending
            </div>
            <div className="text-[13px] text-[#92400E]">
              Tap to respond • Expires in 08:23
            </div>
          </div>
        </button>

        {/* Recent Activity */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[15px] font-semibold text-gray-900">
              Recent Activity
            </h2>
            <button
              onClick={() => navigate('/parent/app/health')}
              className="text-[13px] text-[#2563EB] font-medium"
            >
              View all
            </button>
          </div>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {recentActivity.map((activity, index) => {
              const Icon = activity.icon;
              return (
                <div key={activity.id} className="p-4 flex items-center gap-3">
                  <div className={`w-10 h-10 rounded-full ${activity.bg} flex items-center justify-center flex-shrink-0`}>
                    <Icon className={`w-5 h-5 ${activity.color}`} />
                  </div>
                  <div className="flex-1">
                    <div className="text-[14px] font-medium text-gray-900">
                      {activity.description}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      {activity.time}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Quick Actions */}
        <div>
          <h2 className="text-[15px] font-semibold text-gray-900 mb-3">
            Quick Actions
          </h2>

          <div className="grid grid-cols-2 gap-3">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <button
                  key={action.id}
                  onClick={action.action}
                  className="bg-white rounded-xl border border-gray-200 p-4 flex flex-col items-center gap-3 min-h-[112px] active:bg-gray-50"
                >
                  <div className={`w-12 h-12 rounded-full ${action.bg} flex items-center justify-center`}>
                    <Icon className={`w-6 h-6 ${action.color}`} />
                  </div>
                  <span className="text-[13px] font-medium text-gray-900 text-center">
                    {action.label}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Document Expiry Reminder */}
        <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4">
          <div className="flex items-start gap-3">
            <FileText className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[14px] font-semibold text-[#92400E] mb-1">
                Health Insurance Card expires in 28 days
              </div>
              <button className="text-[13px] text-[#2563EB] font-medium">
                Upload new document
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}