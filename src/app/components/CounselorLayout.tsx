import { Outlet, useLocation, useNavigate } from 'react-router';
import { Home, Users, FileText, Settings } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

import { FloatingAiButton } from './FloatingAiButton';

export function CounselorLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'home', label: 'Home', icon: Home, path: '/counselor/home' },
    { id: 'students', label: 'Students', icon: Users, path: '/counselor/students' },
    { id: 'reports', label: 'Reports', icon: FileText, path: '/counselor/reports' },
    { id: 'settings', label: 'Settings', icon: Settings, path: '/counselor/settings' }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  const isActive = (path: string) => {
    if (path === '/counselor/home') {
      return location.pathname === path;
    }
    return location.pathname.startsWith(path);
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      <Outlet />
      <FloatingAiButton />

      {/* Bottom Tab Bar */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 safe-area-inset-bottom">
        <div className="flex items-center justify-around h-[83px] px-2">
          {tabsToRender.map((tab) => {
            const Icon = tab.icon;
            const active = isActive(tab.path);
            const activeColor = tab.id === 'settings' ? '#2563EB' : '#7C3AED';

            return (
              <button
                key={tab.id}
                onClick={() => navigate(tab.path)}
                className="flex-1 flex flex-col items-center justify-center gap-1 min-h-[44px]"
              >
                <Icon
                  className={`w-6 h-6 ${
                    active ? `text-[${activeColor}]` : 'text-[#64748B]'
                  }`}
                  style={active ? { color: activeColor } : {}}
                />
                <span
                  className={`text-[11px] ${
                    active ? 'font-semibold' : 'text-[#64748B] font-medium'
                  }`}
                  style={active ? { color: activeColor } : {}}
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
