import { Bell, Pill, Zap, FileText, Info, AlertCircle, RefreshCw, BellOff } from 'lucide-react';
import { useState } from 'react';
import { useNavigate } from 'react-router';

type NotificationType = 'medication' | 'emergency' | 'document' | 'system';

interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  body: string;
  time: string;
  timestamp: Date;
  isUnread: boolean;
  navigateTo?: string;
}

export function NurseNotifications() {
  const navigate = useNavigate();
  const [activeFilter, setActiveFilter] = useState<'all' | NotificationType>('all');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const [notifications, setNotifications] = useState<Notification[]>([
    {
      id: '1',
      type: 'medication',
      title: 'Dose Due — Maya Chen',
      body: 'Methylphenidate 10mg due in 8 minutes',
      time: '10:52 AM',
      timestamp: new Date(new Date().setHours(10, 52)),
      isUnread: true,
      navigateTo: '/nurse/medications'
    },
    {
      id: '2',
      type: 'emergency',
      title: 'Emergency Referral — Jordan Smith',
      body: 'Severe allergic reaction — parent consent received',
      time: '10:45 AM',
      timestamp: new Date(new Date().setHours(10, 45)),
      isUnread: true,
      navigateTo: '/nurse/clinic'
    },
    {
      id: '3',
      type: 'medication',
      title: 'Low Supply Alert',
      body: 'Albuterol Inhaler — only 2 doses remaining',
      time: '10:30 AM',
      timestamp: new Date(new Date().setHours(10, 30)),
      isUnread: true,
      navigateTo: '/nurse/medications/low-supply'
    },
    {
      id: '4',
      type: 'document',
      title: 'New Authorization Form',
      body: 'Medication consent for Emma Rodriguez received',
      time: '9:15 AM',
      timestamp: new Date(new Date().setHours(9, 15)),
      isUnread: false,
      navigateTo: '/nurse/students'
    },
    {
      id: '5',
      type: 'medication',
      title: 'Dose Administered',
      body: 'Adderall XR 10mg given to James Patterson',
      time: '9:00 AM',
      timestamp: new Date(new Date().setHours(9, 0)),
      isUnread: false,
      navigateTo: '/nurse/medications'
    },
    {
      id: '6',
      type: 'system',
      title: 'Daily Report Available',
      body: 'Medication administration summary for May 24',
      time: 'Yesterday at 5:00 PM',
      timestamp: new Date(new Date().setDate(new Date().getDate() - 1)),
      isUnread: false,
      navigateTo: '/nurse/reports'
    },
    {
      id: '7',
      type: 'document',
      title: 'Updated Health Plan',
      body: 'Individualized healthcare plan updated for Marcus Chen',
      time: 'Yesterday at 2:30 PM',
      timestamp: new Date(new Date().setDate(new Date().getDate() - 1)),
      isUnread: false,
      navigateTo: '/nurse/students'
    },
    {
      id: '8',
      type: 'emergency',
      title: 'Incident Report Filed',
      body: 'Minor injury report completed for Sophia Williams',
      time: 'Yesterday at 11:20 AM',
      timestamp: new Date(new Date().setDate(new Date().getDate() - 1)),
      isUnread: false,
      navigateTo: '/nurse/clinic'
    }
  ]);

  const filters: Array<{ id: 'all' | NotificationType; label: string }> = [
    { id: 'all', label: 'All' },
    { id: 'medication', label: 'Medications' },
    { id: 'emergency', label: 'Emergency' },
    { id: 'document', label: 'Documents' },
    { id: 'system', label: 'System' }
  ];

  const getIconConfig = (type: NotificationType) => {
    switch (type) {
      case 'medication':
        return {
          icon: Pill,
          bgColor: 'bg-[#F59E0B]',
          iconColor: 'text-white'
        };
      case 'emergency':
        return {
          icon: Zap,
          bgColor: 'bg-[#DC2626]',
          iconColor: 'text-white'
        };
      case 'document':
        return {
          icon: FileText,
          bgColor: 'bg-[#2563EB]',
          iconColor: 'text-white'
        };
      case 'system':
        return {
          icon: Info,
          bgColor: 'bg-[#64748B]',
          iconColor: 'text-white'
        };
    }
  };

  const filteredNotifications = activeFilter === 'all' 
    ? notifications 
    : notifications.filter(n => n.type === activeFilter);

  const isToday = (date: Date) => {
    const today = new Date();
    return date.getDate() === today.getDate() &&
           date.getMonth() === today.getMonth() &&
           date.getFullYear() === today.getFullYear();
  };

  const isYesterday = (date: Date) => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    return date.getDate() === yesterday.getDate() &&
           date.getMonth() === yesterday.getMonth() &&
           date.getFullYear() === yesterday.getFullYear();
  };

  const todayNotifications = filteredNotifications.filter(n => isToday(n.timestamp));
  const yesterdayNotifications = filteredNotifications.filter(n => isYesterday(n.timestamp));
  const olderNotifications = filteredNotifications.filter(n => !isToday(n.timestamp) && !isYesterday(n.timestamp));

  const unreadCount = notifications.filter(n => n.isUnread).length;

  const markAllAsRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, isUnread: false })));
  };

  const handleNotificationClick = (notification: Notification) => {
    // Mark as read
    setNotifications(prev => 
      prev.map(n => n.id === notification.id ? { ...n, isUnread: false } : n)
    );
    // Navigate if path provided
    if (notification.navigateTo) {
      navigate(notification.navigateTo);
    }
  };

  const renderNotificationGroup = (groupNotifications: Notification[], groupLabel: string) => {
    if (groupNotifications.length === 0) return null;

    return (
      <div className="mb-6">
        <div className="px-4 mb-3">
          <p 
            className="text-[11px] text-[#64748B] uppercase tracking-wide"
            style={{ fontWeight: 500, letterSpacing: '0.05em' }}
          >
            {groupLabel}
          </p>
        </div>
        <div className="space-y-2">
          {groupNotifications.map((notification) => {
            const iconConfig = getIconConfig(notification.type);
            const Icon = iconConfig.icon;

            return (
              <button
                key={notification.id}
                onClick={() => handleNotificationClick(notification)}
                className={`w-full bg-white border border-[#E2E8F0] rounded-xl p-3 flex items-start gap-3 min-h-[72px] mx-4 ${
                  notification.isUnread ? 'border-l-[2px] border-l-[#2563EB] bg-[#EFF6FF]/30' : ''
                }`}
                style={{ width: 'calc(100% - 32px)' }}
              >
                {/* Icon Circle */}
                <div 
                  className={`${iconConfig.bgColor} rounded-full flex items-center justify-center flex-shrink-0`}
                  style={{ width: '40px', height: '40px' }}
                >
                  <Icon className={`${iconConfig.iconColor}`} style={{ width: '20px', height: '20px' }} />
                </div>

                {/* Content */}
                <div className="flex-1 min-w-0 text-left">
                  <p 
                    className="text-[14px] text-[#0F172A] mb-1"
                    style={{ fontWeight: 500 }}
                  >
                    {notification.title}
                  </p>
                  <p 
                    className="text-[13px] text-[#64748B] mb-1 leading-snug"
                    style={{ fontWeight: 400 }}
                  >
                    {notification.body}
                  </p>
                  <p 
                    className="text-[11px] text-[#64748B]"
                    style={{ fontWeight: 400 }}
                  >
                    {notification.time}
                  </p>
                </div>

                {/* Unread Indicator */}
                {notification.isUnread && (
                  <div 
                    className="bg-[#2563EB] rounded-full flex-shrink-0 mt-1"
                    style={{ width: '8px', height: '8px' }}
                    aria-label="Unread"
                  />
                )}
              </button>
            );
          })}
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]" style={{ maxWidth: '393px', height: '852px', margin: '0 auto' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <button 
          onClick={() => navigate('/nurse/dashboard')}
          className="p-2 min-w-[44px] min-h-[44px] flex items-center justify-center -ml-2"
          aria-label="Back to dashboard"
        >
          <Bell className="w-6 h-6 text-[#64748B]" />
        </button>
        <h1 
          className="text-[17px] text-[#0F172A] flex-1 text-center"
          style={{ fontWeight: 500 }}
        >
          Notifications
        </h1>
        {unreadCount > 0 ? (
          <button
            onClick={markAllAsRead}
            className="text-[13px] text-[#2563EB] min-h-[44px] px-2"
            style={{ fontWeight: 500 }}
          >
            Mark all read
          </button>
        ) : (
          <div className="w-[100px]" />
        )}
      </div>

      {/* Filter Chips */}
      <div className="bg-[#FFFFFF] border-b border-[#E2E8F0] px-4 py-3 overflow-x-auto">
        <div className="flex gap-2" style={{ minWidth: 'min-content' }}>
          {filters.map((filter) => {
            const isActive = activeFilter === filter.id;
            return (
              <button
                key={filter.id}
                onClick={() => setActiveFilter(filter.id)}
                className={`px-4 py-2 rounded-full whitespace-nowrap text-[13px] min-h-[44px] ${
                  isActive
                    ? 'bg-[#2563EB] text-white'
                    : 'bg-[#F1F5F9] text-[#64748B]'
                }`}
                style={{ fontWeight: 500 }}
              >
                {filter.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="mx-4 mt-4 bg-[#FEE2E2] border border-[#DC2626] rounded-xl p-3">
          <div className="flex items-start gap-2">
            <AlertCircle className="w-5 h-5 text-[#DC2626] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-[13px] text-[#DC2626] font-medium mb-2">
                {error}
              </p>
              <button
                onClick={() => {
                  setError(null);
                  setIsLoading(true);
                  setTimeout(() => setIsLoading(false), 1000);
                }}
                className="flex items-center gap-1 text-[13px] text-[#DC2626] font-medium min-h-[44px] px-2 -ml-2"
              >
                <RefreshCw className="w-4 h-4" />
                Retry
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Notification List */}
      <div className="pt-6">
        {/* Loading State */}
        {isLoading && (
          <div className="px-4 space-y-3">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="bg-white rounded-xl p-3 border border-gray-200 animate-pulse">
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#E2E8F0]" />
                  <div className="flex-1">
                    <div className="h-4 bg-[#E2E8F0] rounded w-40 mb-2" />
                    <div className="h-3 bg-[#E2E8F0] rounded w-full mb-2" />
                    <div className="h-3 bg-[#E2E8F0] rounded w-20" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Empty State */}
        {!isLoading && !error && filteredNotifications.length === 0 && (
          <div className="flex flex-col items-center justify-center px-4 pt-20">
            <div className="w-16 h-16 bg-[#EFF6FF] rounded-full flex items-center justify-center mb-4">
              <BellOff className="w-8 h-8 text-[#2563EB]" />
            </div>
            <p
              className="text-[17px] text-gray-900 mb-2"
              style={{ fontWeight: 500 }}
            >
              You're all caught up
            </p>
            <p
              className="text-[14px] text-[#64748B] text-center"
              style={{ fontWeight: 400 }}
            >
              New alerts and notifications will appear here
            </p>
          </div>
        )}

        {/* Notification Groups */}
        {!isLoading && !error && filteredNotifications.length > 0 && (
          <>
            {renderNotificationGroup(todayNotifications, 'Today')}
            {renderNotificationGroup(yesterdayNotifications, 'Yesterday')}
            {renderNotificationGroup(olderNotifications, 'Older')}
          </>
        )}
      </div>
    </div>
  );
}
