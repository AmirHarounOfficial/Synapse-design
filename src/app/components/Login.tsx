import { Eye, EyeOff, AlertCircle } from 'lucide-react';
import { useState } from 'react';
import { useNavigate } from 'react-router';
import { useLanguage } from '../../context/LanguageContext';

export function Login() {
  const navigate = useNavigate();
  const { language, toggleLanguage, isRTL } = useLanguage();
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailError, setEmailError] = useState('');
  const [passwordError, setPasswordError] = useState('');
  const [emailFocused, setEmailFocused] = useState(false);
  const [passwordFocused, setPasswordFocused] = useState(false);

  const handleSignIn = () => {
    // Reset errors
    setEmailError('');
    setPasswordError('');

    // Basic validation
    if (!email) {
      setEmailError(isRTL ? 'البريد الإلكتروني مطلوب' : 'Email is required');
      return;
    }
    if (!email.includes('@')) {
      setEmailError(isRTL ? 'يرجى إدخال بريد إلكتروني صالح للمدرسة' : 'Please enter a valid school email');
      return;
    }
    if (!password) {
      setPasswordError(isRTL ? 'كلمة المرور مطلوبة' : 'Password is required');
      return;
    }
    if (password.length < 6) {
      setPasswordError(isRTL ? 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل' : 'Password must be at least 6 characters');
      return;
    }

    // Proceed with sign in
    console.log('Sign in:', { email, password });

    // Navigate to 2FA screen
    navigate('/verify');
  };

  return (
    <div className="w-full h-screen bg-[#F8FAFC] flex flex-col items-center justify-center px-4" style={{ direction: isRTL ? 'rtl' : 'ltr' }}>
      {/* Safe area top padding */}
      <div className="h-[44px]" />

      {/* Main content - centered vertically */}
      <div className="flex-1 flex items-center justify-center w-full">
        <div className="w-full max-w-[345px] bg-[#FFFFFF] rounded-2xl border border-[#E2E8F0] p-6 text-left">
          
          {/* Synapse Logo & Language Toggle Row */}
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-[#2563EB] rounded-lg flex items-center justify-center text-white font-bold text-lg">
                S
              </div>
              <span className="text-[16px] font-bold text-[#0f172a]">Synapse</span>
            </div>
            
            <button
              type="button"
              onClick={toggleLanguage}
              className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-[#F1F5F9] border border-[#E2E8F0] hover:border-[#CBD5E1] text-[12px] font-medium text-[#475569] transition-all cursor-pointer"
            >
              <span>{language === 'en' ? 'العربية' : 'English'}</span>
            </button>
          </div>

          {/* Card title */}
          <h1 className="text-[20px] font-medium text-[#0F172A] mb-2" style={{ fontWeight: 500, textAlign: isRTL ? 'right' : 'left' }}>
            {isRTL ? 'مرحباً بك مجدداً' : 'Welcome back'}
          </h1>

          {/* Subtitle */}
          <p className="text-[14px] text-[#64748B] mb-6" style={{ fontWeight: 400, textAlign: isRTL ? 'right' : 'left' }}>
            {isRTL ? 'سجل الدخول باستخدام البريد الإلكتروني للمدرسة' : 'Sign in with your school email'}
          </p>

          {/* Email input */}
          <div className="mb-4">
            <div className="relative">
              <input
                type="email"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  setEmailError('');
                }}
                onFocus={() => setEmailFocused(true)}
                onBlur={() => setEmailFocused(false)}
                placeholder=" "
                className={`w-full h-[52px] px-4 rounded-lg border bg-[#FFFFFF] text-[#0F172A] placeholder-transparent peer outline-none transition-all ${
                  isRTL ? 'text-right' : 'text-left'
                } ${
                  emailError
                    ? 'border-[#DC2626] focus:border-[#DC2626]'
                    : emailFocused
                    ? 'border-[#2563EB] ring-2 ring-[#2563EB]'
                    : 'border-[#E2E8F0] focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]'
                }`}
              />
              <label
                className={`absolute transition-all pointer-events-none ${
                  isRTL ? 'right-4' : 'left-4'
                } ${
                  email || emailFocused
                    ? 'top-1 text-xs'
                    : 'top-1/2 -translate-y-1/2 text-base'
                } ${
                  emailError
                    ? 'text-[#DC2626]'
                    : emailFocused
                    ? 'text-[#2563EB]'
                    : 'text-[#64748B]'
                }`}
                style={{ fontWeight: 400 }}
              >
                {isRTL ? 'البريد الإلكتروني للمدرسة' : 'School email'}
              </label>
            </div>
            {emailError && (
              <div className="flex items-center gap-1.5 mt-2 justify-start">
                <AlertCircle className="w-4 h-4 text-[#DC2626]" />
                <span className="text-[13px] text-[#DC2626]" style={{ fontWeight: 400 }}>
                  {emailError}
                </span>
              </div>
            )}
          </div>

          {/* Password input */}
          <div className="mb-2">
            <div className="relative">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => {
                  setPassword(e.target.value);
                  setPasswordError('');
                }}
                onFocus={() => setPasswordFocused(true)}
                onBlur={() => setPasswordFocused(false)}
                placeholder=" "
                className={`w-full h-[52px] rounded-lg border bg-[#FFFFFF] text-[#0F172A] placeholder-transparent peer outline-none transition-all ${
                  isRTL ? 'pl-12 pr-4 text-right' : 'pl-4 pr-12 text-left'
                } ${
                  passwordError
                    ? 'border-[#DC2626] focus:border-[#DC2626]'
                    : passwordFocused
                    ? 'border-[#2563EB] ring-2 ring-[#2563EB]'
                    : 'border-[#E2E8F0] focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]'
                }`}
              />
              <label
                className={`absolute transition-all pointer-events-none ${
                  isRTL ? 'right-4' : 'left-4'
                } ${
                  password || passwordFocused
                    ? 'top-1 text-xs'
                    : 'top-1/2 -translate-y-1/2 text-base'
                } ${
                  passwordError
                    ? 'text-[#DC2626]'
                    : passwordFocused
                    ? 'text-[#2563EB]'
                    : 'text-[#64748B]'
                }`}
                style={{ fontWeight: 400 }}
              >
                {isRTL ? 'كلمة المرور' : 'Password'}
              </label>
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className={`absolute top-1/2 -translate-y-1/2 p-2 min-w-[44px] min-h-[44px] flex items-center justify-center ${
                  isRTL ? 'left-4' : 'right-4'
                }`}
              >
                {showPassword ? (
                  <EyeOff className="w-5 h-5 text-[#64748B]" />
                ) : (
                  <Eye className="w-5 h-5 text-[#64748B]" />
                )}
              </button>
            </div>
            {passwordError && (
              <div className="flex items-center gap-1.5 mt-2 justify-start">
                <AlertCircle className="w-4 h-4 text-[#DC2626]" />
                <span className="text-[13px] text-[#DC2626]" style={{ fontWeight: 400 }}>
                  {passwordError}
                </span>
              </div>
            )}
          </div>

          {/* Forgot password link */}
          <div className={`mb-6 ${isRTL ? 'text-left' : 'text-right'}`}>
            <button className="text-[14px] text-[#2563EB] font-medium" style={{ fontWeight: 500 }}>
              {isRTL ? 'هل نسيت كلمة المرور؟' : 'Forgot password?'}
            </button>
          </div>

          {/* Sign in button */}
          <button
            type="button"
            onClick={handleSignIn}
            className="w-full h-[52px] bg-[#2563EB] text-white rounded-xl font-semibold mb-6 cursor-pointer"
            style={{ fontWeight: 600 }}
          >
            {isRTL ? 'تسجيل الدخول' : 'Sign in'}
          </button>

          {/* Divider */}
          <div className="relative mb-4">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-[#E2E8F0]" />
            </div>
            <div className="relative flex justify-center">
              <span className="px-3 bg-[#FFFFFF] text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
                {isRTL ? 'هل أنت جديد هنا؟' : 'New here?'}
              </span>
            </div>
          </div>

          {/* Contact administrator text */}
          <p className="text-center text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
            {isRTL ? 'اتصل بمسؤول المدرسة الخاص بك' : 'Contact your school administrator'}
          </p>
        </div>
      </div>

      {/* Safe area bottom padding */}
      <div className="h-[44px]" />
    </div>
  );
}
