// src/app/components/AllergenChipGrid.tsx
import React from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { NonHalalBadge } from './NonHalalBadge';
import { AlertTriangle } from 'lucide-react';

interface AllergenItem {
  id: string;
  emoji: string;
  en: string;
  ar: string;
}

interface AllergenChipGridProps {
  selectedIds: string[];
  onToggle?: (id: string) => void;
  readOnly?: boolean;
}

export function AllergenChipGrid({ 
  selectedIds, 
  onToggle, 
  readOnly = false 
}: AllergenChipGridProps) {
  const { isRTL } = useLanguage();

  const dietaryItems: AllergenItem[] = [
    { id: 'non-halal', emoji: '⚠️', en: 'Non-Halal', ar: 'غير حلال' },
    { id: 'pork', emoji: '🐷', en: 'Pork/Pork-derived', ar: 'خنزير/مشتقات الخنزير' },
    { id: 'alcohol', emoji: '🍺', en: 'Alcohol-derived', ar: 'مشتقات كحولية' }
  ];

  const allergenItems: AllergenItem[] = [
    { id: 'peanuts', emoji: '🥜', en: 'Peanuts', ar: 'فول سوداني' },
    { id: 'tree-nuts', emoji: '🌰', en: 'Tree Nuts', ar: 'مكسرات الأشجار' },
    { id: 'dairy', emoji: '🥛', en: 'Dairy', ar: 'ألبان' },
    { id: 'eggs', emoji: '🥚', en: 'Eggs', ar: 'بيض' },
    { id: 'wheat', emoji: '🌾', en: 'Wheat/Gluten', ar: 'قمح/غلوتين' },
    { id: 'soy', emoji: '🫘', en: 'Soy', ar: 'صويا' },
    { id: 'sesame', emoji: '🟤', en: 'Sesame', ar: 'سمسم' },
    { id: 'fish', emoji: '🐟', en: 'Fish', ar: 'أسماك' },
    { id: 'shellfish', emoji: '🦐', en: 'Shellfish', ar: 'قشريات' }
  ];

  const handleToggle = (id: string) => {
    if (!readOnly && onToggle) {
      onToggle(id);
    }
  };

  const renderChip = (item: AllergenItem, isDietary = false) => {
    const isSelected = selectedIds.includes(item.id);
    
    // Select border/bg color based on item type and active state
    let activeClass = '';
    if (isSelected) {
      activeClass = isDietary 
        ? 'bg-[#DC2626] border-[#DC2626] text-white' 
        : 'bg-[#2563EB] border-[#2563EB] text-white';
    } else {
      activeClass = isDietary
        ? 'bg-white border-[#FCA5A5] text-[#DC2626] hover:bg-[#FEF2F2]'
        : 'bg-white border-[#E2E8F0] text-gray-900 hover:bg-gray-50';
    }

    const disabledClass = readOnly ? 'cursor-default' : 'cursor-pointer active:scale-[0.98]';

    return (
      <button
        key={item.id}
        type="button"
        onClick={() => handleToggle(item.id)}
        disabled={readOnly}
        className={`flex flex-col items-center justify-center p-2 rounded-xl border text-center transition-all min-h-[56px] select-none ${activeClass} ${disabledClass}`}
      >
        <div className="flex items-center gap-1.5 justify-center">
          <span className="text-lg">{item.emoji}</span>
          <span className="text-[12px] font-bold leading-tight">{item.en}</span>
        </div>
        <span className={`text-[10px] mt-0.5 font-medium leading-none ${isSelected ? 'text-white/95' : 'text-[#64748B]'}`}>
          {item.ar}
        </span>
      </button>
    );
  };

  return (
    <div className="space-y-4 w-full">
      {/* Row 1: Dietary Requirements */}
      <div>
        <div className="flex items-center gap-2 mb-2">
          <div className="h-[1px] bg-red-200 flex-1" />
          <span className="text-[11px] font-bold text-[#DC2626] uppercase tracking-wider">
            {isRTL ? 'المتطلبات الغذائية / الشرعية' : 'Dietary Requirements'}
          </span>
          <div className="h-[1px] bg-red-200 flex-1" />
        </div>
        <div className="grid grid-cols-3 gap-2.5">
          {dietaryItems.map(item => renderChip(item, true))}
        </div>
      </div>

      {/* Row 2: FDA Allergens */}
      <div>
        <div className="flex items-center gap-2 mb-2">
          <div className="h-[1px] bg-blue-100 flex-1" />
          <span className="text-[11px] font-bold text-[#2563EB] uppercase tracking-wider">
            {isRTL ? 'المواد المسببة للحساسية' : 'Allergen Restrictions'}
          </span>
          <div className="h-[1px] bg-blue-100 flex-1" />
        </div>
        <div className="grid grid-cols-3 gap-2.5">
          {allergenItems.map(item => renderChip(item, false))}
        </div>
      </div>
    </div>
  );
}
