import { Home, Pill, User, Bell } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useLanguage } from '../../context/LanguageContext';

interface BottomNavigationProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export function BottomNavigation({ activeTab, onTabChange }: BottomNavigationProps) {
  const { t } = useTranslation();
  const { isRTL } = useLanguage();

  const tabs = [
    { id: 'dashboard', label: t('common.home'), icon: Home },
    { id: 'medications', label: t('navigation.medications'), icon: Pill },
    { id: 'profile', label: t('common.settings'), icon: User },
    { id: 'notifications', label: t('common.notifications'), icon: Bell }
  ];

  const tabsToRender = isRTL ? [...tabs].reverse() : tabs;

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-[#FFFFFF] border-t border-[#E2E8F0] pb-[env(safe-area-inset-bottom)]">
      <div className="flex justify-around items-center h-[83px] max-w-[393px] mx-auto">
        {tabsToRender.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;

          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
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
            </button>
          );
        })}
      </div>
    </div>
  );
}
