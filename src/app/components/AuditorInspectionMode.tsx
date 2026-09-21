import React from 'react';
import { useNavigate } from 'react-router';
import { ArrowRight, Award, ShieldCheck, CheckCircle2, FileCheck, Building2, Calendar, Printer } from 'lucide-react';

export function AuditorInspectionMode() {
  const navigate = useNavigate();

  const handlePrint = () => {
    window.print();
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
            <h1 className="text-2xl font-bold text-white">معاينة زيارة التطبيق للشهادة الاختبارية</h1>
            <p className="text-xs text-slate-400">نمودج التقييم واختبار الجاهزية للزيارات التفتيشية الرسمية</p>
          </div>
        </div>

        <button
          onClick={handlePrint}
          className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-white rounded-xl text-xs font-bold flex items-center gap-2"
        >
          <Printer className="w-4 h-4" />
          طباعة الشهادة الاختبارية
        </button>
      </header>

      <div className="max-w-4xl mx-auto bg-slate-900 border-2 border-teal-500/40 rounded-3xl p-8 md:p-12 space-y-8 relative overflow-hidden shadow-2xl">
        <div className="absolute top-0 right-0 w-40 h-40 bg-teal-500/10 blur-3xl pointer-events-none" />

        <div className="flex items-center justify-between border-b border-slate-800 pb-6">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-xl bg-teal-500/20 text-teal-400 flex items-center justify-center">
              <Award className="w-7 h-7" />
            </div>
            <div>
              <span className="text-xs text-teal-400 font-mono block">TEST & INSPECTION CERTIFICATE</span>
              <h2 className="text-xl font-bold text-white">شهادة الجاهزية والاختبار الميداني</h2>
            </div>
          </div>
          <span className="px-3 py-1 bg-teal-500/10 border border-teal-500/30 text-teal-300 text-xs font-bold rounded-full">
            معتمدة للاختبار
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-xs text-slate-300">
          <div className="p-4 bg-slate-950 rounded-2xl border border-slate-800 space-y-2">
            <span className="text-slate-500 block">جهة التقييم والاختبار:</span>
            <strong className="text-white text-sm block">فريق الجودة والسيبرانية — SchooKeep Platform</strong>
            <span className="text-slate-400 block">رقم الشهادة: SK-CERT-2026-9901</span>
          </div>

          <div className="p-4 bg-slate-950 rounded-2xl border border-slate-800 space-y-2">
            <span className="text-slate-500 block">تاريخ الزيارة والاختبار:</span>
            <strong className="text-white text-sm block">21 سبتمبر 2026</strong>
            <span className="text-teal-400 block">الحالة: اجتياز كامل لجميع المتطلبات 100%</span>
          </div>
        </div>

        <div className="space-y-4">
          <h3 className="font-bold text-white text-sm border-b border-slate-800 pb-2">نتائج مراجعة المتطلبات الـ 16 المعتمدة:</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
            <div className="flex items-center gap-2 text-slate-300"><CheckCircle2 className="w-4 h-4 text-teal-400 shrink-0" /> مصفوفة العيادة وإعادة الترتيب</div>
            <div className="flex items-center gap-2 text-slate-300"><CheckCircle2 className="w-4 h-4 text-teal-400 shrink-0" /> بوابة الدفع الإلكترونية ورصيد SMS</div>
            <div className="flex items-center gap-2 text-slate-300"><CheckCircle2 className="w-4 h-4 text-teal-400 shrink-0" /> الشروط والأحكام وخصوصية PDPL</div>
            <div className="flex items-center gap-2 text-slate-300"><CheckCircle2 className="w-4 h-4 text-teal-400 shrink-0" /> باقات ولي الأمر المباشرة</div>
            <div className="flex items-center gap-2 text-slate-300"><CheckCircle2 className="w-4 h-4 text-teal-400 shrink-0" /> حاسبة القيمة العادلة وتكاليف التشغيل</div>
            <div className="flex items-center gap-2 text-slate-300"><CheckCircle2 className="w-4 h-4 text-teal-400 shrink-0" /> يوزر BI ومؤشرات الأداء للجهات</div>
          </div>
        </div>

        <div className="pt-6 border-t border-slate-800 flex items-center justify-between text-xs text-slate-400">
          <span>التوقيع الإلكتروني المعتمد: <strong className="text-white">SchooKeep Audit Engine</strong></span>
          <span>schookeep.com</span>
        </div>
      </div>
    </div>
  );
}
