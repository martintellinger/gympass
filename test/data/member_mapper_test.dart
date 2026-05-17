import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/data/dto/db_rows.dart';
import 'package:bytfit_klub/core/data/dto/member_mapper.dart';
import 'package:bytfit_klub/core/domain/deposit.dart';

void main() {
  final now = DateTime(2026, 5, 17);

  MemberRow row({
    DateTime? expires,
    DateTime? createdAt,
    DateTime? pausedAt,
    String status = 'active',
    bool keyIssued = true,
    DateTime? keyReturnedAt,
    String tariff = 'standard',
    String? studentProof,
  }) =>
      MemberRow(
        id: 'm1',
        firstName: 'Pavel',
        lastName: 'Novák',
        email: 'p@x.cz',
        phone: '+420 1',
        role: 'member',
        status: status,
        tariffType: tariff,
        studentProofUrl: studentProof,
        membershipExpiresAt: expires,
        billingDayOfMonth: 23,
        keyIssued: keyIssued,
        keyReturnedAt: keyReturnedAt,
        pausedAt: pausedAt,
        createdAt: createdAt,
      );

  group('memberFromRow — derives view fields via the domain layer', () {
    test('days left + CZ expiry string + ok pill', () {
      final m = memberFromRow(
        row(expires: DateTime(2026, 6, 23), createdAt: DateTime(2025, 9, 1)),
        now: now,
      );
      expect(m.daysNum, 37);
      expect(m.expiresAt, '23. 6. 2026');
      expect(m.joined, '9 · 2025');
      expect(m.state, 'ok');
      expect(m.name, 'Pavel Novák');
      expect(m.overdue, isFalse);
    });

    test('lapsed membership → error pill + overdue', () {
      final m = memberFromRow(row(expires: DateTime(2026, 5, 10)), now: now);
      expect(m.daysNum, -7);
      expect(m.state, 'error');
      expect(m.overdue, isTrue);
    });

    test('≤7 days → warn pill', () {
      final m = memberFromRow(row(expires: DateTime(2026, 5, 22)), now: now);
      expect(m.state, 'warn');
    });

    test('paused freezes the expiry forward (domain expiryAfterPause)', () {
      // Expired 7 days ago on paper, but paused 10 days ago → frozen, so
      // effective expiry slides +10 days and it is no longer lapsed.
      final m = memberFromRow(
        row(
          expires: DateTime(2026, 5, 10),
          pausedAt: DateTime(2026, 5, 7),
          status: 'active',
        ),
        now: now,
      );
      expect(m.isPaused, isTrue);
      expect(m.state, 'muted');
      expect(m.expiresAt, '20. 5. 2026'); // 10 → 20 (+10 paused days)
    });

    test('student with proof maps tariff + isic', () {
      final m = memberFromRow(
        row(
            expires: DateTime(2026, 7, 1),
            tariff: 'student',
            studentProof: 'https://x/isic.jpg'),
        now: now,
      );
      expect(m.tariff, 'Student');
      expect(m.isic, isTrue);
    });

    test('returned key → hasKey false', () {
      final m = memberFromRow(
        row(expires: DateTime(2026, 7, 1), keyReturnedAt: DateTime(2026, 5, 1)),
        now: now,
      );
      expect(m.hasKey, isFalse);
    });
  });

  group('depositStatusFor — §5 forfeit clock', () {
    test('forfeits 30 days after expiry without key return', () {
      final r = row(expires: DateTime(2026, 4, 1), keyIssued: true);
      expect(depositStatusFor(r, now: now), DepositStatus.forfeited);
    });

    test('still paid within the 30-day grace window', () {
      final r = row(expires: DateTime(2026, 5, 10));
      expect(depositStatusFor(r, now: now), DepositStatus.paid);
    });

    test('returned key always settles', () {
      final r = row(
          expires: DateTime(2026, 1, 1), keyReturnedAt: DateTime(2026, 2, 1));
      expect(depositStatusFor(r, now: now), DepositStatus.returned);
    });
  });

  test('PaymentRow.fromMap → view Payment', () {
    final p = paymentFromRow(PaymentRow.fromMap({
      'id': 'p1',
      'member_id': 'm1',
      'amount': 2250,
      'tariff': '3m_standard',
      'paid_at': '2026-03-23T10:00:00Z',
      'method': 'qr_bank',
      'is_historical': false,
    }));
    expect(p.amount, 2250);
    expect(p.memberId, 'm1');
    expect(p.state, 'ok');
  });
}
