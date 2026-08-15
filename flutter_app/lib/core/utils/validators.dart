/// UAE phone + Emirates ID validation/formatting.
/// Ported from `src/utils/phoneValidator.ts` and `src/utils/eidValidator.ts`.
abstract final class Validators {
  static final RegExp _uaePhone =
      RegExp(r'^(\+971|00971|0)(5[024568]\d{7}|[234679]\d{7})$');

  /// UAE mobile (+971 5X XXX XXXX) or landline (+971 X XXX XXXX).
  static bool isValidUaePhone(String phone) {
    final stripped = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    return _uaePhone.hasMatch(stripped);
  }

  /// Auto-format a phone number as the user types: `+971 50 123 4567` / `050 123 4567`.
  static String formatUaePhone(String raw) {
    final cleaned = raw.trim();
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (cleaned.startsWith('+')) {
      if (!digits.startsWith('971')) return cleaned;
      final main = digits.substring(3);
      if (main.isEmpty) return '+971';
      if (main.length <= 2) return '+971 $main';
      if (main.length <= 5) return '+971 ${main.substring(0, 2)} ${main.substring(2)}';
      return '+971 ${main.substring(0, 2)} ${main.substring(2, 5)} ${main.substring(5, main.length.clamp(5, 9))}';
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

  static final RegExp _eid = RegExp(r'^784\d{12}$');

  /// Emirates ID: 784-YYYY-XXXXXXX-X.
  static bool isValidEid(String eid) {
    final stripped = eid.replaceAll('-', '');
    return _eid.hasMatch(stripped);
  }

  /// Auto-format an Emirates ID as the user types: `784-YYYY-XXXXXXX-X`.
  static String formatEid(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 15) digits = digits.substring(0, 15);
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 3)}-${digits.substring(3)}';
    if (digits.length <= 14) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, 14)}-${digits.substring(14)}';
  }
}
