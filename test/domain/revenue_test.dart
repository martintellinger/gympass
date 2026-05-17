import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/domain/revenue.dart';
import 'package:bytfit_klub/core/store/models.dart';

Payment _p({
  String id = 'p',
  DateTime? date,
  int amount = 1000,
  String state = 'ok',
}) =>
    Payment(
      id: id,
      memberId: 'm',
      date: date ?? DateTime(2026, 5, 10),
      amount: amount,
      type: 'x',
      tariff: 'Standard',
      state: state,
    );

void main() {
  group('revenueSum (§9)', () {
    test('counts only confirmed payments in the period', () {
      final ps = [
        _p(amount: 850, date: DateTime(2026, 5, 2)),
        _p(amount: 2250, date: DateTime(2026, 5, 20)),
        _p(amount: 999, date: DateTime(2026, 5, 5), state: 'pending'),
        _p(amount: 500, date: DateTime(2026, 4, 30)), // other month
        _p(amount: 700, date: DateTime(2025, 5, 1)), // other year
      ];
      expect(revenueSum(ps, year: 2026, month: 5), 3100);
      expect(revenueSum(ps, year: 2026), 3600); // May + April
    });

    test('historical payments are excluded by default, included on demand',
        () {
      final ps = [
        _p(id: 'live', amount: 1000, date: DateTime(2026, 5, 1)),
        _p(id: 'hist', amount: 5000, date: DateTime(2026, 5, 1)),
      ];
      bool isHist(Payment p) => p.id == 'hist';
      expect(
        revenueSum(ps, year: 2026, isHistorical: isHist),
        1000,
      );
      expect(
        revenueSum(ps,
            year: 2026, includeHistorical: true, isHistorical: isHist),
        6000,
      );
    });
  });

  group('overdueTotal', () {
    test('sums only overdue payments', () {
      final ps = [
        _p(amount: 1000, state: 'overdue'),
        _p(amount: 250, state: 'overdue'),
        _p(amount: 9999, state: 'ok'),
      ];
      expect(overdueTotal(ps), 1250);
    });
  });
}
