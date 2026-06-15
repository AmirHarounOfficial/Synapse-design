import { Outlet, Link, useLocation } from 'react-router';
import { Home, Pill, User, Bell } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

export function ParentLayout() {
  const location = useLocation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'dashboard', label: 'Home', icon: Home, path: '/parent/dashboard' },
    { id: 'medications', label: 'Medications', icon: Pill, path: '/parent/medications' },
    { id: 'profile', label: 'Profile', icon: User, path: '/parent/profile' },
    { id: 'notifications', label: 'Alerts', icon: Bell, path: '/parent/notifications' }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      <Outlet />

      {/* Bottom Tab Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-[#FFFFFF] border-t border-[#E2E8F0] pb-[env(safe-area-inset-bottom)]">
        <div className="flex justify-around items-center h-[83px] max-w-[393px] mx-auto">
          {tabsToRender.map((tab) => {
            const Icon = tab.icon;
            const isActive = location.pathname === tab.path;

            return (
              <Link
                key={tab.id}
                to={tab.path}
                className="flex flex-col items-center justify-center gap-1 px-3 py-2 min-w-[44px] min-h-[44px]"
              >
                <Icon
                  className={`w-6 h-6 ${
                    isActive ? 'text-[#2563EB]' : 'text-[#64748B]'
                  }`}
                />
                <span
                  className={`text-xs font-semibold ${
                    isActive ? 'text-[#2563EB]' : 'text-[#64748B]'
                  }`}
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
