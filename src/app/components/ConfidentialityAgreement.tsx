import { AlertTriangle } from 'lucide-react';
import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router';

export function ConfidentialityAgreement() {
  const navigate = useNavigate();
  const [scrollProgress, setScrollProgress] = useState(0);
  const [isScrolledToBottom, setIsScrolledToBottom] = useState(false);
  const [showPulse, setShowPulse] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleScroll = () => {
      if (!scrollRef.current) return;

      const { scrollTop, scrollHeight, clientHeight } = scrollRef.current;
      const totalScrollable = scrollHeight - clientHeight;
      const progress = totalScrollable > 0 ? (scrollTop / totalScrollable) * 100 : 0;

      setScrollProgress(progress);

      // Check if scrolled to bottom (with 10px threshold)
      if (scrollTop + clientHeight >= scrollHeight - 10) {
        if (!isScrolledToBottom) {
          setIsScrolledToBottom(true);
          setShowPulse(true);
          setTimeout(() => setShowPulse(false), 600);
        }
      }
    };

    const scrollElement = scrollRef.current;
    if (scrollElement) {
      scrollElement.addEventListener('scroll', handleScroll);
      // Initial check
      handleScroll();
    }

    return () => {
      if (scrollElement) {
        scrollElement.removeEventListener('scroll', handleScroll);
      }
    };
  }, [isScrolledToBottom]);

  return (
    <div className="w-full h-screen bg-[#F8FAFC] flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center justify-between border-b border-[#E2E8F0]">
        <h1 className="text-[17px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
          Confidentiality Agreement
        </h1>
        <span className="text-[12px] text-[#64748B]" style={{ fontWeight: 400 }}>
          Step 1 of 2
        </span>
      </div>

      {/* Amber info banner */}
      <div className="bg-[#FEF3C7] border-l-8 border-[#F59E0B] p-4">
        <div className="flex gap-3">
          <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0" />
          <p className="text-[12px] text-[#92400E]" style={{ fontWeight: 400 }}>
            Please scroll to the bottom to continue
          </p>
        </div>
      </div>

      {/* Progress bar */}
      <div className="h-1 bg-[#E2E8F0]">
        <div
          className="h-full bg-[#2563EB] transition-all duration-150"
          style={{ width: `${scrollProgress}%` }}
        />
      </div>

      {/* Scrollable content */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 py-6">
        <div className="text-[14px] text-[#0F172A] space-y-4" style={{ fontWeight: 400, lineHeight: 1.7 }}>
          <h2 className="text-[16px] font-semibold text-[#0F172A] mb-4" style={{ fontWeight: 600 }}>
            Health Information Privacy & Confidentiality Agreement
          </h2>

          <p>
            This Confidentiality Agreement ("Agreement") is entered into by and between the authorized school health professional ("User") and the educational institution ("School") utilizing the Synapse health management system.
          </p>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            1. Purpose
          </h3>
          <p>
            The User acknowledges that in the course of their duties, they will have access to confidential and sensitive health information regarding students, including but not limited to medical histories, diagnoses, treatment plans, medication records, and other protected health information (PHI) as defined under the Health Insurance Portability and Accountability Act (HIPAA) and the Family Educational Rights and Privacy Act (FERPA).
          </p>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            2. Confidentiality Obligations
          </h3>
          <p>
            The User agrees to:
          </p>
          <ul className="list-disc pl-6 space-y-2">
            <li>Maintain the confidentiality of all student health information accessed through the Synapse system</li>
            <li>Use such information solely for the purpose of providing authorized healthcare services to students</li>
            <li>Not disclose, share, or discuss student health information with unauthorized individuals</li>
            <li>Access only those records necessary to perform their assigned duties</li>
            <li>Comply with all applicable federal and state privacy laws, including HIPAA and FERPA</li>
          </ul>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            3. Security Measures
          </h3>
          <p>
            The User agrees to take all reasonable precautions to prevent unauthorized access to student health information, including:
          </p>
          <ul className="list-disc pl-6 space-y-2">
            <li>Using strong, unique passwords and not sharing login credentials</li>
            <li>Logging out of the system when not in active use</li>
            <li>Ensuring physical security of devices used to access the system</li>
            <li>Reporting any suspected security breaches immediately to the system administrator</li>
          </ul>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            4. Consequences of Breach
          </h3>
          <p>
            The User understands that any breach of this Agreement may result in:
          </p>
          <ul className="list-disc pl-6 space-y-2">
            <li>Immediate termination of system access</li>
            <li>Disciplinary action up to and including termination of employment</li>
            <li>Civil and/or criminal penalties under applicable law</li>
            <li>Personal liability for damages resulting from unauthorized disclosure</li>
          </ul>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            5. Duration
          </h3>
          <p>
            This Agreement remains in effect for the duration of the User's access to the Synapse system and continues indefinitely with respect to information accessed during such period.
          </p>

          <h3 className="text-[15px] font-semibold text-[#0F172A] mt-6 mb-2" style={{ fontWeight: 600 }}>
            6. Acknowledgment
          </h3>
          <p>
            By continuing to the signature page, the User acknowledges that they have read, understood, and agree to be bound by the terms of this Confidentiality Agreement. The User further acknowledges their responsibility to protect student health information and their understanding of the serious nature of these obligations.
          </p>

          <div className="h-8" />
        </div>
      </div>

      {/* Fixed bottom area */}
      <div className="border-t border-[#E2E8F0] bg-[#FFFFFF] px-4 py-4">
        <button
          onClick={() => navigate('/signature')}
          disabled={!isScrolledToBottom}
          className={`w-full h-[52px] rounded-xl font-semibold transition-all ${
            isScrolledToBottom
              ? 'bg-[#2563EB] text-white'
              : 'bg-[#2563EB] text-white opacity-40 cursor-not-allowed'
          } ${showPulse ? 'animate-pulse-success' : ''}`}
          style={{ fontWeight: 600 }}
        >
          Continue
        </button>
      </div>
    </div>
  );
}
