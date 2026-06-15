import { ArrowLeft, Info, Search, X } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function PrincipalAfterHoursAccess() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStaff, setSelectedStaff] = useState<string | null>(null);
  const [duration, setDuration] = useState('tonight');
  const [reason, setReason] = useState('');

  const activeOverrides = [
    {
      id: '1',
      staffName: 'Sarah Chen',
      role: 'School Nurse',
      expiry: 'Tonight 11:59 PM'
    },
    {
      id: '2',
      staffName: 'Michael Rodriguez',
      role: 'Teacher',
      expiry: 'Sunday 11:59 PM'
    }
  ];

  const staffMembers = [
    { id: '1', name: 'Sarah Chen', role: 'School Nurse' },
    { id: '2', name: 'Jennifer Williams', role: 'Secretary' },
    { id: '3', name: 'David Park', role: 'Counselor' }
  ];

  const filteredStaff = staffMembers.filter(s =>
    s.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleRevoke = (overrideId: string) => {
    if (window.confirm('Revoke this access override?')) {
      alert('Access override revoked');
    }
  };

  const handleGrant = () => {
    if (selectedStaff && reason) {
      alert('Access override granted. This action has been logged in the audit trail.');
      setSelectedStaff(null);
      setSearchQuery('');
      setReason('');
    }
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
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          After-Hours Access
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Info Box */}
        <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-lg p-3">
          <div className="flex items-start gap-2">
            <Info className="w-4 h-4 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <p className="text-[12px] text-[#1E40AF] leading-relaxed">
              By default, all staff access is blocked outside school hours (7:30 AM – 5:00 PM Mon–Fri). Grant exceptions below.
            </p>
          </div>
        </div>

        {/* Active Overrides */}
        <div>
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Active Overrides
          </h2>
          {activeOverrides.length > 0 ? (
            <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
              {activeOverrides.map((override) => (
                <div key={override.id} className="p-4 flex items-center justify-between">
                  <div className="flex-1">
                    <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                      {override.staffName}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      {override.role} • Expires {override.expiry}
                    </div>
                  </div>
                  <button
                    onClick={() => handleRevoke(override.id)}
                    className="text-[13px] text-[#DC2626] font-medium"
                  >
                    Revoke
                  </button>
                </div>
              ))}
            </div>
          ) : (
            <div className="bg-white rounded-xl border border-gray-200 p-4 text-center text-[13px] text-[#64748B]">
              No active overrides
            </div>
          )}
        </div>

        {/* Grant Override Form */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Grant Override
          </h2>

          {/* Staff Search */}
          <div className="mb-3">
            <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
              Staff Member
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
              <input
                type="text"
                placeholder="Search staff..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full h-[44px] pl-10 pr-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>

            {searchQuery && (
              <div className="mt-2 bg-white border border-gray-200 rounded-lg divide-y divide-gray-100 max-h-[160px] overflow-y-auto">
                {filteredStaff.map((staff) => (
                  <button
                    key={staff.id}
                    onClick={() => {
                      setSelectedStaff(staff.id);
                      setSearchQuery(staff.name);
                    }}
                    className="w-full p-3 flex items-center justify-between text-left active:bg-gray-50"
                  >
                    <div>
                      <div className="text-[14px] font-medium text-[#0F172A]">
                        {staff.name}
                      </div>
                      <div className="text-[12px] text-[#64748B]">
                        {staff.role}
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Duration */}
          <div className="mb-3">
            <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
              Duration
            </label>
            <div className="grid grid-cols-3 gap-2">
              {[
                { id: 'tonight', label: 'Tonight only' },
                { id: 'weekend', label: 'This weekend' },
                { id: 'custom', label: 'Custom' }
              ].map((option) => (
                <button
                  key={option.id}
                  onClick={() => setDuration(option.id)}
                  className={`h-[44px] rounded-lg font-medium text-[13px] transition-colors border ${
                    duration === option.id
                      ? 'bg-[#2563EB] text-white border-[#2563EB]'
                      : 'bg-white text-[#0F172A] border-gray-300 active:bg-gray-50'
                  }`}
                >
                  {option.label}
                </button>
              ))}
            </div>
          </div>

          {/* Reason */}
          <div className="mb-3">
            <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
              Reason (required)
            </label>
            <textarea
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder="Why is after-hours access needed?"
              className="w-full h-[80px] p-3 bg-white border border-gray-300 rounded-lg text-[14px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent resize-none"
            />
          </div>

          <button
            onClick={handleGrant}
            disabled={!selectedStaff || !reason}
            className={`w-full h-[48px] rounded-lg font-medium text-[15px] transition-colors ${
              selectedStaff && reason
                ? 'bg-[#2563EB] text-white active:bg-[#1D4ED8]'
                : 'bg-gray-200 text-gray-400 cursor-not-allowed'
            }`}
          >
            Grant Access
          </button>
        </div>
      </div>
    </div>
  );
}
