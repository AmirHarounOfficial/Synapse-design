import { Outlet, useLocation, useNavigate } from 'react-router';
import { Home, Users, MessageCircle, Bot, Settings } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

export function SecretaryLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'home', label: 'Home', icon: Home, path: '/secretary/home' },
    { id: 'students', label: 'Students', icon: Users, path: '/secretary/students' },
    { id: 'messages', label: 'Messages', icon: MessageCircle, path: '/secretary/messages' },
    { id: 'chatbot', label: 'Chatbot', icon: Bot, path: '/secretary/chatbot' },
    { id: 'settings', label: 'Settings', icon: Settings, path: '/secretary/settings' }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  const isActive = (path: string) => {
    if (path === '/secretary/home') {
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
