import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowRight, KeyRound, ShieldAlert, CheckCircle2, UserCheck, Shield, ChevronRight } from 'lucide-react';

export function FirstTimeAdminSetup() {
  const navigate = useNavigate();
  const [step, setStep] = useState<number>(1);
  const [role, setRole] = useState<'super_admin' | 'ceo_executive' | 'system_admin'>('ceo_executive');
  const [adminName, setAdminName] = useState('د. عبد العزيز الشمري');
  const [adminEmail, setAdminEmail] = useState('executive@schookeep.com');

  const [permissions, setPermissions] = useState({
    principal_clinic_access: true,
    principal_financial_gateway: true,
    counselor_bias_reporting: true,
    cafeteria_pos_override: false,
    bi_user_access: true,
  });

  const togglePermission = (key: keyof typeof permissions) => {
    setPermissions({ ...permissions, [key]: !permissions[key] });
  };

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 p-6 dir-rtl" dir="rtl">
      <header className="max-w-4xl mx-auto flex items-center justify-between pb-6 border-b border-slate-800 mb-8">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/')}
            className="p-2 hover:bg-slate-800 rounded-lg text-slate-300 hover:text-white transition-colors"
          >
            <ArrowRight className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-white">إعدادات الدخول لأول مرة وتوزيع الصلاحيات</h1>
            <p className="text-xs text-slate-400">خاص بالمدير التنفيذي، مدير المنصة، وإدارة النظام لإعطاء الصلاحيات للمدراء</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-teal-400 bg-teal-500/10 px-3 py-1 rounded-full font-mono">
            الخطوة {step} من 3
          </span>
        </div>
      </header>

      <div className="max-w-4xl mx-auto bg-slate-900 border border-slate-800 rounded-3xl p-8 md:p-10 space-y-8">
        {step === 1 && (
          <div className="space-y-6">
            <h2 className="text-xl font-bold text-white flex items-center gap-2">
              <KeyRound className="w-6 h-6 text-teal-400" />
              ١. تحديد دور مدير النظام والتوثيق المعتمد
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <button
                onClick={() => setRole('ceo_executive')}
                className={`p-5 rounded-2xl border text-right transition-all ${
                  role === 'ceo_executive'
                    ? 'border-teal-500 bg-teal-500/10 text-teal-300'
                    : 'border-slate-800 bg-slate-950 text-slate-400'
                }`}
              >
                <Shield className="w-6 h-6 mb-2 text-teal-400" />
                <h3 className="font-bold text-sm text-white">المدير التنفيذي (CEO)</h3>
                <p className="text-xs text-slate-400 mt-1">صلاحيات الإشراف الإستراتيجي والمالي الكامل</p>
              </button>

              <button
                onClick={() => setRole('super_admin')}
                className={`p-5 rounded-2xl border text-right transition-all ${
                  role === 'super_admin'
                    ? 'border-teal-500 bg-teal-500/10 text-teal-300'
                    : 'border-slate-800 bg-slate-950 text-slate-400'
                }`}
              >
                <UserCheck className="w-6 h-6 mb-2 text-cyan-400" />
                <h3 className="font-bold text-sm text-white">مدير المنصة (Platform Admin)</h3>
                <p className="text-xs text-slate-400 mt-1">إدارة اشتراكات المدارس والربط البرمجي</p>
              </button>

              <button
                onClick={() => setRole('system_admin')}
                className={`p-5 rounded-2xl border text-right transition-all ${
                  role === 'system_admin'
                    ? 'border-teal-500 bg-teal-500/10 text-teal-300'
                    : 'border-slate-800 bg-slate-950 text-slate-400'
                }`}
              >
                <ShieldAlert className="w-6 h-6 mb-2 text-amber-400" />
                <h3 className="font-bold text-sm text-white">مدير النظام (System Admin)</h3>
                <p className="text-xs text-slate-400 mt-1">إدارة الصلاحيات والمستخدمين والتحقق السيبراني</p>
              </button>
            </div>

            <div className="space-y-4 pt-4 border-t border-slate-800">
              <div>
                <label className="block text-xs font-bold text-slate-300 mb-2">الاسم الكامل للمسؤول</label>
                <input
                  type="text"
                  value={adminName}
                  onChange={(e) => setAdminName(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-950 border border-slate-800 rounded-xl text-sm text-white outline-none focus:border-teal-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-300 mb-2">البريد الإلكتروني المؤسسي</label>
                <input
                  type="email"
                  value={adminEmail}
                  onChange={(e) => setAdminEmail(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-950 border border-slate-800 rounded-xl text-sm text-white outline-none focus:border-teal-500"
                />
              </div>
            </div>

            <button
              onClick={() => setStep(2)}
              className="w-full py-3.5 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-sm transition-colors"
            >
              الانتقال إلى تفويض الصلاحيات للمدراء
            </button>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-6">
            <h2 className="text-xl font-bold text-white flex items-center gap-2">
              <ShieldCheck className="w-6 h-6 text-teal-400" />
              ٢. مصفوفة الصلاحيات والحوكمة المعتمدة للمدراء
            </h2>

            <div className="space-y-3">
              <label className="flex items-center justify-between p-4 bg-slate-950 border border-slate-800 rounded-2xl cursor-pointer">
                <div>
                  <span className="font-bold text-sm text-white block">صلاحية الاطلاع الكامل على العيادة المدرسية</span>
                  <span className="text-xs text-slate-400">تسمح لمدير المدرسة بمتابعة زيارات العيادة والإحالات الطارئة.</span>
                </div>
                <input
                  type="checkbox"
                  checked={permissions.principal_clinic_access}
                  onChange={() => togglePermission('principal_clinic_access')}
                  className="w-5 h-5 accent-teal-400 rounded cursor-pointer"
                />
              </label>

              <label className="flex items-center justify-between p-4 bg-slate-950 border border-slate-800 rounded-2xl cursor-pointer">
                <div>
                  <span className="font-bold text-sm text-white block">إدارة شحن بوابة الدفع والتراخيص</span>
                  <span className="text-xs text-slate-400">إمكانية الوصول إلى بوابة الدفع وشحن رصيد الرسائل المعتمد.</span>
                </div>
                <input
                  type="checkbox"
                  checked={permissions.principal_financial_gateway}
                  onChange={() => togglePermission('principal_financial_gateway')}
                  className="w-5 h-5 accent-teal-400 rounded cursor-pointer"
                />
              </label>

              <label className="flex items-center justify-between p-4 bg-slate-950 border border-slate-800 rounded-2xl cursor-pointer">
                <div>
                  <span className="font-bold text-sm text-white block">متابعة بلاغات التمييز والسلوك للموجه الطلابي</span>
                  <span className="text-xs text-slate-400">تمكين الموجه ومدير المدرسة من استقبال خطة الدعم التربوي.</span>
                </div>
                <input
                  type="checkbox"
                  checked={permissions.counselor_bias_reporting}
                  onChange={() => togglePermission('counselor_bias_reporting')}
                  className="w-5 h-5 accent-teal-400 rounded cursor-pointer"
                />
              </label>

              <label className="flex items-center justify-between p-4 bg-slate-950 border border-slate-800 rounded-2xl cursor-pointer">
                <div>
                  <span className="font-bold text-sm text-white block">تمكين يوزر BI للتحليلات المؤسسية العامة</span>
                  <span className="text-xs text-slate-400">السماح لمحلل البيانات بتصدير التقارير الإحصائية التراكمية.</span>
                </div>
                <input
                  type="checkbox"
                  checked={permissions.bi_user_access}
                  onChange={() => togglePermission('bi_user_access')}
                  className="w-5 h-5 accent-teal-400 rounded cursor-pointer"
                />
              </label>
            </div>

            <div className="flex items-center gap-4">
              <button
                onClick={() => setStep(1)}
                className="w-1/3 py-3.5 bg-slate-800 hover:bg-slate-700 text-slate-300 font-bold rounded-xl text-sm"
              >
                السابق
              </button>
              <button
                onClick={() => setStep(3)}
                className="w-2/3 py-3.5 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-sm"
              >
                حفظ وإتمام الإعداد الأول
              </button>
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="text-center py-8 space-y-6">
            <div className="w-16 h-16 rounded-full bg-teal-500/20 text-teal-400 flex items-center justify-center mx-auto">
              <CheckCircle2 className="w-10 h-10" />
            </div>
            <h2 className="text-2xl font-bold text-white">تم إكمال الإعداد الأول وتفويض الصلاحيات!</h2>
            <p className="text-sm text-slate-400 max-w-md mx-auto">
              تم تثبيت حساب <strong>{adminName}</strong> وتفعيل مصفوفة الصلاحيات المخصصة لمدراء الجهات والمدارس.
            </p>
            <button
              onClick={() => navigate('/bi-dashboard')}
              className="px-8 py-3.5 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-sm"
            >
              الانتقال إلى لوحة الإحصاءات ويوزر BI
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
