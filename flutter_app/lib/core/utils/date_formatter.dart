/// Date helpers ported from the React export (`src/utils/dateFormatter.ts`).
/// The Hijri conversion uses the same astronomical tabular algorithm as the
/// original so results match the prototype exactly.
abstract final class DateFormatter {
  static const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static const _monthsAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static const _monthsEn = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani", 'Jumada al-Awwal', 'Jumada al-Thani',
    'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
  ];

  static const _gregMonthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _gregMonthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static String toArabicNumerals(Object num) {
    return num.toString().replaceAllMapped(RegExp(r'[0-9]'), (m) => _arabicDigits[int.parse(m[0]!)]);
  }

  static int _julianDay(DateTime date) =>
      ((date.millisecondsSinceEpoch / 86400000) + 2440587.5).floor();

  static ({int day, int month, int year}) _toHijriParts(DateTime date) {
    // Correct tabular Islamic ("Kuwaiti") algorithm. The React export's formula
    // produced out-of-range month indices (JS silently returned `undefined`;
    // Dart would throw a RangeError), so this is a fixed, correct conversion.
    final jd = _julianDay(date);
    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return (day: day, month: month.clamp(1, 12), year: year);
  }

  static String toHijri(DateTime date, String lang) {
    final p = _toHijriParts(date);
    final dayStr = lang == 'ar' ? toArabicNumerals(p.day) : p.day.toString();
    final yearStr = lang == 'ar' ? toArabicNumerals(p.year) : p.year.toString();
    final monthName = lang == 'ar' ? _monthsAr[p.month - 1] : _monthsEn[p.month - 1];
    return '$dayStr $monthName $yearStr';
  }

  static int getHijriMonthIndex(DateTime date) => _toHijriParts(date).month;

  /// Ramadan is the 9th Hijri month.
  static bool isRamadanActive(DateTime date) => getHijriMonthIndex(date) == 9;

  /// `dd/MM/yyyy`.
  static String formatGregorian(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd/$mm/${date.year}';
  }

  static String formatGregorianLong(DateTime date, String lang) {
    if (lang == 'ar') {
      final dayStr = toArabicNumerals(date.day);
      final yearStr = toArabicNumerals(date.year);
      return '$dayStr ${_gregMonthsAr[date.month - 1]} $yearStr';
    }
    return '${date.day} ${_gregMonthsEn[date.month - 1]} ${date.year}';
  }

  static ({String gregorian, String hijri}) formatDateDual(DateTime date, String lang) =>
      (gregorian: formatGregorian(date), hijri: toHijri(date, lang));
}
