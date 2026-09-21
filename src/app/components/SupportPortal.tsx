import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowRight, MessageSquare, Send, CheckCircle2, AlertCircle, HelpCircle, LifeBuoy, FileQuestion } from 'lucide-react';

export function SupportPortal() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<'complaint' | 'suggestion' | 'tech_support'>('complaint');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [ticketId, setTicketId] = useState<string | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!subject || !message) return;
    const generatedId = `TCK-${Math.floor(1000 + Math.random() * 9000)}`;
    setTicketId(generatedId);
    setSubject('');
    setMessage('');
  };

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 p-6 dir-rtl" dir="rtl">
      {/* Header */}
      <header className="max-w-4xl mx-auto flex items-center justify-between pb-6 border-b border-slate-800 mb-8">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/')}
            className="p-2 hover:bg-slate-800 rounded-lg text-slate-300 hover:text-white transition-colors"
          >
            <ArrowRight className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-white">صفحة الشكاوى - الاقتراحات - الدعم الفني</h1>
            <p className="text-xs text-slate-400">مركز تواصل المدارس، الكوادر الطبية، وأولياء الأمور</p>
          </div>
        </div>

        <div className="flex bg-slate-900 border border-slate-800 p-1 rounded-xl">
          <button
            onClick={() => setActiveTab('complaint')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'complaint' ? 'bg-red-500/20 text-red-300 border border-red-500/40' : 'text-slate-400'
            }`}
          >
            تقديم شكوى
          </button>
          <button
            onClick={() => setActiveTab('suggestion')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'suggestion' ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40' : 'text-slate-400'
            }`}
          >
            صندوق الاقتراحات
          </button>
          <button
            onClick={() => setActiveTab('tech_support')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'tech_support' ? 'bg-teal-500/20 text-teal-300 border border-teal-500/40' : 'text-slate-400'
            }`}
          >
            طلب دعم فني
          </button>
        </div>
      </header>

      <div className="max-w-4xl mx-auto bg-slate-900 border border-slate-800 rounded-3xl p-8 md:p-10 space-y-6">
        {ticketId ? (
          <div className="text-center py-10 space-y-4">
            <div className="w-16 h-16 rounded-full bg-teal-500/20 text-teal-400 flex items-center justify-center mx-auto">
              <CheckCircle2 className="w-10 h-10" />
            </div>
            <h2 className="text-2xl font-bold text-white">تم استلام طلبكم بنجاح!</h2>
            <p className="text-sm text-slate-400">
              رقم التذكرة الخاص بكم: <strong className="text-teal-400 font-mono text-base">{ticketId}</strong>
            </p>
            <p className="text-xs text-slate-400 max-w-md mx-auto">
              سيقوم فريق الدعم الفني بمنصة SchooKeep بمراجعة الطلب والتواصل معكم خلال 24 ساعة عبر البريد الإلكتروني أو الرسائل النصية.
            </p>
            <button
              onClick={() => setTicketId(null)}
              className="px-6 py-2.5 bg-slate-800 text-white rounded-xl text-xs font-bold"
            >
              تقديم تذكرة جديدة
            </button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-2">عنوان التذكرة / الموضوع</label>
              <input
                type="text"
                value={subject}
                onChange={(e) => setSubject(e.target.value)}
                placeholder="أدخل عنوان ملخص للطلب أو المشكلة..."
                className="w-full px-4 py-3 bg-slate-950 border border-slate-800 rounded-xl text-sm text-white outline-none focus:border-teal-500"
                required
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-2">تفاصيل الشكوى / الاقتراح / الدعم الفني</label>
              <textarea
                rows={5}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="اكتب التفاصيل الكاملة هنا..."
                className="w-full px-4 py-3 bg-slate-950 border border-slate-800 rounded-xl text-sm text-white outline-none focus:border-teal-500"
                required
              />
            </div>

            <button
              type="submit"
              className="w-full py-3.5 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-sm flex items-center justify-center gap-2"
            >
              <Send className="w-4 h-4" />
              إرسال التذكرة للفريق المختص
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
