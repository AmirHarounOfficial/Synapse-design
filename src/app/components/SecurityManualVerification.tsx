import { useNavigate } from 'react-router';
import { ArrowLeft, Search, Check, X } from 'lucide-react';
import { useState } from 'react';

interface Student {
  id: string;
  name: string;
  grade: string;
  authorizedPerson: {
    name: string;
    relationship: string;
    initials: string;
  };
}

export function SecurityManualVerification() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [verificationChoice, setVerificationChoice] = useState<'match' | 'no-match' | null>(null);

  const students: Student[] = [
    {
      id: '1',
      name: 'Maya Chen',
      grade: '3rd Grade',
      authorizedPerson: {
        name: 'Dr. Jennifer Chen',
        relationship: 'Mother',
        initials: 'JC'
      }
    },
    {
      id: '2',
      name: 'Lucas Martinez',
      grade: '5th Grade',
      authorizedPerson: {
        name: 'Carlos Martinez',
        relationship: 'Father',
        initials: 'CM'
      }
    },
    {
      id: '3',
      name: 'Sophia Williams',
      grade: '2nd Grade',
      authorizedPerson: {
        name: 'Emma Williams',
        relationship: 'Guardian',
        initials: 'EW'
      }
    }
  ];

  const filteredStudents = students.filter(s =>
    s.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleMatchConfirm = () => {
    setVerificationChoice('match');
    setShowConfirmation(true);
  };

  const handleNoMatchConfirm = () => {
    setVerificationChoice('no-match');
    setShowConfirmation(true);
  };

  const handleFinalConfirm = () => {
    if (verificationChoice === 'match') {
      navigate('/security/authorized-confirmation');
    } else {
      // In real app, would log the denial and notify administration
      navigate('/security/pickups');
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200 relative">
        <button
          onClick={() => navigate('/security/scanner')}
          className="p-2 -ml-2 min-h-[44px] min-w-[44px] flex items-center justify-center"
        >
          <ArrowLeft className="w-6 h-6 text-gray-900" />
        </button>
        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900">
          Manual Verification
        </h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Search Student */}
        {!selectedStudent && (
          <>
            <div className="bg-white rounded-xl border border-gray-200 p-4">
              <label className="text-[13px] font-medium text-[#64748B] mb-2 block">
                SEARCH FOR STUDENT
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Type student name..."
                  className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg text-[15px] min-h-[52px] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                />
              </div>
            </div>

            {/* Search Results */}
            {searchQuery && (
              <div className="space-y-2">
                <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide">
                  RESULTS ({filteredStudents.length})
                </h2>
                {filteredStudents.map((student) => (
                  <button
                    key={student.id}
                    onClick={() => setSelectedStudent(student)}
                    className="w-full bg-white rounded-xl border border-gray-200 p-4 text-left"
                  >
                    <div className="text-[16px] font-medium text-gray-900 mb-1">
                      {student.name}
                    </div>
                    <div className="text-[13px] text-[#64748B]">
                      {student.grade}
                    </div>
                  </button>
                ))}
                {filteredStudents.length === 0 && (
                  <div className="bg-white rounded-xl border border-gray-200 p-4 text-center">
                    <p className="text-[14px] text-[#64748B]">
                      No students found matching "{searchQuery}"
                    </p>
                  </div>
                )}
              </div>
            )}
          </>
        )}

        {/* Verification Screen */}
        {selectedStudent && (
          <>
            {/* Info Banner */}
            <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-xl p-3">
              <p className="text-[13px] text-[#1E40AF] leading-relaxed">
                Compare the person's physical ID to the information shown below. Both name and photo must match.
              </p>
            </div>

            {/* Student Info */}
            <div className="bg-white rounded-xl border border-gray-200 p-4">
              <div className="text-[12px] font-medium text-[#64748B] mb-2">
                STUDENT
              </div>
              <div className="text-[17px] font-semibold text-gray-900 mb-1">
                {selectedStudent.name}
              </div>
              <div className="text-[14px] text-[#64748B]">
                {selectedStudent.grade}
              </div>
            </div>

            {/* Authorized Person */}
            <div className="bg-white rounded-xl border-2 border-[#2563EB] p-4">
              <div className="text-[12px] font-medium text-[#64748B] mb-3">
                AUTHORIZED PICKUP PERSON
              </div>
              
              <div className="flex items-center gap-4 mb-4">
                <div className="w-20 h-20 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                  <span className="text-[24px] font-semibold text-[#2563EB]">
                    {selectedStudent.authorizedPerson.initials}
                  </span>
                </div>
                <div className="flex-1">
                  <div className="text-[17px] font-semibold text-gray-900 mb-1">
                    {selectedStudent.authorizedPerson.name}
                  </div>
                  <div className="text-[14px] text-[#64748B]">
                    {selectedStudent.authorizedPerson.relationship}
                  </div>
                </div>
              </div>

              <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-lg p-3">
                <p className="text-[12px] text-[#92400E] leading-relaxed">
                  <strong className="font-semibold">Verify:</strong> Does the person's government-issued ID match the name above? Do they appear to match the photo on file?
                </p>
              </div>
            </div>

            {/* Verification Buttons */}
            <div className="space-y-3">
              <button
                onClick={handleMatchConfirm}
                className="w-full px-4 py-4 bg-[#10B981] text-white rounded-lg text-[17px] font-semibold min-h-[52px] flex items-center justify-center gap-2"
              >
                <Check className="w-6 h-6" />
                ID Matches ✓
              </button>
              <button
                onClick={handleNoMatchConfirm}
                className="w-full px-4 py-4 bg-[#DC2626] text-white rounded-lg text-[17px] font-semibold min-h-[52px] flex items-center justify-center gap-2"
              >
                <X className="w-6 h-6" />
                ID Does Not Match ✗
              </button>
            </div>

            <button
              onClick={() => setSelectedStudent(null)}
              className="w-full text-[#2563EB] text-[15px] font-medium py-3 min-h-[44px]"
            >
              Search Different Student
            </button>
          </>
        )}
      </div>

      {/* Confirmation Dialog */}
      {showConfirmation && selectedStudent && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setShowConfirmation(false)}
          />
          <div className="relative bg-white rounded-2xl p-6 max-w-sm w-full">
            {verificationChoice === 'match' ? (
              <>
                <div className="w-16 h-16 rounded-full bg-[#D1FAE5] flex items-center justify-center mx-auto mb-4">
                  <Check className="w-8 h-8 text-[#10B981]" />
                </div>
                <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
                  Confirm Student Release
                </h3>
                <p className="text-[14px] text-[#64748B] mb-6 text-center">
                  Release {selectedStudent.name} to {selectedStudent.authorizedPerson.name}?
                </p>
                <p className="text-[12px] text-[#64748B] mb-6 text-center bg-[#F8FAFC] rounded-lg p-3">
                  This action will be logged with your security guard ID and timestamp.
                </p>
              </>
            ) : (
              <>
                <div className="w-16 h-16 rounded-full bg-[#FEE2E2] flex items-center justify-center mx-auto mb-4">
                  <X className="w-8 h-8 text-[#DC2626]" />
                </div>
                <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
                  Deny Pickup Request
                </h3>
                <p className="text-[14px] text-[#64748B] mb-6 text-center">
                  This will log a denied pickup attempt and notify administration immediately.
                </p>
              </>
            )}

            <div className="flex gap-3">
              <button
                onClick={() => setShowConfirmation(false)}
                className="flex-1 px-4 py-3.5 bg-white text-gray-900 border border-gray-200 rounded-lg text-[15px] font-medium min-h-[52px]"
              >
                Cancel
              </button>
              <button
                onClick={handleFinalConfirm}
                className={`flex-1 px-4 py-3.5 text-white rounded-lg text-[15px] font-medium min-h-[52px] ${
                  verificationChoice === 'match' ? 'bg-[#10B981]' : 'bg-[#DC2626]'
                }`}
              >
                Confirm
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
