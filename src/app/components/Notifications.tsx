import { CheckCircle, AlertCircle, Info, X } from 'lucide-react';
import { useState } from 'react';

interface Notification {
  id: string;
  type: 'success' | 'warning' | 'info' | 'error';
  title: string;
  message: string;
  time: string;
  read: boolean;
}

export function Notifications() {
  const [notifications, setNotifications] = useState<Notification[]>([
    {
      id: '1',
      type: 'warning',
      title: 'Consent Required',
      message: 'Parent consent needed for Emma Rodriguez medication administration',
      time: '10 min ago',
      read: false
    },
    {
      id: '2',
      type: 'success',
      title: 'Medication Administered',
      message: 'Adderall XR 10mg given to James Patterson at 9:00 AM',
      time: '1 hour ago',
      read: false
    },
    {
      id: '3',
      type: 'info',
      title: 'Upcoming Medication',
      message: 'Marcus Chen - Albuterol Inhaler scheduled for 11:00 AM',
      time: '2 hours ago',
      read: true
    },
    {
      id: '4',
      type: 'error',
      title: 'Missed Administration',
      message: 'Sophia Williams medication was not given at scheduled time 8:00 AM',
      time: '3 hours ago',
      read: true
    },
    {
      id: '5',
      type: 'success',
      title: 'Record Updated',
      message: 'Medical record updated for Isabella Martinez',
      time: '5 hours ago',
      read: true
    },
    {
      id: '6',
      type: 'info',
      title: 'New Student Added',
      message: 'Noah Thompson has been added to the medication tracking system',
      time: 'Yesterday',
      read: true
    }
  ]);

  const unreadCount = notifications.filter(n => !n.read).length;

  const getNotificationStyle = (type: Notification['type']) => {
    switch (type) {
      case 'success':
        return {
          icon: CheckCircle,
          iconColor: 'text-[#10B981]',
          bgColor: 'bg-[#10B981]/10',
          borderColor: 'border-l-[#10B981]'
        };
      case 'warning':
        return {
          icon: AlertCircle,
          iconColor: 'text-[#F59E0B]',
          bgColor: 'bg-[#F59E0B]/10',
          borderColor: 'border-l-[#F59E0B]'
        };
      case 'error':
        return {
          icon: AlertCircle,
          iconColor: 'text-[#DC2626]',
          bgColor: 'bg-[#DC2626]/10',
          borderColor: 'border-l-[#DC2626]'
        };
      case 'info':
        return {
          icon: Info,
          iconColor: 'text-[#2563EB]',
          bgColor: 'bg-[#2563EB]/10',
          borderColor: 'border-l-[#2563EB]'
        };
    }
  };

  const markAsRead = (id: string) => {
    setNotifications(prev =>
      prev.map(n => n.id === id ? { ...n, read: true } : n)
    );
  };

  const deleteNotification = (id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center border-b border-[#E2E8F0]">
        <div className="flex items-center gap-2">
          <h1 className="text-xl font-semibold text-[#0F172A]">Notifications</h1>
          {unreadCount > 0 && (
            <span className="bg-[#DC2626] text-white text-xs px-2 py-1 rounded-full font-semibold min-w-[24px] text-center">
              {unreadCount}
            </span>
          )}
        </div>
      </div>

      {/* Content */}
      <div className="px-4 pt-6">
        {unreadCount > 0 && (
          <div className="mb-4">
            <button
              onClick={() => setNotifications(prev => prev.map(n => ({ ...n, read: true })))}
              className="text-sm text-[#2563EB] font-semibold"
            >
              Mark all as read
            </button>
          </div>
        )}

        <div className="space-y-3">
          {notifications.map((notification) => {
            const style = getNotificationStyle(notification.type);
            const Icon = style.icon;

            return (
              <div
                key={notification.id}
                className={`bg-[#FFFFFF] rounded-xl p-4 border-l-4 ${style.borderColor} border-t border-r border-b border-[#E2E8F0] ${
                  !notification.read ? 'shadow-sm' : ''
                }`}
              >
                <div className="flex gap-3">
                  <div className={`${style.bgColor} rounded-full p-2 flex-shrink-0 h-10 w-10 flex items-center justify-center`}>
                    <Icon className={`w-5 h-5 ${style.iconColor}`} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between mb-1">
                      <h3 className={`font-semibold ${!notification.read ? 'text-[#0F172A]' : 'text-[#64748B]'}`}>
                        {notification.title}
                      </h3>
                      <button
                        onClick={() => deleteNotification(notification.id)}
                        className="p-1 -mt-1 -mr-1"
                      >
                        <X className="w-4 h-4 text-[#64748B]" />
                      </button>
                    </div>
                    <p className="text-sm text-[#64748B] mb-2">{notification.message}</p>
                    <div className="flex items-center justify-between">
                      <span className="text-xs text-[#64748B]">{notification.time}</span>
                      {!notification.read && (
                        <button
                          onClick={() => markAsRead(notification.id)}
                          className="text-xs text-[#2563EB] font-semibold"
                        >
                          Mark as read
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {notifications.length === 0 && (
          <div className="text-center py-12">
            <p className="text-[#64748B]">No notifications</p>
          </div>
        )}
      </div>
    </div>
  );
}
