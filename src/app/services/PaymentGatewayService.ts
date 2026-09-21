export interface PaymentTransaction {
  id: string;
  orderId: string;
  customerName: string;
  customerEmail: string;
  amount: number;
  currency: 'SAR' | 'AED' | 'USD';
  paymentMethod: 'apple_pay' | 'mada' | 'credit_card' | 'bank_transfer';
  status: 'succeeded' | 'pending' | 'failed';
  tier: 'platform_b2b' | 'guardian_b2c' | 'sms_topup';
  description: string;
  createdAt: string;
  invoiceUrl: string;
}

export class DummyPaymentGatewayService {
  private static transactions: PaymentTransaction[] = [
    {
      id: 'TXN-99812',
      orderId: 'ORD-2026-001',
      customerName: 'مدارس المستقبل الأهلية (Al-Mustaqbal School)',
      customerEmail: 'admin@mustaqbal.edu.sa',
      amount: 4500,
      currency: 'SAR',
      paymentMethod: 'bank_transfer',
      status: 'succeeded',
      tier: 'platform_b2b',
      description: 'اشتراك المنصة السنوي - باقة المدارس المتقدمة',
      createdAt: '2026-09-01 10:30 AM',
      invoiceUrl: '#',
    },
    {
      id: 'TXN-99813',
      orderId: 'ORD-2026-002',
      customerName: 'أحمد محمود العتيبي (Parent)',
      customerEmail: 'ahmed.o@gmail.com',
      amount: 150,
      currency: 'SAR',
      paymentMethod: 'apple_pay',
      status: 'succeeded',
      tier: 'guardian_b2c',
      description: 'باقة العناية الطبية الفائقة + متابعة الكافتيريا',
      createdAt: '2026-09-15 02:15 PM',
      invoiceUrl: '#',
    },
    {
      id: 'TXN-99814',
      orderId: 'ORD-2026-003',
      customerName: 'عيادة الصحة المدرسية - فرع جدة',
      customerEmail: 'clinic.jeddah@synapse.med',
      amount: 500,
      currency: 'SAR',
      paymentMethod: 'mada',
      status: 'succeeded',
      tier: 'sms_topup',
      description: 'شحن رصيد بوابة الدفع - 1000 رسالة SMS طارئة',
      createdAt: '2026-09-20 09:00 AM',
      invoiceUrl: '#',
    },
  ];

  public static async processPayment(params: {
    customerName: string;
    customerEmail: string;
    amount: number;
    currency: 'SAR' | 'AED' | 'USD';
    paymentMethod: 'apple_pay' | 'mada' | 'credit_card' | 'bank_transfer';
    tier: 'platform_b2b' | 'guardian_b2c' | 'sms_topup';
    description: string;
  }): Promise<{ success: boolean; transaction: PaymentTransaction; message: string }> {
    await new Promise((resolve) => setTimeout(resolve, 1000));

    const newTxn: PaymentTransaction = {
      id: `TXN-${Math.floor(10000 + Math.random() * 90000)}`,
      orderId: `ORD-2026-${Math.floor(100 + Math.random() * 900)}`,
      customerName: params.customerName,
      customerEmail: params.customerEmail,
      amount: params.amount,
      currency: params.currency,
      paymentMethod: params.paymentMethod,
      status: 'succeeded',
      tier: params.tier,
      description: params.description,
      createdAt: new Date().toLocaleString('ar-SA'),
      invoiceUrl: `#invoice-${Date.now()}`,
    };

    this.transactions.unshift(newTxn);
    return {
      success: true,
      transaction: newTxn,
      message: 'تمت عملية الدفع بنجاح عبر بوابة الدفع (Dummy Payment Gateway)',
    };
  }

  public static getTransactions(): PaymentTransaction[] {
    return [...this.transactions];
  }
}
