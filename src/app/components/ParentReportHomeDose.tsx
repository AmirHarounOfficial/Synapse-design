import { useState } from 'react';
import { useNavigate } from 'react-router';
import { X, AlertTriangle, CheckCircle } from 'lucide-react';

export function ParentReportHomeDose() {
  const navigate = useNavigate();
  const [selectedMedication, setSelectedMedication] = useState('');
  const [selectedTime, setSelectedTime] = useState('');
  const [note, setNote] = useState('');
  const [showConfirmation, setShowConfirmation] = useState(false);

  const medications = [
    { id: '1', name: 'Ritalin 10mg', nextSchoolDose: '10:30 AM' },
    { id: '2', name: 'Albuterol Inhaler', nextSchoolDose: 'As needed' }
  ];

  const selectedMed = medications.find(m => m.id === selectedMedication);

  const handleSubmit = () => {
    if (selectedMedication && selectedTime) {
      setShowConfirmation(true);
    }
  };

  const handleDone = () => {
    navigate('/parent/app/medications');
  };

  if (showConfirmation) {
    return (
      <div className="fixed inset-0 z-50 flex items-end bg-black/50">
        <div className="bg-white rounded-t-3xl p-6 w-full">
          <div className="w-16 h-16 rounded-full bg-[#D1FAE5] flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-8 h-8 text-[#10B981]" />
          </div>

          <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
            Home Dose Reported
          </h3>
          <p className="text-[14px] text-[#64748B] mb-6 text-center">
            School nurse has been notified. Today's school dose schedule has been adjusted automatically.
          </p>

          <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4 mb-6">
            <div className="flex justify-between mb-2">
              <span className="text-[13px] text-[#64748B]">Medication</span>
              <span className="text-[13px] font-medium text-gray-900">
                {selectedMed?.name}
              </span>
            </div>
            <div className="flex justify-between mb-2">
              <span className="text-[13px] text-[#64748B]">Home dose time</span>
              <span className="text-[13px] font-medium text-gray-900">{selectedTime}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-[13px] text-[#64748B]">Reported at</span>
              <span className="text-[13px] font-medium text-gray-900">
                {new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}
              </span>
            </div>
          </div>

          <button
            onClick={handleDone}
            className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold"
          >
            Done
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end bg-black/50">
      <div className="bg-white rounded-t-3xl w-full max-h-[90vh] overflow-y-auto">
        {/* Handle */}
        <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mt-3 mb-4" />

        <div className="px-6 pb-6">
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-[17px] font-semibold text-gray-900">
              Report home dose timing
            </h2>
            <button
              onClick={() => navigate(-1)}
              className="w-8 h-8 -mr-2 flex items-center justify-center"
            >
              <X className="w-6 h-6 text-gray-900" />
            </button>
          </div>

          {/* Medication Picker */}
          <div className="mb-4">
            <label className="block text-[13px] font-medium text-gray-900 mb-2">
              Medication
            </label>
            <select
              value={selectedMedication}
              onChange={(e) => setSelectedMedication(e.target.value)}
              className="w-full min-h-[48px] px-4 border border-gray-200 rounded-lg text-[15px] focus:outline-none focus:border-[#2563EB]"
            >
              <option value="">Select medication</option>
              {medications.map((med) => (
                <option key={med.id} value={med.id}>
                  {med.name}
                </option>
              ))}
            </select>
          </div>

          {/* Time Picker */}
          <div className="mb-4">
            <label className="block text-[13px] font-medium text-gray-900 mb-2">
              What time was the dose given?
            </label>
            <input
              type="time"
              value={selectedTime}
              onChange={(e) => setSelectedTime(e.target.value)}
              className="w-full min-h-[48px] px-4 border border-gray-200 rounded-lg text-[15px] focus:outline-none focus:border-[#2563EB]"
            />
          </div>

          {/* Optional Note */}
          <div className="mb-4">
            <label className="block text-[13px] font-medium text-gray-900 mb-2">
              Note (optional)
            </label>
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              placeholder="Add any additional context..."
              rows={3}
              className="w-full px-4 py-3 border border-gray-200 rounded-lg text-[15px] focus:outline-none focus:border-[#2563EB] resize-none"
            />
          </div>

          {/* Conflict Preview */}
          {selectedMedication && selectedTime && selectedMed && (
            <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4 mb-4">
              <div className="flex items-start gap-3">
                <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
                <div>
                  <div className="text-[13px] font-semibold text-[#92400E] mb-1">
                    Schedule Impact
                  </div>
                  <p className="text-[12px] text-[#92400E] leading-relaxed">
                    Home dose at {selectedTime} will adjust today's school dose from {selectedMed.nextSchoolDose} to maintain proper medication spacing.
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Info */}
          <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-3 mb-6">
            <p className="text-[12px] text-[#64748B] leading-relaxed">
              This report helps the school nurse maintain accurate medication timing and prevent double-dosing.
            </p>
          </div>

          {/* Submit Button */}
          <button
            onClick={handleSubmit}
            disabled={!selectedMedication || !selectedTime}
            className="w-full min-h-[52px] px-4 py-3.5 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold disabled:opacity-40 disabled:cursor-not-allowed"
          >
            Submit Report
          </button>
        </div>
      </div>
    </div>
  );
}
