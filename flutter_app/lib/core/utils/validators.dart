/// Saudi phone + National ID / Iqama validation/formatting.
abstract final class Validators {
  static final RegExp _saudiPhone =
      RegExp(r'^(?:\+966|00966|0)(5[0-9]{8}|1[0-9]{8}|2[0-9]{8}|3[0-9]{8}|4[0-9]{8}|6[0-9]{8}|7[0-9]{8}|8[0-9]{8}|9[0-9]{8})$');

  /// Saudi mobile (+966 5X XXX XXXX) or landline (+966 X XXX XXXX).
  static bool isValidSaudiPhone(String phone) {
    final stripped = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    return _saudiPhone.hasMatch(stripped);
  }

  /// Auto-format a Saudi phone number as the user types: `+966 50 123 4567` / `050 123 4567`.
  static String formatSaudiPhone(String raw) {
    final cleaned = raw.trim();
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (cleaned.startsWith('+')) {
      if (!digits.startsWith('966')) return cleaned;
      final main = digits.substring(3);
      if (main.isEmpty) return '+966';
      if (main.length <= 2) return '+966 $main';
      if (main.length <= 5) return '+966 ${main.substring(0, 2)} ${main.substring(2)}';
      return '+966 ${main.substring(0, 2)} ${main.substring(2, 5)} ${main.substring(5, main.length.clamp(5, 9))}';
    } else if (cleaned.startsWith('0')) {
      if (digits.length <= 1) return '0';
      if (digits.length <= 3) return '0${digits.substring(1)}';
      if (digits.length <= 6) return '0${digits.substring(1, 3)} ${digits.substring(3)}';
      return '0${digits.substring(1, 3)} ${digits.substring(3, 6)} ${digits.substring(6, digits.length.clamp(6, 10))}';
    } else {
      if (digits.length <= 2) return digits;
      if (digits.length <= 5) return '${digits.substring(0, 2)} ${digits.substring(2)}';
      return '${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, digits.length.clamp(5, 9))}';
    }
  }

  /// Saudi National ID: 10 digits (1XXXXXX for citizens) or (2XXXXXX for residents/Iqama).
  static bool isValidNationalId(String id) {
    final stripped = id.replaceAll(RegExp(r'\D'), '');
    if (stripped.length != 10) return false;
    return stripped.startsWith('1') || stripped.startsWith('2');
  }

  /// Auto-format Saudi National ID / Iqama: `XXXXXXXXXX` (10 digits)
  static String formatNationalId(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);
    return digits;
  }
}
