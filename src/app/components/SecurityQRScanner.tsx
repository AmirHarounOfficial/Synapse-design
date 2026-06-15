import { useNavigate } from 'react-router';
import { X, Check } from 'lucide-react';
import { useState } from 'react';

export function SecurityQRScanner() {
  const navigate = useNavigate();
  const [scanResult, setScanResult] = useState<'authorized' | 'unauthorized' | null>(null);

  // Simulate scan - in real app would use device camera
  const simulateAuthorizedScan = () => {
    setScanResult('authorized');
  };

  const simulateUnauthorizedScan = () => {
    setScanResult('unauthorized');
  };

  const handleConfirmRelease = () => {
    navigate('/security/authorized-confirmation');
  };

  const handleManualVerification = () => {
    navigate('/security/manual-verification');
  };

  return (
    <div className="min-h-screen bg-black pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-black" />

      {/* Scanner View */}
      {!scanResult && (
        <>
          {/* Camera View Simulation */}
          <div className="relative h-[calc(100vh-127px)]">
            {/* Dark overlay with clear center */}
            <div className="absolute inset-0 bg-black/60" />
            
            {/* Scan area */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="relative w-64 h-64">
                {/* Corner brackets */}
                <div className="absolute top-0 left-0 w-12 h-12 border-l-4 border-t-4 border-white rounded-tl-lg" />
                <div className="absolute top-0 right-0 w-12 h-12 border-r-4 border-t-4 border-white rounded-tr-lg" />
                <div className="absolute bottom-0 left-0 w-12 h-12 border-l-4 border-b-4 border-white rounded-bl-lg" />
                <div className="absolute bottom-0 right-0 w-12 h-12 border-r-4 border-b-4 border-white rounded-br-lg" />
              </div>
            </div>

            {/* Instruction text */}
            <div className="absolute bottom-8 left-0 right-0 px-4">
              <div className="bg-black/80 rounded-xl p-4 text-center">
                <p className="text-white text-[15px] font-medium mb-4">
                  Scan the pickup person's QR code
                </p>
                <p className="text-[#94A3B8] text-[13px] mb-4">
                  Position the QR code within the frame above
                </p>
                
                {/* Debug buttons - remove in production */}
                <div className="space-y-2 pt-4 border-t border-white/20">
                  <button
                    onClick={simulateAuthorizedScan}
                    className="w-full px-4 py-2.5 bg-[#10B981] text-white rounded-lg text-[13px] font-medium min-h-[44px]"
                  >
                    Simulate Authorized Scan
                  </button>
                  <button
                    onClick={simulateUnauthorizedScan}
                    className="w-full px-4 py-2.5 bg-[#DC2626] text-white rounded-lg text-[13px] font-medium min-h-[44px]"
                  >
                    Simulate Unauthorized Scan
                  </button>
                  <button
                    onClick={() => navigate('/security/manual-verification')}
                    className="w-full px-4 py-2.5 bg-white/20 text-white rounded-lg text-[13px] font-medium min-h-[44px]"
                  >
                    Manual Verification Instead
                  </button>
                </div>
              </div>
            </div>
          </div>
        </>
      )}

      {/* Authorized Result */}
      {scanResult === 'authorized' && (
        <div className="h-[calc(100vh-127px)] bg-[#10B981] flex items-center justify-center p-4">
          <div className="text-center max-w-sm w-full">
            <div className="w-24 h-24 rounded-full bg-white/20 flex items-center justify-center mx-auto mb-6">
              <Check className="w-16 h-16 text-white" />
            </div>
            
            <h1 className="text-[28px] font-bold text-white mb-8">
              AUTHORIZED
            </h1>

            {/* Person Info */}
            <div className="bg-white/10 backdrop-blur rounded-2xl p-6 mb-6">
              <div className="w-20 h-20 rounded-full bg-white/30 flex items-center justify-center mx-auto mb-4">
                <span className="text-[24px] font-semibold text-white">JC</span>
              </div>
              <div className="text-white mb-1 text-[17px] font-semibold">
                Dr. Jennifer Chen
              </div>
              <div className="text-white/80 text-[14px] mb-4">
                Mother
              </div>
              
              <div className="pt-4 border-t border-white/20">
                <div className="text-white/70 text-[12px] mb-1">
                  Authorized to pick up:
                </div>
                <div className="text-white text-[16px] font-medium">
                  Maya Chen
                </div>
              </div>
            </div>

            <button
              onClick={handleConfirmRelease}
              className="w-full px-4 py-4 bg-white text-[#10B981] rounded-lg text-[17px] font-semibold min-h-[52px] shadow-lg"
            >
              Confirm Release
            </button>
          </div>
        </div>
      )}

      {/* Unauthorized Result */}
      {scanResult === 'unauthorized' && (
        <div className="h-[calc(100vh-127px)] bg-[#DC2626] flex items-center justify-center p-4">
          <div className="text-center max-w-sm w-full">
            <div className="w-24 h-24 rounded-full bg-white/20 flex items-center justify-center mx-auto mb-6">
              <X className="w-16 h-16 text-white" />
            </div>
            
            <h1 className="text-[28px] font-bold text-white mb-4">
              NOT RECOGNIZED
            </h1>

            <p className="text-white/90 text-[15px] mb-8">
              This QR code is not in our authorized pickup database for any current student.
            </p>

            <div className="space-y-3">
              <button
                onClick={handleManualVerification}
                className="w-full px-4 py-4 bg-white text-[#DC2626] rounded-lg text-[17px] font-semibold min-h-[52px] shadow-lg"
              >
                Manual Verification Required
              </button>
              <button
                onClick={() => setScanResult(null)}
                className="w-full px-4 py-3 bg-white/20 text-white rounded-lg text-[15px] font-medium min-h-[52px]"
              >
                Scan Again
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
