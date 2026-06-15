import { useNavigate } from 'react-router';
import { Bell, Bot } from 'lucide-react';

export function SecretaryChatbotQueue() {
  const navigate = useNavigate();

  const escalations = [
    {
      id: '1',
      parentName: 'James Thompson',
      initials: 'JT',
      question: 'How do I update my emergency contact information?',
      timeEscalated: '15 min ago',
      priority: 'normal'
    },
    {
      id: '2',
      parentName: 'Sarah Williams',
      initials: 'SW',
      question: 'My child needs a specific accommodation for field trips...',
      timeEscalated: '1 hour ago',
      priority: 'high'
    },
    {
      id: '3',
      parentName: 'Carlos Martinez',
      initials: 'CM',
      question: 'When is the deadline for submitting immunization records?',
      timeEscalated: '3 hours ago',
      priority: 'normal'
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Chatbot Escalations
        </h1>
        <button className="w-10 h-10 -mr-2 flex items-center justify-center relative">
          <Bell className="w-6 h-6 text-[#0F172A]" />
          <div className="absolute top-2 right-2 w-2 h-2 bg-[#DC2626] rounded-full" />
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Queue Info */}
        <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-lg p-3">
          <div className="flex items-start gap-2">
            <Bot className="w-4 h-4 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[12px] font-medium text-[#1E40AF] mb-0.5">
                AI Chatbot Escalations
              </div>
              <div className="text-[12px] text-[#1E40AF]">
                These conversations were escalated because the AI couldn't provide a satisfactory answer. Review and respond to help the parent.
              </div>
            </div>
          </div>
        </div>

        {/* Escalations List */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[15px] font-semibold text-[#0F172A]">
              Pending Escalations ({escalations.length})
            </h2>
          </div>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {escalations.map((escalation) => (
              <div key={escalation.id} className="p-4">
                <div className="flex items-start gap-3 mb-3">
                  <div className="w-12 h-12 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                    <span className="text-[14px] font-medium text-[#2563EB]">
                      {escalation.initials}
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <div className="text-[14px] font-semibold text-[#0F172A]">
                        {escalation.parentName}
                      </div>
                      {escalation.priority === 'high' && (
                        <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium bg-[#FEE2E2] text-[#DC2626]">
                          High priority
                        </span>
                      )}
                    </div>
                    <div className="text-[13px] text-[#64748B] mb-2 line-clamp-2">
                      {escalation.question}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      Escalated {escalation.timeEscalated}
                    </div>
                  </div>
                </div>

                <button
                  onClick={() => navigate(`/secretary/chatbot-thread/${escalation.id}`)}
                  className="w-full h-[40px] bg-[#2563EB] text-white rounded-lg font-medium text-[14px] active:bg-[#1D4ED8]"
                >
                  View conversation & reply
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Stats */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Today's Stats
          </h3>
          <div className="grid grid-cols-3 gap-3">
            <div className="text-center">
              <div className="text-[20px] font-semibold text-[#2563EB] mb-0.5">
                5
              </div>
              <div className="text-[11px] text-[#64748B]">
                Resolved
              </div>
            </div>
            <div className="text-center">
              <div className="text-[20px] font-semibold text-[#F59E0B] mb-0.5">
                3
              </div>
              <div className="text-[11px] text-[#64748B]">
                Pending
              </div>
            </div>
            <div className="text-center">
              <div className="text-[20px] font-semibold text-[#10B981] mb-0.5">
                2.4
              </div>
              <div className="text-[11px] text-[#64748B]">
                Avg response (hrs)
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
