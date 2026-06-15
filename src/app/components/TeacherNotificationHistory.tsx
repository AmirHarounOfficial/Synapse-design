import { useNavigate } from 'react-router';
import { ChevronLeft, AlertCircle, Cloud, Stethoscope, Users, Bell, BellOff } from 'lucide-react';
import { useState } from 'react';

interface Notification {
  id: string;
  type: 'medical' | 'weather' | 'clinic' | 'students' | 'system';
  title: string;
  message: string;
  timestamp: string;
  isRead: boolean;
}

type FilterType = 'all' | 'medical' | 'weather' | 'clinic' | 'students' | 'system';

export function TeacherNotificationHistory() {
  const navigate = useNavigate();
  const [activeFilter, setActiveFilter] = useState<FilterType>('all');
  const [showClearDialog, setShowClearDialog] = useState(false);
  const [notifications, setNotifications] = useState<Notification[]>([
    {
      id: '1',
      type: 'clinic',
      title: 'Student Called to Clinic',
      message: 'Maya Chen has been called to the clinic',
      timestamp: '10 minutes ago',
      isRead: false
    },
    {
      id: '2',
      type: 'weather',
      title: 'Weather Advisory Issued',
      message: 'AQI advisory in effect — 3 students must remain indoors',
      timestamp: '1 hour ago',
      isRead: false
    },
    {
      id: '3',
      type: 'medical',
      title: 'Health Consideration Updated',
      message: 'Activity restriction added for Emma Rodriguez',
      timestamp: '2 hours ago',
      isRead: true
    },
    {
      id: '4',
      type: 'clinic',
      title: 'Student Returned from Clinic',
      message: 'Marcus Chen has returned to class',
      timestamp: 'Yesterday',
      isRead: true
    },
    {
      id: '5',
      type: 'system',
      title: 'System Announcement',
      message: 'Attendance must be submitted by 9:00 AM daily',
      timestamp: '2 days ago',
      isRead: true
    }
  ]);

  const filters: { id: FilterType; label: string }[] = [
    { id: 'all', label: 'All' },
    { id: 'medical', label: 'Medical Alerts' },
    { id: 'weather', label: 'Weather' },
    { id: 'clinic', label: 'Clinic' },
    { id: 'students', label: 'Students' },
    { id: 'system', label: 'System' }
  ];

  const filteredNotifications = notifications.filter(
    n => activeFilter === 'all' || n.type === activeFilter
  );

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'medical':
        return <AlertCircle className="w-5 h-5 text-[#2563EB]" />;
      case 'weather':
        return <Cloud className="w-5 h-5 text-[#F59E0B]" />;
      case 'clinic':
        return <Stethoscope className="w-5 h-5 text-[#14B8A6]" />;
      case 'students':
        return <Users className="w-5 h-5 text-[#8B5CF6]" />;
      case 'system':
        return <Bell className="w-5 h-5 text-[#64748B]" />;
      default:
        return <Bell className="w-5 h-5 text-[#64748B]" />;
    }
  };

  const getNotificationBg = (type: string) => {
    switch (type) {
      case 'medical':
        return 'bg-[#EFF6FF]';
      case 'weather':
        return 'bg-[#FEF3C7]';
      case 'clinic':
        return 'bg-[#CCFBF1]';
      case 'students':
        return 'bg-[#F3E8FF]';
      case 'system':
        return 'bg-[#F8FAFC]';
      default:
        return 'bg-[#F8FAFC]';
    }
  };

  const handleClearAll = () => {
    setNotifications([]);
    setShowClearDialog(false);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="flex items-center justify-between px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center justify-center w-11 h-11 -ml-2"
          aria-label="Go back"
        >
          <ChevronLeft className="w-6 h-6 text-gray-900" />
        </button>

        <h1 className="absolute left-1/2 -translate-x-1/2 font-medium text-gray-900">
          Alerts & Notifications
        </h1>

        {notifications.length > 0 && (
          <button
            onClick={() => setShowClearDialog(true)}
            className="px-3 py-2 text-[14px] text-[#DC2626] font-medium min-h-[44px]"
          >
            Clear all
          </button>
        )}
      </header>

      {/* Filter Chips */}
      <div className="bg-white border-b border-gray-200 px-4 py-3">
        <div className="flex gap-2 overflow-x-auto">
          {filters.map((filter) => (
            <button
              key={filter.id}
              onClick={() => setActiveFilter(filter.id)}
              className={`px-4 py-2 rounded-full text-[13px] font-medium whitespace-nowrap min-h-[44px] transition-colors ${
                activeFilter === filter.id
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-[#F8FAFC] text-[#64748B] border border-[#E2E8F0]'
              }`}
            >
              {filter.label}
            </button>
          ))}
        </div>
      </div>

      {/* Notification List */}
      <div className="px-4 py-4 space-y-2">
        {filteredNotifications.length > 0 ? (
          filteredNotifications.map((notification) => (
            <button
              key={notification.id}
              onClick={() => {/* Mark as read */}}
              className="w-full bg-white rounded-xl border border-gray-200 p-3 min-h-[64px] text-left"
            >
              <div className="flex items-start gap-3">
                <div className={`w-10 h-10 rounded-full ${getNotificationBg(notification.type)} flex items-center justify-center flex-shrink-0`}>
                  {getNotificationIcon(notification.type)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="text-[14px] font-medium text-gray-900">
                      {notification.title}
                    </h3>
                    {!notification.isRead && (
                      <div className="w-2 h-2 rounded-full bg-[#2563EB] flex-shrink-0" />
                    )}
                  </div>
                  <p className="text-[13px] text-[#64748B] mb-1">
                    {notification.message}
                  </p>
                  <p className="text-[12px] text-[#94A3B8]">
                    {notification.timestamp}
                  </p>
                </div>
              </div>
            </button>
          ))
        ) : (
          /* Empty State */
          <div className="bg-white rounded-xl border border-gray-200 p-8 text-center mt-8">
            <div className="w-16 h-16 rounded-full bg-[#F8FAFC] flex items-center justify-center mx-auto mb-4">
              <BellOff className="w-8 h-8 text-[#94A3B8]" />
            </div>
            <h3 className="text-[17px] font-medium text-gray-900 mb-2">
              No Alerts in This Category
            </h3>
            <p className="text-[14px] text-[#64748B]">
              You're all caught up
            </p>
          </div>
        )}
      </div>

      {/* Clear All Confirmation Dialog */}
      {showClearDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full">
            <h3 className="text-[17px] font-semibold text-gray-900 mb-2">
              Clear All Notifications?
            </h3>
            <p className="text-[14px] text-[#64748B] mb-6">
              This will remove all notifications from your history. This action cannot be undone.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowClearDialog(false)}
                className="flex-1 px-4 py-2.5 bg-white border border-gray-200 text-gray-900 rounded-lg text-[15px] font-medium min-h-[44px]"
              >
                Cancel
              </button>
              <button
                onClick={handleClearAll}
                className="flex-1 px-4 py-2.5 bg-[#DC2626] text-white rounded-lg text-[15px] font-medium min-h-[44px]"
              >
                Clear All
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
