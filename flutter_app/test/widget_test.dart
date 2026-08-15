import 'package:flutter_test/flutter_test.dart';
import 'package:schookeep/core/utils/validators.dart';

void main() {
  group('UAE validators', () {
    test('valid UAE mobile numbers pass', () {
      expect(Validators.isValidUaePhone('+971501234567'), isTrue);
      expect(Validators.isValidUaePhone('0501234567'), isTrue);
    });

    test('invalid phone numbers fail', () {
      expect(Validators.isValidUaePhone('12345'), isFalse);
    });

    test('Emirates ID validation', () {
      expect(Validators.isValidEid('784-1990-1234567-1'), isTrue);
      expect(Validators.isValidEid('123-1990-1234567-1'), isFalse);
    });
  });
}
