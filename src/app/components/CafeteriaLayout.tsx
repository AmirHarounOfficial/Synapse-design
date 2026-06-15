import { Outlet, useLocation, useNavigate } from 'react-router';
import { AlertTriangle, Clock, Settings } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

export function CafeteriaLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'alerts', label: 'Alerts', icon: AlertTriangle, path: '/cafeteria/alerts' },
    { id: 'history', label: 'History', icon: Clock, path: '/cafeteria/history' },
    { id: 'settings', label: 'Settings', icon: Settings, path: '/cafeteria/settings' }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  const isActive = (path: string) => {
    // For the alerts tab, consider detail and realtime-alert screens as part of alerts
    if (path === '/cafeteria/alerts') {
      return location.pathname === path || 
             location.pathname.startsWith('/cafeteria/detail/') ||
             location.pathname === '/cafeteria/realtime-alert' ||
             location.pathname === '/cafeteria/empty';
    }
    return location.pathname === path;
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      <Outlet />

      {/* Bottom Tab Bar */}
      <nav className="fixed bottom-0 left-0 right-0 h-[83px] bg-white border-t border-gray-200 flex items-start pt-2">
        {tabsToRender.map((tab) => {
          const Icon = tab.icon;
          const active = isActive(tab.path);

          return (
            <button
              key={tab.id}
              onClick={() => navigate(tab.path)}
              className="flex-1 flex flex-col items-center gap-1 min-h-[44px] px-2"
            >
              <Icon
                className={`w-6 h-6 ${
                  active ? 'text-[#2563EB]' : 'text-[#64748B]'
                }`}
              />
              <span
                className={`text-[11px] ${
                  active ? 'text-[#2563EB] font-medium' : 'text-[#64748B]'
                }`}
              >
                {tab.label}
              </span>
            </button>
          );
        })}
      </nav>
    </div>
  );
}