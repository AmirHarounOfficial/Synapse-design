import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowRight, ShoppingBag, CheckCircle2, ShieldCheck, Heart, Coffee, Bus, CreditCard } from 'lucide-react';
import { DummyPaymentGatewayService } from '../services/PaymentGatewayService';

export function ParentServiceMarketplace() {
  const navigate = useNavigate();
  const [selectedStudent, setSelectedStudent] = useState('سارة أحمد العتيبي');
  const [cart, setCart] = useState<Array<{ id: string; name: string; price: number }>>([]);
  const [isProcessing, setIsProcessing] = useState(false);
  const [paidSuccess, setPaidSuccess] = useState(false);

  const availableServices = [
    {
      id: 'srv-1',
      name: 'باقة الرعاية الصحية الفائقة (Clinic Care +)',
      description: 'إشعارات SMS فورية مع صور الإصابة وتغطية متابعة الحرارة والجرعات المستمرة.',
      price: 49,
      icon: Heart,
    },
    {
      id: 'srv-2',
      name: 'إدارة ميزانية وحدود الكافتيريا اليومية',
      description: 'تحديد سقف يومي للشراء، حظر مسببات الحساسية، والاطلاع على فاتورة المشتريات التفصيلية.',
      price: 29,
      icon: Coffee,
    },
    {
      id: 'srv-3',
      name: 'التتبع الحي للحافلة المدرسية والتصاريح العاجلة',
      description: 'تتبع الحافلة عبر الخريطة التفاعلية، وإصدار تصاريح الخروج الرقمية المعتمدة.',
      price: 39,
      icon: Bus,
    },
  ];

  const addToCart = (service: { id: string; name: string; price: number }) => {
    if (!cart.find((item) => item.id === service.id)) {
      setCart([...cart, service]);
    }
  };

  const removeFromCart = (id: string) => {
    setCart(cart.filter((item) => item.id !== id));
  };

  const totalPrice = cart.reduce((sum, item) => sum + item.price, 0);

  const handleCheckout = async () => {
    if (cart.length === 0) return;
    setIsProcessing(true);
    await DummyPaymentGatewayService.processPayment({
      customerName: 'أحمد العتيبي (ولي الأمر)',
      customerEmail: 'parent.ahmed@schookeep.com',
      amount: totalPrice,
      currency: 'SAR',
      paymentMethod: 'apple_pay',
      tier: 'guardian_b2c',
      description: `خيار خدمات ولي الأمر للطالب: ${selectedStudent}`,
    });
    setIsProcessing(false);
    setPaidSuccess(true);
    setCart([]);
  };

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 p-6 dir-rtl" dir="rtl">
      {/* Header */}
      <header className="max-w-6xl mx-auto flex items-center justify-between pb-6 border-b border-slate-800 mb-8">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/')}
            className="p-2 hover:bg-slate-800 rounded-lg text-slate-300 hover:text-white transition-colors"
          >
            <ArrowRight className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-white">سوق خدمات ولي الأمر وبوابة الدفع</h1>
            <p className="text-xs text-slate-400">اختيار الباقات والخدمات المضافة للأبناء وتفعيلها فورياً</p>
          </div>
        </div>

        {/* Student Selector */}
        <div className="flex items-center gap-2 bg-slate-900 border border-slate-800 px-4 py-2 rounded-xl text-xs">
          <span className="text-slate-400">الطالب المختار:</span>
          <select
            value={selectedStudent}
            onChange={(e) => setSelectedStudent(e.target.value)}
            className="bg-transparent text-teal-400 font-bold outline-none cursor-pointer"
          >
            <option value="سارة أحمد العتيبي">سارة أحمد العتيبي (الصف 4-أ)</option>
            <option value="محمد أحمد العتيبي">محمد أحمد العتيبي (الصف 1-ب)</option>
          </select>
        </div>
      </header>

      <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8">
        {/* Available Services */}
        <div className="md:col-span-2 space-y-4">
          <h2 className="text-lg font-bold text-white mb-4">الخدمات المتاحة للتفعيل المباشر</h2>

          {availableServices.map((service) => {
            const Icon = service.icon;
            const inCart = cart.some((item) => item.id === service.id);
            return (
              <div
                key={service.id}
                className="p-6 bg-slate-900 border border-slate-800 rounded-2xl flex items-center justify-between gap-4 hover:border-slate-700 transition-colors"
              >
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-teal-500/10 text-teal-400 flex items-center justify-center shrink-0">
                    <Icon className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="font-bold text-white text-base">{service.name}</h3>
                    <p className="text-xs text-slate-400 mt-1 leading-relaxed">{service.description}</p>
                    <div className="text-teal-400 font-extrabold text-sm mt-3">{service.price} ر.س / شهرياً</div>
                  </div>
                </div>

                <button
                  onClick={() => (inCart ? removeFromCart(service.id) : addToCart(service))}
                  className={`px-4 py-2.5 rounded-xl text-xs font-bold transition-all shrink-0 ${
                    inCart
                      ? 'bg-red-500/10 text-red-400 border border-red-500/30 hover:bg-red-500/20'
                      : 'bg-teal-500 hover:bg-teal-400 text-slate-950 shadow-lg shadow-teal-500/20'
                  }`}
                >
                  {inCart ? 'إزالة من السلة' : 'إضافة للخدمات'}
                </button>
              </div>
            );
          })}
        </div>

        {/* Cart & Gateway Checkout Summary */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-6 h-fit">
          <div className="flex items-center justify-between border-b border-slate-800 pb-4">
            <div className="flex items-center gap-2">
              <ShoppingBag className="w-5 h-5 text-teal-400" />
              <span className="font-bold text-white text-base">سلة الخدمات المحددة</span>
            </div>
            <span className="text-xs font-mono text-slate-400">({cart.length}) خدمات</span>
          </div>

          {paidSuccess ? (
            <div className="text-center py-6 space-y-3">
              <CheckCircle2 className="w-12 h-12 text-teal-400 mx-auto" />
              <h4 className="font-bold text-white text-lg">تم تفعيل الخدمات بنجاح!</h4>
              <p className="text-xs text-slate-400">تمت العملية عبر بوابة الدفع الإلكترونية وتم ربط الخدمات بحساب الطالب.</p>
              <button
                onClick={() => setPaidSuccess(false)}
                className="w-full py-2 bg-slate-800 text-slate-300 rounded-xl text-xs"
              >
                إغلاق والتسوق مجدداً
              </button>
            </div>
          ) : (
            <>
              {cart.length === 0 ? (
                <div className="text-center py-8 text-xs text-slate-500">
                  لم تقم بإضافة أي خدمات بعد. اختر من القائمة لتحديد الخدمات المرغوبة.
                </div>
              ) : (
                <div className="space-y-3 text-xs">
                  {cart.map((item) => (
                    <div key={item.id} className="flex items-center justify-between p-2 bg-slate-950 rounded-lg">
                      <span className="text-slate-300 font-medium truncate max-w-[180px]">{item.name}</span>
                      <span className="text-teal-400 font-bold">{item.price} ر.س</span>
                    </div>
                  ))}

                  <div className="pt-4 border-t border-slate-800 flex items-center justify-between text-sm">
                    <span className="font-bold text-slate-300">الإجمالي النهائي:</span>
                    <span className="font-black text-teal-400 text-lg">{totalPrice} ر.س</span>
                  </div>

                  <div className="pt-2 text-[10px] text-slate-400 text-center">
                    يتم السداد الآمن عبر <strong>بوابة الدفع (Payment Gateway)</strong> باستخدام Apple Pay أو مدى.
                  </div>

                  <button
                    onClick={handleCheckout}
                    disabled={isProcessing}
                    className="w-full py-3 bg-gradient-to-r from-teal-500 to-cyan-500 hover:from-teal-400 hover:to-cyan-400 text-slate-950 font-bold rounded-xl text-sm shadow-xl shadow-teal-500/20 transition-all flex items-center justify-center gap-2"
                  >
                    <CreditCard className="w-4 h-4" />
                    {isProcessing ? 'جاري الاتصال ببوابة الدفع...' : 'السداد عبر بوابة الدفع'}
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
