import { Outlet, useLocation, useNavigate } from 'react-router';
import { Home, Users, BarChart3, Settings, Shield } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

export function PrincipalLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'home', label: 'Home', icon: Home, path: '/principal/home' },
    { id: 'staff', label: 'Staff', icon: Users, path: '/principal/staff' },
    { id: 'analytics', label: 'Analytics', icon: BarChart3, path: '/principal/analytics' },
    { id: 'settings', label: 'Settings', icon: Settings, path: '/principal/settings' },
    { id: 'audit', label: 'Audit', icon: Shield, path: '/principal/audit' }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  const isActive = (path: string) => {
    if (path === '/principal/home') {
      return location.pathname === path;
    }
    return location.pathname.startsWith(path);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      <Outlet />

      {/* Bottom Tab Bar */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 safe-area-inset-bottom">
        <div className="flex items-center justify-around h-[83px] px-2">
          {tabsToRender.map((tab) => {
            const Icon = tab.icon;
            const active = isActive(tab.path);

            return (
              <button
                key={tab.id}
                onClick={() => navigate(tab.path)}
                className="flex-1 flex flex-col items-center justify-center gap-1 min-h-[44px]"
              >
                <Icon
                  className={`w-6 h-6 ${
                    active ? 'text-[#2563EB]' : 'text-[#64748B]'
                  }`}
                />
                <span
                  className={`text-[11px] ${
                    active ? 'text-[#2563EB] font-semibold' : 'text-[#64748B] font-medium'
                  }`}
                >
                  {tab.label}
                </span>
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
