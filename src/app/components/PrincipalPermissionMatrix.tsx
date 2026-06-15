import { ArrowLeft, Info, Lock, Check, X } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function PrincipalPermissionMatrix() {
  const navigate = useNavigate();
  const [unsavedChanges, setUnsavedChanges] = useState(0);
  const [showGuidance, setShowGuidance] = useState(false);

  // Data categories (columns)
  const categories = [
    { id: 'clinical', label: 'Clinical Record', short: 'Clinical' },
    { id: 'meds', label: 'Medications', short: 'Meds' },
    { id: 'contraindications', label: 'Contraindications Only', short: 'Contra.' },
    { id: 'visit-dates', label: 'Clinic Visit Dates', short: 'Visits' },
    { id: 'diagnosis', label: 'Diagnosis', short: 'Diag.' },
    { id: 'documents', label: 'Documents', short: 'Docs' },
    { id: 'student-name', label: 'Student Name', short: 'Name' },
    { id: 'emergency', label: 'Emergency Contacts', short: 'Emergency' }
  ];

  // Roles (rows)
  const roles = [
    { id: 'nurse', label: 'Nurse' },
    { id: 'secretary', label: 'Secretary' },
    { id: 'teacher', label: 'Teacher' },
    { id: 'counselor', label: 'Counselor' },
    { id: 'pe-teacher', label: 'PE Teacher' },
    { id: 'cafeteria', label: 'Cafeteria' },
    { id: 'security', label: 'Security' },
    { id: 'driver', label: 'Bus Driver' },
    { id: 'parent', label: 'Parent' }
  ];

  // Permission matrix (role -> category -> permission)
  // true = allowed, false = denied, 'partial' = partial access, 'locked' = system-enforced
  const permissions: Record<string, Record<string, boolean | 'partial' | 'locked'>> = {
    'nurse': { 'clinical': 'locked', 'meds': 'locked', 'contraindications': 'locked', 'visit-dates': 'locked', 'diagnosis': 'locked', 'documents': true, 'student-name': true, 'emergency': true },
    'secretary': { 'clinical': false, 'meds': false, 'contraindications': false, 'visit-dates': false, 'diagnosis': false, 'documents': 'partial', 'student-name': true, 'emergency': true },
    'teacher': { 'clinical': false, 'meds': false, 'contraindications': 'locked', 'visit-dates': false, 'diagnosis': false, 'documents': false, 'student-name': true, 'emergency': false },
    'counselor': { 'clinical': false, 'meds': false, 'contraindications': false, 'visit-dates': false, 'diagnosis': false, 'documents': false, 'student-name': true, 'emergency': false },
    'pe-teacher': { 'clinical': false, 'meds': false, 'contraindications': 'locked', 'visit-dates': false, 'diagnosis': false, 'documents': false, 'student-name': true, 'emergency': false },
    'cafeteria': { 'clinical': false, 'meds': false, 'contraindications': 'locked', 'visit-dates': false, 'diagnosis': false, 'documents': false, 'student-name': true, 'emergency': false },
    'security': { 'clinical': false, 'meds': false, 'contraindications': false, 'visit-dates': false, 'diagnosis': false, 'documents': false, 'student-name': true, 'emergency': 'partial' },
    'driver': { 'clinical': false, 'meds': false, 'contraindications': false, 'visit-dates': false, 'diagnosis': false, 'documents': false, 'student-name': true, 'emergency': false },
    'parent': { 'clinical': false, 'meds': 'partial', 'contraindications': true, 'visit-dates': true, 'diagnosis': 'partial', 'documents': true, 'student-name': true, 'emergency': true }
  };

  const handleSave = () => {
    alert('Permission changes saved successfully');
    setUnsavedChanges(0);
  };

  const renderCell = (role: string, category: string) => {
    const permission = permissions[role]?.[category];

    if (permission === 'locked') {
      return (
        <div className="flex items-center justify-center">
          <div className="relative group">
            <Lock className="w-4 h-4 text-[#64748B]" />
            <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 hidden group-active:block">
              <div className="bg-[#0F172A] text-white text-[10px] px-2 py-1 rounded whitespace-nowrap">
                Required by FERPA
              </div>
            </div>
          </div>
        </div>
      );
    }

    if (permission === true) {
      return (
        <div className="flex items-center justify-center">
          <Check className="w-4 h-4 text-[#10B981]" />
        </div>
      );
    }

    if (permission === false) {
      return (
        <div className="flex items-center justify-center">
          <X className="w-4 h-4 text-[#DC2626]" />
        </div>
      );
    }

    if (permission === 'partial') {
      return (
        <div className="flex items-center justify-center">
          <span className="inline-flex items-center px-1.5 py-0.5 rounded-full text-[9px] font-medium bg-[#FEF3C7] text-[#F59E0B]">
            Partial
          </span>
        </div>
      );
    }

    return null;
  };

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
        <h1 className="text-[17px] font-medium text-[#0F172A] flex-1">
          Permission Matrix
        </h1>
        <button
          onClick={() => setShowGuidance(!showGuidance)}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
        >
          <Info className="w-5 h-5 text-[#2563EB]" />
        </button>
      </header>

      {/* FERPA Notice */}
      <div className="px-4 pt-4">
        <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-lg p-3">
          <div className="flex items-start gap-2">
            <Info className="w-4 h-4 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-[11px] text-[#1E40AF] leading-relaxed">
                ℹ Permissions define the minimum necessary data exposure per role, in compliance with FERPA 34 CFR § 99.31.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Matrix Table */}
      <div className="flex-1 overflow-auto px-4 py-4">
        <div className="inline-block min-w-full">
          <table className="w-full border-collapse">
            <thead>
              <tr>
                <th className="sticky left-0 bg-white z-10 border border-gray-200 p-2 text-left">
                  <div className="text-[11px] font-semibold text-[#0F172A]">Role</div>
                </th>
                {categories.map((cat) => (
                  <th key={cat.id} className="border border-gray-200 p-2 min-w-[64px] bg-[#F8FAFC]">
                    <div className="text-[10px] font-semibold text-[#0F172A] text-center leading-tight">
                      {cat.short}
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {roles.map((role) => (
                <tr key={role.id}>
                  <td className="sticky left-0 bg-white z-10 border border-gray-200 p-2">
                    <div className="text-[11px] font-medium text-[#0F172A] whitespace-nowrap">
                      {role.label}
                    </div>
                  </td>
                  {categories.map((cat) => (
                    <td key={cat.id} className="border border-gray-200 p-2 bg-white">
                      {renderCell(role.id, cat.id)}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Legend */}
      <div className="px-4 pb-4">
        <div className="bg-white rounded-lg border border-gray-200 p-3">
          <div className="text-[11px] font-semibold text-[#0F172A] mb-2">Legend</div>
          <div className="grid grid-cols-2 gap-2 text-[10px]">
            <div className="flex items-center gap-2">
              <Check className="w-3 h-3 text-[#10B981]" />
              <span className="text-[#64748B]">Full access</span>
            </div>
            <div className="flex items-center gap-2">
              <X className="w-3 h-3 text-[#DC2626]" />
              <span className="text-[#64748B]">No access</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="inline-flex items-center px-1.5 py-0.5 rounded-full text-[9px] font-medium bg-[#FEF3C7] text-[#F59E0B]">
                Partial
              </span>
              <span className="text-[#64748B]">Limited</span>
            </div>
            <div className="flex items-center gap-2">
              <Lock className="w-3 h-3 text-[#64748B]" />
              <span className="text-[#64748B]">FERPA locked</span>
            </div>
          </div>
        </div>
      </div>

      {/* Save Changes Bar */}
      {unsavedChanges > 0 && (
        <div className="bg-white border-t border-gray-200 p-4 flex items-center justify-between">
          <span className="text-[13px] text-[#64748B]">
            You have {unsavedChanges} unsaved change{unsavedChanges > 1 ? 's' : ''}
          </span>
          <button
            onClick={handleSave}
            className="h-[40px] px-6 bg-[#2563EB] text-white rounded-lg font-medium text-[14px] active:bg-[#1D4ED8]"
          >
            Save
          </button>
        </div>
      )}
    </div>
  );
}
