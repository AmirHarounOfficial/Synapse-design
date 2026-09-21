export interface SMSLogEntry {
  id: string;
  recipientPhone: string;
  recipientRole: 'parent' | 'teacher' | 'counselor' | 'principal';
  messageBody: string;
  category: 'emergency_alert' | 'clinic_referral' | 'cafeteria_limit' | 'attendance' | 'otp_verification';
  status: 'sent' | 'delivered' | 'failed' | 'queued';
  sentAt: string;
}

export class SMSHandlerService {
  private static logs: SMSLogEntry[] = [
    {
      id: 'SMS-101',
      recipientPhone: '+966 50 123 4567',
      recipientRole: 'parent',
      messageBody: 'تنبيه صحي من عيادة المدرسة: تم استقبال ابنكم (سارة أحمد) بالعيادة للتحقق من الحرارة.',
      category: 'clinic_referral',
      status: 'delivered',
      sentAt: '2026-09-21 08:30 AM',
    },
    {
      id: 'SMS-102',
      recipientPhone: '+966 55 987 6543',
      recipientRole: 'parent',
      messageBody: 'تنبيه الكافتيريا: تجاوز حد الشراء اليومي المحدد لـ (محمد أحمد). المتبقي 5 ريال.',
      category: 'cafeteria_limit',
      status: 'delivered',
      sentAt: '2026-09-21 09:15 AM',
    },
    {
      id: 'SMS-103',
      recipientPhone: '+966 54 321 0987',
      recipientRole: 'parent',
      messageBody: 'رمز توثيق الدخول الخاص بك في منصة شوكيب SchooKeep هو: 4892. ينتهي خلال 5 دقائق.',
      category: 'otp_verification',
      status: 'delivered',
      sentAt: '2026-09-21 10:00 AM',
    },
  ];

  public static async triggerSMS(params: {
    recipientPhone: string;
    recipientRole: 'parent' | 'teacher' | 'counselor' | 'principal';
    messageBody: string;
    category: 'emergency_alert' | 'clinic_referral' | 'cafeteria_limit' | 'attendance' | 'otp_verification';
  }): Promise<{ success: boolean; log: SMSLogEntry }> {
    const newEntry: SMSLogEntry = {
      id: `SMS-${Math.floor(100 + Math.random() * 900)}`,
      recipientPhone: params.recipientPhone,
      recipientRole: params.recipientRole,
      messageBody: params.messageBody,
      category: params.category,
      status: 'delivered',
      sentAt: new Date().toLocaleString('ar-SA'),
    };

    this.logs.unshift(newEntry);
    console.log('[In-App SMS Handler Triggered]', newEntry);

    return {
      success: true,
      log: newEntry,
    };
  }

  public static getSMSLogs(): SMSLogEntry[] {
    return [...this.logs];
  }
}
