import { useNavigate } from 'react-router';
import { AlertTriangle, Check, ChevronRight } from 'lucide-react';
import { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { HalalBadge } from './HalalBadge';
import { NonHalalBadge } from './NonHalalBadge';
import { toast } from 'sonner';

interface Student {
  id: string;
  firstNameInitial: string;
  grade: string;
  allergens: string[];
  specialMeal?: string;
  delivered: boolean;
  deliveredAt?: string;
}

export function CafeteriaAlertDashboard() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [isAcknowledged, setIsAcknowledged] = useState(false);
  const [acknowledgedAt, setAcknowledgedAt] = useState<string | null>(null);
  
  const [checkedAllergens, setCheckedAllergens] = useState(false);
  const [checkedHalal, setCheckedHalal] = useState(false);

  const [students, setStudents] = useState<Student[]>([
    {
      id: '1',
      firstNameInitial: 'Emma R.',
      grade: 'Grade 3',
      allergens: ['non-halal', 'peanut'],
      specialMeal: isRTL ? 'وجبة خاصة خالية من الفول السوداني وحلال' : 'Halal & Peanut-free lunch pack',
      delivered: false
    },
    {
      id: '2',
      firstNameInitial: 'Marcus C.',
      grade: 'Grade 5',
      allergens: ['pork', 'dairy'],
      specialMeal: isRTL ? 'وجبة خالية من الخنزير والألبان' : 'Pork-free & Dairy-free tray',
      delivered: false
    },
    {
      id: '3',
      firstNameInitial: 'Sarah W.',
      grade: 'Grade 2',
      allergens: ['fish', 'shellfish'],
      specialMeal: isRTL ? 'وجبة خالية من المأكولات البحرية' : 'Seafood-free tray',
      delivered: false
    }
  ]);

  const todaysDate = new Date().toLocaleDateString(isRTL ? 'ar-AE' : 'en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  });

  const handleAcknowledge = () => {
    const time = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    setAcknowledgedAt(time);
    setIsAcknowledged(true);
    toast.success(isRTL ? "تم تسجيل تأكيد الامتثال بنجاح" : "Allergens & Halal compliance confirmed!");
  };

  const handleDelivered = (studentId: string) => {
    const time = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    setStudents(prev =>
      prev.map(s => s.id === studentId ? { ...s, delivered: true, deliveredAt: time } : s)
    );
    toast.success(isRTL ? "تم تسجيل تسليم الوجبة" : "Meal delivery confirmed.");
  };

  const getAllergenLabel = (allergen: string) => {
    if (isRTL) {
      switch (allergen) {
        case 'non-halal': return '⚠️ غير حلال';
        case 'pork': return '🐷 خالٍ من الخنزير';
        case 'alcohol': return '🍺 خالٍ من الكحول';
        case 'peanut': return '🥜 خالٍ من الفستق';
        case 'tree-nut': return '🌰 خالٍ من المكسرات';
        case 'dairy': return '🥛 خالٍ من الألبان';
        case 'fish': return '🐟 خالٍ من الأسماك';
        case 'shellfish': return '🦐 خالٍ من القشريات';
        case 'gluten': return '🌾 خالٍ من الغلوتين';
        default: return allergen;
      }
    }
    switch (allergen) {
      case 'non-halal':
        return '⚠️ NON-HALAL';
      case 'pork':
        return '🐷 PORK-FREE';
      case 'alcohol':
        return '🍺 ALCOHOL-FREE';
      case 'peanut':
        return '🥜 PEANUT-FREE';
      case 'tree-nut':
        return '🌰 TREE NUT-FREE';
      case 'dairy':
        return '🥛 DAIRY-FREE';
      case 'fish':
        return '🐟 FISH-FREE';
      case 'shellfish':
        return '🦐 SHELLFISH-FREE';
      case 'gluten':
        return '🌾 GLUTEN-FREE';
      default:
        return allergen.toUpperCase();
    }
  };

  const getAllergenColor = (allergen: string) => {
    switch (allergen) {
      case 'non-halal':
      case 'pork':
      case 'alcohol':
      case 'peanut':
      case 'tree-nut':
        return 'bg-[#FEE2E2] text-[#991B1B] border-[#DC2626]';
      case 'dairy':
        return 'bg-[#FEF3C7] text-[#92400E] border-[#F59E0B]';
      case 'fish':
      case 'shellfish':
        return 'bg-[#DBEAFE] text-[#1E40AF] border-[#2563EB]';
      case 'gluten':
        return 'bg-[#F3E8FF] text-[#6B21A8] border-[#9333EA]';
      default:
        return 'bg-[#FEE2E2] text-[#991B1B] border-[#DC2626]';
    }
  };

  const canAcknowledge = checkedAllergens && checkedHalal;

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="px-4 py-3 text-left">
          <h1 className="text-[17px] font-bold text-gray-900">
            {isRTL ? 'قيود الوجبات المدرسية لليوم' : 'Today\'s Meal Restrictions'}
          </h1>
          <p className="text-[13px] text-[#64748B]">
            {todaysDate}
          </p>
        </div>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Halal Status Banner */}
        <div 
          className="bg-white rounded-xl p-4 border border-[#E2E8F0] shadow-sm flex items-center justify-between text-left"
          style={{
            borderLeftWidth: isRTL ? '1px' : '4px',
            borderRightWidth: isRTL ? '4px' : '1px',
            borderLeftColor: isRTL ? '#E2E8F0' : '#15803D',
            borderRightColor: isRTL ? '#15803D' : '#E2E8F0',
          }}
        >
          <div className="space-y-0.5">
            <h4 className="text-[10px] font-bold text-slate-500 uppercase tracking-wide">
              {isRTL ? 'حالة التوافق مع الشريعة الإسلامية' : 'Halal Certification Status'}
            </h4>
            <p className="text-sm font-bold text-[#15803D] leading-snug">
              {isRTL 
                ? 'جميع الوجبات المقدمة اليوم معتمدة وحلال ✓' 
                : 'All meals today are Halal-certified ✓'}
            </p>
            <p className="text-[11px] text-slate-400">
              {isRTL ? 'صلاحية الشهادة: 15/06/2027' : 'Certificate Exp: 15/06/2027'}
            </p>
          </div>
          <HalalBadge />
        </div>

        {/* Acknowledgment Banner */}
        {!isAcknowledged ? (
          <div 
            className="bg-[#FFFBEB] rounded-xl p-4 space-y-4 text-left border"
            style={{
              borderStyle: 'solid',
              borderLeftWidth: isRTL ? 0 : '4px',
              borderRightWidth: isRTL ? '4px' : 0,
              borderLeftColor: isRTL ? 'transparent' : '#F59E0B',
              borderRightColor: isRTL ? '#F59E0B' : 'transparent',
            }}
          >
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-6 h-6 text-[#F59E0B] flex-shrink-0 mt-0.5 animate-bounce" />
              <p className="text-[13px] text-[#92400E] font-semibold leading-relaxed">
                {isRTL 
                  ? 'يرجى تأكيد مراجعة قائمة المواد المسببة للحساسية لليوم والامتثال لمتطلبات الحلال قبل بدء تقديم الطعام.'
                  : 'Please confirm review of today\'s allergen list and Halal-compliance before starting meal service.'}
              </p>
            </div>
            
            <div className="space-y-2.5 pt-3 border-t border-amber-200 flex flex-col">
              <label className="flex items-center gap-3 cursor-pointer min-h-[44px]">
                <input
                  type="checkbox"
                  checked={checkedAllergens}
                  onChange={(e) => setCheckedAllergens(e.target.checked)}
                  className="w-5 h-5 rounded border-amber-300 text-[#F59E0B] focus:ring-[#F59E0B] cursor-pointer"
                />
                <span className="text-xs font-bold text-[#92400E] select-none">
                  {isRTL ? "أؤكد مراجعة قائمة الحساسية لليوم" : "I have reviewed today's allergen list"}
                </span>
              </label>

              <label className="flex items-center gap-3 cursor-pointer min-h-[44px]">
                <input
                  type="checkbox"
                  checked={checkedHalal}
                  onChange={(e) => setCheckedHalal(e.target.checked)}
                  className="w-5 h-5 rounded border-amber-300 text-[#F59E0B] focus:ring-[#F59E0B] cursor-pointer"
                />
                <span className="text-xs font-bold text-[#92400E] select-none">
                  {isRTL ? "أؤكد أن جميع الوجبات المقدمة اليوم حلال معتمدة" : "I confirm all meals today are Halal-certified"}
                </span>
              </label>
            </div>

            <button
              disabled={!canAcknowledge}
              onClick={handleAcknowledge}
              className={`w-full px-4 py-3.5 text-white rounded-lg text-[15px] font-bold min-h-[52px] cursor-pointer shadow transition-all ${
                canAcknowledge ? 'bg-[#F59E0B] hover:bg-[#D97706]' : 'bg-amber-200 cursor-not-allowed text-amber-500'
              }`}
            >
              {isRTL ? 'تأكيد وقبول الالتزام' : 'Confirm Compliance'}
            </button>
          </div>
        ) : (
          <div className="bg-[#D1FAE5] border border-[#10B981] rounded-xl p-4 text-left shadow-sm">
            <div className="flex items-center gap-2">
              <Check className="w-5 h-5 text-[#10B981] flex-shrink-0" />
              <p className="text-[13px] text-[#065F46] font-bold">
                {isRTL 
                  ? `تم تأكيد وقبول المراجعة في تمام الساعة ${acknowledgedAt} ✓`
                  : `List & Halal compliance acknowledged at ${acknowledgedAt} ✓`}
              </p>
            </div>
          </div>
        )}

        {/* Restriction List */}
        <div className="text-left">
          <h2 className="text-[12px] font-bold text-[#64748B] uppercase tracking-wide mb-3">
            {isRTL ? `الطلاب الذين لديهم قيود غذائية (${students.length})` : `Students with Restrictions (${students.length})`}
          </h2>

          <div className="space-y-3">
            {students.map((student) => (
              <div
                key={student.id}
                className={`bg-white rounded-xl border-2 p-4 transition-all shadow-sm ${
                  student.delivered
                    ? 'border-[#10B981] bg-[#F0FDF4]'
                    : 'border-gray-200 hover:border-[#0D9488]/50'
                }`}
              >
                {student.delivered ? (
                  /* Collapsed Confirmed State */
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-[#10B981] flex items-center justify-center text-white">
                        <Check className="w-5 h-5" />
                      </div>
                      <div>
                        <div className="text-[14px] font-bold text-gray-900">
                          {student.firstNameInitial}
                        </div>
                        <div className="text-[12px] text-[#10B981]">
                          {isRTL ? `تم التسليم الساعة ${student.deliveredAt}` : `Delivered at ${student.deliveredAt}`}
                        </div>
                      </div>
                    </div>
                  </div>
                ) : (
                  /* Full Card */
                  <>
                    <button
                      onClick={() => navigate(`/cafeteria/detail/${student.id}`)}
                      className="w-full text-left mb-3 cursor-pointer"
                    >
                      <div className="flex items-center justify-between mb-2">
                        <div>
                          <div className="text-[16px] font-bold text-gray-900">
                            {student.firstNameInitial}
                          </div>
                          <div className="text-[13px] text-[#64748B]">
                            {isRTL 
                              ? `${student.grade === 'Grade 3' ? 'الصف الثالث' : student.grade === 'Grade 5' ? 'الصف الخامس' : student.grade}` 
                              : student.grade}
                          </div>
                        </div>
                        <ChevronRight className={`w-5 h-5 text-[#64748B] ${isRTL ? 'rotate-180' : ''}`} />
                      </div>

                      {/* Allergen Chips */}
                      <div className="flex flex-wrap gap-2 mb-3">
                        {student.allergens.map((allergen) => (
                          <div
                            key={allergen}
                            className={`px-3 py-1.5 rounded-lg text-[12px] font-bold border ${getAllergenColor(allergen)}`}
                          >
                            {getAllergenLabel(allergen)}
                          </div>
                        ))}
                      </div>

                      {/* Special Meal Badge */}
                      {student.specialMeal && (
                        <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-[#D1FAE5] text-[#065F46] text-[12px] font-semibold">
                          <Check className="w-4 h-4" />
                          {isRTL ? 'وجبة خاصة مطلوبة' : 'Special meal required'}
                        </div>
                      )}
                    </button>

                    {/* Delivery Button */}
                    <button
                      onClick={() => handleDelivered(student.id)}
                      className="w-full px-4 py-3.5 bg-[#0D9488] text-white rounded-lg text-[15px] font-bold min-h-[52px] flex items-center justify-center gap-2 cursor-pointer shadow"
                    >
                      <Check className="w-5 h-5" />
                      {isRTL ? 'تأكيد تسليم الوجبة للطالب' : 'Meal Delivered'}
                    </button>
                  </>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
export default CafeteriaAlertDashboard;
