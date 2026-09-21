import React from 'react';
import { useNavigate, Link, useLocation } from 'react-router';
import { ArrowRight, ShieldCheck, FileText, Lock, RefreshCw, AlertTriangle } from 'lucide-react';

interface LegalLayoutProps {
  title: string;
  subtitle: string;
  children: React.ReactNode;
}

export function LegalLayout({ title, subtitle, children }: LegalLayoutProps) {
  const navigate = useNavigate();
  const location = useLocation();

  const legalNav = [
    { path: '/legal/terms', label: 'الشروط والأحكام', icon: FileText },
    { path: '/legal/privacy', label: 'سياسة الخصوصية PDPL', icon: Lock },
    { path: '/legal/disclaimer', label: 'إخلاء المسؤولية', icon: AlertTriangle },
    { path: '/legal/refund', label: 'سياسة المرجوع من المنصة', icon: RefreshCw },
  ];

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 dir-rtl" dir="rtl">
      {/* Header */}
      <header className="bg-slate-900 border-b border-slate-800 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/')}
            className="p-2 hover:bg-slate-800 rounded-lg text-slate-300 hover:text-white transition-colors flex items-center gap-2 text-sm"
          >
            <ArrowRight className="w-5 h-5" />
            الرئيسية
          </button>
          <div className="h-5 w-px bg-slate-800" />
          <div className="flex items-center gap-2">
            <ShieldCheck className="w-5 h-5 text-teal-400" />
            <span className="font-bold text-white text-base">مركز الوثائق القانونية — SchooKeep</span>
          </div>
        </div>

        <span className="text-xs font-mono text-teal-400 bg-teal-500/10 border border-teal-500/20 px-3 py-1 rounded-full">
          schookeep.com
        </span>
      </header>

      <div className="max-w-7xl mx-auto px-6 py-10 grid grid-cols-1 md:grid-cols-4 gap-8">
        {/* Sidebar Nav */}
        <aside className="space-y-2">
          <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block px-3 mb-2">
            السياسات والأنظمة
          </span>
          {legalNav.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-teal-500/10 text-teal-300 border border-teal-500/30'
                    : 'text-slate-400 hover:text-white hover:bg-slate-900'
                }`}
              >
                <Icon className={`w-4 h-4 ${isActive ? 'text-teal-400' : 'text-slate-500'}`} />
                {item.label}
              </Link>
            );
          })}
        </aside>

        {/* Content */}
        <main className="md:col-span-3 bg-slate-900/60 border border-slate-800 rounded-2xl p-8 md:p-10 space-y-6">
          <div className="border-b border-slate-800 pb-6">
            <h1 className="text-3xl font-extrabold text-white">{title}</h1>
            <p className="text-sm text-slate-400 mt-2">{subtitle}</p>
          </div>

          <div className="prose prose-invert max-w-none text-slate-300 text-sm leading-relaxed space-y-6">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
