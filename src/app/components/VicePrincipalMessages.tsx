import { Search, Plus, ArrowLeft } from 'lucide-react';
import { useNavigate, useSearchParams } from 'react-router';
import { useState } from 'react';

export function VicePrincipalMessages() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedThread, setSelectedThread] = useState<string | null>(null);

  const composeMode = searchParams.get('compose');
  const prefillSubject = searchParams.get('subject');

  const conversations = [
    {
      id: '1',
      recipient: 'Principal M. Davis',
      initials: 'MD',
      lastMessage: 'Thank you for the clinic readiness report. I will review the budget for equipment replacement.',
      timestamp: '2026-05-30T14:30:00',
      unread: false,
      role: 'Principal'
    },
    {
      id: '2',
      recipient: 'Jennifer Clarke, RN',
      initials: 'JC',
      lastMessage: 'The year-end clinic report is ready for your review.',
      timestamp: '2026-05-29T11:15:00',
      unread: true,
      role: 'Nurse'
    },
    {
      id: '3',
      recipient: 'Principal M. Davis',
      initials: 'MD',
      lastMessage: "I've updated your analytics access. You should now be able to view the aggregate health dashboard.",
      timestamp: '2026-05-28T16:45:00',
      unread: false,
      role: 'Principal'
    },
    {
      id: '4',
      recipient: 'Sarah Martinez',
      initials: 'SM',
      lastMessage: 'Can you approve my time off request for June 15-16?',
      timestamp: '2026-05-27T09:20:00',
      unread: false,
      role: 'Teacher'
    }
  ];

  const filteredConversations = conversations.filter(conv =>
    conv.recipient.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (composeMode === 'principal') {
    return (
      <div className="min-h-screen bg-[#F8FAFC] flex flex-col pb-[83px]" style={{ width: '393px', height: '852px' }}>
        {/* Status Bar */}
        <div className="h-[44px] bg-white" />

        {/* Top App Bar */}
        <header className="bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate('/vice-principal/messages')}
              className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
              aria-label="Cancel"
            >
              <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
            </button>
            <h1 className="text-[17px] font-medium text-[#0F172A]">
              New Message
            </h1>
          </div>
          <button className="text-[15px] font-medium text-[#2563EB]">
            Send
          </button>
        </header>

        <div className="flex-1 overflow-y-auto">
          {/* Recipient */}
          <div className="bg-white border-b border-gray-200 px-4 py-3">
            <div className="flex items-center gap-3">
              <span className="text-[14px] text-[#64748B] w-12">To:</span>
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-[#EFF6FF] flex items-center justify-center">
                  <span className="text-[12px] font-medium text-[#2563EB]">MD</span>
                </div>
                <span className="text-[14px] text-[#0F172A]">Principal M. Davis</span>
              </div>
            </div>
          </div>

          {/* Subject */}
          <div className="bg-white border-b border-gray-200 px-4 py-3">
            <div className="flex items-center gap-3">
              <span className="text-[14px] text-[#64748B] w-12">Subject:</span>
              <input
                type="text"
                defaultValue={prefillSubject || ''}
                placeholder="Message subject"
                className="flex-1 text-[14px] text-[#0F172A] outline-none"
              />
            </div>
          </div>

          {/* Message Body */}
          <div className="bg-white px-4 py-3">
            <textarea
              placeholder="Type your message here..."
              className="w-full min-h-[200px] text-[14px] text-[#0F172A] outline-none resize-none"
              autoFocus
            />
          </div>
        </div>
      </div>
    );
  }

  if (selectedThread) {
    const conversation = conversations.find(c => c.id === selectedThread);
    if (!conversation) return null;

    const messages = [
      {
        id: '1',
        sender: 'you',
        content: 'I wanted to share the year-end clinic readiness report. There are a few items that need budgetary attention for the upcoming year.',
        timestamp: '2026-05-30T10:15:00'
      },
      {
        id: '2',
        sender: conversation.recipient,
        content: 'Thank you for the clinic readiness report. I will review the budget for equipment replacement.',
        timestamp: '2026-05-30T14:30:00'
      }
    ];

    return (
      <div className="min-h-screen bg-[#F8FAFC] flex flex-col pb-[83px]" style={{ width: '393px', height: '852px' }}>
        {/* Status Bar */}
        <div className="h-[44px] bg-white" />

        {/* Top App Bar */}
        <header className="bg-white border-b border-gray-200 px-4 py-3">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setSelectedThread(null)}
              className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
              aria-label="Back to messages"
            >
              <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
            </button>
            <div className="flex items-center gap-3 flex-1">
              <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center">
                <span className="text-[14px] font-medium text-[#2563EB]">{conversation.initials}</span>
              </div>
              <div>
                <div className="text-[15px] font-medium text-[#0F172A]">
                  {conversation.recipient}
                </div>
                <div className="text-[11px] text-[#64748B]">
                  {conversation.role}
                </div>
              </div>
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`flex ${message.sender === 'you' ? 'justify-end' : 'justify-start'}`}
            >
              <div className={`max-w-[280px] rounded-2xl px-4 py-3 ${
                message.sender === 'you'
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-white border border-gray-200 text-[#0F172A]'
              }`}>
                <div className="text-[14px] leading-relaxed mb-1">
                  {message.content}
                </div>
                <div className={`text-[11px] ${
                  message.sender === 'you' ? 'text-blue-100' : 'text-[#64748B]'
                }`}>
                  {new Date(message.timestamp).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Message Input */}
        <div className="bg-white border-t border-gray-200 px-4 py-3">
          <div className="flex items-center gap-2">
            <input
              type="text"
              placeholder="Type a message..."
              className="flex-1 h-[36px] px-3 bg-[#F1F5F9] rounded-full text-[14px] text-[#0F172A] outline-none"
            />
            <button className="w-[36px] h-[36px] bg-[#2563EB] rounded-full flex items-center justify-center text-white">
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Messages
        </h1>
        <button
          onClick={() => navigate('/vice-principal/messages?compose=new')}
          className="w-10 h-10 -mr-2 flex items-center justify-center"
        >
          <Plus className="w-6 h-6 text-[#2563EB]" />
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
          <input
            type="text"
            placeholder="Search conversations"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-[44px] pl-10 pr-4 bg-white border border-gray-200 rounded-xl text-[14px] text-[#0F172A] outline-none focus:border-[#2563EB]"
          />
        </div>

        {/* Conversations List */}
        <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
          {filteredConversations.map((conversation) => (
            <button
              key={conversation.id}
              onClick={() => setSelectedThread(conversation.id)}
              className="w-full p-4 flex items-start gap-3 active:bg-gray-50 text-left"
            >
              <div className="w-12 h-12 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <span className="text-[14px] font-medium text-[#2563EB]">{conversation.initials}</span>
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-baseline justify-between mb-1">
                  <div className="text-[14px] font-medium text-[#0F172A]">
                    {conversation.recipient}
                  </div>
                  <div className="text-[11px] text-[#64748B] flex-shrink-0 ml-2">
                    {new Date(conversation.timestamp).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                  </div>
                </div>
                <div className={`text-[13px] ${conversation.unread ? 'text-[#0F172A] font-medium' : 'text-[#64748B]'} line-clamp-2`}>
                  {conversation.lastMessage}
                </div>
                <div className="flex items-center gap-2 mt-1">
                  <div className="text-[11px] text-[#64748B]">
                    {conversation.role}
                  </div>
                  {conversation.unread && (
                    <div className="w-2 h-2 rounded-full bg-[#2563EB]" />
                  )}
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
