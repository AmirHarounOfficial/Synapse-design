import React from 'react';
import { LegalLayout } from './LegalLayout';

export function RefundPolicyPage() {
  return (
    <LegalLayout
      title="سياسة المرجوع واسترداد المبالغ من المنصة"
      subtitle="تاريخ التحديث: سبتمبر 2026 — منصة SchooKeep"
    >
      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">١. شروط استرداد اشتراكات المؤسسات والمدارس (B2B)</h2>
        <p>
          يحق للجهة التعليمية إلغاء الاشتراك السنوي واسترداد المتبقي من المبالغ المدفوعة خلال 14 يوماً من تاريخ التفعيل الأول، بشرط عدم تجاوز استخدام رصيد الرسائل أو الخدمات الميدانية نسبة 10%.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">٢. استرداد اشتراكات ولي الأمر وباقة الخدمات (B2C)</h2>
        <p>
          في حال إلغاء ولي الأمر لأي باقة مضافة (كافيتريا أو عيادة فائقة)، يتم إعادة الرصيد غير المستهلك فوراً إلى حساب "بوابة الدفع" في المنصة أو الحساب البنكي الخيار خلال 3-5 أيام عمل.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">٣. آلية تقديم طلب المرجوع</h2>
        <p>
          يتم تقديم طلب الاسترداد من خلال بوابة الدعم الفني بالمنصة مع إرفاق رقم العملية المرجعية (Transaction ID).
        </p>
      </section>
    </LegalLayout>
  );
}
