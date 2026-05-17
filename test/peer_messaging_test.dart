import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/store/store.dart';

void main() {
  group('pairKey — order-independent conversation key', () {
    test('same key regardless of argument order', () {
      expect(pairKey('eva', 'pavel'), pairKey('pavel', 'eva'));
      expect(pairKey('pavel', 'eva'), 'eva|pavel');
    });
  });

  group('memberThread — normalised "mine" flag', () {
    test('peer thread marks the current member\'s own messages', () {
      final s = GymStore();
      final t = s.memberThread('pavel', 'eva'); // seed: eva|pavel, 3 msgs
      expect(t.length, 3);
      // Seed order: eva, pavel, eva.
      expect(t[0].mine, isFalse);
      expect(t[1].mine, isTrue);
      expect(t[2].mine, isFalse);
    });

    test('owner thread maps from=="member" to mine', () {
      final s = GymStore();
      final t = s.memberThread('pavel', kOwnerId);
      expect(t, isNotEmpty);
      // Seed: olda then member ⇒ last bubble is mine.
      expect(t.last.mine, isTrue);
    });
  });

  group('memberSend', () {
    test('appends to an existing peer thread as the sender', () {
      final s = GymStore();
      final before = s.memberThread('pavel', 'eva').length;
      s.memberSend('pavel', 'eva', 'Tak jo, dorazím.');
      final after = s.memberThread('pavel', 'eva');
      expect(after.length, before + 1);
      expect(after.last.mine, isTrue);
      expect(after.last.text, 'Tak jo, dorazím.');
    });

    test('creates a brand-new peer thread on first message', () {
      final s = GymStore();
      expect(s.memberThread('pavel', 'tomas'), isEmpty);
      s.memberSend('pavel', 'tomas', 'Ahoj Tomáši');
      expect(s.memberThread('pavel', 'tomas').single.text, 'Ahoj Tomáši');
    });

    test('blank text is ignored', () {
      final s = GymStore();
      final before = s.memberThread('pavel', 'eva').length;
      s.memberSend('pavel', 'eva', '   ');
      expect(s.memberThread('pavel', 'eva').length, before);
    });

    test('owner messages route into the owner thread as "member"', () {
      final s = GymStore();
      final before = s.memberThread('pavel', kOwnerId).length;
      s.memberSend('pavel', kOwnerId, 'Oldo, díky.');
      final after = s.memberThread('pavel', kOwnerId);
      expect(after.length, before + 1);
      expect(after.last.mine, isTrue);
    });
  });

  group('memberInbox', () {
    test('always contains the owner conversation, even with no history', () {
      final s = GymStore();
      // filip has neither an owner thread nor any peer thread.
      final inbox = s.memberInbox('filip');
      expect(inbox.length, 1);
      expect(inbox.single.isOwner, isTrue);
      expect(inbox.single.unread, 0);
    });

    test('lists the member\'s peer threads, newest first', () {
      final s = GymStore();
      final inbox = s.memberInbox('pavel');
      expect(inbox.any((c) => c.isOwner), isTrue);
      expect(inbox.any((c) => c.peerId == 'eva'), isTrue);
      expect(inbox.any((c) => c.peerId == 'adam'), isTrue);
      for (var i = 1; i < inbox.length; i++) {
        expect(
          !inbox[i - 1].lastAt.isBefore(inbox[i].lastAt),
          isTrue,
        );
      }
    });

    test('excludes threads the member is not part of', () {
      final s = GymStore();
      final inbox = s.memberInbox('pavel');
      // adam|pavel exists; an eva|adam-style thread must not surface here.
      expect(inbox.every((c) => c.isOwner || c.peerId != 'pavel'), isTrue);
    });
  });

  group('unread tally', () {
    test('memberMarkRead clears a peer thread', () {
      final s = GymStore();
      final evaBefore =
          s.memberInbox('pavel').firstWhere((c) => c.peerId == 'eva');
      expect(evaBefore.unread, greaterThanOrEqualTo(1));
      s.memberMarkRead('pavel', 'eva');
      final evaAfter =
          s.memberInbox('pavel').firstWhere((c) => c.peerId == 'eva');
      expect(evaAfter.unread, 0);
    });

    test('memberUnreadTotal equals the sum over the inbox', () {
      final s = GymStore();
      final sum =
          s.memberInbox('pavel').fold<int>(0, (a, c) => a + c.unread);
      expect(s.memberUnreadTotal('pavel'), sum);
    });
  });
}
