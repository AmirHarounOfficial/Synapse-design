import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowRight, ShieldCheck, CheckCircle2, CreditCard, Building2, UserCheck, Zap, Sparkles } from 'lucide-react';
import { DummyPaymentGatewayService, PaymentTransaction } from '../services/PaymentGatewayService';

export function SubscriptionManagement() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<'platform' | 'school' | 'parent'>('school');
  const [showCheckoutModal, setShowCheckoutModal] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState<{ title: string; price: number; type: 'platform_b2b' | 'guardian_b2c' } | null>(null);
  const [paymentMethod, setPaymentMethod] = useState<'apple_pay' | 'mada' | 'credit_card'>('mada');
  const [isProcessing, setIsProcessing] = useState(false);
  const [lastTxn, setLastTxn] = useState<PaymentTransaction | null>(null);

  const handleCheckout = async () => {
    if (!selectedPlan) return;
    setIsProcessing(true);
    const result = await DummyPaymentGatewayService.processPayment({
      customerName: 'مستخدم المنصة التجريبي',
      customerEmail: 'user@schookeep.com',
      amount: selectedPlan.price,
      currency: 'SAR',
      paymentMethod: paymentMethod,
      tier: selectedPlan.type,
      description: `اشتراك - ${selectedPlan.title}`,
    });
    setIsProcessing(false);
    setLastTxn(result.transaction);
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
            <h1 className="text-2xl font-bold text-white">إدارة الاشتراكات والتراخيص</h1>
            <p className="text-xs text-slate-400">إدارة الباقات للمدير العام، المنصة، وإشتراكات ولي الأمر</p>
          </div>
        </div>

        {/* Tab Switcher */}
        <div className="flex bg-slate-900 border border-slate-800 p-1 rounded-xl">
          <button
            onClick={() => setActiveTab('platform')}
            className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'platform' ? 'bg-teal-500 text-slate-950' : 'text-slate-400 hover:text-white'
            }`}
          >
            إدارة المنصة (Super Admin)
          </button>
          <button
            onClick={() => setActiveTab('school')}
            className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'school' ? 'bg-teal-500 text-slate-950' : 'text-slate-400 hover:text-white'
            }`}
          >
            باقات المدارس والجهات (B2B)
          </button>
          <button
            onClick={() => setActiveTab('parent')}
            className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'parent' ? 'bg-teal-500 text-slate-950' : 'text-slate-400 hover:text-white'
            }`}
          >
            اشتراكات ولي الأمر (B2C)
          </button>
        </div>
      </header>

      {/* Main Grid */}
      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8">
        {activeTab === 'school' && (
          <>
            <div className="p-8 bg-slate-900/80 border border-slate-800 rounded-3xl space-y-6 flex flex-col justify-between">
              <div>
                <span className="px-3 py-1 bg-slate-800 text-slate-300 text-xs font-semibold rounded-full">الباقة الأساسية</span>
                <h3 className="text-2xl font-bold text-white mt-4">المدرسة الفضية</h3>
                <div className="text-3xl font-extrabold text-teal-400 mt-2">2,500 <span className="text-xs text-slate-400 font-normal">ر.س / سنوياً</span></div>
                <ul className="mt-6 space-y-3 text-xs text-slate-300">
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> حتى 300 طالب</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> مصفوفة العيادة الأساسية</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> 500 رسالة SMS طوارئ</li>
                </ul>
              </div>
              <button
                onClick={() => {
                  setSelectedPlan({ title: 'الباقة الفضية للمدارس', price: 2500, type: 'platform_b2b' });
                  setShowCheckoutModal(true);
                }}
                className="w-full py-3 bg-slate-800 hover:bg-slate-700 text-white font-bold rounded-xl text-sm transition-colors"
              >
                اختيار الباقة وشحن الحساب
              </button>
            </div>

            <div className="p-8 bg-gradient-to-b from-slate-900 to-slate-950 border-2 border-teal-500 rounded-3xl space-y-6 flex flex-col justify-between relative shadow-xl shadow-teal-500/10">
              <div className="absolute -top-3 left-1/2 -translate-x-1/2 px-4 py-1 bg-teal-500 text-slate-950 text-xs font-extrabold rounded-full">
                الأكثر طلباً للمؤسسات
              </div>
              <div>
                <span className="px-3 py-1 bg-teal-500/10 text-teal-300 text-xs font-semibold rounded-full">الباقة المتقدمة</span>
                <h3 className="text-2xl font-bold text-white mt-4">المدرسة الذهبية</h3>
                <div className="text-3xl font-extrabold text-teal-400 mt-2">4,800 <span className="text-xs text-slate-400 font-normal">ر.س / سنوياً</span></div>
                <ul className="mt-6 space-y-3 text-xs text-slate-300">
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> طلاب لا محدود</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> مصفوفة العيادة + الكافتيريا + البلاغات</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> 2,000 رسالة SMS وطوارئ</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> يوزر BI ورسوم بيانية تنموية</li>
                </ul>
              </div>
              <button
                onClick={() => {
                  setSelectedPlan({ title: 'الباقة الذهبية للمدارس', price: 4800, type: 'platform_b2b' });
                  setShowCheckoutModal(true);
                }}
                className="w-full py-3 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-sm transition-colors"
              >
                تفعيل الباقة الذهبية فوراً
              </button>
            </div>

            <div className="p-8 bg-slate-900/80 border border-slate-800 rounded-3xl space-y-6 flex flex-col justify-between">
              <div>
                <span className="px-3 py-1 bg-slate-800 text-slate-300 text-xs font-semibold rounded-full">باقة المجمع التعليمي</span>
                <h3 className="text-2xl font-bold text-white mt-4">المجمعات والجهات (Enterprise)</h3>
                <div className="text-3xl font-extrabold text-teal-400 mt-2">حسب الطلب</div>
                <ul className="mt-6 space-y-3 text-xs text-slate-300">
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> ربط متعدد الفروع</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> بوابة دفع مخصصة للجهة</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="w-4 h-4 text-teal-400" /> فحص اختراق ودعم سيبراني مخصص</li>
                </ul>
              </div>
              <button
                onClick={() => navigate('/support-portal')}
                className="w-full py-3 bg-slate-800 hover:bg-slate-700 text-white font-bold rounded-xl text-sm transition-colors"
              >
                طلب عرض سعر مخصص
              </button>
            </div>
          </>
        )}

        {activeTab === 'parent' && (
          <div className="col-span-3 p-8 bg-slate-900 border border-slate-800 rounded-3xl space-y-6 text-center">
            <Sparkles className="w-10 h-10 text-teal-400 mx-auto" />
            <h3 className="text-2xl font-bold text-white">باقات ولي الأمر المباشرة</h3>
            <p className="text-sm text-slate-400 max-w-xl mx-auto">
              يمكن لولي الأمر الاشتراك الفردي لباقات التنبيهات الخاصة بالأبناء، متابعة ميزانية الكافتيريا، والحصول على إشعارات الفحوصات الطبية الدورية.
            </p>
            <button
              onClick={() => navigate('/parent-marketplace')}
              className="px-6 py-3 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-sm"
            >
              الانتقال إلى سوق خدمات ولي الأمر وبوابة الدفع
            </button>
          </div>
        )}
      </div>

      {/* Simulated Payment Checkout Modal */}
      {showCheckoutModal && selectedPlan && (
        <div className="fixed inset-0 bg-slate-950/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl p-8 max-w-md w-full space-y-6">
            <h3 className="text-xl font-bold text-white border-b border-slate-800 pb-4">
              بوابة الدفع - سداد قيمة الاشتراك
            </h3>

            {lastTxn ? (
              <div className="space-y-4 text-center">
                <div className="w-12 h-12 rounded-full bg-teal-500/20 text-teal-400 flex items-center justify-center mx-auto">
                  <CheckCircle2 className="w-8 h-8" />
                </div>
                <h4 className="text-lg font-bold text-white">تمت العملية بنجاح!</h4>
                <p className="text-xs text-slate-400">رقم الفاتورة: {lastTxn.id}</p>
                <div className="p-4 bg-slate-950 rounded-xl text-right text-xs space-y-1">
                  <div>المبلغ المدفوع: <strong>{lastTxn.amount} {lastTxn.currency}</strong></div>
                  <div>طريقة الدفع: <strong>{lastTxn.paymentMethod}</strong></div>
                  <div>التاريخ: <strong>{lastTxn.createdAt}</strong></div>
                </div>
                <button
                  onClick={() => {
                    setShowCheckoutModal(false);
                    setLastTxn(null);
                  }}
                  className="w-full py-2.5 bg-teal-500 text-slate-950 font-bold rounded-xl text-sm"
                >
                  إغلاق
                </button>
              </div>
            ) : (
              <div className="space-y-4">
                <div className="p-4 bg-slate-950 rounded-xl space-y-1 text-xs">
                  <div className="text-slate-400">الاشتراك المختار:</div>
                  <div className="font-bold text-white text-sm">{selectedPlan.title}</div>
                  <div className="text-teal-400 text-base font-extrabold">{selectedPlan.price} ر.س</div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-2">اختر طريقة الدفع (بوابة الدفع)</label>
                  <div className="grid grid-cols-3 gap-2">
                    <button
                      onClick={() => setPaymentMethod('mada')}
                      className={`p-3 rounded-xl border text-xs font-bold ${
                        paymentMethod === 'mada' ? 'border-teal-500 bg-teal-500/10 text-teal-300' : 'border-slate-800 text-slate-400'
                      }`}
                    >
                      مدى (MADA)
                    </button>
                    <button
                      onClick={() => setPaymentMethod('apple_pay')}
                      className={`p-3 rounded-xl border text-xs font-bold ${
                        paymentMethod === 'apple_pay' ? 'border-teal-500 bg-teal-500/10 text-teal-300' : 'border-slate-800 text-slate-400'
                      }`}
                    >
                      Apple Pay
                    </button>
                    <button
                      onClick={() => setPaymentMethod('credit_card')}
                      className={`p-3 rounded-xl border text-xs font-bold ${
                        paymentMethod === 'credit_card' ? 'border-teal-500 bg-teal-500/10 text-teal-300' : 'border-slate-800 text-slate-400'
                      }`}
                    >
                      بطاقة ائتمان
                    </button>
                  </div>
                </div>

                <button
                  onClick={handleCheckout}
                  disabled={isProcessing}
                  className="w-full py-3 bg-teal-500 hover:bg-teal-400 text-slate-950 font-bold rounded-xl text-sm flex items-center justify-center gap-2"
                >
                  {isProcessing ? 'جاري معالجة الدفع عبر Gateway...' : 'تأكيد ودفع عبر بوابة الدفع'}
                </button>
                <button
                  onClick={() => setShowCheckoutModal(false)}
                  className="w-full py-2 text-xs text-slate-400 hover:text-white"
                >
                  إلغاء
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
