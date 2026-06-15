import { useNavigate, useLocation } from 'react-router';
import { ChevronLeft, Share2, Download, ChevronLeft as ArrowLeft, ChevronRight as ArrowRight, Check, Clock, Lock } from 'lucide-react';
import { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { toast } from 'sonner';

export function ReportPreview() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isRTL } = useLanguage();
  const [currentPage, setCurrentPage] = useState(1);
  const [sendToParent, setSendToParent] = useState(false);

  const searchParams = new URLSearchParams(location.search);
  const isCosignPending = searchParams.get('cosign') === 'true';

  const report = {
    type: isRTL ? 'الملخص اليومي للعيادة' : 'Daily Summary',
    dateRange: '15/06/2026',
    schoolName: 'Lincoln Elementary School',
    preparedBy: 'Emily Smith',
    license: 'RN-4521',
    totalPages: 5
  };

  const handleShare = () => {
    toast.success(isRTL ? "تم فتح خيارات المشاركة" : "Share dialog opened.");
  };

  const handleDownload = () => {
    toast.success(isRTL ? "بدء تحميل ملف التقرير..." : "Downloading report file...");
  };

  const handleShareToPrincipal = () => {
    if (isCosignPending) {
      toast.error(isRTL ? "عذراً، يجب توقيع التقرير من الطبيب أولاً" : "Report must be co-signed by physician first.");
      return;
    }
    toast.success(isRTL ? "تم إرسال التقرير لمدير المدرسة بنجاح" : "Report sent to Principal successfully!");
  };

  const handleExportPDF = () => {
    toast.success(isRTL ? "تصدير بصيغة PDF..." : "Exporting PDF...");
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[180px]" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
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

        <h1 className="absolute left-1/2 -translate-x-1/2 font-semibold text-gray-900">
          {isRTL ? 'معاينة التقرير الطبي' : 'Report Preview'}
        </h1>

        <div className="flex items-center gap-1">
          <button
            onClick={handleShare}
            className="flex items-center justify-center w-11 h-11"
            aria-label="Share"
          >
            <Share2 className="w-5 h-5 text-[#64748B]" />
          </button>
          <button
            onClick={handleDownload}
            className="flex items-center justify-center w-11 h-11"
            aria-label="Download"
          >
            <Download className="w-5 h-5 text-[#64748B]" />
          </button>
        </div>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Co-signature Pending Warning Banner */}
        {isCosignPending && (
          <div 
            className="bg-[#FFFBEB] rounded-xl p-3 flex gap-2.5 text-left border shadow-sm animate-pulse-warning"
            style={{
              borderStyle: 'solid',
              borderLeftWidth: isRTL ? 0 : '4px',
              borderRightWidth: isRTL ? '4px' : 0,
              borderLeftColor: isRTL ? 'transparent' : '#F59E0B',
              borderRightColor: isRTL ? '#F59E0B' : 'transparent',
            }}
          >
            <Clock className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <h4 className="text-[13px] font-bold text-[#78350F]">
                {isRTL ? '⏳ بانتظار التوقيع المشترك للطبيب' : 'Awaiting Physician Co-Signature'}
              </h4>
              <p className="text-[11px] text-[#B45309] mt-0.5 leading-normal">
                {isRTL 
                  ? 'تم إرسال هذا التقرير إلى الطبيب المناوب للمراجعة والتوقيع الثنائي. تم تعطيل خيار الإرسال للمدير حالياً.'
                  : 'Report submitted and routed to the on-duty school physician. Sharing is disabled until co-signed.'}
              </p>
            </div>
          </div>
        )}

        {/* Report Header Card */}
        <div className="bg-white rounded-xl p-4 border border-gray-200 text-left shadow-sm">
          <div className="flex items-start gap-3 mb-4">
            <div className="w-12 h-12 rounded-lg bg-[#EFF6FF] flex items-center justify-center flex-shrink-0 text-xl">
              📋
            </div>
            <div className="flex-1">
              <h2 className="text-[16px] font-bold text-gray-900 mb-1">
                {report.type}
              </h2>
              <p className="text-[13px] text-[#64748B] mb-1 font-semibold font-mono">
                {report.dateRange}
              </p>
              <p className="text-[13px] text-[#64748B]">
                {report.schoolName}
              </p>
            </div>
          </div>

          <div className="pt-3 border-t border-gray-200">
            <div className="flex items-center justify-between mb-2">
              <p className="text-[12px] text-[#64748B]">
                {isRTL 
                  ? `إعداد الممرضة: ${report.preparedBy} (${report.license})` 
                  : `Prepared by: ${report.preparedBy} (${report.license})`}
              </p>
            </div>
            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-[#D1FAE5] text-[#065F46]">
              <Check className="w-3.5 h-3.5" />
              {isRTL ? 'تم التحقق من التوقيع الرقمي للممرضة ✓' : 'Nurse digital signature verified ✓'}
            </span>
          </div>
        </div>

        {/* PDF Preview Sheet */}
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
          {/* Preview Content */}
          <div className="aspect-[8.5/11] bg-white p-5">
            <div className="h-full bg-[#FAFAFA] rounded border border-gray-200 p-4 overflow-auto text-left font-serif space-y-4">
              <div className="text-center space-y-1 pb-4 border-b border-gray-200 font-sans">
                <h3 className="text-xs font-bold uppercase tracking-wide text-gray-900">{report.schoolName}</h3>
                <h4 className="text-[10px] font-bold text-gray-600">SCHOOL HEALTH CENTER - CLINICAL SUMMARY</h4>
                <p className="text-[9px] text-[#64748B]">DHA Compliance: DHA/HRS/HPSD/ST-22</p>
              </div>

              <div className="space-y-3 text-[11px] text-gray-800 leading-relaxed">
                <p>
                  This report summarizes medical center operations at {report.schoolName} for {report.dateRange}.
                </p>

                <div className="bg-slate-50 p-2.5 rounded border border-gray-200 space-y-1 font-sans">
                  <div className="flex justify-between text-[10px] font-bold border-b border-gray-100 pb-1">
                    <span>Clinical Metric</span>
                    <span>Count</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Clinic Student Visits</span>
                    <span>12</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Medication Administrations</span>
                    <span>8</span>
                  </div>
                  <div className="flex justify-between text-amber-700 font-medium">
                    <span>Awaiting Physician Review</span>
                    <span>2</span>
                  </div>
                </div>

                <p className="font-sans text-[10px] text-gray-500 italic mt-2">
                  All procedures performed complied with the UAE PDPL (المرسوم بقانون رقم 45/2021) for patient confidentiality.
                </p>
              </div>
            </div>
          </div>

          {/* Page Navigation */}
          <div className="py-3 border-t border-gray-200 flex items-center justify-between px-4">
            <button
              onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
              disabled={currentPage === 1}
              className="flex items-center gap-1 text-[13px] text-[#64748B] disabled:opacity-50 min-h-[44px] cursor-pointer"
            >
              <ArrowLeft className={`w-4 h-4 ${isRTL ? 'rotate-180' : ''}`} />
              {isRTL ? 'السابق' : 'Previous'}
            </button>

            <span className="text-[13px] font-bold text-gray-900">
              {isRTL 
                ? `صفحة ${currentPage} من ${report.totalPages}`
                : `Page ${currentPage} of ${report.totalPages}`}
            </span>

            <button
              onClick={() => setCurrentPage(Math.min(report.totalPages, currentPage + 1))}
              disabled={currentPage === report.totalPages}
              className="flex items-center gap-1 text-[13px] text-[#64748B] disabled:opacity-50 min-h-[44px] cursor-pointer"
            >
              {isRTL ? 'التالي' : 'Next'}
              <ArrowRight className={`w-4 h-4 ${isRTL ? 'rotate-180' : ''}`} />
            </button>
          </div>
        </div>

        {/* Send to Parent Toggle */}
        <div className="bg-white rounded-xl p-4 border border-gray-200 shadow-sm text-left">
          <label className="flex items-center justify-between cursor-pointer">
            <span className="text-[14px] font-bold text-gray-900">
              {isRTL ? 'إرسال نسخة لأولياء الأمور' : 'Send to Parent'}
            </span>
            <input
              type="checkbox"
              checked={sendToParent}
              onChange={(e) => setSendToParent(e.target.checked)}
              className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#0D9488] relative transition-colors cursor-pointer
                before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                checked:before:translate-x-6"
            />
          </label>
        </div>
      </div>

      {/* Action Row (Fixed Bottom) */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 p-4 pb-[calc(16px+env(safe-area-inset-bottom))] space-y-3 max-w-[393px] mx-auto z-40">
        <button
          onClick={handleShareToPrincipal}
          className={`w-full px-4 py-3 border-2 rounded-lg text-[15px] font-bold min-h-[52px] cursor-pointer transition-all ${
            isCosignPending 
              ? 'border-gray-200 text-gray-400 bg-gray-50 opacity-60 cursor-not-allowed'
              : 'border-[#0D9488] text-[#0D9488] bg-white hover:bg-teal-50/20'
          }`}
        >
          {isRTL ? 'إرسال لمدير المدرسة' : 'Share to Principal'}
        </button>

        <button
          onClick={handleExportPDF}
          className="w-full px-4 py-3 bg-[#0D9488] text-white rounded-lg text-[15px] font-bold min-h-[52px] flex items-center justify-center gap-2 cursor-pointer shadow-md"
        >
          <Download className="w-5 h-5" />
          {isRTL ? 'تصدير بصيغة PDF' : 'Export PDF'}
        </button>
      </div>
    </div>
  );
}
export default ReportPreview;
