import { ChevronLeft, Camera, AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function EmergencyPhotoUpload() {
  const navigate = useNavigate();
  const [photoCapture, setPhotoCapture] = useState<'idle' | 'capturing' | 'captured'>('idle');
  const [selectedLocation, setSelectedLocation] = useState('');
  const [incidentDescription, setIncidentDescription] = useState('');
  const [severity, setSeverity] = useState<'minor' | 'moderate' | 'severe' | ''>('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const locations = ['Classroom', 'Hallway', 'Cafeteria', 'Playground', 'Gym', 'Other'];

  const handleCapture = () => {
    setPhotoCapture('capturing');
    setTimeout(() => {
      setPhotoCapture('captured');
    }, 1000);
  };

  const handleSubmit = () => {
    setIsSubmitting(true);
    // Simulate sending
    setTimeout(() => {
      navigate('/nurse/clinic/emergency-consent');
    }, 2000);
  };

  const isFormValid = photoCapture === 'captured' && selectedLocation && incidentDescription.trim().length > 0 && severity;

  const getSeverityStyle = (level: string) => {
    switch (level) {
      case 'minor':
        return 'bg-[#D1FAE5] text-[#065F46] border-[#10B981]';
      case 'moderate':
        return 'bg-[#FEF3C7] text-[#92400E] border-[#F59E0B]';
      case 'severe':
        return 'bg-[#FEE2E2] text-[#991B1B] border-[#DC2626]';
      default:
        return 'bg-[#F8FAFC] text-[#64748B] border-[#E2E8F0]';
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#DC2626] px-4 flex items-center border-b border-[#B91C1C]">
        <button
          onClick={() => navigate('/nurse/clinic')}
          className="p-2 -ml-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
        >
          <ChevronLeft className="w-6 h-6 text-white" />
        </button>
        <h1 className="flex-1 text-[17px] font-medium text-white" style={{ fontWeight: 500 }}>
          Emergency Report
        </h1>
      </div>

      {/* Emergency Banner */}
      <div className="bg-[#DC2626] px-4 py-4 border-b border-[#B91C1C]">
        <p className="text-[16px] font-semibold text-white text-center" style={{ fontWeight: 600 }}>
          🚨 Emergency Visit in Progress
        </p>
        <p className="text-[14px] text-white/90 text-center mt-1" style={{ fontWeight: 400 }}>
          Maya Chen · Grade 5
        </p>
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Photo/Video Section */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="block text-[13px] font-medium text-[#64748B] mb-3" style={{ fontWeight: 500 }}>
            Incident Photo/Video *
          </label>

          <div className="relative w-full h-[200px] bg-[#1F2937] rounded-xl flex items-center justify-center overflow-hidden mb-3">
            {photoCapture === 'idle' && (
              <button
                onClick={handleCapture}
                className="flex flex-col items-center gap-2"
              >
                <Camera className="w-12 h-12 text-[#64748B]" />
                <span className="text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
                  Tap to capture
                </span>
              </button>
            )}

            {photoCapture === 'capturing' && (
              <div className="text-white text-center">
                <div className="w-12 h-12 border-4 border-white/30 border-t-white rounded-full animate-spin mx-auto mb-3" />
                <p className="text-sm" style={{ fontWeight: 500 }}>Capturing...</p>
              </div>
            )}

            {photoCapture === 'captured' && (
              <div className="w-full h-full bg-[#374151] flex items-center justify-center">
                <Camera className="w-16 h-16 text-[#9CA3AF]" />
              </div>
            )}
          </div>

          {photoCapture === 'captured' && (
            <button
              onClick={() => setPhotoCapture('idle')}
              className="w-full h-[44px] bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0] rounded-lg font-semibold"
              style={{ fontWeight: 600 }}
            >
              Retake
            </button>
          )}
        </div>

        {/* Location */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="block text-[13px] font-medium text-[#64748B] mb-3" style={{ fontWeight: 500 }}>
            Student Location *
          </label>
          <div className="flex flex-wrap gap-2">
            {locations.map((location) => (
              <button
                key={location}
                onClick={() => setSelectedLocation(location)}
                className={`px-4 py-2 rounded-full text-[13px] font-semibold transition-colors ${
                  selectedLocation === location
                    ? 'bg-[#2563EB] text-white'
                    : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
                }`}
                style={{ fontWeight: 600 }}
              >
                {location}
              </button>
            ))}
          </div>
        </div>

        {/* Description */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="block text-[13px] font-medium text-[#64748B] mb-2" style={{ fontWeight: 500 }}>
            Incident Description *
          </label>
          <textarea
            value={incidentDescription}
            onChange={(e) => setIncidentDescription(e.target.value)}
            placeholder="Describe the incident in detail..."
            rows={5}
            className="w-full px-4 py-3 rounded-lg border border-[#E2E8F0] bg-[#FFFFFF] text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB] resize-none"
            style={{ fontWeight: 400 }}
          />
        </div>

        {/* Severity */}
        <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
          <label className="block text-[13px] font-medium text-[#64748B] mb-3" style={{ fontWeight: 500 }}>
            Severity Assessment *
          </label>
          <div className="space-y-2">
            {[
              { level: 'minor', label: 'Minor', description: 'No immediate medical attention needed' },
              { level: 'moderate', label: 'Moderate', description: 'May require medical evaluation' },
              { level: 'severe', label: 'Severe', description: 'Requires immediate medical attention' }
            ].map((option) => (
              <button
                key={option.level}
                onClick={() => setSeverity(option.level as any)}
                className={`w-full p-4 rounded-lg border-2 text-left transition-all ${
                  severity === option.level
                    ? getSeverityStyle(option.level)
                    : 'border-[#E2E8F0] bg-[#FFFFFF]'
                }`}
              >
                <p className="text-[14px] font-semibold" style={{ fontWeight: 600 }}>
                  {option.label}
                </p>
                <p className={`text-[12px] mt-1 ${
                  severity === option.level ? '' : 'text-[#64748B]'
                }`} style={{ fontWeight: 400 }}>
                  {option.description}
                </p>
              </button>
            ))}
          </div>
        </div>

        {/* Submit Button */}
        <button
          onClick={handleSubmit}
          disabled={!isFormValid || isSubmitting}
          className="w-full h-[52px] bg-[#DC2626] text-white rounded-xl font-semibold disabled:opacity-40 flex items-center justify-center gap-2"
          style={{ fontWeight: 600 }}
        >
          {isSubmitting ? (
            <>
              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              Sending to school administration and parent...
            </>
          ) : (
            <>
              <AlertTriangle className="w-5 h-5" />
              Send Emergency Report
            </>
          )}
        </button>
      </div>
    </div>
  );
}
