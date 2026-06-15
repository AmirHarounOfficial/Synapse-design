import { ArrowLeft, CheckCircle, AlertTriangle, Calendar, FileText } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function VicePrincipalEquipmentChecklist() {
  const navigate = useNavigate();
  const [selectedCategory, setSelectedCategory] = useState<string>('all');

  const categories = [
    { id: 'all', label: 'All Items' },
    { id: 'emergency', label: 'Emergency' },
    { id: 'diagnostic', label: 'Diagnostic' },
    { id: 'safety', label: 'Safety' }
  ];

  const equipmentItems = [
    {
      id: '1',
      name: 'AED (Automated External Defibrillator)',
      category: 'emergency',
      status: 'action-needed',
      lastInspection: '2026-04-15',
      nextDue: '2026-07-15',
      notes: 'Battery replacement needed',
      batteryExpiry: '2026-07-31'
    },
    {
      id: '2',
      name: 'Blood pressure monitor',
      category: 'diagnostic',
      status: 'action-needed',
      lastInspection: '2025-12-10',
      nextDue: '2026-06-10',
      notes: 'Calibration due'
    },
    {
      id: '3',
      name: 'Eye wash station',
      category: 'safety',
      status: 'ok',
      lastInspection: '2026-05-01',
      nextDue: '2026-11-01',
      notes: ''
    },
    {
      id: '4',
      name: 'First aid kit (main clinic)',
      category: 'emergency',
      status: 'ok',
      lastInspection: '2026-05-20',
      nextDue: '2026-08-20',
      notes: 'All items present and stocked'
    },
    {
      id: '5',
      name: 'Oxygen tank',
      category: 'emergency',
      status: 'ok',
      lastInspection: '2026-05-15',
      nextDue: '2026-08-15',
      notes: 'Pressure level normal'
    },
    {
      id: '6',
      name: 'Thermometers (digital, infrared)',
      category: 'diagnostic',
      status: 'ok',
      lastInspection: '2026-05-28',
      nextDue: '2026-08-28',
      notes: 'All units functional'
    }
  ];

  const filteredItems = selectedCategory === 'all'
    ? equipmentItems
    : equipmentItems.filter(item => item.category === selectedCategory);

  const actionNeededCount = equipmentItems.filter(item => item.status === 'action-needed').length;

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col pb-[83px]" style={{ width: '393px', height: '852px' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
          aria-label="Go back"
        >
          <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
        </button>
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Equipment Checklist
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Summary Card */}
        {actionNeededCount > 0 && (
          <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4">
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[14px] font-semibold text-[#92400E] mb-1">
                  {actionNeededCount} {actionNeededCount === 1 ? 'item requires' : 'items require'} attention
                </div>
                <div className="text-[12px] text-[#92400E]">
                  Review items below marked for maintenance or replacement
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Category Filter */}
        <div className="flex gap-2 overflow-x-auto pb-2">
          {categories.map((category) => (
            <button
              key={category.id}
              onClick={() => setSelectedCategory(category.id)}
              className={`px-4 py-2 rounded-full text-[13px] font-medium whitespace-nowrap transition-colors ${
                selectedCategory === category.id
                  ? 'bg-[#2563EB] text-white'
                  : 'bg-white text-[#64748B] border border-gray-200'
              }`}
            >
              {category.label}
            </button>
          ))}
        </div>

        {/* Equipment List */}
        <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
          {filteredItems.map((item) => (
            <div key={item.id} className="p-4">
              <div className="flex items-start gap-3 mb-3">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                  item.status === 'ok' ? 'bg-[#D1FAE5]' : 'bg-[#FEF3C7]'
                }`}>
                  {item.status === 'ok' ? (
                    <CheckCircle className="w-5 h-5 text-[#10B981]" />
                  ) : (
                    <AlertTriangle className="w-5 h-5 text-[#F59E0B]" />
                  )}
                </div>
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-1">
                    {item.name}
                  </div>
                  <div className={`inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium mb-2 ${
                    item.status === 'ok'
                      ? 'bg-[#D1FAE5] text-[#10B981]'
                      : 'bg-[#FEF3C7] text-[#92400E]'
                  }`}>
                    {item.status === 'ok' ? 'Up to date' : 'Action needed'}
                  </div>
                  {item.notes && (
                    <div className="text-[12px] text-[#DC2626] mb-2 font-medium">
                      {item.notes}
                    </div>
                  )}
                  <div className="space-y-1 text-[12px] text-[#64748B]">
                    <div className="flex items-center gap-1.5">
                      <Calendar className="w-3.5 h-3.5" />
                      <span>Last: {new Date(item.lastInspection).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Calendar className="w-3.5 h-3.5" />
                      <span>Next: {new Date(item.nextDue).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                    </div>
                    {item.batteryExpiry && (
                      <div className="flex items-center gap-1.5 text-[#DC2626]">
                        <AlertTriangle className="w-3.5 h-3.5" />
                        <span>Battery expires: {new Date(item.batteryExpiry).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Export Report */}
        <button
          className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center justify-center gap-2 active:bg-gray-50"
        >
          <FileText className="w-5 h-5 text-[#2563EB]" />
          <span className="text-[14px] font-medium text-[#2563EB]">
            Export checklist as PDF
          </span>
        </button>

        {/* Info */}
        <div className="bg-[#F1F5F9] rounded-lg p-3">
          <p className="text-[12px] text-[#64748B] leading-relaxed">
            Equipment maintenance schedules are managed by the school nurse. As Vice Principal, you have view-only access to this checklist.
          </p>
        </div>
      </div>
    </div>
  );
}
