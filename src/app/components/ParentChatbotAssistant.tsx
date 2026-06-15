import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Info, Send, Paperclip, AlertTriangle } from 'lucide-react';

interface Message {
  id: string;
  text: string;
  isBot: boolean;
  timestamp: string;
  isTransfer?: boolean;
}

export function ParentChatbotAssistant() {
  const navigate = useNavigate();
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: 'Hello! I am Synapse Assistant. How can I help you today?',
      isBot: true,
      timestamp: '2:30 PM'
    },
    {
      id: '2',
      text: 'What time does the clinic open?',
      isBot: false,
      timestamp: '2:31 PM'
    },
    {
      id: '3',
      text: 'The school clinic opens at 8:00 AM on school days and closes at 3:30 PM. The clinic is staffed by licensed school nurses. Is there anything else you need?',
      isBot: true,
      timestamp: '2:31 PM'
    },
    {
      id: '4',
      text: 'Can I schedule a meeting with the school secretary?',
      isBot: false,
      timestamp: '2:32 PM'
    },
    {
      id: '5',
      text: 'I am transferring you to the school secretary - Zainab will respond within 1 business day.',
      isBot: true,
      timestamp: '2:32 PM',
      isTransfer: true
    }
  ]);

  // Simulate school hours check (in real app, this would be based on actual time)
  const isSchoolClosed = false; // Set to true to show the banner

  const handleSend = () => {
    if (message.trim()) {
      const newMessage: Message = {
        id: Date.now().toString(),
        text: message,
        isBot: false,
        timestamp: new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
      };
      setMessages([...messages, newMessage]);
      setMessage('');

      // Simulate bot response
      setTimeout(() => {
        const botResponse: Message = {
          id: (Date.now() + 1).toString(),
          text: 'I understand. Let me help you with that.',
          isBot: true,
          timestamp: new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
        };
        setMessages(prev => [...prev, botResponse]);
      }, 1000);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 -ml-2 flex items-center justify-center"
        >
          <ArrowLeft className="w-6 h-6 text-gray-900" />
        </button>
        <div className="flex items-center gap-2 flex-1">
          <div className="w-8 h-8 rounded-full bg-[#2563EB] flex items-center justify-center">
            <span className="text-[14px] font-semibold text-white">S</span>
          </div>
          <h1 className="text-[17px] font-medium text-gray-900">
            Synapse Assistant
          </h1>
        </div>
        <button className="w-10 h-10 -mr-2 flex items-center justify-center">
          <Info className="w-6 h-6 text-gray-900" />
        </button>
      </header>

      {/* School Hours Banner (shown when closed) */}
      {isSchoolClosed && (
        <div className="bg-[#FEF3C7] border-b border-[#F59E0B] px-4 py-3">
          <div className="flex items-start gap-2">
            <AlertTriangle className="w-4 h-4 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <p className="text-[12px] text-[#92400E] leading-relaxed">
              ⚠ School is closed. The assistant will respond to general questions. For emergencies, call 911.
            </p>
          </div>
        </div>
      )}

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex gap-2 ${msg.isBot ? '' : 'flex-row-reverse'}`}
          >
            {/* Bot Avatar */}
            {msg.isBot && (
              <div className="w-8 h-8 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0 mt-1">
                <span className="text-[12px] font-semibold text-[#2563EB]">S</span>
              </div>
            )}

            <div className={`flex flex-col max-w-[75%] ${msg.isBot ? '' : 'items-end'}`}>
              {/* Message Bubble */}
              <div
                className={`px-4 py-3 ${
                  msg.isBot
                    ? 'bg-white border border-gray-200 rounded-[18px] rounded-bl-sm'
                    : 'bg-[#2563EB] text-white rounded-[18px] rounded-br-sm'
                }`}
              >
                <p className="text-[15px] leading-relaxed">{msg.text}</p>
              </div>

              {/* Transfer Status Chip */}
              {msg.isTransfer && (
                <div className="mt-2 inline-flex items-center px-3 py-1 rounded-full bg-[#FEF3C7] border border-[#F59E0B]">
                  <span className="text-[11px] font-semibold text-[#F59E0B]">
                    Transferred to secretary
                  </span>
                </div>
              )}

              {/* Timestamp */}
              <span className="text-[11px] text-[#64748B] mt-1 px-1">
                {msg.timestamp}
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Disclaimer Banner */}
      <div className="bg-[#F8FAFC] border-t border-gray-200 px-4 py-2">
        <p className="text-[11px] text-[#64748B] text-center">
          This assistant cannot provide medical advice.
        </p>
      </div>

      {/* Input Bar */}
      <div className="p-4 bg-white border-t border-gray-200">
        <div className="flex items-center gap-2">
          <button className="w-11 h-11 flex items-center justify-center text-[#64748B]">
            <Paperclip className="w-5 h-5" />
          </button>
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Type a message..."
            className="flex-1 min-h-[52px] px-4 border border-gray-200 rounded-full text-[15px] focus:outline-none focus:border-[#2563EB]"
            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
          />
          <button
            onClick={handleSend}
            disabled={!message.trim()}
            className="w-11 h-11 bg-[#2563EB] text-white rounded-full flex items-center justify-center disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}