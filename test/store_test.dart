import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/store/models.dart';
import 'package:bytfit_klub/core/store/store.dart';

Member _m(String id, {String name = 'X Y', String tariff = 'Standard'}) =>
    Member(
      id: id,
      name: name,
      phone: '+420 000 000 000',
      email: '$id@email.cz',
      state: 'ok',
      daysNum: 30,
      tariff: tariff,
      hasKey: true,
      joined: '1 · 2026',
      expiresAt: '—',
      monthlyPrice: 750,
    );

void main() {
  group('memberById', () {
    test('returns the seeded member on a hit, null on a miss', () {
      final s = GymStore();
      expect(s.memberById('pavel')?.name, 'Pavel Novák');
      expect(s.memberById('does-not-exist'), isNull);
    });
  });

  group('addMember', () {
    test('preserves the name and inserts at the top of the roster', () {
      final s = GymStore();
      final before = s.members.length;
      final created = s.addMember(_m('ignored', name: 'Nový Člen'));
      expect(s.members.length, before + 1);
      expect(s.members.first.id, created.id);
      expect(created.name, 'Nový Člen');
    });

    test('derives the id from the lowercased first name word', () {
      final s = GymStore();
      final created = s.addMember(_m('ignored', name: 'Pavel Novák'));
      expect(created.id, startsWith('pavel'));
    });

    test('empty name falls back to the "novy" slug', () {
      final s = GymStore();
      final created = s.addMember(_m('ignored', name: ''));
      expect(created.id, startsWith('novy'));
    });

    test('monthly price is derived from the tariff', () {
      final s = GymStore();
      expect(s.addMember(_m('a', tariff: 'Student')).monthlyPrice, 500);
      expect(s.addMember(_m('b', tariff: 'Standard')).monthlyPrice, 750);
    });
  });

  group('importMembers — idempotent, identity-preserving', () {
    test('additions are inserted, no member is lost', () {
      final s = GymStore();
      final before = s.members.length;
      s.importMembers(additions: [_m('imp1', name: 'Import One')], updates: {});
      expect(s.members.length, before + 1);
      expect(s.memberById('imp1')?.name, 'Import One');
    });

    test('updates patch an existing member in place (no duplicate)', () {
      final s = GymStore();
      final before = s.members.length;
      final patched = s.memberById('pavel')!.copyWith(phone: '+420 111');
      s.importMembers(additions: [], updates: {'pavel': patched});
      expect(s.members.length, before);
      expect(s.memberById('pavel')!.phone, '+420 111');
    });

    test('an update for an unknown id is ignored, not inserted', () {
      final s = GymStore();
      final before = s.members.length;
      s.importMembers(
          additions: [], updates: {'ghost': _m('ghost')});
      expect(s.members.length, before);
      expect(s.memberById('ghost'), isNull);
    });

    test('re-applying the same import is stable (Excel stays control layer)',
        () {
      final s = GymStore();
      final patched = s.memberById('pavel')!.copyWith(phone: '+420 222');
      s.importMembers(additions: [], updates: {'pavel': patched});
      final afterFirst = s.members.length;
      s.importMembers(additions: [], updates: {'pavel': patched});
      expect(s.members.length, afterFirst);
      expect(s.memberById('pavel')!.phone, '+420 222');
    });

    test('an empty import is a no-op', () {
      final s = GymStore();
      final before = s.members.length;
      s.importMembers(additions: [], updates: {});
      expect(s.members.length, before);
    });
  });

  group('threads — sorting and unread tally', () {
    test('only members with messages, newest conversation first', () {
      final s = GymStore();
      final sorted = s.threadsSorted();
      expect(sorted, isNotEmpty);
      for (var i = 1; i < sorted.length; i++) {
        expect(
          sorted[i - 1].last.at.isAfter(sorted[i].last.at) ||
              sorted[i - 1].last.at.isAtSameMomentAs(sorted[i].last.at),
          isTrue,
        );
      }
    });

    test('unread counts only trailing unread member messages', () {
      final s = GymStore();
      final david =
          s.threadsSorted().firstWhere((t) => t.member.id == 'david');
      // Seed: david's last message is from the member, unread.
      expect(david.unread, greaterThanOrEqualTo(1));
      final bara =
          s.threadsSorted().firstWhere((t) => t.member.id == 'bara');
      // Seed: bara's last message is from Olda ⇒ nothing unread.
      expect(bara.unread, 0);
    });

    test('markRead clears a thread and lowers the global badge', () {
      final s = GymStore();
      final before = s.totalUnread();
      expect(before, greaterThan(0));
      s.markRead('david');
      final david =
          s.threadsSorted().firstWhere((t) => t.member.id == 'david');
      expect(david.unread, 0);
      expect(s.totalUnread(), lessThan(before));
    });

    test('totalUnread equals the sum over sorted threads', () {
      final s = GymStore();
      final sum =
          s.threadsSorted().fold<int>(0, (a, t) => a + t.unread);
      expect(s.totalUnread(), sum);
    });
  });

  group('membership pause/resume — members pause, only Olda resumes', () {
    test('pauseMembership freezes the member and notes it from the member',
        () {
      final s = GymStore();
      s.pauseMembership('pavel',
          reason: 'holiday', notice: 'Pozastavil(a) jsem si členství.');
      final m = s.memberById('pavel')!;
      expect(m.isPaused, isTrue);
      expect(m.suspended, isTrue);
      expect(m.state, 'muted');
      expect(s.threadFor('pavel').last.from, 'member');
    });

    test('pausing an already-paused member is a no-op', () {
      final s = GymStore();
      s.pauseMembership('pavel', notice: 'x');
      final len = s.threadFor('pavel').length;
      s.pauseMembership('pavel', notice: 'y');
      expect(s.threadFor('pavel').length, len);
    });

    test('resumeMembership clears the pause and notes it FROM OLDA', () {
      final s = GymStore();
      s.pauseMembership('pavel', notice: 'pauza');
      s.resumeMembership('pavel', notice: 'Olda ti obnovil členství.');
      final m = s.memberById('pavel')!;
      expect(m.isPaused, isFalse);
      expect(m.suspended, isFalse);
      // The resume note is owner-voiced (Olda did it), not from the member.
      expect(s.threadFor('pavel').last.from, 'olda');
    });

    test('resume is a no-op when the member is not paused', () {
      final s = GymStore();
      final len = s.threadFor('pavel').length;
      s.resumeMembership('pavel', notice: 'nope');
      expect(s.memberById('pavel')!.isPaused, isFalse);
      expect(s.threadFor('pavel').length, len);
    });
  });
}
