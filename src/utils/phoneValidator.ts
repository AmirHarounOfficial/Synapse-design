// src/utils/phoneValidator.ts

export function validateUAEPhone(phone: string): boolean {
  // UAE mobile: +971 5X XXX XXXX (or 05X XXX XXXX local)
  // UAE landline: +971 X XXX XXXX
  const stripped = phone.replace(/[\s\-\(\)]/g, '');
  return /^(\+971|00971|0)(5[024568]\d{7}|[234679]\d{7})$/.test(stripped);
}

export function formatUAEPhone(raw: string): string {
  // Auto-format as user types
  // Target output: +971 50 123 4567 or local 050 123 4567
  const cleaned = raw.trim();
  const digits = raw.replace(/\D/g, '');
  
  if (cleaned.startsWith('+')) {
    if (!digits.startsWith('971')) {
      // Keep raw but formatted
      return cleaned;
    }
    const main = digits.slice(3);
    if (main.length === 0) return '+971';
    if (main.length <= 2) return `+971 ${main}`;
    if (main.length <= 5) return `+971 ${main.slice(0, 2)} ${main.slice(2)}`;
    return `+971 ${main.slice(0, 2)} ${main.slice(2, 5)} ${main.slice(5, 9)}`;
  } else if (cleaned.startsWith('0')) {
    if (digits.length <= 1) return '0';
    if (digits.length <= 3) return `0${digits.slice(1)}`;
    if (digits.length <= 6) return `0${digits.slice(1, 3)} ${digits.slice(3)}`;
    return `0${digits.slice(1, 3)} ${digits.slice(3, 6)} ${digits.slice(6, 10)}`;
  } else {
    // No + or 0, just digits
    if (digits.length <= 2) return digits;
    if (digits.length <= 5) return `${digits.slice(0, 2)} ${digits.slice(2)}`;
    return `${digits.slice(0, 2)} ${digits.slice(2, 5)} ${digits.slice(5, 9)}`;
  }
}
