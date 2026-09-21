import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router';
import {
  Activity,
  ShieldCheck,
  CreditCard,
  Building2,
  Users,
  Smartphone,
  CheckCircle2,
  ArrowRight,
  Calculator,
  Globe,
  FileText,
  Mail,
  Phone,
  HelpCircle,
  ExternalLink,
  MessageSquare,
} from 'lucide-react';

export function LandingPage() {
  const navigate = useNavigate();
  const [studentCount, setStudentCount] = useState<number>(500);
  const [schoolCount, setSchoolCount] = useState<number>(1);

  // Operational fair value calculation
  const baseCostPerStudent = 12; // SAR / month
  const monthlyEst = studentCount * schoolCount * baseCostPerStudent;
  const annualEst = monthlyEst * 10; // 10 academic months

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 font-sans dir-rtl" dir="rtl">
      {/* Top Announcement Bar */}
      <div className="bg-gradient-to-r from-teal-600 to-cyan-600 text-white text-xs md:text-sm py-2 px-4 text-center font-medium">
        ✨ المنصة الوطنية المتكاملة لإدارة الصحة المدرسية والخدمات الرقمية — جاهزة للنشر على <strong>schookeep.com</strong>
      </div>

      {/* Main Navbar */}
      <header className="sticky top-0 z-50 bg-[#0F172A]/90 backdrop-blur-md border-b border-slate-800 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-teal-400 to-cyan-500 flex items-center justify-center shadow-lg shadow-teal-500/20">
            <Activity className="w-6 h-6 text-slate-950 font-bold" />
          </div>
          <div>
            <span className="text-xl font-bold tracking-tight text-white">SchooKeep</span>
            <span className="text-xs block text-teal-400 font-mono">schookeep.com</span>
          </div>
        </div>

        <nav className="hidden md:flex items-center gap-8 text-sm text-slate-300 font-medium">
          <a href="#features" className="hover:text-teal-400 transition-colors">الميزات الرئيسية</a>
          <a href="#matrix" className="hover:text-teal-400 transition-colors">مصفوفة العيادة</a>
          <a href="#pricing" className="hover:text-teal-400 transition-colors">الباقات والدفع</a>
          <a href="#calculator" className="hover:text-teal-400 transition-colors">حاسبة القيمة العادلة</a>
          <a href="#legal" className="hover:text-teal-400 transition-colors">الوثائق الرسمية</a>
        </nav>

        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/login')}
            className="px-4 py-2 text-sm font-medium text-slate-300 hover:text-white transition-colors"
          >
            تسجيل الدخول
          </button>
          <button
            onClick={() => navigate('/navigation-map')}
            className="px-5 py-2.5 rounded-xl bg-gradient-to-r from-teal-500 to-cyan-500 hover:from-teal-400 hover:to-cyan-400 text-slate-950 font-bold text-sm shadow-lg shadow-teal-500/25 transition-all transform hover:-translate-y-0.5"
          >
            استكشاف الخريطة التفاعلية
          </button>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative pt-20 pb-28 px-6 max-w-7xl mx-auto text-center overflow-hidden">
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-teal-500/10 blur-[140px] rounded-full pointer-events-none" />

        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-teal-500/10 border border-teal-500/20 text-teal-300 text-xs font-semibold mb-6">
          <ShieldCheck className="w-4 h-4 text-teal-400" />
          متوافقة مع نظام حماية البيانات الشخصية PDPL ومعايير الصحة المدرسية
        </div>

        <h1 className="text-4xl md:text-6xl font-black tracking-tight text-white leading-tight max-w-4xl mx-auto">
          منظومة <span className="bg-gradient-to-r from-teal-400 via-cyan-300 to-teal-200 bg-clip-text text-transparent">SchooKeep</span> الصحة والخدمات المدرسية المباشرة
        </h1>

        <p className="mt-6 text-lg md:text-xl text-slate-300 max-w-3xl mx-auto font-light leading-relaxed">
          حل رقمي متكامل يربط الإدارة المدرسية، عيادة الصحة، نقطة بيع الكافتيريا، الموجه الطلابي، وبوابة دفع أولياء الأمور في منصة سحابية موحدة وآمنة.
        </p>

        <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
          <button
            onClick={() => navigate('/first-time-setup')}
            className="px-8 py-4 rounded-xl bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold text-base shadow-xl shadow-teal-500/30 transition-all transform hover:-translate-y-1 flex items-center gap-3"
          >
            تفعيل دخول مدير النظام لأول مرة
            <ArrowRight className="w-5 h-5 rotate-180" />
          </button>
          <button
            onClick={() => navigate('/auditor-inspection')}
            className="px-8 py-4 rounded-xl bg-slate-800/80 hover:bg-slate-700/80 border border-slate-700 text-white font-medium text-base transition-all flex items-center gap-3"
          >
            معاينة شهادة الاختبار والزيارة التفتيشية
          </button>
        </div>

        {/* Store Download Badges */}
        <div className="mt-12 flex flex-wrap items-center justify-center gap-4">
          <div className="px-5 py-2.5 bg-slate-900 border border-slate-800 rounded-xl flex items-center gap-3 cursor-pointer hover:border-slate-700 transition-colors">
            <Smartphone className="w-6 h-6 text-teal-400" />
            <div className="text-right">
              <span className="text-[10px] block text-slate-400">حمل التطبيق من</span>
              <span className="text-sm font-bold text-white">App Store (iOS)</span>
            </div>
          </div>
          <div className="px-5 py-2.5 bg-slate-900 border border-slate-800 rounded-xl flex items-center gap-3 cursor-pointer hover:border-slate-700 transition-colors">
            <Smartphone className="w-6 h-6 text-cyan-400" />
            <div className="text-right">
              <span className="text-[10px] block text-slate-400">حمل التطبيق من</span>
              <span className="text-sm font-bold text-white">Google Play</span>
            </div>
          </div>
        </div>
      </section>

      {/* Feature Grid */}
      <section id="features" className="py-20 px-6 max-w-7xl mx-auto border-t border-slate-800">
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold text-white">المكونات والخدمات الميدانية للمنصة</h2>
          <p className="mt-3 text-slate-400">تغطي كافة الاحتياجات التنظيمية، الطبية، والمالية في المؤسسة التعليمية</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="p-6 bg-slate-900/60 border border-slate-800 rounded-2xl hover:border-teal-500/40 transition-colors">
            <div className="w-12 h-12 rounded-xl bg-teal-500/10 flex items-center justify-center text-teal-400 mb-5">
              <Activity className="w-6 h-6" />
            </div>
            <h3 className="text-xl font-bold text-white mb-2">مصفوفة العيادة الصحية</h3>
            <p className="text-sm text-slate-400 leading-relaxed">
              إدارة الزيارات الطبية، سجل الأدوية اليومي، التنبيهات المناخية، والإحالات العاجلة مع تدرج خطورة الحالة.
            </p>
          </div>

          <div className="p-6 bg-slate-900/60 border border-slate-800 rounded-2xl hover:border-teal-500/40 transition-colors">
            <div className="w-12 h-12 rounded-xl bg-cyan-500/10 flex items-center justify-center text-cyan-400 mb-5">
              <CreditCard className="w-6 h-6" />
            </div>
            <h3 className="text-xl font-bold text-white mb-2">بوابة الدفع وباقات الخدمات</h3>
            <p className="text-sm text-slate-400 leading-relaxed">
              ربط سداد الاشتراكات السنوية للجهة مع خيارات دفع خدمات ولي الأمر الكترونياً بمرونة وأمان كامل.
            </p>
          </div>

          <div className="p-6 bg-slate-900/60 border border-slate-800 rounded-2xl hover:border-teal-500/40 transition-colors">
            <div className="w-12 h-12 rounded-xl bg-emerald-500/10 flex items-center justify-center text-emerald-400 mb-5">
              <Users className="w-6 h-6" />
            </div>
            <h3 className="text-xl font-bold text-white mb-2">خدمات ولي الأمر والميزانية</h3>
            <p className="text-sm text-slate-400 leading-relaxed">
              تحديد سقف الشراء اليومي للكافتيريا، متابعة خط السير وتصاريح الخروج، واختيار الخدمات الإضافية.
            </p>
          </div>

          <div className="p-6 bg-slate-900/60 border border-slate-800 rounded-2xl hover:border-teal-500/40 transition-colors">
            <div className="w-12 h-12 rounded-xl bg-indigo-500/10 flex items-center justify-center text-indigo-400 mb-5">
              <Building2 className="w-6 h-6" />
            </div>
            <h3 className="text-xl font-bold text-white mb-2">لوحة BI والتحليلات المؤسسية</h3>
            <p className="text-sm text-slate-400 leading-relaxed">
              يوزر اختصاصي BI للجهات والإدارات لمتابعة المؤشرات العامة، معدلات الإصابة، وتقارير القيمة العادلة.
            </p>
          </div>

          <div className="p-6 bg-slate-900/60 border border-slate-800 rounded-2xl hover:border-teal-500/40 transition-colors">
            <div className="w-12 h-12 rounded-xl bg-amber-500/10 flex items-center justify-center text-amber-400 mb-5">
              <ShieldCheck className="w-6 h-6" />
            </div>
            <h3 className="text-xl font-bold text-white mb-2">متابعة السلوك ومناهضة التمييز</h3>
            <p className="text-sm text-slate-400 leading-relaxed">
              نظام بلاغات التمييز والعنصرية المدرسية الموجه للموجه الطلابي والمعلمين لحماية البيئة التربوية.
            </p>
          </div>

          <div className="p-6 bg-slate-900/60 border border-slate-800 rounded-2xl hover:border-teal-500/40 transition-colors">
            <div className="w-12 h-12 rounded-xl bg-purple-500/10 flex items-center justify-center text-purple-400 mb-5">
              <MessageSquare className="w-6 h-6" />
            </div>
            <h3 className="text-xl font-bold text-white mb-2">الدعم الفني والشكاوي</h3>
            <p className="text-sm text-slate-400 leading-relaxed">
              مركز موحد لتلقي الشكاوي والاقترحات، والتواصل الفوري لمعالجة أي صعوبات تقنية.
            </p>
          </div>
        </div>
      </section>

      {/* Operational Fair Value & Cost Calculator Widget */}
      <section id="calculator" className="py-20 px-6 max-w-5xl mx-auto">
        <div className="p-8 md:p-12 bg-gradient-to-br from-slate-900 to-slate-950 border border-slate-800 rounded-3xl relative overflow-hidden shadow-2xl">
          <div className="flex items-center gap-3 mb-6">
            <Calculator className="w-7 h-7 text-teal-400" />
            <h2 className="text-2xl font-bold text-white">حاسبة القيمة العادلة وتكاليف التشغيل للمؤسسات</h2>
          </div>

          <p className="text-sm text-slate-400 mb-8">
            احسب التكلفة التقديرية العادلة لاشتراك المنصة وحزم الرسائل والخدمات بناءً على عدد الطلاب والمدارس:
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-slate-300 mb-2">
                  عدد الطلاب في المدرسة / المجموعات ({studentCount} طالب)
                </label>
                <input
                  type="range"
                  min="100"
                  max="5000"
                  step="50"
                  value={studentCount}
                  onChange={(e) => setStudentCount(Number(e.target.value))}
                  className="w-full accent-teal-400 cursor-pointer"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-300 mb-2">
                  عدد الفروع / المدارس المشمولة ({schoolCount} مدرسة)
                </label>
                <input
                  type="range"
                  min="1"
                  max="20"
                  step="1"
                  value={schoolCount}
                  onChange={(e) => setSchoolCount(Number(e.target.value))}
                  className="w-full accent-teal-400 cursor-pointer"
                />
              </div>
            </div>

            <div className="p-6 bg-slate-950 border border-slate-800 rounded-2xl text-center space-y-4">
              <span className="text-xs text-slate-400 block font-mono">القيمة العادلة المحتسبة (Fair Market Value)</span>
              <div>
                <span className="text-4xl font-extrabold text-teal-400">{monthlyEst.toLocaleString()}</span>
                <span className="text-sm text-slate-400 mr-2">ر.س / شهرياً</span>
              </div>
              <div className="text-xs text-slate-400 pt-3 border-t border-slate-800">
                التكلفة التقديرية السنوية (10 أشهر دراسية): <strong className="text-white">{annualEst.toLocaleString()} ر.س</strong>
              </div>
              <button
                onClick={() => navigate('/b2b-subscriptions')}
                className="w-full py-2.5 rounded-xl bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold text-sm transition-colors"
              >
                طلب عرض سعر مؤسسي متكامل
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Legal Footer & Social Links */}
      <footer id="legal" className="py-12 px-6 border-t border-slate-800 text-sm text-slate-400">
        <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-8 mb-12">
          <div>
            <span className="text-lg font-bold text-white block mb-3">SchooKeep</span>
            <p className="text-xs text-slate-400 leading-relaxed mb-4">
              المنصة المتكاملة لحوكمة وإدارة الخدمات الصحية والتربوية في المدارس والمؤسسات التعليمية.
            </p>
            <div className="text-xs text-slate-500">موقع المنصة الرسمي: schookeep.com</div>
          </div>

          <div>
            <h4 className="font-bold text-white mb-3 text-sm">الوثائق القانونية</h4>
            <ul className="space-y-2 text-xs">
              <li><Link to="/legal/terms" className="hover:text-teal-400">الشروط والأحكام</Link></li>
              <li><Link to="/legal/privacy" className="hover:text-teal-400">سياسة الخصوصية PDPL</Link></li>
              <li><Link to="/legal/disclaimer" className="hover:text-teal-400">إخلاء المسؤولية الطبية</Link></li>
              <li><Link to="/legal/refund" className="hover:text-teal-400">سياسة المرجوع من المنصة</Link></li>
            </ul>
          </div>

          <div>
            <h4 className="font-bold text-white mb-3 text-sm">روابط سريعة</h4>
            <ul className="space-y-2 text-xs">
              <li><Link to="/parent-marketplace" className="hover:text-teal-400">خدمات ولي الأمر وبوابة الدفع</Link></li>
              <li><Link to="/bi-dashboard" className="hover:text-teal-400">لوحة تحليلات BI للجهات</Link></li>
              <li><Link to="/support-portal" className="hover:text-teal-400">مركز الشكاوى والدعم الفني</Link></li>
              <li><Link to="/system-training" className="hover:text-teal-400">مركز تدريب ودليل استخدام البرنامج</Link></li>
            </ul>
          </div>

          <div>
            <h4 className="font-bold text-white mb-3 text-sm">تواصل معنا</h4>
            <div className="space-y-2 text-xs">
              <div className="flex items-center gap-2"><Mail className="w-4 h-4 text-teal-400" /> support@schookeep.com</div>
              <div className="flex items-center gap-2"><Phone className="w-4 h-4 text-teal-400" /> 800-SCHOOKEEP (72466)</div>
              <div className="flex items-center gap-2 pt-2">
                <span className="text-slate-400">السوشيال ميديا:</span>
                <span className="hover:text-teal-400 cursor-pointer">X</span> |
                <span className="hover:text-teal-400 cursor-pointer">LinkedIn</span> |
                <span className="hover:text-teal-400 cursor-pointer">YouTube</span>
              </div>
            </div>
          </div>
        </div>

        <div className="max-w-7xl mx-auto pt-6 border-t border-slate-800 text-center text-xs text-slate-500">
          جميع الحقوق محفوظة © 2026 SchooKeep | schookeep.com
        </div>
      </footer>
    </div>
  );
}
