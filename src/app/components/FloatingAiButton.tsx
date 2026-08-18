import { useNavigate, useLocation } from 'react-router';
import { Sparkles } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

export function FloatingAiButton() {
  const navigate = useNavigate();
  const location = useLocation();
  const { isRTL } = useLanguage();

  // Determine active role from current URL path
  const getRoleFromPath = (): string => {
    const path = location.pathname;
    if (path.startsWith('/nurse')) return 'nurse';
    if (path.startsWith('/teacher')) return 'teacher';
    if (path.startsWith('/cafeteria')) return 'cafeteria';
    if (path.startsWith('/security')) return 'security';
    if (path.startsWith('/bus')) return 'busDriver';
    if (path.startsWith('/counselor')) return 'counselor';
    if (path.startsWith('/secretary')) return 'secretary';
    if (path.startsWith('/principal')) return 'principal';
    if (path.startsWith('/physician')) return 'physician';
    if (path.startsWith('/vice-principal')) return 'vicePrincipal';
    if (path.startsWith('/parent')) return 'parent';
    return 'general';
  };

  // Hide button if already on AI assistant screen or login/splash
  if (
    location.pathname.includes('/ai-assistant') ||
    location.pathname.includes('/chatbot-assistant') ||
    location.pathname === '/' ||
    location.pathname === '/login' ||
    location.pathname === '/splash'
  ) {
    return null;
  }

  const role = getRoleFromPath();

  return (
    <div
      className={`fixed bottom-[88px] z-40 ${
        isRTL ? 'left-4' : 'right-4'
      }`}
    >
      <button
        onClick={() => navigate(`/ai-assistant?role=${role}`)}
        className="flex items-center gap-2 px-4 py-3 bg-[#2563EB] hover:bg-[#1D4ED8] text-white font-medium text-[13px] rounded-full shadow-xl hover:shadow-2xl transition-all transform hover:-translate-y-0.5 active:translate-y-0 cursor-pointer border border-blue-400/30 group"
        title={isRTL ? 'مساعد سكوكيب الذكي' : 'SchooKeep AI Assistant'}
      >
        <div className="w-6 h-6 rounded-full bg-white/20 flex items-center justify-center group-hover:rotate-12 transition-transform">
          <Sparkles className="w-3.5 h-3.5 text-white fill-current" />
        </div>
        <span className="font-semibold tracking-wide">
          {isRTL ? 'مساعد AI' : 'SchooKeep AI'}
        </span>
      </button>
    </div>
  );
}
