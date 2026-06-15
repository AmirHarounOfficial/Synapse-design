import { ChevronLeft, Camera, CheckCircle, AlertCircle, Upload, ChevronDown } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { toast } from 'sonner';

export function AddMedicationStep2() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [medicationType, setMedicationType] = useState<'permanent' | 'temporary'>('permanent');
  const [dailyDoses, setDailyDoses] = useState(1);
  const [hasPhysicianOrder, setHasPhysicianOrder] = useState(false);
  const [hasParentAuth, setHasParentAuth] = useState(false);
  const [doseTimes, setDoseTimes] = useState(['08:00']);
  const [showSubmitModal, setShowSubmitModal] = useState(false);

  const isFormValid = hasPhysicianOrder && hasParentAuth && doseTimes.every(time => time);

  const handleAddDose = () => {
    if (dailyDoses < 4) {
      setDailyDoses(dailyDoses + 1);
      setDoseTimes([...doseTimes, '']);
    }
  };

  const handleRemoveDose = () => {
    if (dailyDoses > 1) {
      setDailyDoses(dailyDoses - 1);
      setDoseTimes(doseTimes.slice(0, -1));
    }
  };

  const updateDoseTime = (index: number, value: string) => {
    const newTimes = [...doseTimes];
    newTimes[index] = value;
    setDoseTimes(newTimes);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <button
          onClick={() => navigate('/nurse/medications/add/step1')}
          className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center cursor-pointer"
        >
          <ChevronLeft className={`w-6 h-6 text-[#0F172A] ${isRTL ? 'rotate-180' : ''}`} />
        </button>
        <h1 className="flex-1 text-[17px] font-medium text-[#0F172A] text-center" style={{ fontWeight: 500 }}>
          {isRTL ? 'إضافة دواء جديد' : 'Add Medication'}
        </h1>
        <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 500 }}>
          {isRTL ? 'الخطوة 2 من 3' : 'Step 2 of 3'}
        </span>
      </div>

      {/* Progress Bar */}
      <div className="flex gap-1 px-4 py-3 bg-[#FFFFFF] border-b border-[#E2E8F0]">
        <div className="flex-1 h-1 bg-[#10B981] rounded-full" />
        <div className="flex-1 h-1 bg-[#2563EB] rounded-full" />
        <div className="flex-1 h-1 bg-[#E2E8F0] rounded-full" />
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Photo Thumbnail */}
        <div className="flex justify-end">
          <button className="w-20 h-20 bg-[#1F2937] rounded-lg flex items-center justify-center border-2 border-[#2563EB] cursor-pointer">
            <Camera className="w-8 h-8 text-[#64748B]" />
          </button>
        </div>

        {/* Extracted Info Section */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] space-y-4 text-left">
          <h3 className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
            {isRTL ? 'معلومات الدواء' : 'Medication Information'}
          </h3>

          {/* Student */}
          <div>
            <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
              {isRTL ? 'الطالب' : 'Student'}
            </label>
            <div className="relative">
              <select className="w-full h-[52px] px-4 pr-10 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] appearance-none outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]" style={{ fontWeight: 400 }}>
                <option>Maya Chen - Grade 5</option>
                <option>Emma Rodriguez - Grade 4</option>
                <option>Marcus Chen - Grade 7</option>
              </select>
              <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B] pointer-events-none" />
            </div>

            {/* Physician Context Chip */}
            <div className="mt-2.5 p-3 rounded-lg border border-[#0D9488]/30 bg-[#0D9488]/5 flex items-center justify-between">
              <div>
                <span className="block text-[9px] uppercase font-bold text-[#0D9488] tracking-wider">
                  {isRTL ? 'الطبيب المناوب حالياً' : 'Physician On Duty'}
                </span>
                <span className="text-[13px] font-bold text-[#0f172a] block">
                  {isRTL ? 'د. أمينة الهاشمي' : 'Dr. Amina Al-Hashimi'}
                </span>
                <span className="block text-[10px] text-[#64748B]">
                  {isRTL ? 'متواجد بالمدرسة حتى 3:00 م' : 'On-site until 3:00 PM'}
                </span>
              </div>
              <span className="text-[10px] bg-[#0D9488]/20 text-[#0D9488] font-bold px-2 py-0.5 rounded-full">
                {isRTL ? 'متواجد' : 'On-Site'}
              </span>
            </div>
          </div>

          {/* Medication Name */}
          <div>
            <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
              {isRTL ? 'اسم الدواء' : 'Medication Name'}
            </label>
            <div className="relative">
              <input
                type="text"
                defaultValue="Methylphenidate 10mg"
                className="w-full h-[52px] px-4 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
                style={{ fontWeight: 400 }}
              />
              <div className="absolute right-4 top-1/2 -translate-y-1/2 bg-[#ECFEFF] text-[#0E7490] text-[11px] px-2 py-1 rounded-full font-semibold" style={{ fontWeight: 600 }}>
                {isRTL ? 'مستخرج تلقائياً' : 'Auto-extracted'}
              </div>
            </div>
          </div>

          {/* Type Toggle */}
          <div>
            <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
              {isRTL ? 'النوع' : 'Type'}
            </label>
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setMedicationType('permanent')}
                className={`flex-1 h-[44px] rounded-lg font-semibold transition-colors cursor-pointer ${
                  medicationType === 'permanent'
                    ? 'bg-[#2563EB] text-white'
                    : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
                }`}
                style={{ fontWeight: 600 }}
              >
                {isRTL ? 'دائم' : 'Permanent'}
              </button>
              <button
                type="button"
                onClick={() => setMedicationType('temporary')}
                className={`flex-1 h-[44px] rounded-lg font-semibold transition-colors cursor-pointer ${
                  medicationType === 'temporary'
                    ? 'bg-[#2563EB] text-white'
                    : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
                }`}
                style={{ fontWeight: 600 }}
              >
                {isRTL ? 'مؤقت' : 'Temporary'}
              </button>
            </div>
          </div>
        </div>

        {/* Required Documents Warning Banner */}
        {(!hasPhysicianOrder || !hasParentAuth) && (
          <div 
            className="bg-[#FEE2E2] rounded-xl p-4 text-left"
            style={{
              borderStyle: 'solid',
              borderLeftWidth: isRTL ? 0 : '4px',
              borderRightWidth: isRTL ? '4px' : 0,
              borderLeftColor: isRTL ? 'transparent' : '#DC2626',
              borderRightColor: isRTL ? '#DC2626' : 'transparent',
            }}
          >
            <div className="flex gap-3">
              <AlertCircle className="w-5 h-5 text-[#DC2626] flex-shrink-0 mt-0.5" />
              <p className="text-[13px] text-[#991B1B] font-medium leading-relaxed" style={{ fontWeight: 500 }}>
                {isRTL 
                  ? 'لا يمكن جدولة الدواء حتى يتم تقديم ملف أمر الطبيب وموافقة ولي الأمر أولاً.'
                  : 'Medication cannot be scheduled until physician order AND parent consent are on file.'}
              </p>
            </div>
          </div>
        )}

        {/* Document Uploads */}
        <div className="space-y-3">
          <button
            type="button"
            onClick={() => setHasPhysicianOrder(!hasPhysicianOrder)}
            className={`w-full h-[52px] rounded-xl border-2 flex items-center justify-between px-4 cursor-pointer ${
              hasPhysicianOrder
                ? 'border-[#10B981] bg-[#D1FAE5]'
                : 'border-[#DC2626] bg-[#FFFFFF]'
            }`}
          >
            <span className={`text-[14px] font-semibold ${hasPhysicianOrder ? 'text-[#065F46]' : 'text-[#0F172A]'}`} style={{ fontWeight: 600 }}>
              {isRTL ? 'أمر الطبيب المعالج' : 'Physician Order'}
            </span>
            {hasPhysicianOrder ? (
              <CheckCircle className="w-5 h-5 text-[#10B981]" />
            ) : (
              <Upload className="w-5 h-5 text-[#DC2626]" />
            )}
          </button>

          <button
            type="button"
            onClick={() => setHasParentAuth(!hasParentAuth)}
            className={`w-full h-[52px] rounded-xl border-2 flex items-center justify-between px-4 cursor-pointer ${
              hasParentAuth
                ? 'border-[#10B981] bg-[#D1FAE5]'
                : 'border-[#DC2626] bg-[#FFFFFF]'
            }`}
          >
            <span className={`text-[14px] font-semibold ${hasParentAuth ? 'text-[#065F46]' : 'text-[#0F172A]'}`} style={{ fontWeight: 600 }}>
              {isRTL ? 'موافقة ولي الأمر' : 'Parent Authorization'}
            </span>
            {hasParentAuth ? (
              <CheckCircle className="w-5 h-5 text-[#10B981]" />
            ) : (
              <Upload className="w-5 h-5 text-[#DC2626]" />
            )}
          </button>
        </div>

        {/* Dose Schedule */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] space-y-4 text-left">
          <h3 className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
            {isRTL ? 'جدول الجرعات' : 'Dose Schedule'}
          </h3>

          {/* Daily Doses Stepper */}
          <div>
            <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
              {isRTL ? 'عدد الجرعات اليومية' : 'Daily Doses'}
            </label>
            <div className="flex items-center gap-3">
              <button
                type="button"
                onClick={handleRemoveDose}
                disabled={dailyDoses <= 1}
                className="w-10 h-10 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] font-semibold disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
                style={{ fontWeight: 600 }}
              >
                -
              </button>
              <span className="text-[20px] font-semibold text-[#0F172A] min-w-[40px] text-center" style={{ fontWeight: 600 }}>
                {dailyDoses}
              </span>
              <button
                type="button"
                onClick={handleAddDose}
                disabled={dailyDoses >= 4}
                className="w-10 h-10 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] font-semibold disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
                style={{ fontWeight: 600 }}
              >
                +
              </button>
            </div>
          </div>

          {/* Dose Times */}
          {doseTimes.map((time, index) => (
            <div key={index}>
              <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
                {isRTL ? `وقت الجرعة ${index + 1}` : `Dose ${index + 1} Time`}
              </label>
              <input
                type="time"
                value={time}
                onChange={(e) => updateDoseTime(index, e.target.value)}
                className="w-full h-[52px] px-4 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
                style={{ fontWeight: 400 }}
              />
            </div>
          ))}

          {/* Notify Before */}
          <div>
            <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
              {isRTL ? 'التنبيه قبل (بالدقائق)' : 'Notify Before (minutes)'}
            </label>
            <input
              type="number"
              defaultValue="15"
              className="w-full h-[52px] px-4 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
              style={{ fontWeight: 400 }}
            />
          </div>

          {/* Temporary End Date */}
          {medicationType === 'temporary' && (
            <div>
              <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
                {isRTL ? 'تاريخ الانتهاء' : 'End Date'}
              </label>
              <input
                type="date"
                className="w-full h-[52px] px-4 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
                style={{ fontWeight: 400 }}
              />
            </div>
          )}
        </div>

        {/* Submit Button */}
        <button
          type="button"
          onClick={() => setShowSubmitModal(true)}
          disabled={!isFormValid}
          className="w-full h-[52px] bg-[#0D9488] text-white rounded-xl font-semibold disabled:opacity-40 cursor-pointer shadow-md"
          style={{ fontWeight: 600 }}
        >
          {isRTL ? 'إرسال لمراجعة الطبيب' : 'Submit for Physician Review'}
        </button>
      </div>

      {/* Confirmation Modal */}
      {showSubmitModal && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full border border-gray-100 shadow-xl space-y-4 text-left">
            <div className="text-center space-y-2">
              <div className="w-12 h-12 rounded-full bg-[#0D9488]/10 flex items-center justify-center text-[#0D9488] mx-auto">
                <CheckCircle className="w-6 h-6 animate-bounce" />
              </div>
              <h3 className="text-[17px] font-bold text-gray-900">
                {isRTL ? 'إرسال لمراجعة الطبيب' : 'Submit for Physician Review'}
              </h3>
              <p className="text-xs text-[#64748B] leading-relaxed">
                {isRTL 
                  ? 'سيتم إرسال هذا البروتوكول الدوائي إلى د. أمينة الهاشمي للمراجعة والاعتماد بموجب ترخيصها. لا يمكن إعطاؤه حتى يتم التوقيع عليه.'
                  : 'This medication protocol will be sent to Dr. Amina Al-Hashimi for approval. It cannot be administered until approved.'}
              </p>
            </div>

            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => setShowSubmitModal(false)}
                className="flex-1 h-11 border border-gray-200 text-gray-500 rounded-xl text-xs font-bold cursor-pointer bg-white"
              >
                {isRTL ? 'إلغاء' : 'Cancel'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowSubmitModal(false);
                  toast.success(isRTL ? "تم إرسال طلب البروتوكول للطبيب بنجاح" : "Protocol submitted to physician review queue!");
                  setTimeout(() => {
                    navigate('/nurse/medications');
                  }, 1500);
                }}
                className="flex-1 h-11 bg-[#0D9488] text-white rounded-xl text-xs font-bold cursor-pointer"
              >
                {isRTL ? 'تأكيد وإرسال' : 'Submit'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
export default AddMedicationStep2;
