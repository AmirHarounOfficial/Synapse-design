import { ChevronLeft, Camera, AlertTriangle, ChevronDown, Search } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function NewClinicVisit() {
  const navigate = useNavigate();
  const [visitType, setVisitType] = useState<'routine' | 'emergency'>('routine');
  const [selectedReason, setSelectedReason] = useState('');
  const [showVitals, setShowVitals] = useState(false);
  const [notifyParent, setNotifyParent] = useState(true);
  const [clinicalNotes, setClinicalNotes] = useState('');
  const [selectedStudent, setSelectedStudent] = useState('Maya Chen');

  const reasonCategories = [
    'Injury',
    'Illness',
    'Medication',
    'Checkup',
    'Mental Health',
    'Other'
  ];

  const isFormValid = selectedStudent && selectedReason && clinicalNotes.trim().length > 0;

  const handleSubmit = () => {
    if (visitType === 'emergency') {
      navigate('/nurse/clinic/emergency-photo');
    } else {
      // Submit routine visit
      navigate('/nurse/clinic');
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className={`h-[56px] px-4 flex items-center border-b border-[#E2E8F0] ${
        visitType === 'emergency' ? 'bg-[#DC2626]' : 'bg-[#FFFFFF]'
      }`}>
        <button
          onClick={() => navigate('/nurse/clinic')}
          className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
        >
          <ChevronLeft className={`w-6 h-6 ${visitType === 'emergency' ? 'text-white' : 'text-[#0F172A]'}`} />
        </button>
        <h1 className={`flex-1 text-[17px] font-medium ${visitType === 'emergency' ? 'text-white' : 'text-[#0F172A]'}`} style={{ fontWeight: 500 }}>
          New Clinic Visit
        </h1>
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Student Selector */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
            Student *
          </label>
          <div className="relative">
            <div className="flex items-center gap-3 w-full h-[52px] px-4 pr-10 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF]">
              <div className="w-8 h-8 rounded-full bg-[#2563EB] flex items-center justify-center text-white text-sm font-semibold">
                MC
              </div>
              <div className="flex-1">
                <p className="text-[14px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
                  Maya Chen
                </p>
                <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
                  Grade 5 · Room 204
                </p>
              </div>
            </div>
            <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B] pointer-events-none" />
          </div>
        </div>

        {/* Visit Type */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="block text-[13px] font-medium text-[#64748B] mb-3" style={{ fontWeight: 500 }}>
            Visit Type *
          </label>
          <div className="flex gap-2">
            <button
              onClick={() => setVisitType('routine')}
              className={`flex-1 h-[44px] rounded-lg font-semibold transition-colors ${
                visitType === 'routine'
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
              }`}
              style={{ fontWeight: 600 }}
            >
              Routine
            </button>
            <button
              onClick={() => setVisitType('emergency')}
              className={`flex-1 h-[44px] rounded-lg font-semibold transition-colors ${
                visitType === 'emergency'
                  ? 'bg-[#DC2626] text-white'
                  : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
              }`}
              style={{ fontWeight: 600 }}
            >
              Emergency
            </button>
          </div>
        </div>

        {/* Reason Category */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="block text-[13px] font-medium text-[#64748B] mb-3" style={{ fontWeight: 500 }}>
            Reason Category *
          </label>
          <div className="grid grid-cols-3 gap-2">
            {reasonCategories.map((reason) => (
              <button
                key={reason}
                onClick={() => setSelectedReason(reason)}
                className={`h-[44px] px-3 rounded-lg font-semibold text-[13px] transition-colors ${
                  selectedReason === reason
                    ? 'bg-[#2563EB] text-white'
                    : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
                }`}
                style={{ fontWeight: 600 }}
              >
                {reason}
              </button>
            ))}
          </div>
        </div>

        {/* Vital Signs */}
        <div className="bg-[#FFFFFF] rounded-xl border border-[#E2E8F0] overflow-hidden">
          <button
            onClick={() => setShowVitals(!showVitals)}
            className="w-full p-4 flex items-center justify-between"
          >
            <span className="text-[14px] font-semibold text-[#0F172A]" style={{ fontWeight: 600 }}>
              Vital Signs (Optional)
            </span>
            <ChevronDown className={`w-5 h-5 text-[#64748B] transition-transform ${showVitals ? 'rotate-180' : ''}`} />
          </button>

          {showVitals && (
            <div className="px-4 pb-4 space-y-3 border-t border-[#E2E8F0] pt-4">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[12px] font-medium text-[#64748B] mb-1" style={{ fontWeight: 500 }}>
                    Temperature (°F)
                  </label>
                  <input
                    type="number"
                    step="0.1"
                    placeholder="98.6"
                    className="w-full h-[44px] px-3 rounded-lg border border-[#E2E8F0] text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
                    style={{ fontWeight: 400 }}
                  />
                </div>
                <div>
                  <label className="block text-[12px] font-medium text-[#64748B] mb-1" style={{ fontWeight: 500 }}>
                    Heart Rate (bpm)
                  </label>
                  <input
                    type="number"
                    placeholder="72"
                    className="w-full h-[44px] px-3 rounded-lg border border-[#E2E8F0] text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
                    style={{ fontWeight: 400 }}
                  />
                </div>
              </div>
              <div>
                <label className="block text-[12px] font-medium text-[#64748B] mb-1" style={{ fontWeight: 500 }}>
                  Blood Pressure (mmHg)
                </label>
                <input
                  type="text"
                  placeholder="120/80"
                  className="w-full h-[44px] px-3 rounded-lg border border-[#E2E8F0] text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
                  style={{ fontWeight: 400 }}
                />
              </div>
            </div>
          )}
        </div>

        {/* Clinical Notes */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
            Clinical Notes *
          </label>
          <textarea
            value={clinicalNotes}
            onChange={(e) => setClinicalNotes(e.target.value)}
            placeholder="Notes (will be locked after save)"
            rows={5}
            className="w-full px-4 py-3 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB] resize-none"
            style={{ fontWeight: 400 }}
          />
          <p className="text-[12px] text-[#F59E0B] mt-2" style={{ fontWeight: 400 }}>
            All clinical notes are permanently locked after saving
          </p>
        </div>

        {/* Incident Attachment */}
        <button className="w-full bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] flex items-center gap-3">
          <Camera className="w-6 h-6 text-[#64748B]" />
          <div className="flex-1 text-left">
            <p className="text-[14px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
              Add photo/video
            </p>
            <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
              Optional
            </p>
          </div>
        </button>

        {/* Immutability Warning */}
        <div className="bg-[#FFFBEB] border-l-4 border-[#F59E0B] rounded-xl p-4">
          <div className="flex gap-3">
            <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
            <p className="text-[13px] text-[#92400E]" style={{ fontWeight: 400 }}>
              This record cannot be edited after saving. A corrective note can be appended.
            </p>
          </div>
        </div>

        {/* Parent Notification */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={notifyParent}
              onChange={(e) => setNotifyParent(e.target.checked)}
              className="w-5 h-5 rounded border-2 border-[#E2E8F0] text-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
            />
            <div className="flex-1">
              <p className="text-[14px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
                Notify parent immediately
              </p>
              <p className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
                Send clinic visit notification via SMS and app
              </p>
            </div>
          </label>
        </div>

        {/* Submit Button */}
        <button
          onClick={handleSubmit}
          disabled={!isFormValid}
          className="w-full h-[52px] bg-[#10B981] text-white rounded-xl font-semibold disabled:opacity-40"
          style={{ fontWeight: 600 }}
        >
          Log Visit
        </button>
      </div>
    </div>
  );
}
