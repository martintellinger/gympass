import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/membership.dart' as membership;
import '../domain/opening_hours.dart';
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

  /// Noticeboard posts (owner-authored only — members don't post). Newest
  /// first; the board screen pins separately.
  final List<BoardPost> board = [
    BoardPost(
      id: 'b1',
      type: 'pinned',
      pinned: true,
      title: 'Vítej v BýtFit Klubu',
      body: 'Tady se objeví oznámení od Oldy — výpadky, akce, události.',
      at: _ago(60 * 24 * 6),
      author: 'Olda',
    ),
    BoardPost(
      id: 'b2',
      type: 'outage',
      pinned: false,
      title: 'Sprcha č. 3 mimo provoz',
      body: 'Teče málo, řeším to. Dejte zatím přednost sprchám 1 a 2.',
      at: _ago(60 * 26),
      author: 'Olda',
    ),
    BoardPost(
      id: 'b3',
      type: 'promo',
      pinned: false,
      title: 'Nová sada kotoučů',
      body: 'Přibyly olympijské kotouče 1,25–25 kg. Užijte si je.',
      at: _ago(60 * 24 * 2),
      author: 'Olda',
    ),
  ];

  BoardPost? boardPostById(String id) {
    for (final p in board) {
      if (p.id == id) return p;
    }
    return null;
  }

  BoardPost addBoardPost({
    required String type,
    required String title,
    required String body,
    bool pinned = false,
  }) {
    final post = BoardPost(
      id: 'b${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      pinned: pinned,
      title: title.trim(),
      body: body.trim(),
      at: DateTime.now(),
      author: 'Olda',
    );
    board.insert(0, post);
    notifyListeners();
    return post;
  }

  void updateBoardPost(
    String id, {
    String? type,
    String? title,
    String? body,
    bool? pinned,
  }) {
    final i = board.indexWhere((p) => p.id == id);
    if (i == -1) return;
    final cur = board[i];
    board[i] = BoardPost(
      id: cur.id,
      type: type ?? cur.type,
      pinned: pinned ?? cur.pinned,
      title: (title ?? cur.title).trim(),
      body: (body ?? cur.body).trim(),
      at: cur.at,
      author: cur.author,
      cta: cur.cta,
    );
    notifyListeners();
  }

  void deleteBoardPost(String id) {
    board.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void setBoardPostPinned(String id, bool pinned) =>
      updateBoardPost(id, pinned: pinned);

  /// Club opening hours, indexed by `DateTime.weekday - 1` (0 = Mon …
  /// 6 = Sun). Mirrors the live `opening_hours` defaults: weekdays
  /// 06:00–22:00, weekends 08:00–20:00. Informational only (§14–§15).
  final List<DayHours> openingHours = const [
    DayHours(6 * 60, 22 * 60), // Mon
    DayHours(6 * 60, 22 * 60), // Tue
    DayHours(6 * 60, 22 * 60), // Wed
    DayHours(6 * 60, 22 * 60), // Thu
    DayHours(6 * 60, 22 * 60), // Fri
    DayHours(8 * 60, 20 * 60), // Sat
    DayHours(8 * 60, 20 * 60), // Sun
  ];

  Member? memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// Admin manually confirms a pending/overdue payment (§6 — no bank
  /// matching in MVP, the owner ticks it off by hand). Flips it to `ok`
  /// and stamps today's date; idempotent if already paid.
  void confirmPayment(String paymentId, {String type = 'Potvrzeno ručně'}) {
    final i = payments.indexWhere((p) => p.id == paymentId);
    if (i < 0 || payments[i].state == 'ok') return;
    final p = payments[i];
    payments[i] = Payment(
      id: p.id,
      memberId: p.memberId,
      date: DateTime.now(),
      amount: p.amount,
      type: type,
      tariff: p.tariff,
      state: 'ok',
    );
    notifyListeners();
  }

  /// Admin records a manual payment (§6). Lands as a confirmed (`ok`)
  /// record dated today.
  void addManualPayment({
    required String memberId,
    required int amount,
    required String tariff,
    required String type,
    required int months,
  }) {
    payments.add(Payment(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      memberId: memberId,
      date: DateTime.now(),
      amount: amount,
      type: type,
      tariff: tariff,
      state: 'ok',
    ));
    // Extend the membership so the pill / days-left reflect the payment
    // (§2–§4), mirroring the Supabase repository.
    final i = members.indexWhere((m) => m.id == memberId);
    if (i != -1) {
      final m = members[i];
      final newExpiry = membership.nextExpiration(
        now: kNow,
        currentExpiry: _parseCzDate(m.expiresAt),
        months: months,
      );
      final days = membership.daysLeft(newExpiry, kNow);
      members[i] = m.copyWith(
        expiresAt: '${newExpiry.day}. ${newExpiry.month}. ${newExpiry.year}',
        daysNum: days,
        state: days < 0
            ? 'error'
            : days <= 7
                ? 'warn'
                : 'ok',
        overdue: false,
      );
    }
    notifyListeners();
  }

  /// Parses a CZ display date (`23. 6. 2026`); null if unparseable / "—".
  static DateTime? _parseCzDate(String s) {
    final mm = RegExp(r'(\d{1,2})\.\s*(\d{1,2})\.\s*(\d{4})').firstMatch(s);
    if (mm == null) return null;
    return DateTime(int.parse(mm.group(3)!), int.parse(mm.group(2)!),
        int.parse(mm.group(1)!));
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

  /// **Owner-only** resume of a paused membership (product decision: members
  /// pause but only Olda brings them back). Clears the pause and recomputes
  /// the status pill from the (frozen) remaining days; the note lands in the
  /// member's owner thread as coming from Olda. No-op if not paused.
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
    sendMessage(id, notice, from: 'olda');
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
