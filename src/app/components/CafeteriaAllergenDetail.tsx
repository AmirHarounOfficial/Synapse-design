import { useNavigate, useParams } from 'react-router';
import { ChevronLeft, AlertTriangle, Check } from 'lucide-react';
import { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { HalalBadge } from './HalalBadge';
import { NonHalalBadge } from './NonHalalBadge';
import { toast } from 'sonner';

export function CafeteriaAllergenDetail() {
  const navigate = useNavigate();
  const { id } = useParams();
  const { isRTL } = useLanguage();
  const [isDelivered, setIsDelivered] = useState(false);

  const isPending = id === '1'; // Emma R. has non-halal/pork
  const hasHalalRestriction = id === '1' || id === '2';

  // Mock student data
  const student = {
    id: id || '1',
    firstNameInitial: isPending ? 'Emma R.' : id === '2' ? 'Marcus C.' : 'Sarah W.',
    grade: isPending ? 'Grade 3' : id === '2' ? 'Grade 5' : 'Grade 2',
    restrictions: isPending 
      ? [
          { type: 'non-halal', label: isRTL ? '⚠️ غير حلال' : '⚠️ Non-Halal' },
          { type: 'pork', label: isRTL ? '🐷 مشتقات الخنزير' : '🐷 Pork/Pork-derived' },
          { type: 'peanut', label: isRTL ? '🥜 الفستق / الفول السوداني' : '🥜 Peanuts' }
        ]
      : id === '2'
      ? [
          { type: 'pork', label: isRTL ? '🐷 مشتقات الخنزير' : '🐷 Pork/Pork-derived' },
          { type: 'dairy', label: isRTL ? '🥛 الألبان ومشتقاتها' : '🥛 Dairy' }
        ]
      : [
          { type: 'fish', label: isRTL ? '🐟 الأسماك' : '🐟 Fish' },
          { type: 'shellfish', label: isRTL ? '🦐 القشريات' : '🦐 Shellfish' }
        ],
    specialMeal: {
      name: isPending 
        ? (isRTL ? 'وجبة خاصة خالية من الفول السوداني وحلال' : 'Halal & Peanut-free lunch pack')
        : id === '2'
        ? (isRTL ? 'وجبة خالية من مشتقات الخنزير والألبان' : 'Pork-free & Dairy-free tray')
        : (isRTL ? 'وجبة خالية من المأكولات البحرية' : 'Seafood-free tray'),
      approvedBy: isRTL ? 'ولي الأمر' : 'Parent',
      approvedDate: '15/06/2026'
    }
  };

  const handleConfirmDelivery = () => {
    setIsDelivered(true);
    toast.success(isRTL ? "تم تأكيد تسليم الوجبة بنجاح" : "Meal delivery confirmed successfully!");
    setTimeout(() => {
      navigate('/cafeteria/alerts');
    }, 1500);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[120px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2 cursor-pointer"
          aria-label="Go back"
        >
          <ChevronLeft className={`w-6 h-6 text-gray-900 ${isRTL ? 'rotate-180' : ''}`} />
        </button>

        <h1 className="absolute left-1/2 -translate-x-1/2 font-semibold text-gray-900">
          {isRTL ? 'تفاصيل قيود الوجبة' : 'Meal Restriction Detail'}
        </h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Student Info */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 text-left shadow-sm">
          <div className="text-[17px] font-bold text-gray-900 mb-1">
            {student.firstNameInitial}
          </div>
          <div className="text-[14px] text-[#64748B]">
            {isRTL 
              ? `${student.grade === 'Grade 3' ? 'الصف الثالث' : student.grade === 'Grade 5' ? 'الصف الخامس' : student.grade}` 
              : student.grade}
          </div>
        </div>

        {/* Halal Status Card */}
        {hasHalalRestriction ? (
          <div className="bg-[#FEF2F2] border border-[#FCA5A5] rounded-xl p-4 flex flex-col gap-2 text-left shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <h4 className="text-[14px] font-bold text-[#DC2626]">
                  {isRTL ? '⚠️ تنبيه قيود الحلال نشط' : '⚠️ Non-Halal Restriction Active'}
                </h4>
                <p className="text-[11px] text-[#991B1B] mt-0.5 leading-normal font-semibold">
                  {isRTL ? 'يجب تقديم وجبات معتمدة وحلال فقط لهذا الطالب.' : 'This student requires Halal-certified meals only.'}
                </p>
              </div>
              <NonHalalBadge />
            </div>
            <p className="text-[11px] text-[#64748B] border-t border-[#FCA5A5]/40 pt-1.5 mt-1 font-medium">
              {isRTL ? 'تم تأكيده بواسطة ولي الأمر: نعم' : 'Parent-confirmed restriction: Yes'}
            </p>
          </div>
        ) : (
          <div className="bg-[#F0FDF4] border border-[#A7F3D0] rounded-xl p-4 flex flex-col gap-2 text-left shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <h4 className="text-[14px] font-bold text-[#15803D]">
                  {isRTL ? 'حالة الوجبة: حلال معتمد ✓' : 'Halal Status: Certified ✓'}
                </h4>
                <p className="text-[11px] text-[#166534] mt-0.5 leading-normal">
                  {isRTL ? 'الوجبة اليومية المخصصة للطالب حلال معتمدة.' : 'Standard meal for this student is Halal-certified.'}
                </p>
              </div>
              <HalalBadge />
            </div>
            <p className="text-[11px] text-[#64748B] border-t border-[#A7F3D0]/40 pt-1.5 mt-1 font-medium">
              {isRTL ? 'تم تأكيده بواسطة ولي الأمر: نعم' : 'Parent-confirmed restriction: Yes'}
            </p>
          </div>
        )}

        {/* Restriction Summary */}
        <div>
          <h2 className="text-[12px] font-bold text-[#64748B] uppercase tracking-wide mb-3 text-left">
            {isRTL ? 'مسببات الحساسية الممنوعة' : 'Allergen Restrictions'}
          </h2>

          <div 
            className="bg-[#FEF2F2] rounded-xl p-4 text-left border"
            style={{
              borderStyle: 'solid',
              borderLeftWidth: isRTL ? 0 : '4px',
              borderRightWidth: isRTL ? '4px' : 0,
              borderLeftColor: isRTL ? 'transparent' : '#DC2626',
              borderRightColor: isRTL ? '#DC2626' : 'transparent',
            }}
          >
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-5 h-5 text-[#DC2626] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <h3 className="text-[14px] font-bold text-[#991B1B] mb-3">
                  {isRTL ? 'يُمنع منعاً باتاً تقديم أطعمة تحتوي على:' : 'DO NOT serve items containing:'}
                </h3>
                <div className="space-y-2">
                  {student.restrictions.map((restriction, index) => (
                    <div
                      key={index}
                      className="flex items-center gap-2 px-3 py-2 bg-white rounded-lg border border-[#FCA5A5] shadow-sm"
                    >
                      <AlertTriangle className="w-4 h-4 text-[#DC2626] flex-shrink-0" />
                      <span className="text-[14px] font-bold text-[#991B1B]">
                        {restriction.label}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Special Meal Plan */}
        {student.specialMeal && (
          <div>
            <h2 className="text-[12px] font-bold text-[#64748B] uppercase tracking-wide mb-3 text-left">
              {isRTL ? 'خطة الوجبات المعتمدة' : 'Approved Meal Plan'}
            </h2>

            <div className="bg-[#D1FAE5] border border-[#10B981] rounded-xl p-4 text-left shadow-sm">
              <div className="flex items-start gap-3">
                <Check className="w-5 h-5 text-[#10B981] flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <h3 className="text-[15px] font-bold text-[#065F46] mb-1">
                    {student.specialMeal.name}
                  </h3>
                  <p className="text-[12px] text-[#065F46] leading-normal opacity-90">
                    {isRTL 
                      ? `معتمد بواسطة ولي الأمر بتاريخ ${student.specialMeal.approvedDate}`
                      : `Approved by parent on ${student.specialMeal.approvedDate}`}
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Privacy Notice */}
        <div className="bg-[#F8FAFC] rounded-xl border border-gray-200 p-4 text-left">
          <p className="text-[12px] text-[#64748B] leading-relaxed">
            <span className="font-bold">{isRTL ? 'إشعار خصوصية البيانات:' : 'Privacy Notice:'}</span>{' '}
            {isRTL 
              ? 'أنت تستعرض قيود الوجبات الخاصة بالطالب فقط لدواعي السلامة. تعتبر السجلات الطبية الكاملة سرية للغاية ومحمية بموجب قانون حماية البيانات (PDPL).'
              : 'You are viewing meal restrictions only for student safety. Comprehensive medical records are strictly confidential and protected under UAE PDPL.'}
          </p>
        </div>

        {/* Success State */}
        {isDelivered && (
          <div className="bg-[#D1FAE5] border border-[#10B981] rounded-xl p-4 text-left shadow-sm animate-scale-in">
            <div className="flex items-center gap-2">
              <Check className="w-5 h-5 text-[#10B981]" />
              <p className="text-[14px] text-[#065F46] font-semibold">
                {isRTL ? 'تم تأكيد تسليم الوجبة' : 'Meal delivery confirmed'}
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Confirm Button */}
      <div className="fixed bottom-[83px] left-0 right-0 bg-white border-t border-gray-200 p-4 max-w-[393px] mx-auto z-40">
        <button
          onClick={handleConfirmDelivery}
          disabled={isDelivered}
          className={`w-full px-4 py-3.5 rounded-lg text-[15px] font-bold min-h-[52px] flex items-center justify-center gap-2 transition-all cursor-pointer shadow-md ${
            isDelivered
              ? 'bg-[#E2E8F0] text-[#94A3B8] cursor-not-allowed border border-gray-100 shadow-none'
              : 'bg-[#0D9488] text-white'
          }`}
        >
          <Check className="w-5 h-5" />
          {isDelivered 
            ? (isRTL ? 'تم تأكيد التسليم' : 'Confirmed') 
            : (isRTL ? 'تأكيد تسليم الوجبة للطالب' : 'Confirm Meal Delivered')}
        </button>
      </div>
    </div>
  );
}
export default CafeteriaAllergenDetail;
