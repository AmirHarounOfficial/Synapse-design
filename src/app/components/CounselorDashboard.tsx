import { useNavigate } from 'react-router';
import { Bell, Users, Tag, FileText, Plus } from 'lucide-react';

export function CounselorDashboard() {
  const navigate = useNavigate();

  const stats = [
    { label: 'Active cases', value: '12', icon: Users, color: 'text-[#7C3AED]', bg: 'bg-[#F3F0FF]' },
    { label: 'Tagged today', value: '8', icon: Tag, color: 'text-[#10B981]', bg: 'bg-[#D1FAE5]' },
    { label: 'Pending reports', value: '3', icon: FileText, color: 'text-[#F59E0B]', bg: 'bg-[#FEF3C7]' }
  ];

  const recentTags = [
    {
      id: '1',
      studentName: 'Maya Thompson',
      tag: 'Headache',
      room: 'Room 204',
      time: '10:45 AM',
      tagColor: 'bg-[#F3F0FF] text-[#7C3AED]'
    },
    {
      id: '2',
      studentName: 'Ethan Williams',
      tag: 'Anxiety / tension',
      room: 'Gymnasium',
      time: '10:32 AM',
      tagColor: 'bg-[#F3F0FF] text-[#7C3AED]'
    },
    {
      id: '3',
      studentName: 'Sophia Martinez',
      tag: 'Sensory overload',
      room: 'Room 301',
      time: '9:58 AM',
      tagColor: 'bg-[#F3F0FF] text-[#7C3AED]'
    },
    {
      id: '4',
      studentName: 'Liam Chen',
      tag: 'Difficulty focusing',
      room: 'Library',
      time: '9:23 AM',
      tagColor: 'bg-[#F3F0FF] text-[#7C3AED]'
    },
    {
      id: '5',
      studentName: 'Olivia Brown',
      tag: 'Low mood',
      room: 'Room 102',
      time: '8:47 AM',
      tagColor: 'bg-[#F3F0FF] text-[#7C3AED]'
    }
  ];

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Student Wellbeing
        </h1>
        <button className="w-10 h-10 -mr-2 flex items-center justify-center relative">
          <Bell className="w-6 h-6 text-[#0F172A]" />
        </button>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Today Summary */}
        <div>
          <h2 className="text-[15px] font-semibold text-[#0F172A] mb-3">
            Today Summary
          </h2>
          <div className="grid grid-cols-3 gap-3">
            {stats.map((stat) => {
              const Icon = stat.icon;
              return (
                <div key={stat.label} className="bg-white rounded-xl border border-gray-200 p-3 flex flex-col items-center">
                  <div className={`w-10 h-10 rounded-full ${stat.bg} flex items-center justify-center mb-2`}>
                    <Icon className={`w-5 h-5 ${stat.color}`} />
                  </div>
                  <div className="text-[20px] font-semibold text-[#0F172A] mb-0.5">
                    {stat.value}
                  </div>
                  <div className="text-[11px] text-[#64748B] text-center">
                    {stat.label}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Recent Tags Feed */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[15px] font-semibold text-[#0F172A]">
              Recent Tags
            </h2>
            <button
              onClick={() => navigate('/counselor/tag-entry')}
              className="flex items-center gap-1 text-[13px] text-[#7C3AED] font-medium"
            >
              <Plus className="w-4 h-4" />
              Add Tag
            </button>
          </div>

          <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
            {recentTags.map((tag) => (
              <button
                key={tag.id}
                onClick={() => navigate(`/counselor/student-tags/${tag.id}`)}
                className="w-full p-4 flex items-center gap-3 text-left active:bg-gray-50"
              >
                <div className="w-10 h-10 rounded-full bg-[#F3F0FF] flex items-center justify-center flex-shrink-0">
                  <span className="text-sm font-medium text-[#7C3AED]">
                    {tag.studentName.split(' ').map(n => n[0]).join('')}
                  </span>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-1">
                    {tag.studentName}
                  </div>
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[12px] font-medium ${tag.tagColor}`}>
                      {tag.tag}
                    </span>
                    <span className="text-[12px] text-[#64748B]">
                      {tag.room}
                    </span>
                  </div>
                </div>
                <div className="text-[12px] text-[#64748B] flex-shrink-0">
                  {tag.time}
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={() => navigate('/counselor/tag-entry')}
            className="bg-[#7C3AED] text-white rounded-xl p-4 flex flex-col items-center gap-2 min-h-[88px] active:bg-[#6D28D9]"
          >
            <Tag className="w-6 h-6" />
            <span className="text-[13px] font-medium">
              Add Wellbeing Tag
            </span>
          </button>
          <button
            onClick={() => navigate('/counselor/reports')}
            className="bg-white border border-gray-200 rounded-xl p-4 flex flex-col items-center gap-2 min-h-[88px] active:bg-gray-50"
          >
            <FileText className="w-6 h-6 text-[#7C3AED]" />
            <span className="text-[13px] font-medium text-[#0F172A]">
              Generate Report
            </span>
          </button>
        </div>
      </div>
    </div>
  );
}
