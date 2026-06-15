import { Eye, EyeOff, AlertCircle } from 'lucide-react';
import { useState } from 'react';
import { useNavigate } from 'react-router';

export function Login() {
  const navigate = useNavigate();
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
      setEmailError('Email is required');
      return;
    }
    if (!email.includes('@')) {
      setEmailError('Please enter a valid school email');
      return;
    }
    if (!password) {
      setPasswordError('Password is required');
      return;
    }
    if (password.length < 6) {
      setPasswordError('Password must be at least 6 characters');
      return;
    }

    // Proceed with sign in
    console.log('Sign in:', { email, password });

    // Navigate to 2FA screen
    navigate('/verify');
  };

  return (
    <div className="w-full h-screen bg-[#F8FAFC] flex flex-col items-center justify-center px-4">
      {/* Safe area top padding */}
      <div className="h-[44px]" />

      {/* Main content - centered vertically */}
      <div className="flex-1 flex items-center justify-center w-full">
        <div className="w-full max-w-[345px] bg-[#FFFFFF] rounded-2xl border border-[#E2E8F0] p-6">
          {/* Card title */}
          <h1 className="text-[20px] font-medium text-[#0F172A] mb-2" style={{ fontWeight: 500 }}>
            Welcome back
          </h1>

          {/* Subtitle */}
          <p className="text-[14px] text-[#64748B] mb-6" style={{ fontWeight: 400 }}>
            Sign in with your school email
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
                  emailError
                    ? 'border-[#DC2626] focus:border-[#DC2626]'
                    : emailFocused
                    ? 'border-[#2563EB] ring-2 ring-[#2563EB]'
                    : 'border-[#E2E8F0] focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]'
                }`}
              />
              <label
                className={`absolute left-4 transition-all pointer-events-none ${
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
                School email
              </label>
            </div>
            {emailError && (
              <div className="flex items-center gap-1.5 mt-2">
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
                className={`w-full h-[52px] px-4 pr-12 rounded-lg border bg-[#FFFFFF] text-[#0F172A] placeholder-transparent peer outline-none transition-all ${
                  passwordError
                    ? 'border-[#DC2626] focus:border-[#DC2626]'
                    : passwordFocused
                    ? 'border-[#2563EB] ring-2 ring-[#2563EB]'
                    : 'border-[#E2E8F0] focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]'
                }`}
              />
              <label
                className={`absolute left-4 transition-all pointer-events-none ${
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
                Password
              </label>
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2 p-2 min-w-[44px] min-h-[44px] flex items-center justify-center"
              >
                {showPassword ? (
                  <EyeOff className="w-5 h-5 text-[#64748B]" />
                ) : (
                  <Eye className="w-5 h-5 text-[#64748B]" />
                )}
              </button>
            </div>
            {passwordError && (
              <div className="flex items-center gap-1.5 mt-2">
                <AlertCircle className="w-4 h-4 text-[#DC2626]" />
                <span className="text-[13px] text-[#DC2626]" style={{ fontWeight: 400 }}>
                  {passwordError}
                </span>
              </div>
            )}
          </div>

          {/* Forgot password link */}
          <div className="text-right mb-6">
            <button className="text-[14px] text-[#2563EB] font-medium" style={{ fontWeight: 500 }}>
              Forgot password?
            </button>
          </div>

          {/* Sign in button */}
          <button
            onClick={handleSignIn}
            className="w-full h-[52px] bg-[#2563EB] text-white rounded-xl font-semibold mb-6"
            style={{ fontWeight: 600 }}
          >
            Sign in
          </button>

          {/* Divider */}
          <div className="relative mb-4">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-[#E2E8F0]" />
            </div>
            <div className="relative flex justify-center">
              <span className="px-3 bg-[#FFFFFF] text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
                New here?
              </span>
            </div>
          </div>

          {/* Contact administrator text */}
          <p className="text-center text-[13px] text-[#64748B]" style={{ fontWeight: 400 }}>
            Contact your school administrator
          </p>
        </div>
      </div>

      {/* Safe area bottom padding */}
      <div className="h-[44px]" />
    </div>
  );
}
