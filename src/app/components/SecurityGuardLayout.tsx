import { Outlet, useLocation, useNavigate } from 'react-router';
import { Users, ScanLine, Clock, Settings } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

import { FloatingAiButton } from './FloatingAiButton';

export function SecurityGuardLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'pickups', label: 'Pickups', icon: Users, path: '/security/pickups' },
    { id: 'scanner', label: 'Scanner', icon: ScanLine, path: '/security/scanner' },
    { id: 'history', label: 'History', icon: Clock, path: '/security/history' },
    { id: 'settings', label: 'Settings', icon: Settings, path: '/security/settings' }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  const isActive = (path: string) => {
    // For the pickups tab
    if (path === '/security/pickups') {
      return location.pathname === path;
    }
    // For the scanner tab, include manual verification and confirmation screens
    if (path === '/security/scanner') {
      return location.pathname === path || 
             location.pathname === '/security/manual-verification' ||
             location.pathname === '/security/authorized-confirmation';
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