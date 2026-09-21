import React from 'react';
import { LegalLayout } from './LegalLayout';

export function PrivacyPolicy() {
  return (
    <LegalLayout
      title="سياسة الخصوصية وحماية البيانات (PDPL)"
      subtitle="تاريخ التحديث: سبتمبر 2026 — منصة SchooKeep"
    >
      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">١. جمع البيانات وتصنيفها</h2>
        <p>
          تلتزم منصة SchooKeep بحماية خصوصية بيانات الطلاب وأولياء الأمور والكوادر المدرسية. تشمل البيانات المجمعة: السجلات الصحية المدرسية، تنبيهات الحساسية والوجبات، وبيانات التواصل لغايات التوثيق والإشعار الطارئ.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">٢. معايير الامتثال لنظام PDPL</h2>
        <p>
          يتم تخزين كافة البيانات داخل مراكز بيانات سحابية معتمدة وسيادية داخل المملكة العربية السعودية ودولة الإمارات العربية المتحدة، ويمنع مشاركتها مع أي أطراف خارجية تجارية.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">٣. حقوق صاحب البيانات</h2>
        <p>
          يحق لولي الأمر الاطلاع على كامل الملف الصحي والمالي الخاص بأبنائه، وطلب تصحيح البيانات أو استخراج نسخة من السجل الطبي المدرسي في أي وقت.
        </p>
      </section>
    </LegalLayout>
  );
}
