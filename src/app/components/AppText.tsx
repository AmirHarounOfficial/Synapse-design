// src/app/components/AppText.tsx
import React from 'react';
import { useLanguage } from '../../context/LanguageContext';

interface AppTextProps extends React.HTMLAttributes<HTMLElement> {
  children: React.ReactNode;
  as?: 'span' | 'p' | 'h1' | 'h2' | 'h3' | 'h4' | 'div' | 'label';
}

export function AppText({ children, className = '', as = 'span', ...props }: AppTextProps) {
  const { isRTL } = useLanguage();
  
  let alignClass = '';
  // Apply text alignment if not explicitly specified
  if (!className.includes('text-left') && !className.includes('text-right') && !className.includes('text-center')) {
    alignClass = isRTL ? ' text-right' : ' text-left';
  }

  // Swap margins and padding for text if specified
  let finalClassName = `${className}${alignClass}`;
  if (isRTL) {
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
    <Tag 
      className={finalClassName} 
      style={isRTL ? { direction: 'rtl', ...props.style } : { direction: 'ltr', ...props.style }}
      {...props}
    >
      {children}
    </Tag>
  );
}
