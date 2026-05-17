import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'models.dart';

/// "Now" anchor — store.jsx fixes the clock to 2026-05-16 09:41.
final DateTime kNow = DateTime(2026, 5, 16, 9, 41, 0);
DateTime _ago(int min) => kNow.subtract(Duration(minutes: min));

/// The logged-in member in this mock build (auth not wired yet — every
/// member screen acts as Pavel). Owner conversation uses the sentinel id
/// [kOwnerId] so member↔owner and member↔member share one inbox.
const String kCurrentMemberId = 'pavel';
const String kOwnerId = 'olda';

/// Canonical key for a member↔member thread — order-independent so
/// (pavel,eva) and (eva,pavel) map to the same conversation.
String pairKey(String a, String b) => (([a, b])..sort()).join('|');

/// Mock store — 1:1 port of store.jsx, exposed as a ChangeNotifier so
/// Riverpod widgets re-render on mutation (replaces the JS pub/sub).
class GymStore extends ChangeNotifier {
  final List<Member> members = [
    const Member(id: 'adam', name: 'Adam Beneš', phone: '+420 605 112 388', email: 'adam.benes@email.cz', state: 'ok', daysNum: 47, tariff: 'Standard', hasKey: true, joined: '3 · 2025', expiresAt: '17. 7. 2026', monthlyPrice: 600),
    const Member(id: 'anna', name: 'Anna Dvořáková', phone: '+420 720 884 102', email: 'anna.dvorakova@email.cz', state: 'ok', daysNum: 12, tariff: 'Student', hasKey: true, isic: true, joined: '10 · 2025', expiresAt: '12. 6. 2026'),
    const Member(id: 'bara', name: 'Barbora Horáková', phone: '+420 731 224 871', email: 'bara.horakova@email.cz', state: 'warn', daysNum: 6, tariff: 'Standard', hasKey: true, joined: '11 · 2024', expiresAt: '6. 6. 2026'),
    const Member(id: 'david', name: 'David Janků', phone: '+420 776 998 213', email: 'david.janku@email.cz', state: 'error', daysNum: -3, tariff: 'Standard', hasKey: true, overdue: true, joined: '1 · 2025', expiresAt: '28. 5. 2026'),
    const Member(id: 'eva', name: 'Eva Krátká', phone: '+420 608 712 339', email: 'eva.kratka@email.cz', state: 'ok', daysNum: 21, tariff: 'Standard', hasKey: true, joined: '8 · 2025', expiresAt: '21. 6. 2026'),
    const Member(id: 'filip', name: 'Filip Marek', phone: '+420 728 116 442', email: 'filip.marek@email.cz', state: 'ok', daysNum: 63, tariff: 'Standard', hasKey: false, joined: '4 · 2026', expiresAt: '2. 8. 2026'),
    const Member(id: 'jana', name: 'Jana Kovářová', phone: '+420 776 553 098', email: 'jana.kovarova@email.cz', state: 'muted', daysNum: -45, tariff: 'Standard', hasKey: false, suspended: true, joined: '2 · 2024', expiresAt: '—'),
    const Member(id: 'lukas', name: 'Lukáš Procházka', phone: '+420 605 889 213', email: 'lukas.prochazka@email.cz', state: 'warn', daysNum: 3, tariff: 'Student', hasKey: true, isic: true, joined: '12 · 2025', expiresAt: '3. 6. 2026'),
    const Member(id: 'martin', name: 'Martin Tichý', phone: '+420 720 441 882', email: 'martin.tichy@email.cz', state: 'ok', daysNum: 52, tariff: 'Standard', hasKey: true, joined: '7 · 2025', expiresAt: '22. 7. 2026', monthlyPrice: 700),
    const Member(id: 'pavel', name: 'Pavel Novák', phone: '+420 728 451 209', email: 'pavel.novak@email.cz', state: 'ok', daysNum: 23, tariff: 'Standard', hasKey: true, joined: '9 · 2025', expiresAt: '23. 6. 2026'),
    const Member(id: 'petr', name: 'Petr Soukup', phone: '+420 776 221 558', email: 'petr.soukup@email.cz', state: 'error', daysNum: -12, tariff: 'Standard', hasKey: true, overdue: true, joined: '6 · 2024', expiresAt: '19. 5. 2026'),
    const Member(id: 'tomas', name: 'Tomáš Hladký', phone: '+420 605 882 410', email: 'tomas.hladky@email.cz', state: 'ok', daysNum: 34, tariff: 'Student', hasKey: true, isic: true, joined: '9 · 2025', expiresAt: '3. 7. 2026'),
    const Member(id: 'klara', name: 'Klára Bártová', phone: '+420 720 998 003', email: 'klara.bartova@email.cz', state: 'ok', daysNum: 18, tariff: 'Standard', hasKey: true, joined: '11 · 2025', expiresAt: '18. 6. 2026'),
    const Member(id: 'jakub', name: 'Jakub Veselý', phone: '+420 728 003 661', email: 'jakub.vesely@email.cz', state: 'ok', daysNum: 41, tariff: 'Standard', hasKey: true, joined: '4 · 2025', expiresAt: '11. 7. 2026'),
    const Member(id: 'tereza', name: 'Tereza Černá', phone: '+420 776 410 882', email: 'tereza.cerna@email.cz', state: 'warn', daysNum: 4, tariff: 'Standard', hasKey: true, joined: '6 · 2025', expiresAt: '4. 6. 2026'),
    const Member(id: 'ondrej', name: 'Ondřej Mareš', phone: '+420 605 221 998', email: 'ondrej.mares@email.cz', state: 'ok', daysNum: 29, tariff: 'Standard', hasKey: true, joined: '8 · 2025', expiresAt: '29. 6. 2026'),
  ];

  final Map<String, List<Message>> threads = {
    'david': [
      Message(from: 'olda', text: 'Ahoj Davide, platba ti propadla o 3 dny. Dáš to do víkendu?', at: _ago(60 * 22)),
      Message(from: 'member', text: 'Promiň, zapomněl jsem. Pošlu dnes večer.', at: _ago(60 * 20)),
      Message(from: 'olda', text: 'Super, dík. QR ti pošlu znovu kdyžtak.', at: _ago(60 * 20 - 5)),
      Message(from: 'member', text: 'Jo prosím tě, pošli ho ještě.', at: _ago(15)),
    ],
    'petr': [
      Message(from: 'olda', text: 'Petře, platba 12 dní po lhůtě. Volej mi prosím, ať to vyřešíme.', at: _ago(60 * 24 * 2)),
    ],
    'bara': [
      Message(from: 'member', text: 'Sprcha č. 3 zase teče málo.', at: _ago(60 * 26)),
      Message(from: 'olda', text: 'Díky za hlášku, ráno se na to podívám.', at: _ago(60 * 25)),
      Message(from: 'olda', text: 'Hotovo, sifon vyčištěn. Funguje?', at: _ago(60 * 4)),
    ],
    'pavel': [
      Message(from: 'olda', text: 'Pavle, dík za platbu, vidím to v účtu.', at: _ago(60 * 24 * 3)),
      Message(from: 'member', text: 'Super, dík!', at: _ago(60 * 24 * 3 - 10)),
    ],
    'anna': [
      Message(from: 'olda', text: 'Ahoj Anno, končí ti ISIC. Přines prosím nový, ať tě nepřepnu na Standard.', at: _ago(60 * 5)),
    ],
    'tomas': [
      Message(from: 'member', text: 'Olda ahoj, můžu zítra přivést kamaráda na zkoušku?', at: _ago(60 * 8)),
      Message(from: 'olda', text: 'Jasně, klidně. Ať mi řekne u dveří.', at: _ago(60 * 7)),
    ],
    'lukas': [
      Message(from: 'olda', text: 'Lukáši, končí ti za 3 dny — pošlu QR?', at: _ago(60 * 3)),
    ],
  };

  /// Member↔member conversations, keyed by [pairKey]. `Message.from` holds
  /// the sender's member id (not 'olda'/'member' like owner threads).
  final Map<String, List<Message>> peerThreads = {
    'eva|pavel': [
      Message(from: 'eva', text: 'Ahoj Pavle, nešel bys zítra v 18 na nohy? Ať na to nejsem sám.', at: _ago(60 * 5)),
      Message(from: 'pavel', text: 'Jo můžu, akorát dorazím spíš v 18:15.', at: _ago(60 * 4)),
      Message(from: 'eva', text: 'Super, dík. Budu u stojanu.', at: _ago(40)),
    ],
    'adam|pavel': [
      Message(from: 'pavel', text: 'Adame, nezapomněl jsi tu včera ručník u laviček?', at: _ago(60 * 26)),
      Message(from: 'adam', text: 'Jo to je můj, dík žes napsal. Vyzvednu si ho dnes.', at: _ago(60 * 25), read: true),
    ],
  };

  final List<Payment> payments = [
    Payment(id: 'p1', memberId: 'pavel', date: DateTime(2026, 3, 23), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p2', memberId: 'adam', date: DateTime(2026, 4, 17), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p3', memberId: 'anna', date: DateTime(2026, 3, 12), amount: 1500, type: 'Prodloužení 3 měs.', tariff: 'Student', state: 'ok'),
    Payment(id: 'p4', memberId: 'eva', date: DateTime(2026, 3, 21), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p5', memberId: 'martin', date: DateTime(2026, 4, 22), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p6', memberId: 'klara', date: DateTime(2026, 3, 18), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p7', memberId: 'jakub', date: DateTime(2026, 4, 11), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p8', memberId: 'tomas', date: DateTime(2026, 4, 3), amount: 1500, type: 'Prodloužení 3 měs.', tariff: 'Student', state: 'ok'),
    Payment(id: 'p9', memberId: 'tereza', date: DateTime(2026, 3, 4), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p10', memberId: 'filip', date: DateTime(2026, 4, 2), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p11', memberId: 'bara', date: DateTime(2026, 3, 6), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p12', memberId: 'ondrej', date: DateTime(2026, 4, 29), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p16', memberId: 'pavel', date: DateTime(2026, 5, 8), amount: 4500, type: 'Prodloužení 6 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p17', memberId: 'martin', date: DateTime(2026, 5, 12), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p18', memberId: 'tomas', date: DateTime(2026, 5, 14), amount: 1500, type: 'Prodloužení 3 měs.', tariff: 'Student', state: 'ok'),
    Payment(id: 'p19', memberId: 'klara', date: DateTime(2026, 5, 15), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok'),
    Payment(id: 'p13', memberId: 'lukas', date: DateTime(2026, 5, 13), amount: 1500, type: 'QR čeká', tariff: 'Student', state: 'pending'),
    Payment(id: 'p14', memberId: 'david', date: DateTime(2026, 5, 13), amount: 2250, type: 'Po lhůtě 3 dny', tariff: 'Standard', state: 'overdue'),
    Payment(id: 'p15', memberId: 'petr', date: DateTime(2026, 5, 4), amount: 2250, type: 'Po lhůtě 12 dní', tariff: 'Standard', state: 'overdue'),
  ];

  Member? memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  Member addMember(Member partial) {
    final base = partial.name.isEmpty ? 'novy' : partial.name.toLowerCase();
    final slug = base.split(RegExp(r'\s')).first.replaceAll(RegExp(r'[^a-z]'), '');
    final id = '${slug.substring(0, min(8, slug.length))}${Random().nextInt(99)}';
    final created = Member(
      id: id,
      name: partial.name,
      phone: partial.phone,
      email: partial.email,
      state: partial.state,
      daysNum: partial.daysNum,
      tariff: partial.tariff,
      hasKey: partial.hasKey,
      isic: partial.isic,
      joined: '5 · 2026',
      expiresAt: '14. 8. 2026',
      monthlyPrice: partial.tariff == 'Student' ? 500 : 750,
    );
    members.insert(0, created);
    notifyListeners();
    return created;
  }

  /// Applies a confirmed Excel migration: inserts brand-new members and
  /// patches existing ones in place. Identity-preserving (keeps `id`,
  /// `joined`, threads), so a re-import never duplicates anyone.
  void importMembers({
    required List<Member> additions,
    required Map<String, Member> updates,
  }) {
    for (final m in additions) {
      members.insert(0, m);
    }
    for (final entry in updates.entries) {
      final i = members.indexWhere((m) => m.id == entry.key);
      if (i != -1) members[i] = entry.value;
    }
    notifyListeners();
  }

  void removeMember(String id) {
    members.removeWhere((m) => m.id == id);
    threads.remove(id);
    notifyListeners();
  }

  void updateMember(String id, Member Function(Member) patch) {
    final i = members.indexWhere((m) => m.id == id);
    if (i == -1) return;
    members[i] = patch(members[i]);
    notifyListeners();
  }

  /// Member self-pauses their membership (holiday / long-term illness).
  /// Self-service — no owner approval — but Olda is notified via the owner
  /// thread. Membership freezes: `suspended`/`muted` until resumed; the real
  /// expiry shift lives in `domain/membership.dart#expiryAfterPause`.
  /// [reason] is a key suffix (`holiday`|`illness`|`other`) or null.
  /// [notice] is the localised line posted to the owner thread.
  void pauseMembership(String id, {String? reason, required String notice}) {
    final m = memberById(id);
    if (m == null || m.isPaused) return;
    updateMember(
      id,
      (x) => x.copyWith(
        suspended: true,
        state: 'muted',
        pausedAt: kNow,
        pauseReason: reason,
      ),
    );
    sendMessage(id, notice, from: 'member');
  }

  /// Member resumes a paused membership. Clears the pause and recomputes the
  /// status pill from the (frozen) remaining days. Olda is notified.
  void resumeMembership(String id, {required String notice}) {
    final m = memberById(id);
    if (m == null || !m.isPaused) return;
    final state = m.daysNum < 0
        ? 'error'
        : m.daysNum <= 7
            ? 'warn'
            : 'ok';
    updateMember(
      id,
      (x) => x.copyWith(suspended: false, state: state, clearPause: true),
    );
    sendMessage(id, notice, from: 'member');
  }

  void sendMessage(String memberId, String text, {String from = 'olda'}) {
    threads.putIfAbsent(memberId, () => []);
    threads[memberId]!.add(Message(
      from: from,
      text: text,
      at: DateTime.now(),
      read: from == 'olda',
    ));
    notifyListeners();
  }

  void markRead(String memberId) {
    for (final m in threads[memberId] ?? const <Message>[]) {
      m.read = true;
    }
    notifyListeners();
  }

  List<Message> threadFor(String memberId) => threads[memberId] ?? const [];

  int _unread(List<Message> msgs) {
    var c = 0;
    for (var i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].from == 'member' && !msgs[i].read) {
        c++;
      } else {
        break;
      }
    }
    return c;
  }

  List<ThreadSummary> threadsSorted() {
    final out = <ThreadSummary>[];
    for (final m in members) {
      final msgs = threads[m.id];
      if (msgs == null || msgs.isEmpty) continue;
      out.add(ThreadSummary(
        member: m,
        msgs: msgs,
        last: msgs.last,
        unread: _unread(msgs),
      ));
    }
    out.sort((a, b) => b.last.at.compareTo(a.last.at));
    return out;
  }

  int totalUnread() =>
      threads.values.fold(0, (s, msgs) => s + _unread(msgs));

  // ── Member-side messaging (owner conversation + member↔member) ──────────

  /// Trailing unread messages *not* sent by [meId]. For the owner thread the
  /// counterpart is `'olda'`; for peer threads it is the other member's id.
  int _trailingUnread(List<Message> msgs, bool Function(Message) fromOther) {
    var c = 0;
    for (var i = msgs.length - 1; i >= 0; i--) {
      if (fromOther(msgs[i]) && !msgs[i].read) {
        c++;
      } else {
        break;
      }
    }
    return c;
  }

  /// Normalised bubble list for [meId]'s view of a conversation. [peerId] is
  /// [kOwnerId] for the owner thread, otherwise another member's id.
  List<({bool mine, String text, DateTime at})> memberThread(
      String meId, String peerId) {
    if (peerId == kOwnerId) {
      return threadFor(meId)
          .map((m) => (mine: m.from == 'member', text: m.text, at: m.at))
          .toList();
    }
    final list = peerThreads[pairKey(meId, peerId)] ?? const <Message>[];
    return list
        .map((m) => (mine: m.from == meId, text: m.text, at: m.at))
        .toList();
  }

  void memberSend(String meId, String peerId, String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    if (peerId == kOwnerId) {
      sendMessage(meId, t, from: 'member');
      return;
    }
    final k = pairKey(meId, peerId);
    peerThreads.putIfAbsent(k, () => []);
    peerThreads[k]!
        .add(Message(from: meId, text: t, at: DateTime.now(), read: true));
    notifyListeners();
  }

  void memberMarkRead(String meId, String peerId) {
    if (peerId == kOwnerId) {
      for (final m in threads[meId] ?? const <Message>[]) {
        if (m.from == 'olda') m.read = true;
      }
    } else {
      for (final m in peerThreads[pairKey(meId, peerId)] ??
          const <Message>[]) {
        if (m.from != meId) m.read = true;
      }
    }
    notifyListeners();
  }

  /// The member's inbox: the owner conversation (always present, even empty)
  /// plus every member↔member thread they take part in, newest first.
  List<MemberConvo> memberInbox(String meId) {
    final out = <MemberConvo>[];

    final owner = threads[meId] ?? const <Message>[];
    if (owner.isEmpty) {
      out.add(MemberConvo(
        peerId: kOwnerId,
        isOwner: true,
        lastText: '',
        lastAt: kNow,
        lastMine: false,
        unread: 0,
      ));
    } else {
      final last = owner.last;
      out.add(MemberConvo(
        peerId: kOwnerId,
        isOwner: true,
        lastText: last.text,
        lastAt: last.at,
        lastMine: last.from == 'member',
        unread: _trailingUnread(owner, (m) => m.from == 'olda'),
      ));
    }

    for (final e in peerThreads.entries) {
      final parts = e.key.split('|');
      if (!parts.contains(meId) || e.value.isEmpty) continue;
      final otherId = parts.first == meId ? parts.last : parts.first;
      final last = e.value.last;
      out.add(MemberConvo(
        peerId: otherId,
        isOwner: false,
        lastText: last.text,
        lastAt: last.at,
        lastMine: last.from == meId,
        unread: _trailingUnread(e.value, (m) => m.from != meId),
      ));
    }

    out.sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return out;
  }

  int memberUnreadTotal(String meId) =>
      memberInbox(meId).fold(0, (s, c) => s + c.unread);
}

final storeProvider = ChangeNotifierProvider<GymStore>((ref) => GymStore());
