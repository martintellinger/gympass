import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/data/dto/db_rows.dart';
import 'package:bytfit_klub/core/data/dto/member_mapper.dart';
import 'package:bytfit_klub/core/data/mock_gym_repository.dart';
import 'package:bytfit_klub/core/store/store.dart';

/// Guards the payment mutations at the repository boundary — the seam where
/// "Označit zaplaceno" / "Přidat platbu" cross into persistence. A prior
/// refactor left the Supabase side throwing while the mock passed; these
/// pin the mock contract and the live-schema invariant the UI relies on.
void main() {
  group('MockGymRepository payments', () {
    test('confirmPayment flips a pending row to ok', () async {
      final repo = MockGymRepository(GymStore());

      final before = await repo.payments();
      final pending = before.firstWhere((p) => p.state == 'pending');

      await repo.confirmPayment(pending.id);

      final after = await repo.payments();
      final same = after.firstWhere((p) => p.id == pending.id);
      expect(same.state, 'ok');
    });

    test('confirmPayment is idempotent and never throws on an ok row',
        () async {
      final repo = MockGymRepository(GymStore());
      final ok = (await repo.payments()).firstWhere((p) => p.state == 'ok');

      await repo.confirmPayment(ok.id); // already ok — must be a safe no-op
      await repo.confirmPayment('does-not-exist'); // unknown id — safe too

      final stillOk =
          (await repo.payments()).firstWhere((p) => p.id == ok.id);
      expect(stillOk.state, 'ok');
    });

    test('addManualPayment appends a confirmed payment', () async {
      final repo = MockGymRepository(GymStore());
      final n = (await repo.payments()).length;

      await repo.addManualPayment(
        memberId: 'pavel',
        amount: 2250,
        tariff: 'Standard',
        type: 'Standard · 3 měsíce · 2 250 Kč',
      );

      final after = await repo.payments();
      expect(after.length, n + 1);
      final added = after.firstWhere((p) => p.memberId == 'pavel' &&
          p.amount == 2250 &&
          p.type == 'Standard · 3 měsíce · 2 250 Kč');
      expect(added.state, 'ok');
      expect(added.tariff, 'Standard');
    });
  });

  // The Supabase confirmPayment is a documented no-op because the live
  // `payments` table holds only confirmed rows: paymentFromRow always
  // yields 'ok', so the screen's pending/overdue confirm affordance never
  // renders on real data. Pin that invariant so the no-op stays correct.
  test('paymentFromRow always yields a confirmed (ok) payment', () {
    final p = paymentFromRow(PaymentRow(
      id: 'x',
      memberId: 'm1',
      amount: 850,
      tariff: 'standard',
      paidAt: DateTime(2026, 5, 19),
      method: 'manual',
    ));
    expect(p.state, 'ok');
  });
}
