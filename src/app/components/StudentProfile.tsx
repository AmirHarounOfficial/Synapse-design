import { ChevronLeft, Phone, Mail, AlertCircle, FileText } from 'lucide-react';

export function StudentProfile() {
  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center gap-3 border-b border-[#E2E8F0]">
        <button className="p-2 -ml-2">
          <ChevronLeft className="w-6 h-6 text-[#0F172A]" />
        </button>
        <h1 className="text-xl font-semibold text-[#0F172A]">Student Profile</h1>
      </div>

      {/* Content */}
      <div className="px-4 pt-6">
        {/* Student Header Card */}
        <div className="bg-[#FFFFFF] rounded-xl p-6 border border-[#E2E8F0] mb-6">
          <div className="flex items-start gap-4 mb-4">
            <div className="w-20 h-20 rounded-full bg-[#2563EB] flex items-center justify-center text-white text-2xl font-semibold">
              ER
            </div>
            <div className="flex-1">
              <h2 className="text-xl font-semibold text-[#0F172A] mb-1">Emma Rodriguez</h2>
              <p className="text-sm text-[#64748B] mb-2">Grade 4 • Student ID: 45892</p>
              <div className="flex items-center gap-1.5 bg-[#10B981] text-white text-xs px-3 py-1.5 rounded-full inline-flex">
                <div className="w-2 h-2 rounded-full bg-white" />
                <span className="font-semibold">Active</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3 pt-4 border-t border-[#E2E8F0]">
            <div>
              <p className="text-xs text-[#64748B] mb-1">Date of Birth</p>
              <p className="text-sm font-semibold text-[#0F172A]">March 15, 2016</p>
            </div>
            <div>
              <p className="text-xs text-[#64748B] mb-1">Age</p>
              <p className="text-sm font-semibold text-[#0F172A]">10 years</p>
            </div>
          </div>
        </div>

        {/* Emergency Contacts */}
        <div className="mb-6">
          <h3 className="font-semibold text-[#0F172A] mb-3">Emergency Contacts</h3>

          <div className="space-y-3">
            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-3">
                <div>
                  <p className="font-semibold text-[#0F172A]">Maria Rodriguez</p>
                  <p className="text-sm text-[#64748B]">Mother • Primary Contact</p>
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center gap-3">
                  <Phone className="w-4 h-4 text-[#64748B]" />
                  <span className="text-sm text-[#0F172A]">(555) 234-5678</span>
                </div>
                <div className="flex items-center gap-3">
                  <Mail className="w-4 h-4 text-[#64748B]" />
                  <span className="text-sm text-[#0F172A]">maria.rodriguez@email.com</span>
                </div>
              </div>
            </div>

            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-3">
                <div>
                  <p className="font-semibold text-[#0F172A]">Carlos Rodriguez</p>
                  <p className="text-sm text-[#64748B]">Father • Secondary Contact</p>
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center gap-3">
                  <Phone className="w-4 h-4 text-[#64748B]" />
                  <span className="text-sm text-[#0F172A]">(555) 234-5679</span>
                </div>
                <div className="flex items-center gap-3">
                  <Mail className="w-4 h-4 text-[#64748B]" />
                  <span className="text-sm text-[#0F172A]">carlos.rodriguez@email.com</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Medical Information */}
        <div className="mb-6">
          <h3 className="font-semibold text-[#0F172A] mb-3">Medical Information</h3>

          <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0] mb-3">
            <div className="flex items-start gap-3 mb-3">
              <AlertCircle className="w-5 h-5 text-[#DC2626] flex-shrink-0" />
              <div>
                <p className="font-semibold text-[#0F172A] mb-1">Allergies</p>
                <p className="text-sm text-[#64748B]">Penicillin, Tree nuts</p>
              </div>
            </div>
          </div>

          <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
            <div className="flex items-start gap-3">
              <FileText className="w-5 h-5 text-[#2563EB] flex-shrink-0" />
              <div>
                <p className="font-semibold text-[#0F172A] mb-1">Current Medications</p>
                <div className="space-y-2 mt-2">
                  <div className="bg-[#F8FAFC] rounded-lg p-3 border border-[#E2E8F0]">
                    <p className="font-semibold text-[#0F172A] text-sm">Adderall XR 10mg</p>
                    <p className="text-xs text-[#64748B] mt-1">Once daily at 8:30 AM</p>
                    <p className="text-xs text-[#64748B]">Prescribed by Dr. Johnson for ADHD</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Medical History */}
        <div className="mb-6">
          <h3 className="font-semibold text-[#0F172A] mb-3">Recent Medical History</h3>

          <div className="space-y-3">
            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-2">
                <p className="font-semibold text-[#0F172A]">Medication Administration</p>
                <span className="text-xs text-[#64748B]">Today, 8:30 AM</span>
              </div>
              <p className="text-sm text-[#64748B]">Adderall XR 10mg administered by Nurse Johnson</p>
            </div>

            <div className="bg-[#FFFFFF] rounded-xl p-4 border border-[#E2E8F0]">
              <div className="flex items-start justify-between mb-2">
                <p className="font-semibold text-[#0F172A]">Annual Physical</p>
                <span className="text-xs text-[#64748B]">May 15, 2026</span>
              </div>
              <p className="text-sm text-[#64748B]">Cleared for all activities by Dr. Smith</p>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3">
          <button className="w-full bg-[#2563EB] text-white rounded-xl h-[52px] font-semibold">
            Administer Medication
          </button>
          <button className="w-full bg-[#FFFFFF] text-[#2563EB] border-2 border-[#2563EB] rounded-xl h-[52px] font-semibold">
            View Full Medical Record
          </button>
        </div>
      </div>
    </div>
  );
}
