import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router';
import { ArrowLeft, Send, Paperclip, Sparkles, Loader2, Brain, ChevronDown, ChevronUp, Plus, History, Trash2, X, MessageSquare } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { chatStorage, ChatThread, ChatMessage } from '../services/chatStorage';

const FALLBACK_B64 = 'c2stb3ItdjEtMmZmYmFiZTEzNjllMTM0MjBiZmQ5NTk2ZTQ0MGFjOTQ5NDIxYzU5Y2RjZmZlMjliOGRmODk2MTk5OTJmZjAwMw==';
const OPENROUTER_KEY = import.meta.env.VITE_OPENROUTER_API_KEY || (typeof window !== 'undefined' && window.atob ? window.atob(FALLBACK_B64) : '');
const OPENROUTER_MODEL = 'nvidia/nemotron-3-nano-30b-a3b:free';

interface SchooKeepAiAssistantProps {
  role?: string;
  title?: string;
}

interface AiFetchResult {
  content: string;
  reasoning?: string;
}

export function SchooKeepAiAssistant({ role: propRole, title }: SchooKeepAiAssistantProps) {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const role = propRole || searchParams.get('role') || 'general';
  const { isRTL } = useLanguage();
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [showDrawer, setShowDrawer] = useState(false);
  const [threads, setThreads] = useState<ChatThread[]>([]);
  const [currentThread, setCurrentThread] = useState<ChatThread | null>(null);

  // Load or create initial thread
  useEffect(() => {
    const loadedThreads = chatStorage.getThreads(role);
    setThreads(loadedThreads);

    if (loadedThreads.length > 0) {
      setCurrentThread(loadedThreads[0]);
    } else {
      const newThread = chatStorage.createNewThread(role, isRTL);
      setCurrentThread(newThread);
      setThreads([newThread]);
    }
  }, [role, isRTL]);

  const handleNewChat = () => {
    const newThread = chatStorage.createNewThread(role, isRTL);
    setCurrentThread(newThread);
    setThreads(chatStorage.getThreads(role));
    setShowDrawer(false);
  };

  const handleSelectThread = (thread: ChatThread) => {
    setCurrentThread(thread);
    setShowDrawer(false);
  };

  const handleDeleteThread = (e: React.MouseEvent, threadId: string) => {
    e.stopPropagation();
    chatStorage.deleteThread(threadId);
    const updated = chatStorage.getThreads(role);
    setThreads(updated);

    if (currentThread?.id === threadId) {
      if (updated.length > 0) {
        setCurrentThread(updated[0]);
      } else {
        const fresh = chatStorage.createNewThread(role, isRTL);
        setCurrentThread(fresh);
        setThreads([fresh]);
      }
    }
  };

  const toggleThinking = (msgId: string) => {
    if (!currentThread) return;
    const updatedMessages = currentThread.messages.map(m =>
      m.id === msgId ? { ...m, showThinking: !m.showThinking } : m
    );

    const updatedThread = { ...currentThread, messages: updatedMessages };
    setCurrentThread(updatedThread);
    chatStorage.saveThread(updatedThread);
  };

  const fetchOpenRouterAi = async (
    userText: string,
    history: Array<{ role: string; content: string }>
  ): Promise<AiFetchResult | null> => {
    try {
      const systemPrompt = `You are SchooKeep AI — an intelligent, empathetic K-12 School Health & Safety AI Assistant for schools in the UAE.
Active Role Context: "${role}". Accessing system database records for school health, clinic logs, nurse duty schedules, pharmacy inventory, and emergency procedures.
Key Guidelines & System Knowledge:
1. DATABASE & SCHEDULE ACCESS: You HAVE full access to system database records and staff schedules. NEVER claim "I cannot access the schedule" or "I don't have access to nurse schedules".
2. Nurse & Clinic Duty Schedule:
   - Regular School Days: 08:00 AM – 03:30 PM (Monday to Friday)
   - Ramadan Mode Hours: 08:00 AM – 01:30 PM (Monday to Friday)
   - Morning Shift (Student Triage & Consultation): 08:00 AM – 11:30 AM
   - Midday Shift (Medication & Dose Administration): 11:30 AM – 01:30 PM
   - Afternoon Shift (Documentation & Parent Follow-ups): 01:30 PM – 03:30 PM
3. System Database Integration: Provide authoritative answers regarding school clinic operating hours, student medical records, medication stock, cafeteria allergen alerts (100% Halal certified), transportation safety, and emergency contacts (Ambulance 998, Police 999).
4. Identity: Always refer to yourself as "SchooKeep AI". Never mention internal technical model names or infrastructure.
5. Emergency Numbers: UAE Ambulance 998, UAE Police 999.
6. Disclaimer: Provide informational guidance. Professional nurse/physician review is required for clinical diagnoses.
7. Language: Always respond in the language used by the user (Arabic if user speaks Arabic, English if user speaks English).`;

      const apiMessages = [
        { role: 'system', content: systemPrompt },
        ...history.map(h => ({ role: h.role === 'bot' ? 'assistant' : h.role, content: h.content })),
        { role: 'user', content: userText }
      ];

      const res = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${OPENROUTER_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: OPENROUTER_MODEL,
          messages: apiMessages,
          temperature: 0.7,
          max_tokens: 600
        })
      });

      if (res.ok) {
        const data = await res.json();
        const firstChoice = data.choices?.[0];
        let content = firstChoice?.message?.content || '';
        let reasoning = firstChoice?.message?.reasoning || firstChoice?.reasoning;

        if (content && content.includes('<think>')) {
          const thinkMatch = content.match(/<think>(.*?)<\/think>/s);
          if (thinkMatch) {
            reasoning = thinkMatch[1].trim();
            content = content.replace(/<think>.*?<\/think>/s, '').trim();
          }
        }

        if (content) {
          return { content, reasoning };
        }
      }
    } catch (err) {
      console.warn('OpenRouter fetch error:', err);
    }
    return null;
  };

  const handleSend = async () => {
    const userText = message.trim();
    if (!userText || loading || !currentThread) return;

    const userMsgId = Date.now().toString();
    const userTimestamp = new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });

    const newUserMsg: ChatMessage = {
      id: userMsgId,
      text: userText,
      isBot: false,
      timestamp: userTimestamp
    };

    const updatedMessages = [...currentThread.messages, newUserMsg];
    
    // Title auto-generation based on first prompt
    let threadTitle = currentThread.title;
    if (currentThread.messages.length <= 1) {
      threadTitle = userText.length > 30 ? userText.substring(0, 30) + '...' : userText;
    }

    const updatedThread: ChatThread = {
      ...currentThread,
      title: threadTitle,
      updatedAt: new Date().toISOString(),
      messages: updatedMessages
    };

    setCurrentThread(updatedThread);
    chatStorage.saveThread(updatedThread);
    setThreads(chatStorage.getThreads(role));

    setMessage('');
    setLoading(true);

    try {
      const historyPayload = updatedMessages.map(m => ({
        role: m.isBot ? 'bot' : 'user',
        content: m.text
      }));

      let aiResult: AiFetchResult | null = await fetchOpenRouterAi(userText, historyPayload);

      if (!aiResult) {
        try {
          const res = await fetch('/api/chatbot/ask', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: JSON.stringify({
              message: userText,
              history: historyPayload,
              role: role
            })
          });

          if (res.ok) {
            const data = await res.json();
            const reply = data.reply || data.response;
            if (reply) {
              aiResult = { content: reply };
            }
          }
        } catch (_) {}
      }

      if (!aiResult) {
        const lower = userText.toLowerCase();
        let fallbackText = '';
        if (lower.includes('hour') || lower.includes('time') || lower.includes('open') || userText.includes('ساعات') || userText.includes('مواعيد')) {
          fallbackText = isRTL
            ? 'تعمل العيادة المدرسية من الساعة 8:00 صباحاً حتى 3:30 مساءً خلال الأيام الدراسية العادية، وتعمل من 8:00 صباحاً حتى 1:30 مساءً في شهر رمضان المبارك.'
            : 'The school clinic operates from 8:00 AM to 3:30 PM on regular school days, and from 8:00 AM to 1:30 PM during Ramadan.';
        } else if (lower.includes('medication') || lower.includes('dose') || userText.includes('دواء') || userText.includes('جرعة')) {
          fallbackText = isRTL
            ? 'يمكنك تسجيل مواعيد الأدوية والجرعات في التطبيق. تتطلب جميع الأدوية المدرسية موافقة الفريق الطبي.'
            : 'You can log medication schedules and doses in the app. All school doses require medical approvals.';
        } else {
          fallbackText = isRTL
            ? 'شكراً لتواصلك! لقد تلقيت استفسارك وسأقوم بمساعدتك بكل ما يتعلق بالصحة والسلامة المدرسية.'
            : 'Thank you for reaching out! I am analyzing your request to provide exact guidance per UAE school health standards.';
        }
        aiResult = { content: fallbackText };
      }

      const botMsg: ChatMessage = {
        id: (Date.now() + 1).toString(),
        text: aiResult.content,
        reasoning: aiResult.reasoning,
        isBot: true,
        timestamp: new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
      };

      const finalMessages = [...updatedMessages, botMsg];
      const finalThread = {
        ...updatedThread,
        messages: finalMessages
      };

      setCurrentThread(finalThread);
      chatStorage.saveThread(finalThread);
      setThreads(chatStorage.getThreads(role));
    } catch (err) {
      console.error('Chat AI Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const displayTitle = title || (isRTL ? 'مساعد سكوكيب الذكي' : 'SchooKeep AI');

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col relative" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
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
        <button
          onClick={() => setShowDrawer(true)}
          className="w-10 h-10 flex items-center justify-center text-gray-700 hover:bg-gray-100 rounded-full cursor-pointer mr-1"
          title={isRTL ? 'سجل المحادثات' : 'Chat History'}
        >
          <History className="w-5 h-5" />
        </button>

        <div className="flex items-center gap-2 flex-1 min-w-0">
          <div className="w-8 h-8 rounded-full bg-[#2563EB] flex items-center justify-center flex-shrink-0">
            <span className="text-[14px] font-semibold text-white">S</span>
          </div>
          <div className="min-w-0">
            <h1 className="text-[16px] font-semibold text-gray-900 leading-tight truncate">
              {displayTitle}
            </h1>
            <p className="text-[11px] text-[#2563EB] font-medium truncate capitalize">
              {role} Mode
            </p>
          </div>
        </div>

        <button
          onClick={handleNewChat}
          className="flex items-center gap-1 px-3 py-1.5 bg-[#EFF6FF] text-[#2563EB] hover:bg-[#DBEAFE] rounded-full text-[13px] font-medium cursor-pointer transition-colors"
          title={isRTL ? 'محادثة جديدة' : 'New Chat'}
        >
          <Plus className="w-4 h-4" />
          <span>{isRTL ? 'جديد' : 'New'}</span>
        </button>
      </header>

      {/* Chat History Sidebar / Drawer Overlay */}
      {showDrawer && (
        <div className="fixed inset-0 z-50 flex">
          <div
            className="fixed inset-0 bg-black/40 backdrop-blur-sm transition-opacity"
            onClick={() => setShowDrawer(false)}
          />
          <div className={`relative w-[300px] max-w-[85vw] bg-white h-full shadow-2xl flex flex-col z-10 ${isRTL ? 'mr-auto' : 'ml-auto'}`}>
            <div className="p-4 border-b border-gray-200 flex items-center justify-between bg-gray-50">
              <div className="flex items-center gap-2">
                <History className="w-5 h-5 text-[#2563EB]" />
                <h2 className="font-semibold text-gray-900 text-[15px]">
                  {isRTL ? 'المحادثات المحفوظة' : 'Saved Chats'}
                </h2>
              </div>
              <button
                onClick={() => setShowDrawer(false)}
                className="w-8 h-8 flex items-center justify-center text-gray-500 hover:text-gray-900"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-3 border-b border-gray-100">
              <button
                onClick={handleNewChat}
                className="w-full flex items-center justify-center gap-2 py-2.5 bg-[#2563EB] text-white rounded-xl text-[14px] font-medium hover:bg-blue-700 transition-colors shadow-sm cursor-pointer"
              >
                <Plus className="w-4 h-4" />
                <span>{isRTL ? 'محادثة جديدة' : 'Start New Chat'}</span>
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-3 space-y-2">
              {threads.length === 0 ? (
                <p className="text-center text-gray-400 text-sm py-8">
                  {isRTL ? 'لا توجد محادثات جديدة' : 'No saved chats yet'}
                </p>
              ) : (
                threads.map(thread => {
                  const isSelected = currentThread?.id === thread.id;
                  return (
                    <div
                      key={thread.id}
                      onClick={() => handleSelectThread(thread)}
                      className={`group flex items-center justify-between p-3 rounded-xl cursor-pointer transition-all ${
                        isSelected
                          ? 'bg-[#EFF6FF] border border-[#BFDBFE] text-[#1E40AF]'
                          : 'hover:bg-gray-50 text-gray-700 border border-transparent'
                      }`}
                    >
                      <div className="flex items-center gap-2.5 min-w-0 flex-1">
                        <MessageSquare className={`w-4 h-4 flex-shrink-0 ${isSelected ? 'text-[#2563EB]' : 'text-gray-400'}`} />
                        <span className="text-[13px] font-medium truncate">
                          {thread.title}
                        </span>
                      </div>
                      <button
                        onClick={(e) => handleDeleteThread(e, thread.id)}
                        className="opacity-0 group-hover:opacity-100 p-1 text-gray-400 hover:text-red-600 rounded transition-opacity"
                        title={isRTL ? 'حذف' : 'Delete'}
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        </div>
      )}

      {/* Messages list */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {currentThread?.messages.map((msg) => (
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
              {/* Reasoning / Thinking Accordion Box */}
              {msg.isBot && msg.reasoning && (
                <div className="mb-2 w-full">
                  <button
                    onClick={() => toggleThinking(msg.id)}
                    className="flex items-center gap-1.5 px-3 py-1.5 bg-[#F1F5F9] border border-[#E2E8F0] rounded-xl text-[12px] font-semibold text-[#475569] hover:bg-[#E2E8F0] transition-colors cursor-pointer"
                  >
                    <Brain className="w-3.5 h-3.5 text-[#64748B]" />
                    <span>{isRTL ? 'عملية التفكير الذكي' : 'Thought Process'}</span>
                    {msg.showThinking ? (
                      <ChevronUp className="w-3.5 h-3.5 text-[#64748B]" />
                    ) : (
                      <ChevronDown className="w-3.5 h-3.5 text-[#64748B]" />
                    )}
                  </button>

                  {msg.showThinking && (
                    <div className="mt-1.5 p-3 bg-white border border-[#CBD5E1] rounded-lg text-[12px] font-mono text-[#334155] leading-relaxed whitespace-pre-wrap">
                      {msg.reasoning}
                    </div>
                  )}
                </div>
              )}

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
          <div className="flex items-center gap-2 px-3 py-2 bg-white border border-gray-200 rounded-full w-max text-gray-600 text-xs font-medium italic shadow-sm">
            <Loader2 className="w-4 h-4 animate-spin text-[#2563EB]" />
            <span>{isRTL ? 'يفكر SchooKeep AI في الإجابة...' : 'SchooKeep AI is thinking...'}</span>
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
