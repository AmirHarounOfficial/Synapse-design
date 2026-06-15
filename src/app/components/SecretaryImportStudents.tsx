import { ArrowLeft, Download, Upload, CheckCircle, AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';
import { validateEID } from '../../utils/eidValidator';

export function SecretaryImportStudents() {
  const navigate = useNavigate();
  const [uploadedFile, setUploadedFile] = useState<string | null>(null);
  const [validationErrors, setValidationErrors] = useState<Array<{ row: number; error: string }>>([]);
  const [validationPassed, setValidationPassed] = useState(false);

  const handleFileUpload = () => {
    // Simulate file upload
    setUploadedFile('students_uae_2026.xlsx');

    // Simulate validation with some UAE errors
    // Validate custom EIDs to showcase validation logic
    const invalidEID = "784-1234-5678-9"; // invalid
    const isEIDValid = validateEID(invalidEID);

    setValidationErrors([
      { row: 12, error: 'Missing required field: Parent Email / البريد الإلكتروني لولي الأمر مفقود' },
      { row: 15, error: 'Invalid date format: Birth Date (Must be YYYY-MM-DD) / صيغة تاريخ الميلاد غير صالحة' },
      { 
        row: 18, 
        error: `Invalid Emirates ID: '${invalidEID}'. EID must be 15 digits in 784-YYYY-XXXXXXX-X format / رقم الهوية الإماراتية غير صالح: يجب أن يطابق الصيغة 784-YYYY-XXXXXXX-X` 
      }
    ]);
    setValidationPassed(false);
  };

  const handleFixErrors = () => {
    // Simulate fixing errors
    setValidationErrors([]);
    setValidationPassed(true);
  };

  const handleImport = () => {
    alert('45 students imported successfully');
    navigate('/secretary/students');
  };

  const previewRows = [
    { name: 'Fatima Al Mansoori', eid: '784-2016-1234567-8', grade: '4th', dob: '2016-03-15', parent: 'almansoori.j@email.ae', emirate: 'Dubai', curriculum: 'IB', insurer: 'Daman', policy: 'DM-98765-01' },
    { name: 'Zayed Al Hashimi', eid: '784-2015-7654321-0', grade: '5th', dob: '2015-07-22', parent: 'sarah.hashimi@email.ae', emirate: 'Abu Dhabi', curriculum: 'British', insurer: 'GIG Gulf', policy: 'GG-11223-04' },
    { name: 'Aisha Al Suwaidi', eid: '784-2016-5678901-2', grade: '4th', dob: '2016-05-10', parent: 'carlos.suwaidi@email.ae', emirate: 'Dubai', curriculum: 'IB', insurer: 'Oman Insurance', policy: 'OI-55443-02' },
    { name: 'Liam Chen', eid: '784-2017-9012345-6', grade: '3rd', dob: '2017-01-08', parent: 'wei.chen@email.ae', emirate: 'Dubai', curriculum: 'American', insurer: 'Nextcare', policy: 'NC-44556-09' },
    { name: 'Omar Al Marzooqi', eid: '784-2015-3456789-0', grade: '5th', dob: '2015-11-30', parent: 'michael.marzooqi@email.ae', emirate: 'Sharjah', curriculum: 'SABIS', insurer: 'Daman', policy: 'DM-77331-03' }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col" style={{ width: '393px', height: '852px' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
          aria-label="Go back"
        >
          <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
        </button>
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Import Students
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Step 1: Download Template */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-3 mb-3">
            <div className="w-6 h-6 rounded-full bg-[#2563EB] text-white flex items-center justify-center flex-shrink-0 text-[12px] font-semibold">
              1
            </div>
            <div className="flex-1">
              <h3 className="text-[14px] font-semibold text-[#0F172A] mb-1">
                Download Template
              </h3>
              <p className="text-[13px] text-[#64748B] mb-3">
                Get the official Excel template with UAE required fields: Emirates ID, Emirate, Curriculum, UAE Insurer, and Policy. SSN is not used.
              </p>
              <button className="flex items-center gap-2 text-[13px] text-[#2563EB] font-medium">
                <Download className="w-4 h-4" />
                Download students_uae_template.xlsx
              </button>
            </div>
          </div>
        </div>

        {/* Step 2: Upload File */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-start gap-3 mb-3">
            <div className="w-6 h-6 rounded-full bg-[#2563EB] text-white flex items-center justify-center flex-shrink-0 text-[12px] font-semibold">
              2
            </div>
            <div className="flex-1">
              <h3 className="text-[14px] font-semibold text-[#0F172A] mb-1">
                Upload File
              </h3>
              <p className="text-[13px] text-[#64748B] mb-3">
                Accepts .xlsx and .csv files
              </p>
            </div>
          </div>

          {!uploadedFile ? (
            <button
              onClick={handleFileUpload}
              className="w-full h-[120px] border-2 border-dashed border-gray-300 rounded-lg bg-[#F8FAFC] flex flex-col items-center justify-center gap-2 active:bg-gray-100"
            >
              <Upload className="w-8 h-8 text-[#64748B]" />
              <span className="text-[14px] font-medium text-[#0F172A]">
                Tap to upload
              </span>
              <span className="text-[12px] text-[#64748B]">
                .xlsx or .csv
              </span>
            </button>
          ) : (
            <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-lg p-3 flex items-center gap-3">
              <CheckCircle className="w-5 h-5 text-[#2563EB] flex-shrink-0" />
              <div className="flex-1">
                <div className="text-[13px] font-medium text-[#0F172A]">
                  {uploadedFile}
                </div>
                <div className="text-[12px] text-[#64748B]">
                  45 students detected
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Preview Table */}
        {uploadedFile && (
          <div className="bg-white rounded-xl border border-gray-200 p-4">
            <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3">
              Preview (First 5 rows)
            </h3>
            <div className="overflow-x-auto">
              <table className="min-w-[500px] text-[11px]">
                <thead>
                  <tr className="border-b border-gray-200 text-left">
                    <th className="py-2 pr-2 font-medium text-[#64748B] w-[110px]">Name</th>
                    <th className="py-2 pr-2 font-medium text-[#64748B] w-[130px]">Emirates ID (EID)</th>
                    <th className="py-2 pr-2 font-medium text-[#64748B] w-[50px]">Grade</th>
                    <th className="py-2 pr-2 font-medium text-[#64748B] w-[80px]">DOB</th>
                    <th className="py-2 pr-2 font-medium text-[#64748B] w-[70px]">Emirate</th>
                    <th className="py-2 pr-2 font-medium text-[#64748B] w-[80px]">Curriculum</th>
                    <th className="py-2 pr-2 font-medium text-[#64748B] w-[120px]">Parent Email</th>
                    <th className="py-2 pr-2 font-medium text-[#64748B] w-[80px]">Insurer</th>
                    <th className="py-2 font-medium text-[#64748B] w-[90px]">Policy No</th>
                  </tr>
                </thead>
                <tbody>
                  {previewRows.map((row, index) => (
                    <tr key={index} className="border-b border-gray-100">
                      <td className="py-2 pr-2 text-[#0F172A] truncate">{row.name}</td>
                      <td className="py-2 pr-2 text-[#0F172A] font-mono whitespace-nowrap">{row.eid}</td>
                      <td className="py-2 pr-2 text-[#0F172A]">{row.grade}</td>
                      <td className="py-2 pr-2 text-[#0F172A]">{row.dob}</td>
                      <td className="py-2 pr-2 text-[#0F172A]">{row.emirate}</td>
                      <td className="py-2 pr-2 text-[#0F172A]">{row.curriculum}</td>
                      <td className="py-2 pr-2 text-[#0F172A] text-[10px] truncate">{row.parent}</td>
                      <td className="py-2 pr-2 text-[#0F172A]">{row.insurer}</td>
                      <td className="py-2 text-[#0F172A] font-mono">{row.policy}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Validation Errors */}
        {validationErrors.length > 0 && (
          <div className="bg-[#FEE2E2] border border-[#FCA5A5] rounded-xl p-4">
            <div className="flex items-start gap-3 mb-3">
              <AlertTriangle className="w-5 h-5 text-[#DC2626] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[14px] font-semibold text-[#991B1B] mb-2">
                  Validation Errors Found
                </div>
                <div className="space-y-2">
                  {validationErrors.map((error, index) => (
                    <div key={index} className="text-[12px] text-[#991B1B] leading-relaxed">
                      <strong>Row {error.row}:</strong> {error.error}
                    </div>
                  ))}
                </div>
              </div>
            </div>
            <button
              onClick={handleFixErrors}
              className="text-[13px] text-[#DC2626] font-medium underline"
            >
              Fix errors and re-validate
            </button>
          </div>
        )}

        {/* Validation Passed */}
        {validationPassed && (
          <div className="bg-[#D1FAE5] border border-[#6EE7B7] rounded-xl p-4">
            <div className="flex items-start gap-3">
              <CheckCircle className="w-5 h-5 text-[#10B981] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[14px] font-semibold text-[#065F46]">
                  Validation Passed
                </div>
                <div className="text-[12px] text-[#065F46]">
                  Ready to import 45 students
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Button */}
      {uploadedFile && (
        <div className="bg-white border-t border-gray-200 p-4">
          <button
            onClick={handleImport}
            disabled={!validationPassed}
            className={`w-full h-[48px] rounded-lg font-medium text-[15px] transition-colors ${
              validationPassed
                ? 'bg-[#10B981] text-white active:bg-[#059669]'
                : 'bg-gray-200 text-gray-400 cursor-not-allowed'
            }`}
          >
            Import 45 students
          </button>
        </div>
      )}
    </div>
  );
}
