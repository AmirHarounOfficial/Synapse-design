export function Splash() {
  return (
    <div className="w-full h-screen bg-[#FFFFFF] flex flex-col items-center justify-center px-4">
      {/* Safe area top padding */}
      <div className="h-[44px]" />

      {/* Main content - centered vertically */}
      <div className="flex-1 flex flex-col items-center justify-center">
        {/* Logo wordmark */}
        <h1 className="text-[36px] font-medium text-[#2563EB] mb-2" style={{ fontWeight: 500 }}>
          Synapse
        </h1>

        {/* Tagline */}
        <p className="text-[16px] text-[#64748B]" style={{ fontWeight: 400 }}>
          Smart School Health
        </p>

        {/* Spacer to push loading indicator down */}
        <div className="h-32" />

        {/* Animated loading indicator */}
        <div className="flex items-center gap-2">
          <div
            className="w-2 h-2 rounded-full bg-[#2563EB] animate-pulse"
            style={{
              animationDelay: '0ms',
              animationDuration: '1000ms'
            }}
          />
          <div
            className="w-2 h-2 rounded-full bg-[#2563EB] animate-pulse"
            style={{
              animationDelay: '200ms',
              animationDuration: '1000ms'
            }}
          />
          <div
            className="w-2 h-2 rounded-full bg-[#2563EB] animate-pulse"
            style={{
              animationDelay: '400ms',
              animationDuration: '1000ms'
            }}
          />
        </div>
      </div>

      {/* Safe area bottom padding */}
      <div className="h-[44px]" />
    </div>
  );
}
