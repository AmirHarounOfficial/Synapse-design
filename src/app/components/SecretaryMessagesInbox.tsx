import { useNavigate } from 'react-router';
import { Bell, Plus } from 'lucide-react';
import { useState } from 'react';

export function SecretaryMessagesInbox() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<'all' | 'parents' | 'clinic' | 'sent'>('all');

  const messages = [
    {
      id: '1',
      from: 'James Thompson',
      initials: 'JT',
      preview: 'Re: Maya\'s medication schedule - Thank you for the clarification...',
      time: '10:45 AM',
      unread: true,
      category: 'parents'
    },
    {
      id: '2',
      from: 'Sarah Williams',
      initials: 'SW',
      preview: 'Document expiry reminder - Could you help me understand which...',
      time: '9:30 AM',
      unread: true,
      category: 'parents'
    },
    {
      id: '3',
      from: 'Nurse Chen',
      initials: 'NC',
      preview: '[Copy] Emergency consent sent to Maya Thompson\'s parent',
      time: 'Yesterday',
      unread: false,
      category: 'clinic'
    },
    {
      id: '4',
      from: 'Carlos Martinez',
      initials: 'CM',
      preview: 'Pickup authorization - I need to add my mother to the approved...',
      time: 'Yesterday',
      unread: false,
      category: 'parents'
    },
    {
      id: '5',
      from: 'Nurse Chen',
      initials: 'NC',
      preview: '[Copy] Medication administered - Ethan Williams',
      time: '05/30',
      unread: false,
      category: 'clinic'
    }
  ];

  const filteredMessages = messages.filter(msg => {
    if (activeTab === 'all') return true;
    return msg.category === activeTab;
  });

  const tabs = [
    { id: 'all', label: 'All' },
    { id: 'parents', label: 'From Parents' },
    { id: 'clinic', label: 'Clinic Copies' },
    { id: 'sent', label: 'Sent' }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="flex items-center justify-between px-4 h-14">
          <h1 className="text-[17px] font-medium text-[#0F172A]">
            Messages
          </h1>
          <button className="w-10 h-10 -mr-2 flex items-center justify-center relative">
            <Bell className="w-6 h-6 text-[#0F172A]" />
            <div className="absolute top-2 right-2 w-2 h-2 bg-[#DC2626] rounded-full" />
          </button>
        </div>

        {/* Filter Tabs */}
        <div className="flex overflow-x-auto px-4 pb-2 gap-2">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as typeof activeTab)}
              className={`px-3 py-1.5 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors ${
                activeTab === tab.id
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-[#F1F5F9] text-[#64748B] active:bg-[#E2E8F0]'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </header>

      <div className="px-4 py-4">
        <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
          {filteredMessages.map((message) => (
            <button
              key={message.id}
              onClick={() => navigate(`/secretary/message/${message.id}`)}
              className="w-full p-4 flex items-start gap-3 text-left active:bg-gray-50"
            >
              <div className="w-12 h-12 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <span className="text-[14px] font-medium text-[#2563EB]">
                  {message.initials}
                </span>
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between mb-1">
                  <div className={`text-[14px] ${message.unread ? 'font-semibold' : 'font-medium'} text-[#0F172A]`}>
                    {message.from}
                  </div>
                  {message.unread && (
                    <div className="w-2 h-2 bg-[#2563EB] rounded-full flex-shrink-0" />
                  )}
                </div>
                <div className={`text-[13px] ${message.unread ? 'text-[#0F172A]' : 'text-[#64748B]'} mb-1 line-clamp-2`}>
                  {message.preview}
                </div>
                <div className="text-[12px] text-[#64748B]">
                  {message.time}
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Compose FAB */}
      <button
        onClick={() => navigate('/secretary/compose-message')}
        className="fixed bottom-[100px] right-4 w-14 h-14 bg-[#2563EB] text-white rounded-full shadow-lg flex items-center justify-center active:bg-[#1D4ED8]"
      >
        <Plus className="w-6 h-6" />
      </button>
    </div>
  );
}
