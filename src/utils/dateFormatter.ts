// src/utils/dateFormatter.ts

export function toArabicNumerals(num: number | string): string {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return num.toString().replace(/[0-9]/g, (w) => arabicDigits[parseInt(w)]);
}

export function toHijri(date: Date, lang: 'ar' | 'en'): string {
  // Astronomical tabular conversion algorithm (Islamic Calendar)
  const julianDay = Math.floor((date.getTime() / 86400000) + 2440587.5);
  
  const l = julianDay - 1948440 + 10632;
  const n = Math.floor((l - 1) / 10631);
  const l2 = l - 10631 * n + 354;
  const j = Math.floor((10985 - l2) / 5316) * Math.floor((50 + l2) / 30) + Math.floor((l2 - 1) / 30);
  const l3 = l2 - Math.floor((10985 - j) / 5316) * Math.floor((30 * j + 59) / 30);
  
  const d = l3 - 30; // Day
  const m = j; // Month
  const y = 30 * n + j - 30; // Year
  
  const monthsAr = [
    "محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة",
    "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
  ];
  
  const monthsEn = [
    "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani", "Jumada al-Awwal", "Jumada al-Thani",
    "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
  ];
  
  const dayStr = lang === 'ar' ? toArabicNumerals(d) : d.toString();
  const yearStr = lang === 'ar' ? toArabicNumerals(y) : y.toString();
  const monthName = lang === 'ar' ? monthsAr[m - 1] : monthsEn[m - 1];
  
  return lang === 'ar' ? `${dayStr} ${monthName} ${yearStr}` : `${dayStr} ${monthName} ${yearStr}`;
}

export function getHijriMonthIndex(date: Date): number {
  const julianDay = Math.floor((date.getTime() / 86400000) + 2440587.5);
  const l = julianDay - 1948440 + 10632;
  const n = Math.floor((l - 1) / 10631);
  const l2 = l - 10631 * n + 354;
  return Math.floor((10985 - l2) / 5316) * Math.floor((50 + l2) / 30) + Math.floor((l2 - 1) / 30);
}

export function isRamadanActive(date: Date): boolean {
  return getHijriMonthIndex(date) === 9; // Ramadan is 9th Hijri month
}

export function formatGregorian(date: Date): string {
  const dd = String(date.getDate()).padStart(2, '0');
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const yyyy = date.getFullYear();
  return `${dd}/${mm}/${yyyy}`;
}

export function formatGregorianLong(date: Date, lang: 'ar' | 'en'): string {
  const dd = date.getDate();
  const yyyy = date.getFullYear();
  
  const monthsEn = [
    "January", "February", "March", "April", "May", "June", 
    "July", "August", "September", "October", "November", "December"
  ];
  
  const monthsAr = [
    "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
    "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
  ];
  
  const dayStr = lang === 'ar' ? toArabicNumerals(dd) : dd.toString();
  const yearStr = lang === 'ar' ? toArabicNumerals(yyyy) : yyyy.toString();
  const monthStr = lang === 'ar' ? monthsAr[date.getMonth()] : monthsEn[date.getMonth()];
  
  return lang === 'ar' ? `${dayStr} ${monthStr} ${yearStr}` : `${dd} ${monthStr} ${yyyy}`;
}

export function formatDateDual(date: Date, lang: 'ar' | 'en'): { gregorian: string; hijri: string } {
  return {
    gregorian: formatGregorian(date),
    hijri: toHijri(date, lang)
  };
}
