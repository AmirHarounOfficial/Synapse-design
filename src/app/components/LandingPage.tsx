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
  ChevronDown,
  Sparkles,
  HeartPulse,
  Coffee,
  AlertOctagon,
  Award,
  Zap,
  Lock,
  UserCheck,
  Calendar,
  MessageCircle,
  Menu,
  X,
} from 'lucide-react';

export function LandingPage() {
  const navigate = useNavigate();
  const [studentCount, setStudentCount] = useState<number>(750);
  const [schoolCount, setSchoolCount] = useState<number>(2);
  const [openFaq, setOpenFaq] = useState<number | null>(0);
  const [mobileMenuOpen, setMobileMenuOpen] = useState<boolean>(false);

  // Operational fair value calculation (Nexora Style Estimator)
  const baseCostPerStudent = 12; // SAR / month
  const monthlyEst = studentCount * schoolCount * baseCostPerStudent;
  const annualEst = monthlyEst * 10; // 10 academic months

  const faqs = [
    {
      question: 'كيف يتم الربط مع بوابة الدفع للخدمات وااشتراكات ولي الأمر؟',
      answer:
        'تتيح منصة SchooKeep ربطاً مزدوجاً لسداد اشتراكات الجهات والمدارس (B2B) بالإضافة إلى خدمات ولي الأمر المضافة (B2C) كحزمة العناية المتقدمة وميزانية الكافتيريا عبر مدى وApple Pay.',
    },
    {
      question: 'ما هو نظام حوكمة وتفويض الصلاحيات للدخول لأول مرة؟',
      answer:
        'يتضمن النظام مسار إعداد أولي مخصص للمدير التنفيذي ومدير المنصة لإسناد وتفويض الصلاحيات لمدراء المدارس والممرضين والموجهين الطلابي بحسب مصفوفة الأمان.',
    },
    {
      question: 'كيف تعمل حاسبة القيمة العادلة وتكاليف التشغيل للمؤسسات؟',
      answer:
        'تعتمد الحاسبة التفاعلية على معايير تسعير الحجم العادل (Fair Market Value) بناءً على عدد الطلاب الإجمالي وعدد الفروع التعليمية المشمولة لتوفير أقصى عائد استثماري.',
    },
    {
      question: 'هل المنصة متوافقة مع نظام حماية البيانات الشخصية PDPL؟',
      answer:
        'نعم، جميع بيانات الملفات الصحية والبيانات الشخصية مشفرة وتخزن داخل مراكز بيانات سيادية معتمدة تضمن الخصوصية التامة والامتثال لأعلى التشريعات.',
    },
    {
      question: 'ما هي طريقة معالجة تنبيهات الرسائل النصية SMS؟',
      answer:
        'يمتلك النظام معالجات إشعارات داخلية ووظائف برمجية (In-App SMS Handlers) لإرسال وتتبع الرسائل الطارئة والتنبيهات للوالدين دون الاعتماد الحصري على بوابات خارجية.',
    },
  ];

  return (
    <div className="min-h-screen bg-[#F9FAFB] text-slate-900 font-sans selection:bg-teal-100 selection:text-teal-900 dir-rtl overflow-x-hidden" dir="rtl">
      {/* Top Header Bar (Nexora Top Strip) */}
      <div className="bg-slate-900 text-slate-300 text-xs py-2 px-4 sm:px-6 lg:px-12">
        <div className="max-w-7xl mx-auto flex flex-wrap items-center justify-between gap-2 text-center sm:text-right">
          <p className="font-medium text-slate-300 flex items-center justify-center sm:justify-start gap-2 text-[11px] sm:text-xs">
            <span className="w-2 h-2 rounded-full bg-emerald-400 shrink-0 inline-block" />
            منظومة حوكمة وإدارة الصحة المدرسية والخدمات الرقمية المعتمدة
          </p>
          <div className="flex items-center justify-center sm:justify-end gap-4 sm:gap-6 text-[11px] sm:text-xs text-slate-400 w-full sm:w-auto">
            <a href="tel:80072466" className="hover:text-white transition-colors flex items-center gap-1">
              <Phone className="w-3.5 h-3.5 text-teal-400 shrink-0" />
              800-SCHOOKEEP (72466)
            </a>
            <span>|</span>
            <a href="mailto:info@schookeep.com" className="hover:text-white transition-colors flex items-center gap-1">
              <Mail className="w-3.5 h-3.5 text-teal-400 shrink-0" />
              info@schookeep.com
            </a>
          </div>
        </div>
      </div>

      {/* Main Navbar (Nexora Glass Clean Header with Mobile Drawer) */}
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-slate-200/80 px-4 sm:px-6 lg:px-12 py-3 shadow-sm">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-2xl bg-teal-600 text-white flex items-center justify-center font-bold text-lg shadow-md shadow-teal-600/20 shrink-0">
              <Activity className="w-5 h-5 sm:w-6 sm:h-6" />
            </div>
            <div>
              <span className="text-lg sm:text-xl font-bold tracking-tight text-slate-900 block leading-tight">
                SchooKeep
              </span>
              <span className="text-[9px] sm:text-[10px] text-teal-700 font-semibold tracking-wider block">
                الصحة • الحوكمة • الأمان
              </span>
            </div>
          </div>

          {/* Desktop Nav Links */}
          <nav className="hidden lg:flex items-center gap-1">
            <a href="#hero" className="px-3 py-2 rounded-full text-xs font-semibold text-teal-700 bg-teal-50">الرئيسية</a>
            <a href="#solutions" className="px-3 py-2 rounded-full text-xs font-semibold text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors">الخدمات والأدوات</a>
            <a href="#why" className="px-3 py-2 rounded-full text-xs font-semibold text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors">لماذا SchooKeep</a>
            <a href="#journey" className="px-3 py-2 rounded-full text-xs font-semibold text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors">خطوات التشغيل</a>
            <a href="#calculator" className="px-3 py-2 rounded-full text-xs font-semibold text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors">حاسبة القيمة العادلة</a>
            <a href="#faq" className="px-3 py-2 rounded-full text-xs font-semibold text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors">الأسئلة الشائعة</a>
          </nav>

          {/* Navbar Actions */}
          <div className="flex items-center gap-2 sm:gap-3">
            <button
              onClick={() => navigate('/login')}
              className="hidden sm:inline-flex items-center justify-center px-4 py-2 rounded-full text-xs font-semibold text-slate-700 hover:text-slate-900 transition-colors"
            >
              تسجيل الدخول
            </button>

            <button
              onClick={() => navigate('/b2b-subscriptions')}
              className="inline-flex items-center justify-center gap-1.5 px-3.5 sm:px-5 py-2 sm:py-2.5 rounded-full bg-teal-600 hover:bg-teal-700 text-white text-xs font-bold shadow-md shadow-teal-600/20 transition-colors"
            >
              طلب عرض سعر
            </button>

            <button
              onClick={() => navigate('/navigation-map')}
              aria-label="Interactive Map"
              className="w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200 flex items-center justify-center hover:scale-105 transition-transform shrink-0"
            >
              <Globe className="w-4 h-4 sm:w-5 sm:h-5" />
            </button>

            {/* Mobile Menu Toggle Button */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="lg:hidden w-9 h-9 rounded-full border border-slate-200 flex items-center justify-center text-slate-700 hover:bg-slate-100 transition-colors shrink-0"
              aria-label="Toggle Navigation Menu"
            >
              {mobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation Drawer */}
        {mobileMenuOpen && (
          <div className="lg:hidden mt-3 pt-3 border-t border-slate-200 space-y-2 text-xs font-semibold">
            <a
              href="#hero"
              onClick={() => setMobileMenuOpen(false)}
              className="block p-2.5 rounded-xl bg-teal-50 text-teal-700 font-bold"
            >
              الرئيسية
            </a>
            <a
              href="#solutions"
              onClick={() => setMobileMenuOpen(false)}
              className="block p-2.5 rounded-xl text-slate-700 hover:bg-slate-100"
            >
              الخدمات والأدوات
            </a>
            <a
              href="#why"
              onClick={() => setMobileMenuOpen(false)}
              className="block p-2.5 rounded-xl text-slate-700 hover:bg-slate-100"
            >
              لماذا SchooKeep
            </a>
            <a
              href="#journey"
              onClick={() => setMobileMenuOpen(false)}
              className="block p-2.5 rounded-xl text-slate-700 hover:bg-slate-100"
            >
              خطوات التشغيل
            </a>
            <a
              href="#calculator"
              onClick={() => setMobileMenuOpen(false)}
              className="block p-2.5 rounded-xl text-slate-700 hover:bg-slate-100"
            >
              حاسبة القيمة العادلة
            </a>
            <a
              href="#faq"
              onClick={() => setMobileMenuOpen(false)}
              className="block p-2.5 rounded-xl text-slate-700 hover:bg-slate-100"
            >
              الأسئلة الشائعة
            </a>
            <button
              onClick={() => {
                setMobileMenuOpen(false);
                navigate('/login');
              }}
              className="w-full text-right p-2.5 rounded-xl text-teal-700 font-bold hover:bg-teal-50"
            >
              تسجيل الدخول
            </button>
          </div>
        )}
      </header>

      {/* Nexora Hero Section (Mobile Optimized) */}
      <section id="hero" className="relative pt-8 sm:pt-12 md:pt-20 pb-12 sm:pb-16 md:pb-24 px-4 sm:px-6 lg:px-12 max-w-7xl mx-auto overflow-hidden">
        <div aria-hidden="true" className="pointer-events-none absolute top-10 right-0 h-64 sm:h-96 w-64 sm:w-96 rounded-full bg-teal-400/10 blur-3xl" />
        <div aria-hidden="true" className="pointer-events-none absolute -left-20 bottom-0 h-64 sm:h-80 w-64 sm:w-80 rounded-full bg-emerald-400/10 blur-3xl" />

        <div className="grid items-center gap-8 lg:gap-12 lg:grid-cols-2">
          <div className="space-y-4 sm:space-y-6 text-right">
            <span className="inline-flex items-center gap-2 rounded-full bg-teal-50 border border-teal-200 px-3 sm:px-3.5 py-1 sm:py-1.5 text-[11px] sm:text-xs font-bold text-teal-800 shadow-sm">
              <ShieldCheck className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-teal-600 shrink-0" />
              حوكمة رقمية متكاملة للصحة المدرسية
            </span>

            <h1 className="text-2xl sm:text-4xl md:text-5xl lg:text-6xl font-black text-slate-900 leading-[1.2] sm:leading-[1.15] tracking-tight">
              رحلتك في إدارة الصحة المدرسية تبدأ بخطة رقمية واضحة.
            </h1>

            <p className="text-sm sm:text-base md:text-lg leading-relaxed text-slate-600 font-normal">
              منظومة SchooKeep تدمج العيادة الطبية، ميزانية الكافتيريا، الموجه الطلابي، وتصاريح الحافلة مع بوابة دفع أولياء الأمور في حل رقمي سهل وموثوق.
            </p>

            <div className="flex flex-col sm:flex-row gap-3 pt-2 w-full">
              <button
                onClick={() => navigate('/first-time-setup')}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 text-xs font-bold bg-teal-600 hover:bg-teal-700 text-white px-6 sm:px-7 py-3.5 rounded-full shadow-md shadow-teal-600/20 transition-all transform hover:-translate-y-0.5"
              >
                تفعيل دخول مدير النظام لأول مرة
                <ArrowRight className="w-4 h-4 rotate-180 shrink-0" />
              </button>

              <button
                onClick={() => navigate('/auditor-inspection')}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 text-xs font-bold border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 px-6 sm:px-7 py-3.5 rounded-full shadow-sm transition-colors"
              >
                معاينة شهادة الاختبار والتفتيش
              </button>
            </div>
          </div>

          {/* Nexora Hero Preview Card (Mobile Responsive) */}
          <div className="relative w-full">
            <div className="overflow-hidden rounded-2xl sm:rounded-[2rem] border border-slate-200 bg-white p-4 sm:p-6 shadow-xl space-y-4 sm:space-y-6">
              <div className="flex items-center justify-between pb-3 sm:pb-4 border-b border-slate-100 gap-2">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-2xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold shrink-0">
                    <Activity className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="font-bold text-xs sm:text-sm text-slate-900">مدرسة المستقبل الأهلية</h3>
                    <span className="text-[10px] text-teal-600 font-semibold block">حالة النظام: متصل 100%</span>
                  </div>
                </div>
                <span className="px-2.5 py-1 bg-emerald-50 text-emerald-700 text-[10px] sm:text-xs font-bold rounded-full border border-emerald-200 shrink-0">
                  PDPL معتمد
                </span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                <div className="p-3.5 sm:p-4 rounded-xl sm:rounded-2xl bg-slate-50 border border-slate-100 space-y-1">
                  <span className="text-slate-500 block text-[11px]">زيارات العيادة اليوم:</span>
                  <strong className="text-slate-900 text-sm sm:text-base font-bold block">12 حالة</strong>
                  <span className="text-teal-600 text-[10px] font-semibold">تم التعامل الفوري</span>
                </div>
                <div className="p-3.5 sm:p-4 rounded-xl sm:rounded-2xl bg-slate-50 border border-slate-100 space-y-1">
                  <span className="text-slate-500 block text-[11px]">رصيد الرسائل والتنبيهات:</span>
                  <strong className="text-slate-900 text-sm sm:text-base font-bold block">2,450 رسالة</strong>
                  <span className="text-emerald-600 text-[10px] font-semibold">جاهز لإرسال SMS</span>
                </div>
              </div>

              <div className="p-3.5 sm:p-4 rounded-xl sm:rounded-2xl bg-teal-950 text-white space-y-1.5">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-bold text-teal-300">بوابة الدفع الإلكتروني (Gateway)</span>
                  <span className="text-[10px] text-teal-400 font-mono">MADA / Apple Pay</span>
                </div>
                <p className="text-[11px] sm:text-xs text-slate-300">سداد اشتراكات خدمات ولي الأمر وميزانية الكافتيريا فورياً.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Section 2: Popular Solutions (Mobile Optimized Grid) */}
      <section id="solutions" className="py-12 sm:py-16 md:py-24 bg-white border-t border-slate-200/80">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-12">
          <div className="max-w-2xl mx-auto text-center space-y-2 sm:space-y-3">
            <span className="inline-flex items-center rounded-full bg-teal-50 px-3 py-1 text-[11px] sm:text-xs font-bold text-teal-700 uppercase">
              الخدمات والأدوات الرئيسية
            </span>
            <h2 className="text-xl sm:text-2xl md:text-4xl font-bold text-slate-900">
              أنظمة رقمية متكاملة لإدارة الصحة المدرسية
            </h2>
            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed">
              كل باقة مصممة بمسار عالي الكفاءة يضمن سلامة الطلاب وسهولة الاستخدام للكادر المدرسي.
            </p>
          </div>

          <div className="mt-8 sm:mt-12 grid gap-4 sm:gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
            {/* Cards */}
            <div className="group flex flex-col justify-between rounded-2xl sm:rounded-3xl border border-slate-200 bg-white p-5 sm:p-7 shadow-sm hover:shadow-md transition-all">
              <div className="space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold shrink-0">
                  <HeartPulse className="w-5 h-5 sm:w-6 sm:h-6" />
                </div>
                <h3 className="text-base sm:text-lg font-bold text-slate-900">مصفوفة العيادة وإعادة الترتيب</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  تدرج خطورة الحالات الصحية، متابعة جرعات الأدوية اليومية، وتنبيهات الأحوال الجوية الطارئة.
                </p>
              </div>
              <button
                onClick={() => navigate('/nurse/dashboard')}
                className="mt-4 sm:mt-6 inline-flex items-center gap-1.5 text-xs font-bold text-teal-700 hover:text-teal-800 transition-colors"
              >
                استكشاف مصفوفة العيادة
                <ArrowRight className="w-4 h-4 rotate-180 shrink-0" />
              </button>
            </div>

            <div className="group flex flex-col justify-between rounded-2xl sm:rounded-3xl border border-slate-200 bg-white p-5 sm:p-7 shadow-sm hover:shadow-md transition-all">
              <div className="space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold shrink-0">
                  <CreditCard className="w-5 h-5 sm:w-6 sm:h-6" />
                </div>
                <h3 className="text-base sm:text-lg font-bold text-slate-900">بوابة الدفع الإلكتروني (Gateway)</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  ربط سداد اشتراكات الجهات والمدارس (B2B) وباقات ولي الأمر (B2C) عبر مدى وApple Pay.
                </p>
              </div>
              <button
                onClick={() => navigate('/parent-marketplace')}
                className="mt-4 sm:mt-6 inline-flex items-center gap-1.5 text-xs font-bold text-teal-700 hover:text-teal-800 transition-colors"
              >
                استعراض بوابة الدفع
                <ArrowRight className="w-4 h-4 rotate-180 shrink-0" />
              </button>
            </div>

            <div className="group flex flex-col justify-between rounded-2xl sm:rounded-3xl border border-slate-200 bg-white p-5 sm:p-7 shadow-sm hover:shadow-md transition-all">
              <div className="space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold shrink-0">
                  <Coffee className="w-5 h-5 sm:w-6 sm:h-6" />
                </div>
                <h3 className="text-base sm:text-lg font-bold text-slate-900">ميزانية الكافتيريا ونقطة البيع (POS)</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  تحديد الحد اليومي للشراء من ولي الأمر، وتنبيهات الحساسية الغذائية في نقطة بيع الكافتيريا.
                </p>
              </div>
              <button
                onClick={() => navigate('/cafeteria/alert-dashboard')}
                className="mt-4 sm:mt-6 inline-flex items-center gap-1.5 text-xs font-bold text-teal-700 hover:text-teal-800 transition-colors"
              >
                معاينة نقطة البيع
                <ArrowRight className="w-4 h-4 rotate-180 shrink-0" />
              </button>
            </div>

            <div className="group flex flex-col justify-between rounded-2xl sm:rounded-3xl border border-slate-200 bg-white p-5 sm:p-7 shadow-sm hover:shadow-md transition-all">
              <div className="space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold shrink-0">
                  <AlertOctagon className="w-5 h-5 sm:w-6 sm:h-6" />
                </div>
                <h3 className="text-base sm:text-lg font-bold text-slate-900">بلاغات السلوك ومناهضة التمييز</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  استقبال وتصنيف بلاغات التمييز والعنصرية للموجه الطلابي وسائقي الحافلات لبناء الخطة التربوية.
                </p>
              </div>
              <button
                onClick={() => navigate('/counselor/dashboard')}
                className="mt-4 sm:mt-6 inline-flex items-center gap-1.5 text-xs font-bold text-teal-700 hover:text-teal-800 transition-colors"
              >
                فتح مركز البلاغات
                <ArrowRight className="w-4 h-4 rotate-180 shrink-0" />
              </button>
            </div>

            <div className="group flex flex-col justify-between rounded-2xl sm:rounded-3xl border border-slate-200 bg-white p-5 sm:p-7 shadow-sm hover:shadow-md transition-all">
              <div className="space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold shrink-0">
                  <Building2 className="w-5 h-5 sm:w-6 sm:h-6" />
                </div>
                <h3 className="text-base sm:text-lg font-bold text-slate-900">يوزر BI والتحليلات القيادية</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  حساب مخصص لمحللي بيانات الجهات والمدارس لمتابعة المؤشرات الإحصائية ورسوم الاتجاهات.
                </p>
              </div>
              <button
                onClick={() => navigate('/bi-dashboard')}
                className="mt-4 sm:mt-6 inline-flex items-center gap-1.5 text-xs font-bold text-teal-700 hover:text-teal-800 transition-colors"
              >
                عرض لوحة تحليلات BI
                <ArrowRight className="w-4 h-4 rotate-180 shrink-0" />
              </button>
            </div>

            <div className="group flex flex-col justify-between rounded-2xl sm:rounded-3xl border border-slate-200 bg-white p-5 sm:p-7 shadow-sm hover:shadow-md transition-all">
              <div className="space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold shrink-0">
                  <UserCheck className="w-5 h-5 sm:w-6 sm:h-6" />
                </div>
                <h3 className="text-base sm:text-lg font-bold text-slate-900">الدخول لأول مرة وتفويض الصلاحيات</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  مسار التهيئة الأولي للمدير التنفيذي ومدير المنصة لإسناد مصفوفة الصلاحيات المعتمدة.
                </p>
              </div>
              <button
                onClick={() => navigate('/first-time-setup')}
                className="mt-4 sm:mt-6 inline-flex items-center gap-1.5 text-xs font-bold text-teal-700 hover:text-teal-800 transition-colors"
              >
                بدء مسار الإعداد الأول
                <ArrowRight className="w-4 h-4 rotate-180 shrink-0" />
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Section 3: Why SchooKeep (Mobile Responsive) */}
      <section id="why" className="py-12 sm:py-16 md:py-24 bg-[#F3F4F6] border-t border-slate-200/80">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-12">
          <div className="max-w-2xl mx-auto text-center space-y-2 sm:space-y-3">
            <span className="inline-flex items-center rounded-full bg-teal-50 px-3 py-1 text-[11px] sm:text-xs font-bold text-teal-700 uppercase">
              لماذا SchooKeep
            </span>
            <h2 className="text-xl sm:text-2xl md:text-4xl font-bold text-slate-900">
              معلومات دقيقة. رعاية منظمة. دعم متواصل.
            </h2>
          </div>

          <div className="mt-8 sm:mt-12 grid gap-4 sm:gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
            <div className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6 shadow-sm space-y-2 sm:space-y-3">
              <div className="w-10 h-10 rounded-xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold">
                <Users className="w-5 h-5" />
              </div>
              <h3 className="font-bold text-slate-900 text-sm sm:text-base">نقطة تواصل فردية لكل طالب</h3>
              <p className="text-xs text-slate-600 leading-relaxed">تنظيم كامل لكافة الخطوات الطبية والصحية الخاصة بكافة الطلاب.</p>
            </div>

            <div className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6 shadow-sm space-y-2 sm:space-y-3">
              <div className="w-10 h-10 rounded-xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold">
                <ShieldCheck className="w-5 h-5" />
              </div>
              <h3 className="font-bold text-slate-900 text-sm sm:text-base">امتثال لخصوصية PDPL 100%</h3>
              <p className="text-xs text-slate-600 leading-relaxed">بيانات صحية مشفرة ومحفوظة في سيرفرات سيادية آمنة.</p>
            </div>

            <div className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6 shadow-sm space-y-2 sm:space-y-3">
              <div className="w-10 h-10 rounded-xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold">
                <CreditCard className="w-5 h-5" />
              </div>
              <h3 className="font-bold text-slate-900 text-sm sm:text-base">وضوح باقات بوابة الدفع</h3>
              <p className="text-xs text-slate-600 leading-relaxed">تفاصيل شفافة ومباشرة لكافة المدفوعات والاشتراكات المقررة.</p>
            </div>

            <div className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6 shadow-sm space-y-2 sm:space-y-3">
              <div className="w-10 h-10 rounded-xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold">
                <Zap className="w-5 h-5" />
              </div>
              <h3 className="font-bold text-slate-900 text-sm sm:text-base">دعم التشغيل والتنبيهات SMS</h3>
              <p className="text-xs text-slate-600 leading-relaxed">معالجة فورية للإشعارات وتصاريح الحافلة والزيارات الطارئة.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Section 4: Your Journey Steps (Mobile Responsive Grid) */}
      <section id="journey" className="py-12 sm:py-16 md:py-24 bg-white border-t border-slate-200/80">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-12">
          <div className="max-w-2xl mx-auto text-center space-y-2 sm:space-y-3">
            <span className="inline-flex items-center rounded-full bg-teal-50 px-3 py-1 text-[11px] sm:text-xs font-bold text-teal-700 uppercase">
              خطوات التشغيل
            </span>
            <h2 className="text-xl sm:text-2xl md:text-4xl font-bold text-slate-900">
              منذ التواصل الأول وحتى التشغيل الكامل بالمدرسة
            </h2>
          </div>

          <div className="mt-8 sm:mt-12 grid gap-4 sm:gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
            {[
              { num: '01', title: 'تواصل معنا وحدد الاحتياجات', desc: 'شاركنا عدد الطلاب والفروع وتفاصيل الخدمات المطلوب تفعيلها.' },
              { num: '02', title: 'مراجعة الملاحظات الطبية', desc: 'نقوم بتنسيق السجلات وتعيين مصفوفة العيادة وصلاحيات الممرضين.' },
              { num: '03', title: 'استلام التقرير والقيمة العادلة', desc: 'مراجعة باقة التكلفة المقترحة والتراخيص وبوابة الدفع المعتمدة.' },
              { num: '04', title: 'تفعيل الدخول لأول مرة', desc: 'إتمام مسار الإعداد الأولي وتفويض الصلاحيات لمدراء المدارس.' },
              { num: '05', title: 'تدريب الكادر وتطبيقات الهواتف', desc: 'تقويم الكوادر وإتاحة تنزيل التطبيقات للكوادر وأولياء الأمور.' },
              { num: '06', title: 'التشغيل الميداني والمتابعة', desc: 'تتبع الحالات الصحية ورصيد بوابة الدفع وتقارير BI المباشرة.' },
            ].map((step, idx) => (
              <div key={idx} className="flex gap-3 sm:gap-4 rounded-2xl border border-slate-200 bg-white p-4 sm:p-6 shadow-sm">
                <span className="grid h-10 w-10 sm:h-11 sm:w-11 shrink-0 place-items-center rounded-xl bg-teal-600 font-bold text-xs sm:text-sm text-white">
                  {step.num}
                </span>
                <div className="space-y-1">
                  <h3 className="font-bold text-slate-900 text-xs sm:text-sm">{step.title}</h3>
                  <p className="text-[11px] sm:text-xs text-slate-600 leading-relaxed">{step.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Section 5: Institutional Fair Value Calculator (Mobile Optimized) */}
      <section id="calculator" className="py-12 sm:py-16 md:py-24 bg-[#F9FAFB] border-t border-slate-200/80">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-12">
          <div className="p-5 sm:p-8 md:p-12 rounded-2xl sm:rounded-3xl border border-slate-200 bg-white shadow-lg space-y-6 sm:space-y-8">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-2xl bg-teal-50 text-teal-700 flex items-center justify-center font-bold shrink-0">
                <Calculator className="w-5 h-5" />
              </div>
              <div>
                <span className="text-[10px] sm:text-xs text-teal-700 font-bold block">FAIR VALUE CALCULATOR ENGINE</span>
                <h2 className="text-lg sm:text-xl md:text-2xl font-bold text-slate-900">حاسبة القيمة العادلة وتكاليف التشغيل للمؤسسات</h2>
              </div>
            </div>

            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed">
              احسب التكلفة التقديرية العادلة لاشتراك المنصة وحزم الرسائل والخدمات بناءً على عدد الطلاب والمدارس:
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 sm:gap-8 items-center">
              <div className="space-y-4 sm:space-y-6">
                <div>
                  <div className="flex justify-between items-center text-xs font-bold text-slate-700 mb-2">
                    <span>عدد الطلاب الإجمالي:</span>
                    <span className="text-teal-700 font-bold text-xs sm:text-sm">{studentCount} طالب</span>
                  </div>
                  <input
                    type="range"
                    min="100"
                    max="5000"
                    step="50"
                    value={studentCount}
                    onChange={(e) => setStudentCount(Number(e.target.value))}
                    className="w-full accent-teal-600 cursor-pointer h-2 bg-slate-100 rounded-lg"
                  />
                </div>

                <div>
                  <div className="flex justify-between items-center text-xs font-bold text-slate-700 mb-2">
                    <span>عدد المدارس / الفروع:</span>
                    <span className="text-teal-700 font-bold text-xs sm:text-sm">{schoolCount} مدرسة</span>
                  </div>
                  <input
                    type="range"
                    min="1"
                    max="25"
                    step="1"
                    value={schoolCount}
                    onChange={(e) => setSchoolCount(Number(e.target.value))}
                    className="w-full accent-teal-600 cursor-pointer h-2 bg-slate-100 rounded-lg"
                  />
                </div>
              </div>

              <div className="p-5 sm:p-6 bg-teal-50 rounded-2xl border border-teal-200 text-center space-y-3 sm:space-y-4">
                <span className="text-xs text-teal-800 font-bold block">القيمة العادلة المحتسبة (Monthly Fair Value)</span>
                <div>
                  <span className="text-3xl sm:text-4xl font-black text-teal-700">{monthlyEst.toLocaleString()}</span>
                  <span className="text-xs text-slate-600 mr-1.5">ر.س / شهرياً</span>
                </div>
                <div className="text-[11px] sm:text-xs text-slate-600 pt-3 border-t border-teal-200">
                  التكلفة السنوية التقديرية (10 أشهر): <strong className="text-slate-900">{annualEst.toLocaleString()} ر.س</strong>
                </div>
                <button
                  onClick={() => navigate('/b2b-subscriptions')}
                  className="w-full py-3 rounded-full bg-teal-600 hover:bg-teal-700 text-white font-bold text-xs transition-colors shadow-md shadow-teal-600/20"
                >
                  طلب عرض سعر مؤسسي مخصص
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Section 6: FAQ (Mobile Optimized) */}
      <section id="faq" className="py-12 sm:py-16 md:py-24 bg-white border-t border-slate-200/80">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-12">
          <div className="max-w-2xl mx-auto text-center space-y-2 sm:space-y-3 mb-8 sm:mb-12">
            <span className="inline-flex items-center rounded-full bg-teal-50 px-3 py-1 text-[11px] sm:text-xs font-bold text-teal-700 uppercase">
              الأسئلة الشائعة
            </span>
            <h2 className="text-xl sm:text-2xl md:text-4xl font-bold text-slate-900">
              إجابات الشفافية الفنية والاستفسارات
            </h2>
          </div>

          <div className="space-y-3 sm:space-y-4">
            {faqs.map((faq, idx) => {
              const isOpen = openFaq === idx;
              return (
                <div key={idx} className="rounded-2xl border border-slate-200 bg-white overflow-hidden">
                  <button
                    onClick={() => setOpenFaq(isOpen ? null : idx)}
                    className="w-full p-4 sm:p-6 text-right font-bold text-slate-900 text-xs sm:text-sm flex items-center justify-between gap-3 cursor-pointer hover:bg-slate-50 transition-colors"
                  >
                    <span>{faq.question}</span>
                    <ChevronDown className={`w-4 h-4 sm:w-5 sm:h-5 text-teal-700 shrink-0 transition-transform ${isOpen ? 'rotate-180' : ''}`} />
                  </button>

                  {isOpen && (
                    <div className="px-4 sm:px-6 pb-4 sm:pb-6 text-[11px] sm:text-xs text-slate-600 leading-relaxed border-t border-slate-100 pt-3 sm:pt-4">
                      {faq.answer}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Section 7: Nexora Clean Footer (Mobile Optimized) */}
      <footer id="legal" className="border-t border-slate-200 bg-slate-900 text-slate-300 text-xs">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-12 py-12 sm:py-16 grid gap-8 sm:gap-10 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
          <div className="space-y-3 sm:space-y-4 text-center sm:text-right">
            <div className="flex items-center justify-center sm:justify-start gap-3">
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-2xl bg-teal-600 text-white flex items-center justify-center font-bold text-lg shrink-0">
                <Activity className="w-5 h-5 sm:w-6 sm:h-6" />
              </div>
              <span className="text-lg font-bold text-white">SchooKeep</span>
            </div>
            <p className="text-slate-400 leading-relaxed text-[11px] sm:text-xs">
              منظومة الحوكمة الموحدة لإدارة الصحة المدرسية، بوابة الدفع، وتطبيقات ولي الأمر المعتمدة.
            </p>
          </div>

          <div className="text-center sm:text-right">
            <h4 className="font-bold text-white mb-3 sm:mb-4 text-xs sm:text-sm tracking-wider uppercase">السياسات والوثائق</h4>
            <ul className="space-y-2 sm:space-y-2.5 text-slate-400 text-[11px] sm:text-xs">
              <li><Link to="/legal/terms" className="hover:text-white transition-colors">الشروط والأحكام والاستخدام</Link></li>
              <li><Link to="/legal/privacy" className="hover:text-white transition-colors">سياسة الخصوصية PDPL</Link></li>
              <li><Link to="/legal/disclaimer" className="hover:text-white transition-colors">إخلاء المسؤولية الطبية</Link></li>
              <li><Link to="/legal/refund" className="hover:text-white transition-colors">سياسة المرجوع واسترداد المبالغ</Link></li>
            </ul>
          </div>

          <div className="text-center sm:text-right">
            <h4 className="font-bold text-white mb-3 sm:mb-4 text-xs sm:text-sm tracking-wider uppercase">الأنظمة والأدوات</h4>
            <ul className="space-y-2 sm:space-y-2.5 text-slate-400 text-[11px] sm:text-xs">
              <li><Link to="/parent-marketplace" className="hover:text-white transition-colors">سوق خدمات ولي الأمر وبوابة الدفع</Link></li>
              <li><Link to="/bi-dashboard" className="hover:text-white transition-colors">لوحة تحليلات BI والإحصاءات</Link></li>
              <li><Link to="/system-training" className="hover:text-white transition-colors">مركز تدريب الكوادر المدرسية</Link></li>
              <li><Link to="/auditor-inspection" className="hover:text-white transition-colors">معاينة الشهادة الاختبارية</Link></li>
            </ul>
          </div>

          <div className="text-center sm:text-right">
            <h4 className="font-bold text-white mb-3 sm:mb-4 text-xs sm:text-sm tracking-wider uppercase">تواصل معنا</h4>
            <ul className="space-y-2.5 text-slate-400 text-[11px] sm:text-xs flex flex-col items-center sm:items-start">
              <li className="flex items-center gap-2"><Phone className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-teal-400 shrink-0" /> 800-SCHOOKEEP (72466)</li>
              <li className="flex items-center gap-2"><Mail className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-teal-400 shrink-0" /> info@schookeep.com</li>
              <li className="flex items-center gap-2"><MessageCircle className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-emerald-400 shrink-0" /> واتساب: +966 50 123 4567</li>
            </ul>
          </div>
        </div>

        <div className="border-t border-slate-800 py-6 px-4 sm:px-6 lg:px-12 text-slate-500 text-[11px] sm:text-xs">
          <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-3 text-center sm:text-right">
            <p>© 2026 SchooKeep Platform. جميع الحقوق محفوظة.</p>
            <div className="flex gap-4">
              <Link to="/legal/privacy" className="hover:text-slate-300">سياسة الخصوصية</Link>
              <Link to="/legal/terms" className="hover:text-slate-300">الشروط والأحكام</Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
