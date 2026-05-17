import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/domain/membership.dart';

void main() {
  group('daysInMonth', () {
    test('handles 31/30/28/29-day months', () {
      expect(daysInMonth(2026, 1), 31);
      expect(daysInMonth(2026, 4), 30);
      expect(daysInMonth(2026, 2), 28);
      expect(daysInMonth(2028, 2), 29); // leap
    });
  });

  group('billingDayOf — clamps to a real calendar day (§3 Stripe-style)', () {
    test('normal day passes through', () {
      expect(billingDayOf(2026, 6, 15), DateTime(2026, 6, 15));
    });

    test('day 31 in a 30-day month → last day of month', () {
      expect(billingDayOf(2026, 6, 31), DateTime(2026, 6, 30));
    });

    test('day 31 in February → 28 (or 29 in a leap year)', () {
      expect(billingDayOf(2026, 2, 31), DateTime(2026, 2, 28));
      expect(billingDayOf(2028, 2, 31), DateTime(2028, 2, 29));
    });

    test('null billing day means the 1st', () {
      expect(billingDayOf(2026, 9, null), DateTime(2026, 9, 1));
    });

    test('month overflow rolls into the next year', () {
      expect(billingDayOf(2026, 14, 10), DateTime(2027, 2, 10));
    });
  });

  group('isExpired', () {
    final expiry = DateTime(2026, 6, 1);
    test('valid before expiry', () {
      expect(isExpired(expiry, DateTime(2026, 5, 31, 23, 59)), isFalse);
    });
    test('lapsed at/after expiry', () {
      expect(isExpired(expiry, DateTime(2026, 6, 1)), isTrue);
      expect(isExpired(expiry, DateTime(2026, 6, 2)), isTrue);
    });
  });

  group('nextExpiration', () {
    test('fresh member starts from today, anchored to billing day', () {
      final exp = nextExpiration(
        now: DateTime(2026, 5, 20),
        months: 1,
        billingDay: 15,
      );
      expect(exp, DateTime(2026, 6, 15));
    });

    test('lapsed member also restarts from now, not the old expiry', () {
      final exp = nextExpiration(
        now: DateTime(2026, 5, 20),
        currentExpiry: DateTime(2026, 3, 10), // already passed
        months: 3,
        billingDay: 10,
      );
      expect(exp, DateTime(2026, 8, 10));
    });

    test('renewal while still valid STACKS on the existing expiry (§4)', () {
      final exp = nextExpiration(
        now: DateTime(2026, 5, 20),
        currentExpiry: DateTime(2026, 6, 23),
        months: 1,
        billingDay: 23,
      );
      // Adds to 23 Jun, not to 20 May.
      expect(exp, DateTime(2026, 7, 23));
    });

    test('billing day is preserved across a 31 → short-month renewal', () {
      final exp = nextExpiration(
        now: DateTime(2026, 1, 15),
        currentExpiry: DateTime(2026, 1, 31),
        months: 1,
        billingDay: 31,
      );
      expect(exp, DateTime(2026, 2, 28)); // clamped, billing day kept
    });

    test('null billing day defaults to the 1st', () {
      final exp =
          nextExpiration(now: DateTime(2026, 5, 20), months: 2);
      expect(exp, DateTime(2026, 7, 1));
    });
  });

  group('daysLeft', () {
    test('counts calendar days, ignoring time', () {
      expect(
        daysLeft(DateTime(2026, 6, 1), DateTime(2026, 5, 16, 23, 0)),
        16,
      );
    });
    test('negative once lapsed', () {
      expect(
        daysLeft(DateTime(2026, 5, 10), DateTime(2026, 5, 16)),
        -6,
      );
    });
  });

  group('expiryAfterPause — frozen membership shifts expiry forward', () {
    test('a 10-day pause pushes expiry out by 10 days', () {
      expect(
        expiryAfterPause(
          expiry: DateTime(2026, 6, 23),
          pausedAt: DateTime(2026, 5, 16),
          resumedAt: DateTime(2026, 5, 26),
        ),
        DateTime(2026, 7, 3),
      );
    });

    test('the deposit forfeit deadline (§5) shifts by the same span', () {
      // Forfeit = membershipEnd + 30 days; freezing the end defers it too.
      final originalEnd = DateTime(2026, 6, 23);
      final shiftedEnd = expiryAfterPause(
        expiry: originalEnd,
        pausedAt: DateTime(2026, 5, 16),
        resumedAt: DateTime(2026, 6, 15), // 30-day pause
      );
      expect(
        shiftedEnd
            .add(const Duration(days: 30))
            .difference(originalEnd.add(const Duration(days: 30)))
            .inDays,
        30,
      );
    });

    test('time component of the expiry is preserved across the shift', () {
      final r = expiryAfterPause(
        expiry: DateTime(2026, 6, 23, 9, 41),
        pausedAt: DateTime(2026, 5, 16),
        resumedAt: DateTime(2026, 5, 19),
      );
      expect(r, DateTime(2026, 6, 26, 9, 41));
    });

    test('same-day resume is a no-op', () {
      expect(
        expiryAfterPause(
          expiry: DateTime(2026, 6, 23),
          pausedAt: DateTime(2026, 5, 16, 8),
          resumedAt: DateTime(2026, 5, 16, 20),
        ),
        DateTime(2026, 6, 23),
      );
    });

    test('clock skew (resume before pause) never shortens the membership', () {
      expect(
        expiryAfterPause(
          expiry: DateTime(2026, 6, 23),
          pausedAt: DateTime(2026, 5, 16),
          resumedAt: DateTime(2026, 5, 10),
        ),
        DateTime(2026, 6, 23),
      );
    });
  });
}
