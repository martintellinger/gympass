import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/domain/deposit.dart';

void main() {
  final end = DateTime(2026, 5, 1);

  group('depositStatus (§5 — 100 Kč, 30-day grace)', () {
    test('held while within the grace window', () {
      expect(
        depositStatus(
            membershipEnd: end, keyReturned: false, now: DateTime(2026, 5, 20)),
        DepositStatus.paid,
      );
    });

    test('still held on the last grace day (day 29)', () {
      expect(
        depositStatus(
            membershipEnd: end, keyReturned: false, now: DateTime(2026, 5, 30)),
        DepositStatus.paid,
      );
    });

    test('forfeits exactly 30 days after expiry', () {
      expect(
        depositStatus(
            membershipEnd: end, keyReturned: false, now: DateTime(2026, 5, 31)),
        DepositStatus.forfeited,
      );
    });

    test('forfeits well past the window', () {
      expect(
        depositStatus(
            membershipEnd: end, keyReturned: false, now: DateTime(2026, 8, 1)),
        DepositStatus.forfeited,
      );
    });

    test('returning the key settles it, even after the window', () {
      expect(
        depositStatus(
            membershipEnd: end, keyReturned: true, now: DateTime(2026, 9, 1)),
        DepositStatus.returned,
      );
    });
  });

  group('daysUntilForfeit', () {
    test('positive within the window', () {
      expect(
        daysUntilForfeit(
            membershipEnd: end, keyReturned: false, now: DateTime(2026, 5, 20)),
        11,
      );
    });

    test('zero on the forfeit day', () {
      expect(
        daysUntilForfeit(
            membershipEnd: end, keyReturned: false, now: DateTime(2026, 5, 31)),
        0,
      );
    });

    test('null once the key is returned (nothing to forfeit)', () {
      expect(
        daysUntilForfeit(
            membershipEnd: end, keyReturned: true, now: DateTime(2026, 5, 20)),
        isNull,
      );
    });
  });
}
