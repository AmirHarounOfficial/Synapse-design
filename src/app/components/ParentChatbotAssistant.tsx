import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Info, Send, Paperclip, Sparkles, Loader2 } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

interface Message {
  id: string;
  text: string;
  isBot: boolean;
  timestamp: string;
  isTransfer?: boolean;
}

export function ParentChatbotAssistant() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: isRTL 
        ? 'مرحباً بك! أنا مساعد سكوكيب الذكي (SchooKeep AI). كيف يمكنني مساعدتك اليوم؟'
        : 'Hello! I am SchooKeep AI. How can I help you today?',
      isBot: true,
      timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
    }
  ]);

  const handleSend = async () => {
    const userText = message.trim();
    if (!userText || loading) return;

    const userMsgId = Date.now().toString();
    const userTimestamp = new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });

    const newUserMsg: Message = {
      id: userMsgId,
      text: userText,
      isBot: false,
      timestamp: userTimestamp
    };

    const historyPayload = messages.map(m => ({
      role: m.isBot ? 'bot' : 'user',
      content: m.text
    }));

    setMessages(prev => [...prev, newUserMsg]);
    setMessage('');
    setLoading(true);

    try {
      // Send message to backend OpenRouter API
      const res = await fetch('/api/chatbot/ask', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          message: userText,
          history: historyPayload
        })
      });

      let aiReply = '';

      if (res.ok) {
        const data = await res.json();
        aiReply = data.reply || data.response || '';
      }

      // Fallback if backend server is offline or returns empty
      if (!aiReply) {
        const lower = userText.toLowerCase();
        if (lower.includes('hour') || lower.includes('time') || lower.includes('open') || userText.includes('ساعات') || userText.includes('مواعيد')) {
          aiReply = isRTL
            ? 'تعمل العيادة المدرسية من الساعة 8:00 صباحاً حتى 3:30 مساءً خلال الأيام الدراسية العادية، وتعمل من 8:00 صباحاً حتى 1:30 مساءً في شهر رمضان المبارك.'
            : 'The school clinic operates from 8:00 AM to 3:30 PM on regular school days, and from 8:00 AM to 1:30 PM during Ramadan.';
        } else if (lower.includes('medication') || lower.includes('dose') || userText.includes('دواء') || userText.includes('جرعة')) {
          aiReply = isRTL
            ? 'يمكنك تسجيل مواعيد الأدوية والجرعات المنزلية في قسم الأدوية. تتطلب جميع الأدوية المدرسية موافقة طبيب المدرسة والممرضة.'
            : 'You can log medication schedules and home doses in the Medications tab. All school doses require physician and nurse approvals.';
        } else {
          aiReply = isRTL
            ? 'شكراً لتواصلك! لقد تلقيت استفسارك وسأقوم بمساعدتك بكل ما يتعلق بسلامة وصحة الطالب في المدرسة.'
            : 'Thank you for reaching out! I am analyzing your request to provide exact guidance per UAE school health standards.';
        }
      }

      const botMsg: Message = {
        id: (Date.now() + 1).toString(),
        text: aiReply,
        isBot: true,
        timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
      };

      setMessages(prev => [...prev, botMsg]);
    } catch (err) {
      console.error('Chat AI Error:', err);
      const fallbackMsg: Message = {
        id: (Date.now() + 1).toString(),
        text: isRTL 
          ? 'تعمل العيادة المدرسية من 8:00 ص إلى 3:30 م. في حالات الطوارئ الطبية الحرجة، يرجى الاتصال بالإسعاف 998 مباشرة.'
          : 'The school clinic operates from 8:00 AM to 3:30 PM. For medical emergencies, please dial 998 immediately.',
        isBot: true,
        timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
      };
      setMessages(prev => [...prev, fallbackMsg]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 -ml-2 flex items-center justify-center cursor-pointer"
        >
          <ArrowLeft className={`w-6 h-6 text-gray-900 ${isRTL ? 'rotate-180' : ''}`} />
        </button>
        <div className="flex items-center gap-2 flex-1 min-w-0">
          <div className="w-8 h-8 rounded-full bg-[#2563EB] flex items-center justify-center flex-shrink-0">
            <span className="text-[14px] font-semibold text-white">S</span>
          </div>
          <div className="min-w-0">
            <h1 className="text-[16px] font-semibold text-gray-900 leading-tight truncate">
              {isRTL ? 'مساعد سكوكيب الذكي' : 'SchooKeep AI'}
            </h1>
          </div>
        </div>
        <button className="w-10 h-10 -mr-2 flex items-center justify-center text-gray-900">
          <Info className="w-5 h-5" />
        </button>
      </header>

      {/* Messages list */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex gap-2 ${msg.isBot ? '' : (isRTL ? 'flex-row' : 'flex-row-reverse')}`}
          >
            {/* Bot Avatar */}
            {msg.isBot && (
              <div className="w-8 h-8 rounded-full bg-[#EEF2FF] flex items-center justify-center flex-shrink-0 mt-1">
                <Sparkles className="w-4 h-4 text-[#2563EB]" />
              </div>
            )}

            <div className={`flex flex-col max-w-[80%] ${msg.isBot ? '' : 'items-end'}`}>
              {/* Message Bubble */}
              <div
                className={`px-4 py-3 ${
                  msg.isBot
                    ? 'bg-white border border-gray-200 rounded-[18px] rounded-bl-sm text-gray-900'
                    : 'bg-[#2563EB] text-white rounded-[18px] rounded-br-sm'
                }`}
              >
                <p className="text-[15px] leading-relaxed whitespace-pre-wrap">{msg.text}</p>
              </div>

              {/* Timestamp */}
              <span className="text-[11px] text-[#64748B] mt-1 px-1">
                {msg.timestamp}
              </span>
            </div>
          </div>
        ))}

        {loading && (
          <div className="flex items-center gap-2 text-gray-500 text-sm italic pl-2">
            <Loader2 className="w-4 h-4 animate-spin text-[#2563EB]" />
            <span>{isRTL ? 'جاري الكتابة...' : 'SchooKeep AI is typing...'}</span>
          </div>
        )}
      </div>

      {/* Disclaimer Banner */}
      <div className="bg-[#F8FAFC] border-t border-gray-200 px-4 py-2">
        <p className="text-[11px] text-[#64748B] text-center">
          {isRTL 
            ? 'المساعد الذكي يقدم معلومات ارشادية ولا يغني عن الاستشارة الطبية المباشرة. في الطوارئ اتصل بـ 998.' 
            : 'AI assistant provides informational guidance. For medical emergencies dial 998.'}
        </p>
      </div>

      {/* Input Bar */}
      <div className="p-4 bg-white border-t border-gray-200">
        <div className="flex items-center gap-2">
          <button className="w-11 h-11 flex items-center justify-center text-[#64748B] cursor-pointer">
            <Paperclip className="w-5 h-5" />
          </button>
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder={isRTL ? 'اكتب رسالتك لـ SchooKeep AI...' : 'Type a message for SchooKeep AI...'}
            className="flex-1 min-h-[52px] px-4 border border-gray-200 rounded-full text-[15px] focus:outline-none focus:border-[#2563EB]"
            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
          />
          <button
            onClick={handleSend}
            disabled={!message.trim() || loading}
            className="w-11 h-11 bg-[#2563EB] text-white rounded-full flex items-center justify-center disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
          >
            {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Send className={`w-5 h-5 ${isRTL ? 'rotate-180' : ''}`} />}
          </button>
        </div>
      </div>
    </div>
  );
}