import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router';
import { User, Clock } from 'lucide-react';

export function ParentFullQRCode() {
  const navigate = useNavigate();
  const { personId } = useParams();
  const [timeRemaining, setTimeRemaining] = useState(60);

  useEffect(() => {
    const interval = setInterval(() => {
      setTimeRemaining((prev) => {
        if (prev <= 1) {
          // In real app, this would lock the screen or navigate away
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  // In real app, fetch person data based on personId
  const person = {
    id: personId || '1',
    name: 'Jennifer Thompson',
    relationship: 'Mother',
    photoUrl: null
  };

  const child = {
    name: 'Maya Thompson',
    grade: '4th Grade'
  };

  return (
    <div className="min-h-screen bg-white flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      <div className="flex-1 flex flex-col items-center px-6 py-8">
        {/* Person Photo */}
        <div className="w-[100px] h-[100px] rounded-full bg-[#EFF6FF] flex items-center justify-center mb-4">
          <User className="w-12 h-12 text-[#2563EB]" />
        </div>

        {/* Person Info */}
        <h1 className="text-[24px] font-semibold text-gray-900 mb-1 text-center">
          {person.name}
        </h1>
        <p className="text-[15px] text-[#64748B] mb-2">
          {person.relationship}
        </p>
        <p className="text-[13px] text-[#64748B] mb-8">
          Authorized pickup for {child.name}
        </p>

        {/* QR Code */}
        <div className="w-[280px] h-[280px] bg-white border-4 border-gray-900 rounded-2xl mb-6 flex items-center justify-center relative overflow-hidden">
          {/* Placeholder QR Pattern */}
          <div className="absolute inset-0 grid grid-cols-8 grid-rows-8">
            {Array.from({ length: 64 }).map((_, i) => (
              <div
                key={i}
                className={`${
                  Math.random() > 0.5 ? 'bg-gray-900' : 'bg-white'
                }`}
              />
            ))}
          </div>
          
          {/* Center SchooKeep Logo */}
          <div className="relative w-16 h-16 rounded-lg bg-white border-2 border-gray-900 flex items-center justify-center">
            <span className="text-[20px] font-bold text-[#2563EB]">S</span>
          </div>
        </div>

        {/* Instructions */}
        <div className="bg-[#EFF6FF] border border-[#2563EB] rounded-xl p-4 mb-6 w-full max-w-sm">
          <p className="text-[14px] text-[#1E40AF] text-center leading-relaxed">
            Show this to the security guard at pickup
          </p>
        </div>

        {/* Timeout Warning */}
        <div className={`flex items-center gap-2 ${timeRemaining <= 10 ? 'text-[#DC2626]' : 'text-[#64748B]'}`}>
          <Clock className="w-4 h-4" />
          <p className="text-[13px] font-medium">
            This screen will lock in {timeRemaining} seconds
          </p>
        </div>

        {/* Spacer */}
        <div className="flex-1" />

        {/* School Logo Watermark */}
        <div className="opacity-20">
          <div className="w-20 h-20 rounded-full bg-[#2563EB] flex items-center justify-center">
            <span className="text-[28px] font-bold text-white">S</span>
          </div>
        </div>

        {/* Validity Info */}
        <p className="text-[11px] text-[#64748B] text-center mt-4">
          Valid for 24 hours • Generated at {new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}
        </p>
      </div>
    </div>
  );
}
