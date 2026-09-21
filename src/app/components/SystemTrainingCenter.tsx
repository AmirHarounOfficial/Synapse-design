import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowRight, BookOpen, Video, Play, FileText, CheckCircle2, Award, Sparkles } from 'lucide-react';

export function SystemTrainingCenter() {
  const navigate = useNavigate();
  const [completedModules, setCompletedModules] = useState<number[]>([1]);

  const modules = [
    { id: 1, title: 'الموديل الأول: مصفوفة العيادة وحالات الطوارئ', duration: '15 دقيقة', icon: BookOpen },
    { id: 2, title: 'الموديل الثاني: إدارة بوابة الدفع والشحن', duration: '10 دقائق', icon: Video },
    { id: 3, title: 'الموديل الثالث: نقطة بيع الكافتيريا وحدود الشراء', duration: '12 دقيقة', icon: Play },
    { id: 4, title: 'الموديل الرابع: مسار ولي الأمر والتصاريح والحافلة', duration: '20 دقيقة', icon: FileText },
  ];

  const toggleComplete = (id: number) => {
    if (completedModules.includes(id)) {
      setCompletedModules(completedModules.filter((m) => m !== id));
    } else {
      setCompletedModules([...completedModules, id]);
    }
  };

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 p-6 dir-rtl" dir="rtl">
      {/* Header */}
      <header className="max-w-5xl mx-auto flex items-center justify-between pb-6 border-b border-slate-800 mb-8">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/')}
            className="p-2 hover:bg-slate-800 rounded-lg text-slate-300 hover:text-white transition-colors"
          >
            <ArrowRight className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-white">مركز التدريب ودليل استخدام البرنامج</h1>
            <p className="text-xs text-slate-400">دورات تدريبية تفاعلية وإدلة تشغيل الكوادر والمستعملين</p>
          </div>
        </div>

        <div className="flex items-center gap-2 bg-teal-500/10 border border-teal-500/20 px-4 py-2 rounded-xl text-xs text-teal-300">
          <Award className="w-4 h-4 text-teal-400" />
          <span>نسبة الإنجاز: <strong>{Math.round((completedModules.length / modules.length) * 100)}%</strong></span>
        </div>
      </header>

      <div className="max-w-5xl mx-auto space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {modules.map((mod) => {
            const Icon = mod.icon;
            const isDone = completedModules.includes(mod.id);
            return (
              <div
                key={mod.id}
                className="p-6 bg-slate-900 border border-slate-800 rounded-2xl flex items-center justify-between hover:border-slate-700 transition-colors"
              >
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-teal-500/10 text-teal-400 flex items-center justify-center shrink-0">
                    <Icon className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="font-bold text-white text-base">{mod.title}</h3>
                    <p className="text-xs text-slate-400 mt-1">المدة المقدرة: {mod.duration}</p>
                  </div>
                </div>

                <button
                  onClick={() => toggleComplete(mod.id)}
                  className={`px-4 py-2 rounded-xl text-xs font-bold transition-all shrink-0 ${
                    isDone
                      ? 'bg-teal-500/20 text-teal-300 border border-teal-500/40'
                      : 'bg-slate-800 hover:bg-slate-700 text-white'
                  }`}
                >
                  {isDone ? 'مكتمل ✓' : 'بدء التدريب'}
                </button>
              </div>
            );
          })}
        </div>

        {completedModules.length === modules.length && (
          <div className="p-8 bg-gradient-to-r from-teal-900/40 to-cyan-900/40 border border-teal-500/40 rounded-3xl text-center space-y-4">
            <Sparkles className="w-10 h-10 text-teal-400 mx-auto" />
            <h2 className="text-xl font-bold text-white">تهانينا! لقد أكملت جميع وحدات البرنامج التدريبي.</h2>
            <p className="text-xs text-slate-300">يمكنك الآن استخراج شهادة إتمام التدريب الرسمية لاستخدام نظام SchooKeep.</p>
            <button
              onClick={() => navigate('/auditor-inspection')}
              className="px-6 py-3 bg-teal-500 text-slate-950 font-bold rounded-xl text-xs"
            >
              استعراض شهادة الاختبار والتفتيش
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
