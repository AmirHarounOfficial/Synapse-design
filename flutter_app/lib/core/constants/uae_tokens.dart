/// Locale/domain tokens ported from the React export (`src/tokens/uae.ts`).
abstract final class UaeTokens {
  // Emergency numbers
  static const String ambulanceNumber = '998';
  static const String policeNumber = '999';

  // Date / currency
  static const String dateFormat = 'dd/MM/yyyy';
  static const String currencySymbol = 'AED';
  static const String currencySymbolAr = 'درهم';

  // Geography
  static const List<({String en, String ar})> emirates = [
    (en: 'Dubai', ar: 'دبي'),
    (en: 'Abu Dhabi', ar: 'أبوظبي'),
    (en: 'Sharjah', ar: 'الشارقة'),
    (en: 'Ras Al Khaimah', ar: 'رأس الخيمة'),
    (en: 'Ajman', ar: 'عجمان'),
    (en: 'Fujairah', ar: 'الفجيرة'),
    (en: 'Umm Al Quwain', ar: 'أم القيوين'),
  ];

  // License authorities
  static const List<String> licenseAuthorities = ['DHA', 'DoH Abu Dhabi', 'MOHAP'];

  // Curricula
  static const List<String> curricula = ['UAE MoE', 'British', 'American', 'Indian', 'IB', 'Other'];
}
