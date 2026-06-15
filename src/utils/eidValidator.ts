// src/utils/eidValidator.ts

export function validateEID(eid: string): boolean {
  const stripped = eid.replace(/-/g, '');
  return /^784\d{12}$/.test(stripped);
}

export function formatEID(raw: string): string {
  // Auto-format as user types: 784-YYYY-XXXXXXX-X
  const digits = raw.replace(/\D/g, '').slice(0, 15);
  if (digits.length <= 3)  return digits;
  if (digits.length <= 7)  return `${digits.slice(0,3)}-${digits.slice(3)}`;
  if (digits.length <= 14) return `${digits.slice(0,3)}-${digits.slice(3,7)}-${digits.slice(7)}`;
  return `${digits.slice(0,3)}-${digits.slice(3,7)}-${digits.slice(7,14)}-${digits.slice(14)}`;
}
