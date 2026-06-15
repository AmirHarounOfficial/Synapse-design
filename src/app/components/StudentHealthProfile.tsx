import { useNavigate, useParams } from 'react-router';
import { ChevronLeft, Share2, Check, Plus, Lock, FileText, Download, ChevronDown } from 'lucide-react';
import { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { HijriDateChip } from './HijriDateChip';
import { toast } from 'sonner';

interface Medication {
  id: string;
  name: string;
  dose: string;
  nextTime: string;
  status: 'given' | 'pending' | 'upcoming';
}

interface Visit {
  id: string;
  date: string;
  reason: string;
  nurse: string;
  locked: boolean;
}

interface Document {
  id: string;
  name: string;
  type: 'physician' | 'consent' | 'insurance' | 'immunization' | 'care-plan';
  status: 'approved' | 'pending' | 'missing';
}

interface Screening {
  id: string;
  type: string;
  date: string;
  nurse: string;
  values: string;
}

export function StudentHealthProfile() {
  const navigate = useNavigate();
  const { id } = useParams();
  const { isRTL } = useLanguage();
  const [activeTab, setActiveTab] = useState('medications');
  const [curriculum, setCurriculum] = useState('British');

  // Mock student data
  const student = {
    name: 'Emma Rodriguez',
    initials: 'ER',
    grade: 'Grade 3',
    room: 'Room 204',
    schoolId: 'ST-2024-0342',
    consentComplete: true,
    docsComplete: true,
    medicalAlerts: isRTL ? ['ربو', 'حساسية الفول السوداني'] : ['Asthma', 'Peanut Allergy'],
    dateOfBirth: '2016-05-19',
    emiratesID: '784-2016-1234567-1',
    insurance: {
      provider: 'Daman Health',
      policyNumber: 'DM-992384-01',
      expiry: '12/2026'
    }
  };

  const medications: Medication[] = [
    {
      id: '1',
      name: 'Albuterol Inhaler 90mcg',
      dose: '2 puffs',
      nextTime: '2:00 PM',
      status: 'upcoming'
    },
    {
      id: '2',
      name: 'Adderall XR 10mg',
      dose: '1 tablet',
      nextTime: '8:00 AM',
      status: 'given'
    }
  ];

  const visits: Visit[] = [
    {
      id: '1',
      date: '24/05/2026',
      reason: isRTL ? 'إعطاء الدواء المعتاد' : 'Routine medication',
      nurse: 'Nurse Emily Smith RN-4521',
      locked: true
    },
    {
      id: '2',
      date: '23/05/2026',
      reason: isRTL ? 'إصابة طفيفة' : 'Minor injury',
      nurse: 'Nurse Emily Smith RN-4521',
      locked: true
    },
    {
      id: '3',
      date: '20/05/2026',
      reason: isRTL ? 'وعكة صحية' : 'Illness',
      nurse: 'Nurse Sarah Johnson RN-3298',
      locked: true
    }
  ];

  const documents: Document[] = [
    {
      id: '1',
      name: isRTL ? 'أمر الطبيب المعالج' : 'Physician Order',
      type: 'physician',
      status: 'approved'
    },
    {
      id: '2',
      name: isRTL ? 'موافقة ولي الأمر' : 'Parent Consent',
      type: 'consent',
      status: 'approved'
    },
    {
      id: '3',
      name: isRTL ? 'بطاقة التأمين الصحي' : 'Insurance Card',
      type: 'insurance',
      status: 'pending'
    },
    {
      id: '4',
      name: isRTL ? 'سجل التطعيمات' : 'Immunization Record',
      type: 'immunization',
      status: 'approved'
    }
  ];

  const screenings: Screening[] = [
    {
      id: '1',
      type: isRTL ? 'فحص النظر' : 'Vision',
      date: '01/05/2026',
      nurse: 'ES',
      values: '20/20 OD, 20/20 OS'
    },
    {
      id: '2',
      type: isRTL ? 'فحص السمع' : 'Hearing',
      date: '01/05/2026',
      nurse: 'ES',
      values: isRTL ? 'سليم' : 'Pass bilateral'
    }
  ];

  const tabs = [
    { id: 'medications', label: isRTL ? 'الأدوية' : 'Medications' },
    { id: 'visits', label: isRTL ? 'سجل الزيارات' : 'Visit History' },
    { id: 'documents', label: isRTL ? 'المستندات' : 'Documents' },
    { id: 'screenings', label: isRTL ? 'الفحوصات' : 'Screenings' }
  ];

  const getStatusStyle = (status: string) => {
    switch (status) {
      case 'given':
        return 'bg-[#D1FAE5] text-[#065F46]';
      case 'pending':
        return 'bg-[#FEF3C7] text-[#92400E]';
      case 'upcoming':
        return 'bg-[#DBEAFE] text-[#1E40AF]';
      case 'approved':
        return 'bg-[#D1FAE5] text-[#065F46]';
      case 'missing':
        return 'bg-[#FEE2E2] text-[#DC2626]';
      default:
        return 'bg-[#E2E8F0] text-[#64748B]';
    }
  };

  const getStatusLabel = (status: string) => {
    if (isRTL) {
      switch (status) {
        case 'given': return 'أعطي';
        case 'pending': return 'معلق';
        case 'upcoming': return 'قادم';
        case 'approved': return 'معتمد';
        case 'missing': return 'مفقود';
        default: return status;
      }
    }
    return status.charAt(0).toUpperCase() + status.slice(1);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2 cursor-pointer"
          aria-label="Go back"
        >
          <ChevronLeft className={`w-6 h-6 text-gray-900 ${isRTL ? 'rotate-180' : ''}`} />
        </button>

        <h1 className="absolute left-1/2 -translate-x-1/2 font-semibold text-gray-900 max-w-[200px] truncate">
          {student.name}
        </h1>

        <button
          className="flex items-center justify-center w-11 h-11"
          aria-label="Share"
        >
          <Share2 className="w-5 h-5 text-[#64748B]" />
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Student Hero Card */}
        <div className="bg-white rounded-xl p-4 border border-gray-200 text-left">
          <div className="flex items-start gap-4 mb-4">
            {/* Avatar */}
            <div className="w-16 h-16 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[20px] font-medium flex-shrink-0">
              {student.initials}
            </div>

            {/* Student Info */}
            <div className="flex-1">
              <div className="text-[20px] font-bold text-gray-900 mb-1">
                {student.name}
              </div>
              <div className="text-[13px] text-[#64748B] mb-2">
                {isRTL 
                  ? `${student.grade === 'Grade 3' ? 'الصف الثالث' : student.grade} · ${student.room === 'Room 204' ? 'غرفة 204' : student.room}`
                  : `${student.grade} · ${student.room}`}
              </div>

              {/* Curriculum Selector Dropdown */}
              <div className="mb-3">
                <label className="block text-[10px] font-bold uppercase text-[#64748B] mb-1">
                  {isRTL ? 'المنهج الدراسي للمدرسة' : 'School Curriculum'}
                </label>
                <div className="relative">
                  <select 
                    value={curriculum} 
                    onChange={(e) => {
                      setCurriculum(e.target.value);
                      toast.success(isRTL ? "تم تحديث المنهج الدراسي بنجاح" : "Curriculum updated successfully.");
                    }}
                    className="w-full h-9 px-2 text-xs rounded-lg border border-[#E2E8F0] bg-white text-[#0f172a] appearance-none outline-none focus:border-[#2563EB]"
                  >
                    <option value="UAE MoE">UAE MoE</option>
                    <option value="British">British</option>
                    <option value="American">American</option>
                    <option value="Indian">Indian</option>
                    <option value="IB">IB</option>
                    <option value="Other">Other</option>
                  </select>
                  <ChevronDown className={`absolute top-1/2 -translate-y-1/2 w-4 h-4 text-[#64748B] pointer-events-none ${isRTL ? 'left-2' : 'right-2'}`} />
                </div>
              </div>

              {/* Identity EID & Birth Date Block */}
              <div className="text-[12px] text-gray-700 bg-slate-50 border border-slate-100 p-2.5 rounded-lg flex flex-col gap-1.5 mt-2">
                <div>
                  <span className="font-semibold text-[#64748B] text-[10px] uppercase block tracking-wider">{isRTL ? 'رقم الهوية الإماراتية (EID)' : 'Emirates ID (EID)'}</span>
                  <span className="font-mono font-bold text-gray-900 text-sm">{student.emiratesID}</span>
                </div>
                <div>
                  <span className="font-semibold text-[#64748B] text-[10px] uppercase block tracking-wider">{isRTL ? 'تاريخ الميلاد' : 'Date of Birth'}</span>
                  <div className="flex items-center gap-1.5 flex-wrap mt-0.5">
                    <span className="text-gray-900 font-medium text-xs">19/05/2016</span>
                    <HijriDateChip date={student.dateOfBirth} />
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Consent Status */}
          <div className="flex items-center gap-2 mb-2 pt-2 border-t border-gray-100">
            <span
              className={`inline-flex items-center gap-1 px-3 py-1.5 rounded-full text-[11px] font-semibold ${
                student.consentComplete
                  ? 'bg-[#D1FAE5] text-[#065F46]'
                  : 'bg-[#FEE2E2] text-[#DC2626]'
              }`}
            >
              {isRTL ? 'التفويض الطبي' : 'Consent'} {student.consentComplete && <Check className="w-3.5 h-3.5" />}
            </span>
            <span
              className={`inline-flex items-center gap-1 px-3 py-1.5 rounded-full text-[11px] font-semibold ${
                student.docsComplete
                  ? 'bg-[#D1FAE5] text-[#065F46]'
                  : 'bg-[#FEF3C7] text-[#92400E]'
              }`}
            >
              {isRTL ? 'المستندات مكتملة' : 'Docs Complete'} {student.docsComplete && <Check className="w-3.5 h-3.5" />}
            </span>
          </div>

          {/* Medical Alerts */}
          {student.medicalAlerts.length > 0 && (
            <div className="pt-2">
              <div className="text-[11px] font-bold text-[#64748B] uppercase tracking-wide mb-1.5">
                {isRTL ? 'تنبيهات طبية مهمة' : 'Medical Alerts'}
              </div>
              <div className="flex flex-wrap gap-2">
                {student.medicalAlerts.map((alert, index) => (
                  <span
                    key={index}
                    className="inline-flex items-center px-3 py-1 rounded-full text-[11px] font-bold bg-[#FEE2E2] text-[#DC2626]"
                  >
                    {alert}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* UAE Health Insurance Section */}
        <div className="bg-white rounded-xl p-4 border border-gray-200 text-left space-y-3 shadow-sm">
          <h3 className="text-[14px] font-bold text-[#0F172A] border-b border-gray-100 pb-2">
            {isRTL ? 'التأمين الصحي الإماراتي' : 'UAE Health Insurance'}
          </h3>
          <div className="grid grid-cols-2 gap-3 text-xs">
            <div>
              <span className="text-[#64748B] block mb-0.5">{isRTL ? 'شركة التأمين' : 'Insurer'}</span>
              <span className="font-semibold text-gray-900">{student.insurance.provider}</span>
            </div>
            <div>
              <span className="text-[#64748B] block mb-0.5">{isRTL ? 'رقم وثيقة التأمين' : 'Policy Number'}</span>
              <span className="font-semibold text-gray-900 font-mono">{student.insurance.policyNumber}</span>
            </div>
            <div>
              <span className="text-[#64748B] block mb-0.5">{isRTL ? 'تاريخ انتهاء البطاقة' : 'Card Expiry'}</span>
              <span className="font-semibold text-gray-900 font-mono">{student.insurance.expiry}</span>
            </div>
            <div>
              <span className="text-[#64748B] block mb-0.5">{isRTL ? 'حالة التغطية' : 'Coverage Status'}</span>
              <span className="inline-flex items-center gap-1 bg-[#D1FAE5] text-[#065F46] px-2 py-0.5 rounded-full font-bold text-[10px]">
                <Check className="w-3 h-3" />
                {isRTL ? 'نشط' : 'Active'}
              </span>
            </div>
          </div>
          <div className="mt-2 p-2 bg-[#F8FAFC] border border-[#E2E8F0] rounded-lg flex items-center justify-between text-xs">
            <div className="flex items-center gap-2">
              <FileText className="w-4 h-4 text-[#64748B]" />
              <span className="font-semibold text-gray-900 truncate max-w-[180px]">
                {isRTL ? 'بطاقة_التأمين_الصحية.pdf' : 'Health_Insurance_Card.pdf'}
              </span>
            </div>
            <button
              onClick={() => toast.info(isRTL ? "جاري تحميل بطاقة التأمين..." : "Downloading insurance card file...")}
              className="text-[#2563EB] font-bold hover:underline cursor-pointer"
            >
              {isRTL ? 'تحميل' : 'Download'}
            </button>
          </div>
        </div>

        {/* Tabs */}
        <div>
          <div className="flex gap-2 overflow-x-auto scrollbar-hide border-b border-gray-200">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-4 py-3 text-[14px] font-semibold whitespace-nowrap border-b-2 transition-colors min-h-[44px] cursor-pointer ${
                  activeTab === tab.id
                    ? 'border-[#2563EB] text-[#2563EB]'
                    : 'border-transparent text-[#64748B]'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>

        {/* Tab Content */}
        <div>
          {/* Medications Tab */}
          {activeTab === 'medications' && (
            <div className="space-y-3">
              {medications.map((med) => (
                <div
                  key={med.id}
                  className="bg-white rounded-xl p-3 border border-gray-200 text-left"
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1">
                      <div className="text-[14px] font-semibold text-gray-900 mb-1">
                        {med.name}
                      </div>
                      <div className="text-[13px] text-[#64748B]">
                        {med.dose} • {isRTL ? 'التالي' : 'Next'}: {med.nextTime}
                      </div>
                    </div>
                    <span
                      className={`inline-flex items-center px-2 py-1 rounded-full text-[11px] font-semibold ${getStatusStyle(
                        med.status
                      )}`}
                    >
                      {getStatusLabel(med.status)}
                    </span>
                  </div>
                </div>
              ))}

              <button 
                onClick={() => navigate('/nurse/medications/add/step1')}
                className="w-full bg-white rounded-xl p-3 border border-gray-200 border-dashed flex items-center justify-center gap-2 text-[#2563EB] font-semibold min-h-[44px] cursor-pointer"
              >
                <Plus className="w-5 h-5" />
                {isRTL ? 'إضافة دواء جديد للطالب' : 'Add medication'}
              </button>
            </div>
          )}

          {/* Visit History Tab */}
          {activeTab === 'visits' && (
            <div className="space-y-3">
              {visits.map((visit) => (
                <button
                  key={visit.id}
                  className="w-full text-left bg-white rounded-xl p-3 border border-gray-200 cursor-pointer"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <div className="text-[14px] font-semibold text-gray-900">
                          {visit.date}
                        </div>
                        {visit.locked && (
                          <Lock className="w-3.5 h-3.5 text-[#64748B]" />
                        )}
                      </div>
                      <div className="text-[13px] text-[#64748B] mb-1">
                        {visit.reason}
                      </div>
                      <div className="text-[12px] text-[#64748B]">
                        {visit.nurse}
                      </div>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}

          {/* Documents Tab */}
          {activeTab === 'documents' && (
            <div className="grid grid-cols-2 gap-3 text-left">
              {documents.map((doc) => (
                <button
                  key={doc.id}
                  className="bg-white rounded-xl p-4 border border-gray-200 cursor-pointer"
                >
                  <div className="flex items-center justify-center w-12 h-12 rounded-lg bg-[#F8FAFC] mb-3">
                    <FileText className="w-6 h-6 text-[#64748B]" />
                  </div>
                  <div className="text-[13px] font-bold text-gray-900 mb-2 truncate">
                    {doc.name}
                  </div>
                  <span
                    className={`inline-flex items-center px-2 py-1 rounded-full text-[10px] font-semibold ${getStatusStyle(
                      doc.status
                    )}`}
                  >
                    {getStatusLabel(doc.status)}
                  </span>
                </button>
              ))}
            </div>
          )}

          {/* Screenings Tab */}
          {activeTab === 'screenings' && (
            <div className="space-y-3 text-left">
              {screenings.map((screening) => (
                <div
                  key={screening.id}
                  className="bg-white rounded-xl p-3 border border-gray-200"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <div className="text-[14px] font-semibold text-gray-900">
                          {screening.type}
                        </div>
                        <Lock className="w-3.5 h-3.5 text-[#64748B]" />
                      </div>
                      <div className="text-[13px] text-[#64748B] mb-1">
                        {screening.values}
                      </div>
                      <div className="text-[12px] text-[#64748B]">
                        {screening.date} • {screening.nurse}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
export default StudentHealthProfile;
