import { useNavigate } from 'react-router';
import { ChevronLeft, Search, X, Info, Check } from 'lucide-react';
import { useState } from 'react';
import { AllergenChipGrid } from './AllergenChipGrid';
import { useLanguage } from '../../context/LanguageContext';
import { toast } from 'sonner';

interface Student {
  id: string;
  name: string;
  initials: string;
  grade: string;
  gradeLevel: number;
}

export function SendCafeteriaAlert() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [showResults, setShowResults] = useState(false);
  const [selectedAllergens, setSelectedAllergens] = useState<string[]>([]);
  const [customRestriction, setCustomRestriction] = useState('');
  const [specialMealRequired, setSpecialMealRequired] = useState(false);
  const [mealDescription, setMealDescription] = useState('');
  const [effectiveDate, setEffectiveDate] = useState<'today' | 'ongoing' | 'until'>('today');
  const [untilDate, setUntilDate] = useState('');
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [sendTime, setSendTime] = useState('');

  const students: Student[] = [
    { id: '1', name: 'Emma Rodriguez', initials: 'ER', grade: 'Grade 3', gradeLevel: 3 },
    { id: '2', name: 'Marcus Chen', initials: 'MC', grade: 'Grade 5', gradeLevel: 5 },
    { id: '3', name: 'Sarah Williams', initials: 'SW', grade: 'Grade 2', gradeLevel: 2 },
    { id: '4', name: 'Alex Martinez', initials: 'AM', grade: 'Grade 4', gradeLevel: 4 },
    { id: '5', name: 'Maya Chen', initials: 'MC', grade: 'Grade 5', gradeLevel: 5 }
  ];

  const filteredStudents = students.filter(student =>
    student.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleStudentSelect = (student: Student) => {
    setSelectedStudent(student);
    setSearchQuery('');
    setShowResults(false);
  };

  const handleClearStudent = () => {
    setSelectedStudent(null);
    setSearchQuery('');
  };

  const toggleAllergen = (allergenId: string) => {
    setSelectedAllergens(prev =>
      prev.includes(allergenId)
        ? prev.filter(id => id !== allergenId)
        : [...prev, allergenId]
    );
  };

  const getPreviewText = () => {
    if (!selectedStudent) return '';

    const nameParts = selectedStudent.name.split(' ');
    const firstName = nameParts[0];
    const lastInitial = nameParts[nameParts.length - 1][0];
    const studentNameFormatted = `${firstName} ${lastInitial}.`;

    const dietaryItems = [
      { id: 'non-halal', en: 'NON-HALAL', ar: 'غير حلال' },
      { id: 'pork', en: 'PORK-FREE', ar: 'خالٍ من الخنزير' },
      { id: 'alcohol', en: 'ALCOHOL-FREE', ar: 'خالٍ من الكحول' },
      { id: 'peanuts', en: 'PEANUT-FREE', ar: 'خالٍ من الفول السوداني' },
      { id: 'tree-nuts', en: 'TREE NUT-FREE', ar: 'خالٍ من المكسرات' },
      { id: 'dairy', en: 'DAIRY-FREE', ar: 'خالٍ من الألبان' },
      { id: 'eggs', en: 'EGG-FREE', ar: 'خالٍ من البيض' },
      { id: 'wheat', en: 'WHEAT-FREE', ar: 'خالٍ من القمح' },
      { id: 'soy', en: 'SOY-FREE', ar: 'خالٍ من الصويا' },
      { id: 'sesame', en: 'SESAME-FREE', ar: 'خالٍ من السمسم' },
      { id: 'fish', en: 'FISH-FREE', ar: 'خالٍ من الأسماك' },
      { id: 'shellfish', en: 'SHELLFISH-FREE', ar: 'خالٍ من القشريات' }
    ];

    const selectedEn = selectedAllergens.map(id => {
      const item = dietaryItems.find(x => x.id === id);
      return item ? item.en : '';
    }).filter(Boolean);

    const selectedAr = selectedAllergens.map(id => {
      const item = dietaryItems.find(x => x.id === id);
      return item ? item.ar : '';
    }).filter(Boolean);

    if (customRestriction) {
      selectedEn.push(customRestriction.toUpperCase());
      selectedAr.push(customRestriction);
    }

    if (selectedEn.length === 0) return '';

    return isRTL
      ? `${studentNameFormatted} — [${selectedAr.join('، ')}] / [${selectedEn.join(', ')}]`
      : `${studentNameFormatted} — [${selectedEn.join(', ')}] / [${selectedAr.join(', ')}]`;
  };

  const handleSend = () => {
    setShowConfirmDialog(true);
  };

  const confirmSend = () => {
    const now = new Date();
    const timeString = now.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });
    setSendTime(timeString);
    setIsSuccess(true);
    setShowConfirmDialog(false);
  };

  const getAvatarColor = (gradeLevel: number): string => {
    const colors = [
      '#2563EB', '#10B981', '#F59E0B', '#8B5CF6', '#EC4899', '#06B6D4'
    ];
    return colors[(gradeLevel - 1) % colors.length];
  };

  const canSend = selectedStudent && (selectedAllergens.length > 0 || customRestriction.trim().length > 0);

  if (isSuccess) {
    return (
      <div className="min-h-screen bg-[#F8FAFC] pb-[83px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
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
            {isRTL ? 'إرسال تنبيه للكافتيريا' : 'Send Cafeteria Alert'}
          </h1>
        </header>

        {/* Success State */}
        <div className="flex items-center justify-center min-h-[calc(100vh-142px)]">
          <div className="text-center px-8 space-y-4">
            <div className="w-16 h-16 bg-[#D1FAE5] rounded-full flex items-center justify-center mx-auto mb-2 animate-scale-in">
              <Check className="w-8 h-8 text-[#10B981]" strokeWidth={2.5} />
            </div>
            <h2 className="text-[20px] font-bold text-gray-900">
              {isRTL ? 'تم إرسال التنبيه بنجاح' : 'Alert Sent Successfully'}
            </h2>
            <p className="text-[14px] text-[#64748B]">
              {isRTL 
                ? `تم تسليم تنبيه الكافتيريا في الساعة ${sendTime}`
                : `Alert delivered to cafeteria at ${sendTime}`}
            </p>
          </div>
        </div>
      </div>
    );
  }

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
          {isRTL ? 'تنبيه الكافتيريا' : 'Send Cafeteria Alert'}
        </h1>
      </header>

      <div className="px-4 py-4 mx-[0px] mt-[0px] mb-[80px] space-y-6">
        {/* Info Banner */}
        <div 
          className="bg-[#EFF6FF] rounded-xl p-3 text-left border"
          style={{
            borderStyle: 'solid',
            borderLeftWidth: isRTL ? 0 : '4px',
            borderRightWidth: isRTL ? '4px' : 0,
            borderLeftColor: isRTL ? 'transparent' : '#2563EB',
            borderRightColor: isRTL ? '#2563EB' : 'transparent',
          }}
        >
          <div className="flex gap-2">
            <Info className="w-5 h-5 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <p className="text-[12px] text-[#1E40AF] leading-relaxed">
              {isRTL 
                ? 'سيرى موظفو الكافتيريا القيود المفروضة فقط دون إظهار التشخيص الطبي للطالب حماية للخصوصية بموجب قانون حماية البيانات الإماراتي (PDPL).'
                : 'Cafeteria staff will only see the dietary restriction — not the medical reason. This protects student privacy per UAE PDPL.'}
            </p>
          </div>
        </div>

        {/* Student Selector */}
        <div className="text-left space-y-2">
          <label className="block text-[14px] font-bold text-gray-900">
            {isRTL ? 'اختر الطالب' : 'Select Student'}
          </label>

          {selectedStudent ? (
            <div className="flex items-center gap-2 bg-white rounded-lg border border-gray-200 p-3 shadow-sm">
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center text-white text-[12px] font-medium flex-shrink-0"
                style={{ backgroundColor: getAvatarColor(selectedStudent.gradeLevel) }}
              >
                {selectedStudent.initials}
              </div>
              <div className="flex-1">
                <div className="text-[14px] font-bold text-gray-900">
                  {selectedStudent.name}
                </div>
                <div className="text-[12px] text-[#64748B]">
                  {isRTL 
                    ? `${selectedStudent.grade === 'Grade 3' ? 'الصف الثالث' : selectedStudent.grade === 'Grade 5' ? 'الصف الخامس' : selectedStudent.grade}`
                    : selectedStudent.grade}
                </div>
              </div>
              <button
                onClick={handleClearStudent}
                className="w-6 h-6 flex items-center justify-center cursor-pointer"
                aria-label="Clear selection"
              >
                <X className="w-4 h-4 text-[#64748B]" />
              </button>
            </div>
          ) : (
            <div className="relative">
              <Search className={`absolute top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B] ${isRTL ? 'right-3' : 'left-3'}`} />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value);
                  setShowResults(true);
                }}
                onFocus={() => setShowResults(true)}
                placeholder={isRTL ? "ابحث عن اسم الطالب..." : "Search student name..."}
                className={`w-full h-12 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB] ${
                  isRTL ? 'pr-10 pl-4' : 'pl-10 pr-4'
                }`}
              />

              {showResults && searchQuery && filteredStudents.length > 0 && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-gray-200 rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto">
                  {filteredStudents.map((student) => (
                    <button
                      key={student.id}
                      onClick={() => handleStudentSelect(student)}
                      className="w-full flex items-center gap-3 p-3 hover:bg-[#F8FAFC] border-b border-gray-100 last:border-b-0 cursor-pointer"
                    >
                      <div
                        className="w-8 h-8 rounded-full flex items-center justify-center text-white text-[12px] font-medium flex-shrink-0"
                        style={{ backgroundColor: getAvatarColor(student.gradeLevel) }}
                      >
                        {student.initials}
                      </div>
                      <div className="flex-1 text-left">
                        <div className="text-[14px] font-bold text-gray-900">
                          {student.name}
                        </div>
                        <div className="text-[12px] text-[#64748B]">
                          {isRTL 
                            ? `${student.grade === 'Grade 3' ? 'الصف الثالث' : student.grade === 'Grade 5' ? 'الصف الخامس' : student.grade}`
                            : student.grade}
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>

        {/* Restriction Type */}
        <div className="text-left space-y-3">
          <h2 className="text-[14px] font-bold text-gray-900">
            {isRTL ? 'حدد قيود الطعام والشريعة' : 'Select restriction type'}
          </h2>

          {/* Allergen Chips Grid */}
          <div className="mb-4">
            <AllergenChipGrid selectedIds={selectedAllergens} onToggle={toggleAllergen} />
          </div>

          {/* Custom Restriction */}
          <input
            type="text"
            value={customRestriction}
            onChange={(e) => setCustomRestriction(e.target.value)}
            placeholder={isRTL ? "قيود إضافية أخرى (مثل: نباتي)" : "Other restriction (e.g., vegetarian)"}
            className="w-full h-12 px-4 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
          />
        </div>

        {/* Special Meal Required */}
        <div className="text-left">
          <label className="flex items-center gap-3 cursor-pointer min-h-[44px]">
            <input
              type="checkbox"
              checked={specialMealRequired}
              onChange={(e) => setSpecialMealRequired(e.target.checked)}
              className="w-5 h-5 rounded border-gray-300 text-[#2563EB] focus:ring-[#2563EB] cursor-pointer"
            />
            <span className="text-[14px] font-semibold text-gray-900 select-none">
              {isRTL ? 'طلب تحضير وجبة خاصة' : 'Request special meal preparation'}
            </span>
          </label>

          {specialMealRequired && (
            <textarea
              value={mealDescription}
              onChange={(e) => setMealDescription(e.target.value)}
              placeholder={isRTL ? "تفاصيل الوجبة الخاصة المطلوبة..." : "Meal description (optional)"}
              rows={3}
              className="mt-3 w-full px-4 py-3 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB] resize-none"
            />
          )}
        </div>

        {/* Effective Date */}
        <div className="text-left space-y-3">
          <h2 className="text-[14px] font-bold text-gray-900">
            {isRTL ? 'فترة سريان التنبيه' : 'Effective date'}
          </h2>

          <div className="space-y-2">
            <label className="flex items-center gap-3 cursor-pointer min-h-[44px] p-3 rounded-lg border border-gray-200 bg-white">
              <input
                type="radio"
                name="effectiveDate"
                checked={effectiveDate === 'today'}
                onChange={() => setEffectiveDate('today')}
                className="w-4 h-4 text-[#2563EB] focus:ring-[#2563EB] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'اليوم فقط' : 'Today only'}</span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer min-h-[44px] p-3 rounded-lg border border-gray-200 bg-white">
              <input
                type="radio"
                name="effectiveDate"
                checked={effectiveDate === 'ongoing'}
                onChange={() => setEffectiveDate('ongoing')}
                className="w-4 h-4 text-[#2563EB] focus:ring-[#2563EB] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'حتى إشعار آخر' : 'Until further notice'}</span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer min-h-[44px] p-3 rounded-lg border border-gray-200 bg-white">
              <input
                type="radio"
                name="effectiveDate"
                checked={effectiveDate === 'until'}
                onChange={() => setEffectiveDate('until')}
                className="w-4 h-4 text-[#2563EB] focus:ring-[#2563EB] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'حتى تاريخ محدد' : 'Until date'}</span>
            </label>

            {effectiveDate === 'until' && (
              <input
                type="date"
                value={untilDate}
                onChange={(e) => setUntilDate(e.target.value)}
                className="w-full h-12 px-4 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
              />
            )}
          </div>
        </div>

        {/* Preview Section */}
        {canSend && (
          <div className="text-left space-y-3">
            <h2 className="text-[14px] font-bold text-gray-900">
              {isRTL ? 'معاينة التنبيه' : 'Preview'}
            </h2>
            <div className="bg-white rounded-xl p-4 border border-[#E2E8F0] shadow-sm">
              <p className="text-[12px] text-[#64748B] mb-2">
                {isRTL ? 'سوف تستلم الكافتيريا ما يلي:' : 'Cafeteria will receive:'}
              </p>
              <div className="bg-[#FFFBEB] border border-[#F59E0B] rounded-lg p-3">
                <p className="text-[14px] font-semibold text-[#92400E]">
                  {getPreviewText()}
                </p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Send Button */}
      <div className="fixed bottom-[83px] left-0 right-0 bg-white border-t border-gray-200 p-4 max-w-[393px] mx-auto z-40">
        <button
          onClick={handleSend}
          disabled={!canSend}
          className="w-full px-4 py-3.5 bg-[#0D9488] text-white rounded-xl text-[15px] font-bold min-h-[52px] disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer shadow-md"
        >
          {isRTL ? 'إرسال التنبيه للكافتيريا' : 'Send to Cafeteria'}
        </button>
      </div>

      {/* Confirmation Dialog */}
      {showConfirmDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full text-left space-y-4">
            <h3 className="text-[17px] font-bold text-gray-900">
              {isRTL ? 'تأكيد إرسال التنبيه' : 'Confirm Cafeteria Alert'}
            </h3>
            <p className="text-[14px] text-[#64748B] leading-relaxed">
              {isRTL 
                ? 'سيتم إخطار موظفي الكافتيريا فوراً بالقيود الغذائية للطالب. لا يمكن التراجع عن هذا الإجراء.'
                : 'Cafeteria staff will be notified immediately. This cannot be undone. Confirm?'}
            </p>

            <div className="flex gap-3">
              <button
                onClick={() => setShowConfirmDialog(false)}
                className="flex-1 px-4 py-2.5 bg-white border border-[#E2E8F0] text-[#64748B] rounded-lg text-[14px] font-bold min-h-[44px] cursor-pointer"
              >
                {isRTL ? 'إلغاء' : 'Cancel'}
              </button>
              <button
                onClick={confirmSend}
                className="flex-1 px-4 py-2.5 bg-[#0D9488] text-white rounded-lg text-[14px] font-bold min-h-[44px] cursor-pointer"
              >
                {isRTL ? 'إرسال' : 'Confirm'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
export default SendCafeteriaAlert;
