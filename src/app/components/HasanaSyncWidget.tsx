// src/app/components/HasanaSyncWidget.tsx
import React, { useState } from 'react';
import { RefreshCw, CheckCircle, AlertCircle, Loader2 } from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';
import { formatGregorian } from '../../utils/dateFormatter';

interface HasanaSyncWidgetProps {
  emirate?: string; // only visible if === 'Dubai'
  initialStatus?: 'synced' | 'pending' | 'failed';
}

export function HasanaSyncWidget({ 
  emirate = 'Dubai', 
  initialStatus = 'synced' 
}: HasanaSyncWidgetProps) {
  const { isRTL } = useLanguage();
  const [status, setStatus] = useState<'synced' | 'pending' | 'failed'>(initialStatus);
  const [loading, setLoading] = useState(false);
  const [syncTime, setSyncTime] = useState<string>(formatGregorian(new Date()) + " at 08:30:00");

  // Only show for Dubai schools (DHA HASANA system is unique to Dubai)
  if (emirate.trim().toLowerCase() !== 'dubai') {
    return null;
  }

  const handleRetry = () => {
    setLoading(true);
    setStatus('pending');
    setTimeout(() => {
      setStatus('synced');
      setLoading(false);
      const now = new Date();
      const dd = String(now.getDate()).padStart(2, '0');
      const mm = String(now.getMonth() + 1).padStart(2, '0');
      const time = now.toTimeString().split(' ')[0];
      setSyncTime(`${dd}/${mm}/${now.getFullYear()} at ${time}`);
    }, 1500);
  };

  return (
    <div className="bg-white rounded-xl p-4 border border-gray-200 shadow-sm animate-scale-in">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          {/* DHA compliance badge logo */}
          <div className="w-5 h-5 bg-[#006C35] rounded flex items-center justify-center text-white text-[9px] font-bold">
            DHA
          </div>
          <span className="text-[13px] font-bold text-gray-900">
            {isRTL ? 'ربط حصانة الإلكتروني' : 'HASANA Hub Integration'}
          </span>
        </div>
        
        {/* Sync Status Badge */}
        {status === 'synced' && (
          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#D1FAE5] text-[#065F46]">
            <CheckCircle className="w-3.5 h-3.5" />
            {isRTL ? 'متصل ✓' : 'Synced ✓'}
          </span>
        )}
        
        {status === 'pending' && (
          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#FEF3C7] text-[#92400E]">
            <RefreshCw className="w-3.5 h-3.5 animate-spin" />
            {isRTL ? 'جاري المزامنة...' : 'Syncing...'}
          </span>
        )}
        
        {status === 'failed' && (
          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#FEE2E2] text-[#DC2626]">
            <AlertCircle className="w-3.5 h-3.5" />
            {isRTL ? 'فشل الربط ⚠' : 'Sync Failed ⚠'}
          </span>
        )}
      </div>

      <div className="mt-3 flex items-center justify-between text-[11px] text-[#64748B]">
        <span>
          {status === 'synced' 
            ? (isRTL ? `آخر مزامنة: ${syncTime}` : `Last sync: ${syncTime}`)
            : (isRTL ? 'بانتظار التحقق من بوابة الصحة' : 'Verifying connection gateway')}
        </span>

        {(status === 'failed' || status === 'synced') && (
          <button
            onClick={handleRetry}
            disabled={loading}
            className="text-[#2563EB] font-bold hover:underline flex items-center gap-1"
          >
            {loading ? (
              <Loader2 className="w-3 h-3 animate-spin" />
            ) : (
              <RefreshCw className="w-3 h-3" />
            )}
            {isRTL ? 'إعادة المحاولة' : 'Sync Now'}
          </button>
        )}
      </div>
    </div>
  );
}
