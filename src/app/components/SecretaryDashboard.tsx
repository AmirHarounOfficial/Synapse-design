import { useNavigate } from 'react-router';
import { Bell, Upload, MessageCircle, Bot, Users, AlertCircle } from 'lucide-react';
import { HasanaSyncWidget } from './HasanaSyncWidget';

export function SecretaryDashboard() {
  const navigate = useNavigate();

  const pendingTasks = [
    {
      id: '1',
      icon: MessageCircle,
      description: '2 parents awaiting responses',
      action: () => navigate('/secretary/messages'),
      color: 'text-[#2563EB]',
      bg: 'bg-[#EFF6FF]'
    },
    {
      id: '2',
      icon: Bot,
      description: '1 chatbot escalation',
      action: () => navigate('/secretary/chatbot'),
      color: 'text-[#F59E0B]',
      bg: 'bg-[#FEF3C7]'
    },
    {
      id: '3',
      icon: Upload,
      description: 'Excel import ready to review',
      action: () => navigate('/secretary/import-students'),
      color: 'text-[#10B981]',
      bg: 'bg-[#D1FAE5]'
    }
  ];

  const quickActions = [
    {
      id: 'import',
      label: 'Import students',
      icon: Upload,
      color: 'text-[#10B981]',
      bg: 'bg-[#D1FAE5]',
      action: () => navigate('/secretary/import-students')
    },
    {
      id: 'compose',
      label: 'Compose message',
      icon: MessageCircle,
      color: 'text-[#2563EB]',
      bg: 'bg-[#EFF6FF]',
      action: () => navigate('/secretary/compose-message')
    },
    {
      id: 'chatbot',
      label: 'View chatbot queue',
      icon: Bot,
      color: 'text-[#8B5CF6]',
      bg: 'bg-[#EDE9FE]',
      action: () => navigate('/secretary/chatbot')
    },
    {
      id: 'students',
      label: 'Student directory',
      icon: Users,
      color: 'text-[#64748B]',
      bg: 'bg-[#F1F5F9]',
      action: () => navigate('/secretary/students')
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Administration
        </h1>
        <button className="w-10 h-10 -mr-2 flex items-center justify-center relative">
          <Bell className="w-6 h-6 text-[#0F172A]" />
          <div className="absolute top-2 right-2 w-2 h-2 bg-[#DC2626] rounded-full" />
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Pending Tasks */}
        <div>
          <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
            Pending Tasks
          </h2>
          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {pendingTasks.map((task) => {
              const Icon = task.icon;
              return (
                <button
                  key={task.id}
                  onClick={task.action}
                  className="w-full p-4 flex items-center gap-3 text-left active:bg-gray-50"
                >
                  <div className={`w-10 h-10 rounded-full ${task.bg} flex items-center justify-center flex-shrink-0`}>
                    <Icon className={`w-5 h-5 ${task.color}`} />
                  </div>
                  <div className="flex-1">
                    <div className="text-[14px] font-medium text-[#0F172A]">
                      {task.description}
                    </div>
                  </div>
                  <AlertCircle className="w-5 h-5 text-[#F59E0B] flex-shrink-0" />
                </button>
              );
            })}
          </div>
        </div>

        {/* HASANA Sync Widget */}
        <HasanaSyncWidget />

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
                  className="bg-white rounded-xl border border-gray-200 p-4 flex flex-col items-center gap-3 min-h-[112px] active:bg-gray-50"
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

        {/* Today's Stats */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Today's Activity
          </h3>
          <div className="grid grid-cols-3 gap-3">
            <div className="text-center">
              <div className="text-[20px] font-semibold text-[#2563EB] mb-0.5">
                12
              </div>
              <div className="text-[11px] text-[#64748B]">
                Messages sent
              </div>
            </div>
            <div className="text-center">
              <div className="text-[20px] font-semibold text-[#10B981] mb-0.5">
                5
              </div>
              <div className="text-[11px] text-[#64748B]">
                Escalations resolved
              </div>
            </div>
            <div className="text-center">
              <div className="text-[20px] font-semibold text-[#F59E0B] mb-0.5">
                3
              </div>
              <div className="text-[11px] text-[#64748B]">
                Pending replies
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
