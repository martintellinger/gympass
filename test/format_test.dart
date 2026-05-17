import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/format.dart';

void main() {
  group('groupThousands — CZK space separator (CLAUDE.md "2 250")', () {
    test('small numbers are untouched', () {
      expect(groupThousands(0), '0');
      expect(groupThousands(7), '7');
      expect(groupThousands(999), '999');
    });

    test('thousands get a space, not a comma', () {
      expect(groupThousands(1000), '1 000');
      expect(groupThousands(2250), '2 250');
      expect(groupThousands(12345), '12 345');
      expect(groupThousands(123456), '123 456');
      expect(groupThousands(1234567), '1 234 567');
    });

    test('rounds non-integers before grouping', () {
      expect(groupThousands(2249.6), '2 250');
    });
  });

  group('kc — amount with " Kč" suffix', () {
    test('formats like the brief', () {
      expect(kc(850), '850 Kč');
      expect(kc(2250), '2 250 Kč');
      expect(kc(0), '0 Kč');
    });
  });

  group('fmtTime — zero-padded HH:mm', () {
    test('pads single digits', () {
      expect(fmtTime(DateTime(2026, 5, 16, 9, 5)), '09:05');
      expect(fmtTime(DateTime(2026, 5, 16, 23, 41)), '23:41');
      expect(fmtTime(DateTime(2026, 5, 16, 0, 0)), '00:00');
    });
  });

  group('fmtRelDay — relative day vs a fixed "now"', () {
    final now = DateTime(2026, 5, 16, 9, 41);

    test('same day is "dnes"', () {
      expect(fmtRelDay(DateTime(2026, 5, 16, 7, 0), now), 'dnes');
    });

    test('one day back is "včera"', () {
      expect(fmtRelDay(DateTime(2026, 5, 15, 23, 0), now), 'včera');
    });

    test('2–6 days back is "před N dny"', () {
      expect(fmtRelDay(DateTime(2026, 5, 13), now), 'před 3 dny');
      expect(fmtRelDay(DateTime(2026, 5, 11), now), 'před 5 dny');
    });

    test('7+ days back falls back to a "d. m." date', () {
      expect(fmtRelDay(DateTime(2026, 5, 1), now), '1. 5.');
      expect(fmtRelDay(DateTime(2026, 1, 9), now), '9. 1.');
    });

    test('defaults "now" to the app clock (kNow) when omitted', () {
      // kNow is 2026-05-16 09:41 — same calendar day ⇒ "dnes".
      expect(fmtRelDay(DateTime(2026, 5, 16, 6, 0)), 'dnes');
    });
  });
}
