import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Send, User, Bot } from 'lucide-react';

export function ParentChatTab() {
  const navigate = useNavigate();
  const [message, setMessage] = useState('');

  const conversations = [
    {
      id: '1',
      type: 'bot',
      name: 'Synapse Assistant',
      lastMessage: 'The school clinic opens at 8:00 AM on school days...',
      time: '2:45 PM',
      unread: 0
    },
    {
      id: '2',
      type: 'staff',
      name: 'School Nurse',
      lastMessage: 'Maya did great with her medication today.',
      time: '2:30 PM',
      unread: 1
    },
    {
      id: '3',
      type: 'staff',
      name: 'School Secretary',
      lastMessage: 'I can help you schedule a meeting.',
      time: 'Yesterday',
      unread: 0
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-gray-900">
          Messages
        </h1>
      </header>

      {/* Conversations List */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-2">
        {conversations.map((conv) => (
          <button
            key={conv.id}
            onClick={() => {
              if (conv.type === 'bot') {
                navigate('/parent/app/chatbot-assistant');
              }
            }}
            className="w-full bg-white rounded-xl border border-gray-200 p-4 flex gap-3 active:bg-gray-50"
          >
            <div className={`w-12 h-12 rounded-full ${conv.type === 'bot' ? 'bg-[#EFF6FF]' : 'bg-[#F0F9FF]'} flex items-center justify-center flex-shrink-0`}>
              {conv.type === 'bot' ? (
                <Bot className="w-6 h-6 text-[#2563EB]" />
              ) : (
                <User className="w-6 h-6 text-[#0369A1]" />
              )}
            </div>
            <div className="flex-1 text-left">
              <div className="flex items-center justify-between mb-1">
                <span className="text-[15px] font-semibold text-gray-900">
                  {conv.name}
                </span>
                <span className="text-[12px] text-[#64748B]">
                  {conv.time}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <p className="text-[13px] text-[#64748B] line-clamp-1">
                  {conv.lastMessage}
                </p>
                {conv.unread > 0 && (
                  <div className="w-5 h-5 rounded-full bg-[#2563EB] flex items-center justify-center ml-2">
                    <span className="text-[11px] font-semibold text-white">
                      {conv.unread}
                    </span>
                  </div>
                )}
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}