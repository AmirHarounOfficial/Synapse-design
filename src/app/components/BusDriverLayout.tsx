import { Outlet, useLocation, useNavigate } from 'react-router';
import { Bus, Clock, Settings } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

import { FloatingAiButton } from './FloatingAiButton';

export function BusDriverLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'route', label: 'Route', icon: Bus, path: '/bus/route' },
    { id: 'history', label: 'History', icon: Clock, path: '/bus/history' },
    { id: 'settings', label: 'Settings', icon: Settings, path: '/bus/settings' }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  const isActive = (path: string) => {
    // For the route tab, include boarding/deboarding and dismissal screens
    if (path === '/bus/route') {
      return location.pathname === path || 
             location.pathname.startsWith('/bus/boarding/') ||
             location.pathname.startsWith('/bus/deboarding/') ||
             location.pathname === '/bus/early-dismissal';
    }
    return location.pathname === path;
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      <Outlet />
      <FloatingAiButton />

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