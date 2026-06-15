// src/app/components/DirectionalView.tsx
import React from 'react';
import { useLanguage } from '../../context/LanguageContext';

interface DirectionalViewProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode;
  as?: 'div' | 'section' | 'header' | 'footer' | 'main';
}

export function DirectionalView({ children, className = '', as = 'div', ...props }: DirectionalViewProps) {
  const { isRTL } = useLanguage();
  
  // Parse className to replace physical layout styles with mirrored counterparts in RTL
  let finalClassName = className;
  
  if (isRTL) {
    // Mirror flex row direction
    if (className.includes('flex-row')) {
      finalClassName = finalClassName.replace('flex-row', 'flex-row-reverse');
    } else if (className.includes('flex') && !className.includes('flex-col') && !className.includes('flex-row-reverse')) {
      finalClassName = `${finalClassName} flex-row-reverse`;
    }
    
    // Mirror borders
    if (className.includes('border-l-')) {
      const match = className.match(/border-l-\[?([^\]\s]+)\]?/);
      if (match) finalClassName = finalClassName.replace(match[0], `border-r-${match[1]}`);
    } else if (className.includes('border-l')) {
      finalClassName = finalClassName.replace('border-l', 'border-r');
    }
    
    // Mirror padding
    finalClassName = finalClassName
      .split(' ')
      .map(cls => {
        if (cls.startsWith('pl-')) return cls.replace('pl-', 'pr-');
        if (cls.startsWith('pr-')) return cls.replace('pr-', 'pl-');
        if (cls.startsWith('ml-')) return cls.replace('ml-', 'mr-');
        if (cls.startsWith('mr-')) return cls.replace('mr-', 'ml-');
        return cls;
      })
      .join(' ');
  }

  const Tag = as;
  return (
    <Tag className={finalClassName} {...props}>
      {children}
    </Tag>
  );
}
