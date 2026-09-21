import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowRight, BarChart3, TrendingUp, Download, PieChart, Users, Building, ShieldCheck, Activity } from 'lucide-react';

export function BIDashboard() {
  const navigate = useNavigate();
  const [selectedPeriod, setSelectedPeriod] = useState<'monthly' | 'term' | 'annual'>('term');
  const [selectedEntity, setSelectedEntity] = useState('all');

  const stats = [
    { title: 'إجمالي المدارس والجهات المربوطة', value: '42 مدرسة', change: '+12%', icon: Building },
    { title: 'إجمالي الطلاب المستفيدين', value: '28,450 طالب', change: '+8%', icon: Users },
    { title: 'معدل زيارات العيادة المحسومة', value: '1,240 حالة', change: '-4%', icon: Activity },
    { title: 'نسبة الالتزام بالاشتراكات والمدفوعات', value: '98.5%', change: '+1.2%', icon: ShieldCheck },
  ];

  const handleExportPDF = () => {
    alert('جاري توليد وتنزيل تقرير BI الشامل بتنسيق PDF...');
  };

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 p-6 dir-rtl" dir="rtl">
      {/* Header */}
      <header className="max-w-7xl mx-auto flex items-center justify-between pb-6 border-b border-slate-800 mb-8">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/')}
            className="p-2 hover:bg-slate-800 rounded-lg text-slate-300 hover:text-white transition-colors"
          >
            <ArrowRight className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 bg-indigo-500/10 border border-indigo-500/30 text-indigo-300 text-xs font-bold rounded-full">
                BI Analytics User
              </span>
              <h1 className="text-2xl font-bold text-white">إدارة التطبيق من الجهات + يوزر BI + الإحصاءات</h1>
            </div>
            <p className="text-xs text-slate-400 mt-1">عرض المؤشرات البيانية، التكاليف التشغيلية، ومعدلات الأداء المؤسسي</p>
          </div>
        </div>

        <button
          onClick={handleExportPDF}
          className="px-4 py-2.5 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-xs flex items-center gap-2 transition-colors"
        >
          <Download className="w-4 h-4" />
          تصدير التقرير التنفيذي (PDF)
        </button>
      </header>

      {/* KPI Cards */}
      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, i) => {
          const Icon = stat.icon;
          return (
            <div key={i} className="p-6 bg-slate-900 border border-slate-800 rounded-2xl space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-xs text-slate-400 font-medium">{stat.title}</span>
                <div className="w-8 h-8 rounded-lg bg-teal-500/10 text-teal-400 flex items-center justify-center">
                  <Icon className="w-4 h-4" />
                </div>
              </div>
              <div className="text-2xl font-extrabold text-white">{stat.value}</div>
              <div className="text-[10px] text-teal-400 font-semibold">{stat.change} مقارنة بالفصل السابق</div>
            </div>
          );
        })}
      </div>

      {/* Analytics Visual Section */}
      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8">
        <div className="md:col-span-2 p-8 bg-slate-900 border border-slate-800 rounded-3xl space-y-6">
          <div className="flex items-center justify-between border-b border-slate-800 pb-4">
            <h3 className="font-bold text-white text-base flex items-center gap-2">
              <BarChart3 className="w-5 h-5 text-teal-400" />
              توزيع زيارات العيادة وتنبيهات الطقس حسب الأشهر
            </h3>
            <span className="text-xs text-slate-400">الفصل الدراسي الأول 2026</span>
          </div>

          <div className="h-64 flex items-end justify-between gap-4 pt-8 px-4 border-b border-slate-800">
            {[
              { month: 'سبتمبر', value: 65, color: 'bg-teal-500' },
              { month: 'أكتوبر', value: 85, color: 'bg-cyan-500' },
              { month: 'نوفمبر', value: 45, color: 'bg-teal-400' },
              { month: 'ديسمبر', value: 95, color: 'bg-indigo-500' },
              { month: 'يناير', value: 70, color: 'bg-emerald-400' },
            ].map((bar, idx) => (
              <div key={idx} className="flex-1 flex flex-col items-center gap-2 h-full justify-end">
                <div
                  style={{ height: `${bar.value}%` }}
                  className={`w-full rounded-t-xl ${bar.color} transition-all duration-500`}
                />
                <span className="text-xs text-slate-400 font-medium">{bar.month}</span>
              </div>
            ))}
          </div>

          <div className="flex items-center justify-between text-xs text-slate-400 pt-2">
            <span>إجمالي الحالات المعالجة: <strong className="text-white">4,120 حالة</strong></span>
            <span>نسبة الاستجابة السريعة: <strong className="text-teal-400">99.2%</strong></span>
          </div>
        </div>

        <div className="p-8 bg-slate-900 border border-slate-800 rounded-3xl space-y-6">
          <h3 className="font-bold text-white text-base flex items-center gap-2 border-b border-slate-800 pb-4">
            <PieChart className="w-5 h-5 text-teal-400" />
            توزيع مصروفات بوابة الدفع وقيمة الاشتراكات
          </h3>

          <div className="space-y-4 text-xs">
            <div className="p-4 bg-slate-950 rounded-xl space-y-2">
              <div className="flex items-center justify-between text-slate-300">
                <span>اشتراكات المدارس والجهات (B2B)</span>
                <span className="font-bold text-teal-400">62%</span>
              </div>
              <div className="w-full h-2 bg-slate-800 rounded-full overflow-hidden">
                <div className="h-full bg-teal-400 w-[62%]" />
              </div>
            </div>

            <div className="p-4 bg-slate-950 rounded-xl space-y-2">
              <div className="flex items-center justify-between text-slate-300">
                <span>خدمات وميزانية ولي الأمر (B2C)</span>
                <span className="font-bold text-cyan-400">28%</span>
              </div>
              <div className="w-full h-2 bg-slate-800 rounded-full overflow-hidden">
                <div className="h-full bg-cyan-400 w-[28%]" />
              </div>
            </div>

            <div className="p-4 bg-slate-950 rounded-xl space-y-2">
              <div className="flex items-center justify-between text-slate-300">
                <span>شحن رصيد بوابة الدفع SMS</span>
                <span className="font-bold text-indigo-400">10%</span>
              </div>
              <div className="w-full h-2 bg-slate-800 rounded-full overflow-hidden">
                <div className="h-full bg-indigo-400 w-[10%]" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
