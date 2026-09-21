import React from 'react';
import { LegalLayout } from './LegalLayout';

export function DisclaimerPage() {
  return (
    <LegalLayout
      title="إخلاء المسؤولية الطبية والتقنية"
      subtitle="تاريخ التحديث: سبتمبر 2026 — منصة SchooKeep"
    >
      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">١. طبيعة الخدمات الصحية المدرسية</h2>
        <p>
          تعد منصة SchooKeep أداة مساعدة رقمية لحوكمة وتنظيم الزيارات والجرعات التمريضية في العيادة المدرسية، وليست بديلاً عن التشخيص الطبي المستقل أو المستشفيات وأقسام الطوارئ المعتمدة.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">٢. حالات الطوارئ الحادة</h2>
        <p>
          في حالات الإصابات البالغة أو الطوارئ الحادة، يتوجب على ممرض/ة المدرسة الاتصال الفوري بالإسعاف الوطني وإبلاغ ولي الأمر مباشرة دون الاعتماد الحصري على التنبيهات الإلكترونية.
        </p>
      </section>
    </LegalLayout>
  );
}
