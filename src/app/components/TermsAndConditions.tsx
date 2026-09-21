import React from 'react';
import { LegalLayout } from './LegalLayout';

export function TermsAndConditions() {
  return (
    <LegalLayout
      title="الشروط والأحكام والاستخدام"
      subtitle="تاريخ التحديث: سبتمبر 2026 — منصة SchooKeep"
    >
      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">١. مقدمة ونطاق الاتفاقية</h2>
        <p>
          مرحباً بكم في منصة <strong>SchooKeep</strong> (المشار إليها بـ "المنصة" أو "الموقع الإلكتروني schookeep.com"). تحكم هذه الاتفاقية جميع الخدمات والاستخدامات المقدمة للمدارس، المؤسسات التعليمية، الكوادر الطبية، الإداريين، وأولياء الأمور.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">٢. التزامات المدارس والجهات التعليمية</h2>
        <p>
          تلتزم الجهة التعليمية بتقديم بيانات صحيحة ومحدثة عن الطلاب والكوادر الطبية والمدرسين، وتتحمل المسؤولية الكاملة عن توزيع الصلاحيات وتعيين المسؤولين والمخولين بالتوقيع الإلكتروني.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">٣. خدمات ولي الأمر وبوابة الدفع</h2>
        <p>
          تتيح المنصة لأولياء الأمور الاشتراك في الخدمات المضافة (مثل متابعة الرعاية الصحية المتقدمة، وميزانية الكافتيريا) وسداد رسوم الاشتراكات عبر بوابة الدفع الرقمية بالريال السعودي أو الدرهم الإماراتي.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-lg font-bold text-teal-400">٤. حماية البيانات والسرية</h2>
        <p>
          تلتزم المنصة بتشفير كافة البيانات الصحية والشخصية طبقاً لأعلى المعايير السيبرانية ونظام حماية البيانات الشخصية PDPL.
        </p>
      </section>
    </LegalLayout>
  );
}
