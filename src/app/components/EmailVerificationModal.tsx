import React, { useState } from 'react';
import { Mail, CheckCircle2, Smartphone, Download, ArrowLeft } from 'lucide-react';

export function EmailVerificationModal({ onClose }: { onClose?: () => void }) {
  const [otp, setOtp] = useState(['', '', '', '']);
  const [verified, setVerified] = useState(false);

  const handleVerify = () => {
    if (otp.join('').length === 4) {
      setVerified(true);
    }
  };

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 flex items-center justify-center p-6 dir-rtl" dir="rtl">
      <div className="bg-slate-900 border border-slate-800 rounded-3xl p-8 max-w-md w-full space-y-6 text-center">
        <div className="w-14 h-14 rounded-2xl bg-teal-500/10 text-teal-400 flex items-center justify-center mx-auto">
          <Mail className="w-7 h-7" />
        </div>

        <h2 className="text-xl font-bold text-white">توثيق الإيميل وتنزل التطبيق</h2>
        <p className="text-xs text-slate-400 leading-relaxed">
          تم إرسال رمز التوثيق إلى بريدك الإلكتروني <strong>user@schookeep.com</strong>. يرجى إدخال الرمز لتأكيد تفعيل الحساب.
        </p>

        {verified ? (
          <div className="space-y-4 py-4">
            <div className="w-12 h-12 rounded-full bg-teal-500/20 text-teal-400 flex items-center justify-center mx-auto">
              <CheckCircle2 className="w-8 h-8" />
            </div>
            <h3 className="font-bold text-white text-base">تم توثيق البريد الإلكتروني بنجاح!</h3>
            <p className="text-xs text-slate-400">يمكنك الآن تنزيل التطبيق مباشرة عبر روابط المتجر الرسمية:</p>

            <div className="space-y-2 pt-2">
              <a
                href="#"
                className="p-3 bg-slate-950 border border-slate-800 rounded-xl flex items-center justify-between hover:border-teal-500 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <Smartphone className="w-5 h-5 text-teal-400" />
                  <span className="text-xs font-bold text-white">تحميل تطبيق iOS (App Store)</span>
                </div>
                <Download className="w-4 h-4 text-slate-400" />
              </a>

              <a
                href="#"
                className="p-3 bg-slate-950 border border-slate-800 rounded-xl flex items-center justify-between hover:border-cyan-500 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <Smartphone className="w-5 h-5 text-cyan-400" />
                  <span className="text-xs font-bold text-white">تحميل تطبيق Android (Google Play)</span>
                </div>
                <Download className="w-4 h-4 text-slate-400" />
              </a>
            </div>
          </div>
        ) : (
          <div className="space-y-6">
            <div className="flex justify-center gap-3 dir-ltr" dir="ltr">
              {otp.map((digit, idx) => (
                <input
                  key={idx}
                  type="text"
                  maxLength={1}
                  value={digit}
                  onChange={(e) => {
                    const newOtp = [...otp];
                    newOtp[idx] = e.target.value;
                    setOtp(newOtp);
                  }}
                  className="w-12 h-12 text-center text-lg font-bold bg-slate-950 border border-slate-800 rounded-xl text-white outline-none focus:border-teal-500"
                />
              ))}
            </div>

            <button
              onClick={handleVerify}
              className="w-full py-3 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-sm"
            >
              توثيق الحساب
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
