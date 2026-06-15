import { useNavigate } from 'react-router';
import { ChevronLeft, FileText, Calendar, Users, Clipboard, Activity, Lock, Check } from 'lucide-react';
import { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';

interface ReportType {
  id: string;
  name: string;
  enName: string;
  arName: string;
  description: string;
  enDescription: string;
  arDescription: string;
  icon: any;
}

export function GenerateReport() {
  const navigate = useNavigate();
  const { isRTL } = useLanguage();
  const [selectedType, setSelectedType] = useState<string>('daily');
  const [startDate, setStartDate] = useState('2026-06-15');
  const [endDate, setEndDate] = useState('2026-06-15');
  const [studentScope, setStudentScope] = useState<'all' | 'specific'>('all');
  const [specificStudent, setSpecificStudent] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);
  const [submitForCoSignature, setSubmitForCoSignature] = useState(true);

  const [includeSections, setIncludeSections] = useState({
    clinicVisits: true,
    medicationLog: true,
    documentStatus: true,
    healthScreening: true
  });

  const reportTypes: ReportType[] = [
    {
      id: 'daily',
      name: 'Daily Summary',
      enName: 'Daily Summary',
      arName: 'الملخص اليومي',
      description: 'All activities for a single day',
      enDescription: 'All activities for a single day',
      arDescription: 'جميع الأنشطة والزيارات ليوم واحد',
      icon: Calendar
    },
    {
      id: 'weekly',
      name: 'Weekly Clinic',
      enName: 'Weekly Clinic',
      arName: 'التقرير الأسبوعي للعيادة',
      description: 'Clinic visit statistics and trends',
      enDescription: 'Clinic visit statistics and trends',
      arDescription: 'إحصائيات وزيارات العيادة الأسبوعية والتطورات',
      icon: Activity
    },
    {
      id: 'medication',
      name: 'Medication Log',
      enName: 'Medication Log',
      arName: 'سجل الأدوية اليومي',
      description: 'All medication administration records',
      enDescription: 'All medication administration records',
      arDescription: 'جميع سجلات إعطاء الأدوية للطلاب بالعيادة',
      icon: Clipboard
    },
    {
      id: 'screening',
      name: 'Periodic Health Screening',
      enName: 'Periodic Health Screening',
      arName: 'الفحوصات الطبية الدورية',
      description: 'Vision, hearing, growth screenings',
      enDescription: 'Vision, hearing, growth screenings',
      arDescription: 'نتائج فحص النظر والسمع والنمو الدورية للطلاب',
      icon: Users
    },
    {
      id: 'annual',
      name: 'Annual Report',
      enName: 'Annual Report',
      arName: 'التقرير السنوي الشامل',
      description: 'Comprehensive year-end report',
      enDescription: 'Comprehensive year-end report',
      arDescription: 'تقرير شامل ومفصل لجميع البيانات الصحية بنهاية العام',
      icon: FileText
    }
  ];

  const toggleSection = (section: keyof typeof includeSections) => {
    setIncludeSections(prev => ({ ...prev, [section]: !prev[section] }));
  };

  const handleGenerate = () => {
    setIsGenerating(true);
    // Simulate report generation
    setTimeout(() => {
      setIsGenerating(false);
      navigate(`/nurse/reports/preview?cosign=${submitForCoSignature}`);
    }, 1800);
  };

  const nurseName = 'Emily Smith';
  const licenseNumber = 'RN-4521';

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[180px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
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
          {isRTL ? 'إنشاء تقرير طبي' : 'Generate Report'}
        </h1>
      </header>

      <div className="px-4 py-4 space-y-6">
        {/* Report Type Section */}
        <div className="text-left">
          <h2 className="text-[14px] font-bold text-gray-900 mb-3">
            {isRTL ? 'نوع التقرير الطبي' : 'Report Type'}
          </h2>

          <div className="space-y-3">
            {reportTypes.map((type) => {
              const Icon = type.icon;
              return (
                <button
                  type="button"
                  key={type.id}
                  onClick={() => setSelectedType(type.id)}
                  className={`w-full p-4 rounded-xl border transition-colors text-left cursor-pointer ${
                    selectedType === type.id
                      ? 'border-[#0D9488] bg-teal-50/20'
                      : 'border-gray-200 bg-white'
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 ${
                      selectedType === type.id ? 'bg-[#0D9488]' : 'bg-[#F8FAFC]'
                    }`}>
                      <Icon className={`w-5 h-5 ${
                        selectedType === type.id ? 'text-white' : 'text-[#0D9488]'
                      }`} />
                    </div>
                    <div className="flex-1">
                      <div className="text-[14px] font-bold text-gray-900 mb-1">
                        {isRTL ? type.arName : type.enName}
                      </div>
                      <div className="text-[12px] text-[#64748B]">
                        {isRTL ? type.arDescription : type.enDescription}
                      </div>
                    </div>
                    {selectedType === type.id && (
                      <Check className="w-5 h-5 text-[#0D9488] flex-shrink-0" />
                    )}
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Date Range */}
        <div className="text-left">
          <h2 className="text-[14px] font-bold text-gray-900 mb-3">
            {isRTL ? 'الفترة الزمنية للتقرير' : 'Date Range'}
          </h2>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-[12px] text-[#64748B] mb-1">
                {isRTL ? 'تاريخ البدء' : 'Start Date'}
              </label>
              <input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="w-full h-12 px-3 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] outline-none focus:border-[#0D9488]"
              />
            </div>
            <div>
              <label className="block text-[12px] text-[#64748B] mb-1">
                {isRTL ? 'تاريخ الانتهاء' : 'End Date'}
              </label>
              <input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="w-full h-12 px-3 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] outline-none focus:border-[#0D9488]"
              />
            </div>
          </div>
        </div>

        {/* Student Scope */}
        <div className="text-left">
          <h2 className="text-[14px] font-bold text-gray-900 mb-3">
            {isRTL ? 'نطاق طلاب التقرير' : 'Student Scope'}
          </h2>

          <div className="space-y-2">
            <label className="flex items-center gap-3 cursor-pointer min-h-[44px] p-3 rounded-lg border border-gray-200 bg-white">
              <input
                type="radio"
                name="studentScope"
                checked={studentScope === 'all'}
                onChange={() => setStudentScope('all')}
                className="w-4 h-4 text-[#0D9488] focus:ring-[#0D9488] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'جميع الطلاب بالمدرسة' : 'All students'}</span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer min-h-[44px] p-3 rounded-lg border border-gray-200 bg-white">
              <input
                type="radio"
                name="studentScope"
                checked={studentScope === 'specific'}
                onChange={() => setStudentScope('specific')}
                className="w-4 h-4 text-[#0D9488] focus:ring-[#0D9488] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'طالب محدد فقط' : 'Specific student'}</span>
            </label>
          </div>

          {studentScope === 'specific' && (
            <input
              type="text"
              value={specificStudent}
              onChange={(e) => setSpecificStudent(e.target.value)}
              placeholder={isRTL ? "ابحث عن اسم الطالب..." : "Search student name..."}
              className="mt-3 w-full h-12 px-4 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#0D9488]"
            />
          )}
        </div>

        {/* Include Sections */}
        <div className="text-left">
          <h2 className="text-[14px] font-bold text-gray-900 mb-3">
            {isRTL ? 'الأقسام المشمولة بالتقرير' : 'Include Sections'}
          </h2>

          <div className="space-y-2 bg-white rounded-xl p-4 border border-gray-200 shadow-sm">
            <label className="flex items-center gap-3 cursor-pointer min-h-[44px]">
              <input
                type="checkbox"
                checked={includeSections.clinicVisits}
                onChange={() => toggleSection('clinicVisits')}
                className="w-5 h-5 rounded border-gray-300 text-[#0D9488] focus:ring-[#0D9488] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'ملخص زيارات العيادة المدرسية' : 'Clinic visits summary'}</span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer min-h-[44px]">
              <input
                type="checkbox"
                checked={includeSections.medicationLog}
                onChange={() => toggleSection('medicationLog')}
                className="w-5 h-5 rounded border-gray-300 text-[#0D9488] focus:ring-[#0D9488] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'سجل إعطاء الأدوية والجرعات' : 'Medication administration log'}</span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer min-h-[44px]">
              <input
                type="checkbox"
                checked={includeSections.documentStatus}
                onChange={() => toggleSection('documentStatus')}
                className="w-5 h-5 rounded border-gray-300 text-[#0D9488] focus:ring-[#0D9488] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'حالة التراخيص والمستندات الطبية' : 'Document status'}</span>
            </label>

            <label className="flex items-center gap-3 cursor-pointer min-h-[44px]">
              <input
                type="checkbox"
                checked={includeSections.healthScreening}
                onChange={() => toggleSection('healthScreening')}
                className="w-5 h-5 rounded border-gray-300 text-[#0D9488] focus:ring-[#0D9488] cursor-pointer"
              />
              <span className="text-[14px] text-gray-900 select-none">{isRTL ? 'نتائج الفحوصات الطبية الدورية' : 'Health screening results'}</span>
            </label>

            {/* Submit for Physician Co-Signature Toggle */}
            <div className="pt-3.5 border-t border-gray-100 flex flex-col gap-1.5">
              <label className="flex items-center gap-3 cursor-pointer min-h-[44px]">
                <input
                  type="checkbox"
                  checked={submitForCoSignature}
                  onChange={(e) => setSubmitForCoSignature(e.target.checked)}
                  className="w-5 h-5 rounded border-gray-300 text-[#0D9488] focus:ring-[#0D9488] cursor-pointer"
                />
                <span className="text-[14px] font-semibold text-gray-900 select-none">
                  {isRTL ? 'إرسال للتوقيع المشترك للطبيب' : 'Submit for Physician Co-Signature'}
                </span>
              </label>
              <p className={`text-[11px] text-[#64748B] ${isRTL ? 'pr-8' : 'pl-8'}`}>
                {isRTL 
                  ? 'سيتم إرسال التقرير الطبي للطبيب المناوب للمراجعة والتوقيع الثنائي لاعتماده نهائياً.'
                  : 'Report will be routed to the on-duty school physician for review and dual-signature before final release.'}
              </p>
            </div>
          </div>
        </div>

        {/* Signature Info Card */}
        <div className="bg-white rounded-xl p-4 border border-gray-200 text-left shadow-sm">
          <div className="flex items-start gap-2">
            <Lock className="w-4 h-4 text-[#64748B] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-[12px] text-[#64748B] leading-relaxed">
                {isRTL 
                  ? `سيتم توقيع التقرير رقمياً بواسطة: ${nurseName} · ترخيص: ${licenseNumber} بموجب قانون المعاملات الإلكترونية الإماراتي.`
                  : `Report will be digitally signed by: ${nurseName} · License #${licenseNumber} under UAE Electronic Transactions Law.`}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Generate Button */}
      <div className="fixed bottom-[83px] left-0 right-0 bg-white border-t border-gray-200 p-4 max-w-[393px] mx-auto z-40">
        <button
          onClick={handleGenerate}
          disabled={isGenerating}
          className="w-full px-4 py-3.5 bg-[#0D9488] text-white rounded-xl text-[15px] font-bold min-h-[52px] disabled:opacity-50 flex items-center justify-center gap-2 cursor-pointer shadow-md"
        >
          {isGenerating ? (
            <>
              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              {isRTL ? 'جاري إنشاء التقرير...' : 'Generating Report...'}
            </>
          ) : (
            isRTL ? 'إنشاء التقرير الطبي' : 'Generate Report'
          )}
        </button>
      </div>
    </div>
  );
}
export default GenerateReport;
