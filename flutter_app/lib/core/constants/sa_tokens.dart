/// Locale/domain tokens for the Kingdom of Saudi Arabia.
abstract final class SaTokens {
  // Emergency numbers
  static const String ambulanceNumber = '997';
  static const String civilDefenseNumber = '998';
  static const String policeNumber = '999';

  // Date / currency
  static const String dateFormat = 'dd/MM/yyyy';
  static const String currencySymbol = 'SAR';
  static const String currencySymbolAr = 'ريال';
  static const String currencySvgPath = 'assets/Saudi_Riyal_Symbol.svg';

  // Regions of Saudi Arabia
  static const List<({String en, String ar})> regions = [
    (en: 'Riyadh', ar: 'الرياض'),
    (en: 'Jeddah', ar: 'جدة'),
    (en: 'Makkah', ar: 'مكة المكرمة'),
    (en: 'Madinah', ar: 'المدينة المنورة'),
    (en: 'Dammam', ar: 'الدمام'),
    (en: 'Tabuk', ar: 'تبوك'),
    (en: 'Abha', ar: 'أبها'),
    (en: 'Buraydah', ar: 'بريدة'),
    (en: 'Hail', ar: 'حائل'),
    (en: 'Najran', ar: 'نجران'),
    (en: 'Jazan', ar: 'جازان'),
    (en: 'Al Bahah', ar: 'الباحة'),
    (en: 'Al Jawf', ar: 'الجوف'),
    (en: 'Northern Borders', ar: 'الحدود الشمالية'),
  ];

  // License authorities (Saudi)
  static const List<String> licenseAuthorities = ['MOH KSA', 'CBAHI', 'SCHS'];

  // Curricula (Saudi)
  static const List<String> curricula = ['Saudi National', 'British', 'American', 'Indian', 'IB', 'Other'];
}
