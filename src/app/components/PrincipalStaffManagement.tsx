import { useNavigate } from 'react-router';
import { Search, Plus } from 'lucide-react';
import { useState } from 'react';

export function PrincipalStaffManagement() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState('all');

  const staffMembers = [
    {
      id: '1',
      firstName: 'Sarah',
      lastName: 'Chen',
      initials: 'SC',
      role: 'Nurse',
      roleColor: 'bg-[#FEE2E2] text-[#DC2626]',
      status: 'active',
      lastLogin: '2 hours ago'
    },
    {
      id: '2',
      firstName: 'Michael',
      lastName: 'Rodriguez',
      initials: 'MR',
      role: 'Teacher',
      roleColor: 'bg-[#DBEAFE] text-[#2563EB]',
      status: 'active',
      lastLogin: '30 min ago'
    },
    {
      id: '3',
      firstName: 'Jennifer',
      lastName: 'Williams',
      initials: 'JW',
      role: 'Secretary',
      roleColor: 'bg-[#CFFAFE] text-[#0891B2]',
      status: 'active',
      lastLogin: '1 hour ago'
    },
    {
      id: '4',
      firstName: 'David',
      lastName: 'Park',
      initials: 'DP',
      role: 'Counselor',
      roleColor: 'bg-[#F3F0FF] text-[#7C3AED]',
      status: 'active',
      lastLogin: '3 hours ago'
    },
    {
      id: '5',
      firstName: 'Maria',
      lastName: 'Garcia',
      initials: 'MG',
      role: 'Cafeteria',
      roleColor: 'bg-[#D1FAE5] text-[#10B981]',
      status: 'active',
      lastLogin: '45 min ago'
    },
    {
      id: '6',
      firstName: 'James',
      lastName: 'Thompson',
      initials: 'JT',
      role: 'Security',
      roleColor: 'bg-[#F1F5F9] text-[#475569]',
      status: 'active',
      lastLogin: '20 min ago'
    },
    {
      id: '7',
      firstName: 'Robert',
      lastName: 'Johnson',
      initials: 'RJ',
      role: 'Driver',
      roleColor: 'bg-[#CCFBF1] text-[#14B8A6]',
      status: 'active',
      lastLogin: '5 hours ago'
    },
    {
      id: '8',
      firstName: 'Emily',
      lastName: 'Davis',
      initials: 'ED',
      role: 'Teacher',
      roleColor: 'bg-[#DBEAFE] text-[#2563EB]',
      status: 'suspended',
      lastLogin: '2 weeks ago'
    }
  ];

  const filters = [
    { id: 'all', label: 'All' },
    { id: 'active', label: 'Active' },
    { id: 'inactive', label: 'Inactive' },
    { id: 'nurse', label: 'Nurse' },
    { id: 'teacher', label: 'Teacher' },
    { id: 'secretary', label: 'Secretary' }
  ];

  const filteredStaff = staffMembers.filter(staff => {
    const matchesSearch = staff.firstName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         staff.lastName.toLowerCase().includes(searchQuery.toLowerCase());

    if (activeFilter === 'all') return matchesSearch;
    if (activeFilter === 'active') return matchesSearch && staff.status === 'active';
    if (activeFilter === 'inactive') return matchesSearch && staff.status === 'suspended';
    return matchesSearch && staff.role.toLowerCase() === activeFilter;
  });

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="flex items-center justify-between px-4 h-14">
          <h1 className="text-[17px] font-medium text-[#0F172A]">
            Staff Management
          </h1>
          <button
            onClick={() => navigate('/principal/add-staff')}
            className="flex items-center gap-1 text-[14px] text-[#2563EB] font-medium"
          >
            <Plus className="w-5 h-5" />
            Add staff
          </button>
        </div>

        {/* Search Bar */}
        <div className="px-4 pb-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
            <input
              type="text"
              placeholder="Search staff..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full h-[44px] pl-10 pr-4 bg-[#F1F5F9] border border-transparent rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:bg-white focus:border-transparent"
            />
          </div>
        </div>

        {/* Filter Chips */}
        <div className="flex overflow-x-auto px-4 pb-3 gap-2">
          {filters.map((filter) => (
            <button
              key={filter.id}
              onClick={() => setActiveFilter(filter.id)}
              className={`px-3 py-1.5 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors ${
                activeFilter === filter.id
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-[#F1F5F9] text-[#64748B] active:bg-[#E2E8F0]'
              }`}
            >
              {filter.label}
            </button>
          ))}
        </div>
      </header>

      <div className="px-4 py-4">
        <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
          {filteredStaff.map((staff) => (
            <button
              key={staff.id}
              onClick={() => navigate(`/principal/edit-staff/${staff.id}`)}
              className={`w-full p-4 flex items-center gap-3 text-left active:bg-gray-50 ${
                staff.status === 'suspended' ? 'opacity-60' : ''
              }`}
            >
              <div className={`w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0 ${
                staff.status === 'suspended' ? 'grayscale' : ''
              }`}>
                <span className="text-[14px] font-medium text-[#2563EB]">
                  {staff.initials}
                </span>
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-[15px] font-medium text-[#0F172A] mb-1">
                  {staff.firstName} {staff.lastName}
                </div>
                <div className="flex items-center gap-2 flex-wrap">
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium ${staff.roleColor}`}>
                    {staff.role}
                  </span>
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium ${
                    staff.status === 'active'
                      ? 'bg-[#D1FAE5] text-[#10B981]'
                      : 'bg-[#FEE2E2] text-[#DC2626]'
                  }`}>
                    {staff.status === 'active' ? 'Active' : 'Suspended'}
                  </span>
                </div>
                <div className="text-[12px] text-[#64748B] mt-1">
                  Last login: {staff.lastLogin}
                </div>
              </div>
              <svg className="w-5 h-5 text-[#64748B] flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </button>
          ))}
        </div>
      </div>

      {/* FAB */}
      <button
        onClick={() => navigate('/principal/add-staff')}
        className="fixed bottom-[100px] right-4 w-14 h-14 bg-[#2563EB] text-white rounded-full shadow-lg flex items-center justify-center active:bg-[#1D4ED8]"
      >
        <Plus className="w-6 h-6" />
      </button>
    </div>
  );
}
