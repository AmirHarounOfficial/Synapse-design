import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schookeep/core/utils/date_formatter.dart';
import 'package:schookeep/core/widgets/accent_card.dart';
import 'package:schookeep/core/widgets/schookeep_button.dart';

/// These run in debug mode (assertions ON), so they catch the
/// `Material(shape + borderRadius)` and `BoxDecoration(non-uniform border +
/// borderRadius)` assertions that release web builds silently passed.
void main() {
  testWidgets('AccentCard builds without assertion errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AccentCard(accentColor: Colors.red, child: Text('hi')),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('hi'), findsOneWidget);
  });

  testWidgets('SchooKeepButton outline variant builds (shape, no borderRadius clash)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SchooKeepButton(
          label: 'Outline',
          variant: SchooKeepButtonVariant.outline,
          onPressed: () {},
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('Outline'), findsOneWidget);
  });

  test('Hijri conversion returns a valid month (1-12) and does not throw', () {
    for (final d in [
      DateTime.utc(2026, 6, 24),
      DateTime.utc(2024, 3, 11), // ~Ramadan 1445
      DateTime.utc(2000, 1, 1),
      DateTime.utc(2030, 12, 31),
    ]) {
      final m = DateFormatter.getHijriMonthIndex(d);
      expect(m, inInclusiveRange(1, 12), reason: 'month for $d was $m');
      // Must not throw (would RangeError on the month-name lookup if invalid):
      expect(() => DateFormatter.toHijri(d, 'en'), returnsNormally);
      expect(() => DateFormatter.toHijri(d, 'ar'), returnsNormally);
    }
  });
}
