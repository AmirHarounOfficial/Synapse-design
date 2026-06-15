import { useNavigate } from 'react-router';
import { ChevronLeft, Search, X, Camera, Image, Check, AlertTriangle } from 'lucide-react';
import { useState } from 'react';

interface Student {
  id: string;
  name: string;
  initials: string;
  grade: string;
}

export function TeacherClinicReferral() {
  const navigate = useNavigate();
  const [isEmergency, setIsEmergency] = useState(false);
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [showResults, setShowResults] = useState(false);
  const [description, setDescription] = useState('');
  const [severity, setSeverity] = useState<'minor' | 'moderate' | 'emergency' | null>(null);
  const [location, setLocation] = useState<string | null>(null);
  const [hasMedia, setHasMedia] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const students: Student[] = [
    { id: '1', name: 'Emma Rodriguez', initials: 'ER', grade: '5th Grade' },
    { id: '2', name: 'Marcus Chen', initials: 'MC', grade: '5th Grade' },
    { id: '3', name: 'Sarah Williams', initials: 'SW', grade: '5th Grade' },
    { id: '4', name: 'Alex Martinez', initials: 'AM', grade: '5th Grade' }
  ];

  const filteredStudents = students.filter(student =>
    student.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const locations = ['Classroom', 'Hallway', 'Cafeteria', 'Field', 'Gym', 'Playground'];

  const canSubmit = selectedStudent && description.trim().length > 0 && severity && location;

  const handleStudentSelect = (student: Student) => {
    setSelectedStudent(student);
    setSearchQuery('');
    setShowResults(false);
  };

  const handleSubmit = () => {
    if (canSubmit) {
      setIsSuccess(true);
      setTimeout(() => {
        navigate('/teacher/home');
      }, 3000);
    }
  };

  if (isSuccess) {
    return (
      <div className="min-h-screen bg-[#F8FAFC] pb-[83px] flex items-center justify-center">
        <div className="text-center px-8">
          <div className="w-16 h-16 bg-[#D1FAE5] rounded-full flex items-center justify-center mx-auto mb-4">
            <Check className="w-8 h-8 text-[#10B981]" strokeWidth={2.5} />
          </div>
          <h2 className="text-[20px] font-medium text-gray-900 mb-2">
            Referral Sent to Clinic
          </h2>
          <p className="text-[14px] text-[#64748B] mb-4">
            {selectedStudent?.name}
          </p>
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#FEF3C7] text-[#92400E] text-[13px] font-medium">
            <div className="w-2 h-2 rounded-full bg-[#F59E0B] animate-pulse" />
            Awaiting nurse response
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[120px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2"
          aria-label="Go back"
        >
          <ChevronLeft className="w-6 h-6 text-gray-900" />
        </button>

        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900">
          Clinic Referral
        </h1>
      </header>

      <div className="px-4 py-4 space-y-6">
        {/* Emergency Toggle */}
        <div
          className={`rounded-xl border p-4 transition-colors ${
            isEmergency
              ? 'bg-[#FEE2E2] border-[#DC2626] border-2'
              : 'bg-white border-gray-200'
          }`}
        >
          <label className="flex items-center justify-between cursor-pointer">
            <div className="flex items-center gap-3">
              {isEmergency && <AlertTriangle className="w-5 h-5 text-[#DC2626]" />}
              <span className={`text-[15px] font-medium ${isEmergency ? 'text-[#DC2626]' : 'text-gray-900'}`}>
                Mark as Emergency
              </span>
            </div>
            <input
              type="checkbox"
              checked={isEmergency}
              onChange={(e) => {
                setIsEmergency(e.target.checked);
                if (e.target.checked) {
                  setSeverity('emergency');
                }
              }}
              className="w-12 h-6 rounded-full appearance-none bg-[#E2E8F0] checked:bg-[#DC2626] relative transition-colors cursor-pointer
                before:content-[''] before:absolute before:w-5 before:h-5 before:rounded-full before:bg-white before:top-0.5 before:left-0.5 before:transition-transform
                checked:before:translate-x-6"
            />
          </label>
          {isEmergency && (
            <p className="text-[12px] text-[#DC2626] mt-2">
              Nurse will be notified immediately
            </p>
          )}
        </div>

        {/* Student Selector */}
        <div>
          <label className="block text-[14px] font-medium text-gray-900 mb-2">
            Select Student <span className="text-[#DC2626]">*</span>
          </label>

          {selectedStudent ? (
            <div className="flex items-center gap-2 bg-white rounded-lg border border-gray-200 p-3">
              <div className="w-8 h-8 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[12px] font-medium flex-shrink-0">
                {selectedStudent.initials}
              </div>
              <div className="flex-1">
                <div className="text-[14px] font-medium text-gray-900">
                  {selectedStudent.name}
                </div>
                <div className="text-[12px] text-[#64748B]">
                  {selectedStudent.grade}
                </div>
              </div>
              <button
                onClick={() => setSelectedStudent(null)}
                className="w-6 h-6 flex items-center justify-center"
                aria-label="Clear selection"
              >
                <X className="w-4 h-4 text-[#64748B]" />
              </button>
            </div>
          ) : (
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value);
                  setShowResults(true);
                }}
                onFocus={() => setShowResults(true)}
                placeholder="Search student name..."
                className="w-full h-12 pl-10 pr-4 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]"
              />

              {showResults && searchQuery && filteredStudents.length > 0 && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-gray-200 rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto">
                  {filteredStudents.map((student) => (
                    <button
                      key={student.id}
                      onClick={() => handleStudentSelect(student)}
                      className="w-full flex items-center gap-3 p-3 hover:bg-[#F8FAFC] border-b border-gray-100 last:border-b-0"
                    >
                      <div className="w-8 h-8 rounded-full bg-[#EFF6FF] flex items-center justify-center text-[#2563EB] text-[12px] font-medium flex-shrink-0">
                        {student.initials}
                      </div>
                      <div className="flex-1 text-left">
                        <div className="text-[14px] font-medium text-gray-900">
                          {student.name}
                        </div>
                        <div className="text-[12px] text-[#64748B]">
                          {student.grade}
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>

        {/* Incident Description */}
        <div>
          <label className="block text-[14px] font-medium text-gray-900 mb-2">
            Incident Description <span className="text-[#DC2626]">*</span>
          </label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Describe what happened..."
            rows={4}
            className="w-full px-4 py-3 rounded-lg border border-[#E2E8F0] bg-white text-[#0F172A] placeholder-[#64748B] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB] resize-none"
          />
        </div>

        {/* Media Attachment */}
        <div>
          <label className="block text-[14px] font-medium text-gray-900 mb-2">
            Photo or Video (Optional)
          </label>
          <div className="flex gap-2">
            <button
              onClick={() => setHasMedia(true)}
              className="flex-1 px-4 py-3 bg-white border border-[#E2E8F0] text-[#64748B] rounded-lg text-[14px] font-medium min-h-[44px] flex items-center justify-center gap-2"
            >
              <Camera className="w-5 h-5" />
              Take Photo
            </button>
            <button
              onClick={() => setHasMedia(true)}
              className="flex-1 px-4 py-3 bg-white border border-[#E2E8F0] text-[#64748B] rounded-lg text-[14px] font-medium min-h-[44px] flex items-center justify-center gap-2"
            >
              <Image className="w-5 h-5" />
              Choose from Gallery
            </button>
          </div>
          {hasMedia && (
            <div className="mt-2 flex items-center gap-2 text-[13px] text-[#10B981]">
              <Check className="w-4 h-4" />
              1 photo attached
            </div>
          )}
        </div>

        {/* Severity */}
        <div>
          <label className="block text-[14px] font-medium text-gray-900 mb-2">
            Severity <span className="text-[#DC2626]">*</span>
          </label>
          <div className="grid grid-cols-3 gap-2">
            <button
              onClick={() => setSeverity('minor')}
              disabled={isEmergency}
              className={`px-4 py-2 rounded-lg text-[14px] font-medium min-h-[44px] transition-colors ${
                severity === 'minor'
                  ? 'bg-[#10B981] text-white'
                  : 'bg-white border border-[#E2E8F0] text-[#64748B]'
              } ${isEmergency ? 'opacity-50 cursor-not-allowed' : ''}`}
            >
              Minor
            </button>
            <button
              onClick={() => setSeverity('moderate')}
              disabled={isEmergency}
              className={`px-4 py-2 rounded-lg text-[14px] font-medium min-h-[44px] transition-colors ${
                severity === 'moderate'
                  ? 'bg-[#F59E0B] text-white'
                  : 'bg-white border border-[#E2E8F0] text-[#64748B]'
              } ${isEmergency ? 'opacity-50 cursor-not-allowed' : ''}`}
            >
              Moderate
            </button>
            <button
              onClick={() => setSeverity('emergency')}
              className={`px-4 py-2 rounded-lg text-[14px] font-medium min-h-[44px] transition-colors ${
                severity === 'emergency'
                  ? 'bg-[#DC2626] text-white'
                  : 'bg-white border border-[#E2E8F0] text-[#64748B]'
              }`}
            >
              Emergency
            </button>
          </div>
        </div>

        {/* Location */}
        <div>
          <label className="block text-[14px] font-medium text-gray-900 mb-2">
            Location <span className="text-[#DC2626]">*</span>
          </label>
          <div className="grid grid-cols-2 gap-2">
            {locations.map((loc) => (
              <button
                key={loc}
                onClick={() => setLocation(loc)}
                className={`px-4 py-2 rounded-lg text-[14px] font-medium min-h-[44px] transition-colors ${
                  location === loc
                    ? 'bg-[#2563EB] text-white'
                    : 'bg-white border border-[#E2E8F0] text-[#64748B]'
                }`}
              >
                {loc}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Submit Button */}
      <div className="fixed bottom-[83px] left-0 right-0 bg-white border-t border-gray-200 p-4">
        <button
          onClick={handleSubmit}
          disabled={!canSubmit}
          className={`w-full px-4 py-3.5 rounded-lg text-[15px] font-medium min-h-[52px] transition-colors ${
            isEmergency && canSubmit
              ? 'bg-[#DC2626] text-white'
              : canSubmit
              ? 'bg-[#2563EB] text-white'
              : 'bg-[#E2E8F0] text-[#94A3B8] cursor-not-allowed'
          }`}
        >
          {isEmergency ? 'Send Emergency Referral' : 'Send to Clinic'}
        </button>
      </div>
    </div>
  );
}
