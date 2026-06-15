import { ChevronLeft, MoreVertical, CheckCircle, Lock, Camera, AlertTriangle, Clock } from 'lucide-react';
import { useNavigate, useParams } from 'react-router';
import { useLanguage } from '../../context/LanguageContext';
import { PhysicianApprovalCard } from './PhysicianApprovalCard';
import { toast } from 'sonner';

export function NurseMedicationDetail() {
  const navigate = useNavigate();
  const { id } = useParams();
  const { isRTL } = useLanguage();

  const isPending = id === '2' || id === 'demo-medication';
  const approvalStatus = isPending ? 'pending' : 'approved';

  const medication = {
    studentName: isPending ? 'Marcus Chen' : 'Emma Rodriguez',
    studentInitials: isPending ? 'MC' : 'ER',
    grade: isPending ? 'Grade 5' : 'Grade 3',
    room: isPending ? 'Room 105' : 'Room 204',
    hasPhysicianOrder: true,
    hasParentConsent: true,
    medicationName: isPending ? 'Ritalin 10mg' : 'Albuterol Inhaler 90mcg',
    type: 'permanent',
    createdBy: 'Nurse Emily Smith',
    licenseNumber: 'RN-4521',
    createdDate: '15/06/2026 08:30:00',
    dosesRemaining: isPending ? 24 : 12,
    expiryDate: '15/07/2026',
    isLowSupply: !isPending,
    nextDose: isPending ? '11:00 AM' : '02:00 PM',
    doseStatus: 'scheduled',
    hasConflict: isPending,
    conflictMessage: isRTL 
      ? 'تم الإبلاغ عن جرعة منزلية في الساعة 7:00 صباحاً - تم تعديل جرعة المدرسة إلى 11:30 صباحاً'
      : 'Home dose reported at 7:00 AM — school dose adjusted to 11:30 AM',
    physicianApprovalStatus: approvalStatus,
    doseLog: [
      {
        id: 1,
        time: '08:30:47',
        date: '14/06/2026',
        administeredBy: 'Nurse Emily Smith',
        locked: true
      }
    ]
  };

  const isWithinDoseWindow = true; // Within 30min of scheduled dose

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <button
          onClick={() => navigate('/nurse/medications')}
          className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center cursor-pointer"
        >
          <ChevronLeft className={`w-6 h-6 text-[#0F172A] ${isRTL ? 'rotate-180' : ''}`} />
        </button>
        <h1 className="flex-1 text-[17px] font-medium text-[#0F172A] text-center" style={{ fontWeight: 500 }}>
          {medication.studentName}
        </h1>
        <button className="p-2 min-w-[44px] min-h-[44px] flex items-center justify-center">
          <MoreVertical className="w-6 h-6 text-[#64748B]" />
        </button>
      </div>

      {/* Content */}
      <div className="px-4 py-4 space-y-4">
        {/* Student Banner */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] text-left">
          <div className="flex items-start gap-3 mb-3">
            <div className="w-12 h-12 rounded-full bg-[#2563EB] flex items-center justify-center text-white text-lg font-semibold flex-shrink-0">
              {medication.studentInitials}
            </div>
            <div className="flex-1">
              <p className="text-[16px] font-semibold text-[#0F172A] mb-1" style={{ fontWeight: 600 }}>
                {medication.studentName}
              </p>
              <p className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
                {isRTL 
                  ? `${medication.grade === 'Grade 5' ? 'الصف الخامس' : 'الصف الثالث'} · ${medication.room === 'Room 105' ? 'غرفة 105' : 'غرفة 204'}`
                  : `${medication.grade} · ${medication.room}`}
              </p>
            </div>
          </div>

          <div className="flex gap-2">
            {medication.hasPhysicianOrder && (
              <div className="flex items-center gap-1 bg-[#D1FAE5] text-[#065F46] text-[12px] px-3 py-1.5 rounded-full">
                <CheckCircle className="w-3.5 h-3.5" />
                <span className="font-semibold text-[11px]" style={{ fontWeight: 600 }}>
                  {isRTL ? 'أمر طبيب معتمد' : 'Physician order'}
                </span>
              </div>
            )}
            {medication.hasParentConsent && (
              <div className="flex items-center gap-1 bg-[#D1FAE5] text-[#065F46] text-[12px] px-3 py-1.5 rounded-full">
                <CheckCircle className="w-3.5 h-3.5" />
                <span className="font-semibold text-[11px]" style={{ fontWeight: 600 }}>
                  {isRTL ? 'موافقة ولي الأمر' : 'Parent consent'}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Medication Header Card */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] text-left">
          <div className="flex items-start justify-between mb-3">
            <div className="flex-1">
              <h2 className="text-[20px] font-medium text-[#0F172A] mb-2" style={{ fontWeight: 500 }}>
                {medication.medicationName}
              </h2>
              <div className={`inline-flex items-center px-3 py-1.5 rounded-full text-[12px] font-semibold ${
                medication.type === 'permanent'
                  ? 'bg-[#EFF6FF] text-[#2563EB]'
                  : 'bg-[#FFFBEB] text-[#B45309]'
              }`} style={{ fontWeight: 600 }}>
                {medication.type === 'permanent' 
                  ? (isRTL ? 'دائم' : 'Permanent') 
                  : (isRTL ? 'مؤقت' : 'Temporary')}
              </div>
            </div>
            <button className="w-16 h-16 bg-[#F8FAFC] rounded-lg border border-[#E2E8F0] flex items-center justify-center flex-shrink-0">
              <Camera className="w-6 h-6 text-[#64748B]" />
            </button>
          </div>

          <div className="flex items-start gap-2 text-[11px] text-[#64748B] italic" style={{ fontWeight: 400 }}>
            <Lock className="w-3.5 h-3.5 flex-shrink-0 mt-0.5" />
            <p>
              {isRTL 
                ? `أنشئ السجل بواسطة: ${medication.createdBy} · ترخيص: ${medication.licenseNumber} · ${medication.createdDate}`
                : `Record created by ${medication.createdBy} · License #${medication.licenseNumber} · ${medication.createdDate}`}
            </p>
          </div>
        </div>

        {/* Physician Approval Status Card */}
        <PhysicianApprovalCard 
          status={medication.physicianApprovalStatus}
          approvedBy="Dr. Amina Al-Hashimi"
          licenseNumber="DHA MD-4029"
          approvedAt="15/06/2026 at 09:45:12"
        />

        {/* Supply Counter */}
        {medication.isLowSupply && (
          <div 
            className="bg-[#FFFBEB] rounded-xl p-4 text-left"
            style={{
              borderLeftWidth: isRTL ? 0 : '4px',
              borderRightWidth: isRTL ? '4px' : 0,
              borderLeftColor: isRTL ? 'transparent' : '#F59E0B',
              borderRightColor: isRTL ? '#F59E0B' : 'transparent',
              borderStyle: 'solid',
            }}
          >
            <div className="flex items-start gap-3 mb-3">
              <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0" />
              <div className="flex-1">
                <p className="text-[14px] font-semibold text-[#92400E] mb-1" style={{ fontWeight: 600 }}>
                  {isRTL ? 'المخزون منخفض' : 'Low Supply'}
                </p>
                <p className="text-[13px] text-[#92400E]" style={{ fontWeight: 400 }}>
                  {isRTL 
                    ? `متبقي ${medication.dosesRemaining} جرعات · ينتهي في ${medication.expiryDate}`
                    : `${medication.dosesRemaining} doses remaining · Expires ${medication.expiryDate}`}
                </p>
              </div>
            </div>
            <div className="w-full bg-[#FEF3C7] rounded-full h-2">
              <div
                className="bg-[#F59E0B] h-2 rounded-full"
                style={{ width: `${(medication.dosesRemaining / 30) * 100}%` }}
              />
            </div>
          </div>
        )}

        {/* Dose Conflict Alert */}
        {medication.hasConflict && (
          <div 
            className="bg-[#FFFBEB] rounded-xl p-4 text-left"
            style={{
              borderLeftWidth: isRTL ? 0 : '4px',
              borderRightWidth: isRTL ? '4px' : 0,
              borderLeftColor: isRTL ? 'transparent' : '#F59E0B',
              borderRightColor: isRTL ? '#F59E0B' : 'transparent',
              borderStyle: 'solid',
            }}
          >
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0" />
              <div className="flex-1">
                <p className="text-[13px] text-[#92400E] mb-2" style={{ fontWeight: 400 }}>
                  {medication.conflictMessage}
                </p>
                <button className="text-[13px] text-[#2563EB] font-semibold hover:underline" style={{ fontWeight: 600 }}>
                  {isRTL ? 'عرض التفاصيل' : 'View details'}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Today's Dose Card */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] text-left">
          <div className="flex items-center gap-2 mb-3">
            <Clock className="w-5 h-5 text-[#2563EB]" />
            <p className="text-[14px] font-semibold text-[#64748B]" style={{ fontWeight: 600 }}>
              {isRTL ? 'الجرعة التالية' : 'Next Dose'}
            </p>
          </div>

          <p className="text-[24px] font-semibold text-[#0F172A] mb-2" style={{ fontWeight: 600 }}>
            {medication.nextDose}
          </p>

          <div className="inline-flex items-center gap-1 bg-[#DBEAFE] text-[#1E40AF] text-[12px] px-3 py-1.5 rounded-full mb-4">
            <Clock className="w-3.5 h-3.5" />
            <span className="font-semibold" style={{ fontWeight: 600 }}>
              {isRTL ? 'مجدولة' : 'Scheduled'}
            </span>
          </div>

          <button
            onClick={() => {
              if (medication.physicianApprovalStatus === 'pending') {
                toast.error(
                  isRTL 
                    ? "عذراً، لا يمكن إعطاء الدواء قبل الحصول على موافقة الطبيب" 
                    : "Action Blocked: Medication cannot be given without physician approval.",
                  { position: 'top-center' }
                );
                return;
              }
              if (!isWithinDoseWindow) return;
              toast.success(isRTL ? "تم تسجيل إعطاء الجرعة بنجاح" : "Dose marked as given successfully!");
            }}
            className={`w-full h-[52px] rounded-xl font-semibold transition-all cursor-pointer ${
              medication.physicianApprovalStatus === 'pending'
                ? 'bg-gray-200 text-gray-400 opacity-50 cursor-not-allowed'
                : isWithinDoseWindow
                ? 'bg-[#10B981] text-white hover:bg-[#0D9469]'
                : 'bg-[#E2E8F0] text-[#64748B] cursor-not-allowed'
            }`}
            style={{ fontWeight: 600 }}
          >
            {isRTL ? 'تسجيل كمعطى' : 'Mark as Given'}
          </button>

          {medication.physicianApprovalStatus !== 'pending' && !isWithinDoseWindow && (
            <p className="text-[12px] text-[#64748B] text-center mt-2" style={{ fontWeight: 400 }}>
              {isRTL ? 'متاح قبل 30 دقيقة من الوقت المحدد' : 'Available 30 minutes before scheduled time'}
            </p>
          )}
        </div>

        {/* Dose Log */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] text-left">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3" style={{ fontWeight: 600 }}>
            {isRTL ? 'سجل الجرعات' : 'Dose Log'}
          </h3>

          <div className="space-y-3">
            {medication.doseLog.map((log) => (
              <div key={log.id} className="flex items-start gap-3 pb-3 border-b border-[#E2E8F0] last:border-0 last:pb-0">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <p className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
                      {log.time}
                    </p>
                    {log.locked && (
                      <Lock className="w-3.5 h-3.5 text-[#64748B]" />
                    )}
                  </div>
                  <p className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
                    {log.date}
                  </p>
                  <p className="text-[12px] text-[#64748B] mt-1" style={{ fontWeight: 400 }}>
                    {isRTL ? `أعطيت بواسطة: ${log.administeredBy}` : `Administered by ${log.administeredBy}`}
                  </p>
                </div>
                <div className="flex items-center gap-1 bg-[#D1FAE5] text-[#065F46] text-[11px] px-2.5 py-1.5 rounded-full">
                  <CheckCircle className="w-3 h-3" />
                  <span className="font-semibold" style={{ fontWeight: 600 }}>
                    {isRTL ? 'أعطي' : 'Given'}
                  </span>
                </div>
              </div>
            ))}
          </div>

          <button className="w-full text-[13px] text-[#2563EB] font-semibold mt-3 min-h-[44px]" style={{ fontWeight: 600 }}>
            {isRTL ? 'عرض الكل' : 'View all'}
          </button>
        </div>
      </div>
    </div>
  );
}
export default NurseMedicationDetail;
