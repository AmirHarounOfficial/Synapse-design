// src/app/components/PhysicianLayout.tsx
import { Outlet, Link, useLocation } from 'react-router';
import { Home, Pill, AlertTriangle, Settings } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

import { FloatingAiButton } from './FloatingAiButton';

export function PhysicianLayout() {
  const location = useLocation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'dashboard', label: isRTL ? 'الرئيسية' : 'Home', icon: Home, path: '/physician/dashboard' },
    { id: 'protocols', label: isRTL ? 'البروتوكولات' : 'Protocols', icon: Pill, path: '/physician/protocols' },
    { id: 'escalations', label: isRTL ? 'التصعيدات' : 'Escalations', icon: AlertTriangle, path: '/physician/escalations' },
    { id: 'settings', label: isRTL ? 'الإعدادات' : 'Settings', icon: Settings, path: '/physician/settings' }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      <Outlet />
      <FloatingAiButton />

      {/* Bottom Tab Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-[#FFFFFF] border-t border-[#E2E8F0] pb-[env(safe-area-inset-bottom)] z-50">
        <div className="flex justify-around items-center h-[83px] max-w-[393px] mx-auto">
          {tabsToRender.map((tab) => {
            const Icon = tab.icon;
            const isActive = location.pathname === tab.path || location.pathname.startsWith(tab.path + '/');

            return (
              <Link
                key={tab.id}
                to={tab.path}
                className="flex flex-col items-center justify-center gap-1 px-3 py-2 min-w-[44px] min-h-[44px]"
              >
                <Icon
                  className={`w-6 h-6 transition-colors`}
                  style={{ color: isActive ? '#0D9488' : '#64748B' }}
                />
                <span
                  className={`text-[10px] font-semibold transition-colors`}
                  style={{ color: isActive ? '#0D9488' : '#64748B' }}
                >
                  {tab.label}
                </span>
              </Link>
            );
          })}
        </div>
      </div>
    </div>
  );
}
export default PhysicianLayout;
